-- 1. Enable pgvector extension
create extension if not exists vector;

-- 2. Create incidents table with 3072 dimensions
-- LangChain defaults 'models/gemini-embedding-001' to 3072 dims.
-- CAUTION: Drops existing table to reset dimensions
drop table if exists incidents; 
create table incidents (
  id uuid primary key default gen_random_uuid(),
  content text,
  metadata jsonb,
  embedding vector(3072)
);

-- 3. Create match_documents function for 3072 dimensions
-- Updated with DEFAULT values to prevent PGRST202 errors
create or replace function match_documents (
  query_embedding vector(3072),
  match_threshold float default 0.0,
  match_count int default 10,
  filter jsonb default '{}'
)
returns table (
  id uuid,
  content text,
  metadata jsonb,
  similarity float
)
language plpgsql
stable
as $$
begin
  return query
  select
    incidents.id,
    incidents.content,
    incidents.metadata,
    1 - (incidents.embedding <=> query_embedding) as similarity
  from incidents
  where 1 - (incidents.embedding <=> query_embedding) > match_threshold
  and incidents.metadata @> filter
  order by incidents.embedding <=> query_embedding
  limit match_count;
end;
$$;
