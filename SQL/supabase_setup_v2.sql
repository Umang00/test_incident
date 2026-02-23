-- ============================================================
-- INCIDENT RAG SYSTEM - PRODUCTION SCHEMA (v1)
-- ============================================================
-- Supports:
-- - Gemini 3072-dim embeddings
-- - Metadata filtering (JSONB)
-- - Vector similarity search (cosine)
-- - Fast ANN search via IVFFlat
-- - Fast metadata filtering via GIN index
-- - Threshold support
-- ============================================================


-- ============================================================
-- 1. EXTENSIONS
-- ============================================================

create extension if not exists vector;
create extension if not exists pgcrypto;



-- ============================================================
-- 2. CLEAN RESET (SAFE FOR REDEPLOY)
-- ============================================================

drop function if exists match_documents cascade;
drop table if exists incidents cascade;



-- ============================================================
-- 3. INCIDENTS TABLE
-- ============================================================

create table incidents (
  id uuid primary key default gen_random_uuid(),

  -- Chunked markdown content for embeddings
  content text not null,

  -- Structured metadata for filtering
  metadata jsonb not null default '{}'::jsonb,

  -- Gemini embedding (3072 dimensions)
  embedding vector(3072) not null,

  created_at timestamptz default now()
);



-- ============================================================
-- 4. INDEXES
-- ============================================================

-- 4.1 Vector Index (ANN Search)
-- Adjust lists depending on dataset size:
-- <50k rows → lists=50
-- 50k-1M → lists=100-200
-- >1M → consider HNSW

create index incidents_embedding_idx
on incidents
using ivfflat (embedding vector_cosine_ops)
with (lists = 100);


-- 4.2 Metadata GIN Index (Fast JSON filtering)

create index incidents_metadata_idx
on incidents
using gin (metadata jsonb_path_ops);



-- ============================================================
-- 5. MATCH FUNCTION (OPTIMIZED)
-- ============================================================

create or replace function match_documents (
  query_embedding vector(3072),
  match_threshold float default 0.0,
  match_count int default 10,
  filter jsonb default '{}'::jsonb
)
returns table (
  id uuid,
  content text,
  metadata jsonb,
  similarity float
)
language sql
stable
as $$
  select *
  from (
    select
      id,
      content,
      metadata,
      1 - (embedding <=> query_embedding) as similarity
    from incidents
    where metadata @> filter
    order by embedding <=> query_embedding
    limit match_count * 3
  ) ranked
  where similarity >= match_threshold
  order by similarity desc
  limit match_count;
$$;



-- ============================================================
-- 6. OPTIONAL: ANALYZE FOR PERFORMANCE
-- ============================================================

analyze incidents;
