-- ============================================================
-- INCIDENT RAG – PRODUCTION SETUP (FINAL)
-- ============================================================
-- Features:
-- • pgvector (3072 dims – Gemini embeddings)
-- • No ANN index (pgvector 2000-dim limit; sequential scan is fine <50k rows)
-- • JSONB flexible metadata
-- • Metadata GIN index
-- • Hybrid search (Vector + FTS)
-- • Reranker-ready (distance + similarity)
-- • Dynamic metadata discovery
-- • Auto-refresh trigger
-- • Optional analytics logging
-- ============================================================



-- ============================================================
-- 1️⃣ EXTENSIONS
-- ============================================================

create extension if not exists vector;
create extension if not exists pgcrypto;



-- ============================================================
-- 2️⃣ INCIDENTS TABLE
-- ============================================================

create table if not exists incidents (
  id uuid primary key default gen_random_uuid(),
  content text not null,
  metadata jsonb not null default '{}'::jsonb,
  embedding vector(3072) not null,
  created_at timestamptz default now()
);



-- ============================================================
-- 3️⃣ INDEXES
-- ============================================================

-- 3.1 Vector Index
-- NOTE: Supabase pgvector limits HNSW and IVFFlat to 2000 dimensions.
-- Gemini embeddings are 3072 dimensions, so no ANN index is possible.
-- Sequential scan is used instead — perfectly fine for <50k rows.
-- If pgvector is upgraded to support >2000 dims, add:
--   CREATE INDEX incidents_embedding_idx
--   ON incidents USING hnsw (embedding vector_cosine_ops);


-- 3.2 Metadata JSONB Index (Fast @> filtering)

create index if not exists incidents_metadata_idx
on incidents
using gin (metadata jsonb_path_ops);


-- 3.3 Full Text Search Index (Hybrid search support)

create index if not exists incidents_content_fts_idx
on incidents
using gin (to_tsvector('english', content));



-- ============================================================
-- 4️⃣ CORE VECTOR SEARCH (RERANKER READY)
-- ============================================================
-- Over-fetch pattern improves recall
-- Returns similarity + distance for reranker pipelines

create or replace function match_documents (
  query_embedding vector(3072),
  match_threshold float default 0.0,
  match_count int default 20,
  filter jsonb default '{}'::jsonb
)
returns table (
  id uuid,
  content text,
  metadata jsonb,
  similarity float,
  distance float
)
language sql
stable
as $$
  select *
  from (
    select
      i.id,
      i.content,
      i.metadata,
      1 - (i.embedding <=> query_embedding) as similarity,
      (i.embedding <=> query_embedding) as distance
    from incidents i
    where i.metadata @> filter
    order by i.embedding <=> query_embedding
    limit match_count * 4
  ) ranked
  where similarity >= match_threshold
  order by similarity desc
  limit match_count;
$$;



-- ============================================================
-- 5️⃣ HYBRID SEARCH (VECTOR + KEYWORD)
-- ============================================================
-- 70% vector similarity + 30% keyword ranking
-- ts_rank_cd (cover density) considers term proximity

create or replace function match_documents_hybrid (
  query_embedding vector(3072),
  query_text text,
  match_count int default 20,
  filter jsonb default '{}'::jsonb
)
returns table (
  id uuid,
  content text,
  metadata jsonb,
  final_score float
)
language sql
stable
as $$
  select
    i.id,
    i.content,
    i.metadata,
    (
      (1 - (i.embedding <=> query_embedding)) * 0.7 +
      (ts_rank_cd(
        to_tsvector('english', i.content),
        plainto_tsquery(query_text)
      )) * 0.3
    ) as final_score
  from incidents i
  where i.metadata @> filter
  order by final_score desc
  limit match_count;
$$;



-- ============================================================
-- 6️⃣ DYNAMIC METADATA VALUES TABLE
-- ============================================================

create table if not exists metadata_values (
  id bigserial primary key,
  field_name text not null,
  field_value text not null,
  value_count integer default 1,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(field_name, field_value)
);

create index if not exists metadata_field_idx
on metadata_values(field_name);

create index if not exists metadata_field_value_idx
on metadata_values(field_name, field_value);



-- ============================================================
-- 7️⃣ SMART METADATA REFRESH FUNCTION
-- ============================================================
-- Scans ALL keys inside metadata JSONB dynamically
-- Handles both simple values and arrays
-- Stores counts per value

create or replace function refresh_metadata_values()
returns void
language plpgsql
as $$
begin

  truncate table metadata_values;

  insert into metadata_values (field_name, field_value, value_count)
  select
    key as field_name,
    value_text,
    count(*) as value_count
  from incidents i
  cross join lateral jsonb_each(i.metadata) as m(key, value)
  cross join lateral (
      -- Scalars: #>> '{}' strips JSON quotes ("foo" → foo)
      select value #>> '{}' as value_text
      where jsonb_typeof(value) <> 'array'

      union all

      -- Arrays: jsonb_array_elements_text already returns unquoted
      select jsonb_array_elements_text(value)
      where jsonb_typeof(value) = 'array'
  ) v
  where value_text is not null
    and value_text <> ''
  group by key, value_text;

end;
$$;



-- ============================================================
-- 8️⃣ AUTO REFRESH TRIGGER
-- ============================================================
-- Automatically refresh metadata after inserts/updates
-- (Remove if dataset becomes very large – call manually instead)

create or replace function auto_refresh_metadata()
returns trigger
language plpgsql
as $$
begin
  perform refresh_metadata_values();
  return null;
end;
$$;

drop trigger if exists trg_refresh_metadata on incidents;

create trigger trg_refresh_metadata
after insert or update on incidents
for each statement
execute function auto_refresh_metadata();



-- ============================================================
-- 9️⃣ GROUPED METADATA VIEW (FOR n8n)
-- ============================================================

create or replace view metadata_values_grouped as
select json_agg(t) as metadata
from (
  select
    field_name,
    json_agg(
      json_build_object(
        'value', field_value,
        'count', value_count
      )
      order by field_value
    ) as values
  from metadata_values
  group by field_name
) t;



-- ============================================================
-- 🔟 OPTIONAL RERANK LOGGING
-- ============================================================

create table if not exists rerank_logs (
  id bigserial primary key,
  query_text text,
  top_k_before int,
  top_k_after int,
  created_at timestamptz default now()
);



-- ============================================================
-- 📡 POST-DEPLOYMENT & REST CALLS
-- ============================================================

-- After inserting data:
-- select refresh_metadata_values();
-- analyze incidents;

-- Vector Search:
-- POST /rest/v1/rpc/match_documents

-- Hybrid Search:
-- POST /rest/v1/rpc/match_documents_hybrid

-- Metadata Values:
-- GET /rest/v1/metadata_values_grouped?select=metadata

-- Manual Metadata Refresh:
-- POST /rest/v1/rpc/refresh_metadata_values
