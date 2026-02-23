-- ============================================================
-- INCIDENT RAG METADATA SYSTEM v2 (PRODUCTION READY)
-- ============================================================
-- Features:
-- 1. Fully dynamic JSONB key scanning
-- 2. Auto-detect new metadata fields
-- 3. Store value counts
-- 4. Fast indexed lookups
-- 5. Auto refresh via trigger
-- 6. Single JSON grouped output
-- ============================================================



-- ============================================================
-- 1. SAFE RESET
-- ============================================================

drop trigger if exists trg_refresh_metadata on incidents;
drop function if exists auto_refresh_metadata cascade;
drop function if exists refresh_metadata_values cascade;
drop view if exists metadata_values_grouped cascade;
drop table if exists metadata_values cascade;



-- ============================================================
-- 2. METADATA VALUES TABLE
-- ============================================================

create table metadata_values (
  id bigserial primary key,
  field_name text not null,
  field_value text not null,
  value_count integer default 1,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(field_name, field_value)
);

create index metadata_field_idx
on metadata_values(field_name);

create index metadata_field_value_idx
on metadata_values(field_name, field_value);



-- ============================================================
-- 3. FULL DYNAMIC REFRESH FUNCTION
-- ============================================================
-- Scans ALL keys inside metadata JSONB
-- Handles both:
--   - simple values
--   - arrays
-- Stores counts
-- ============================================================

create or replace function refresh_metadata_values()
returns void
language plpgsql
as $$
begin

  truncate table metadata_values;

  insert into metadata_values (field_name, field_value, value_count)
  select
    key as field_name,
    value_text as field_value,
    count(*) as value_count
  from (
    -- Expand JSON object into key/value pairs
    select
      key,
      case
        when jsonb_typeof(value) = 'array'
          then jsonb_array_elements_text(value)
        else value::text
      end as value_text
    from incidents,
         jsonb_each(metadata)
  ) expanded
  where value_text is not null
    and value_text not in ('null', '""')
  group by key, value_text;

  update metadata_values
  set updated_at = now();

end;
$$;



-- ============================================================
-- 4. AUTO REFRESH TRIGGER
-- ============================================================
-- Automatically refresh after inserts
-- (Can be removed if dataset becomes very large)
-- ============================================================

create or replace function auto_refresh_metadata()
returns trigger
language plpgsql
as $$
begin
  perform refresh_metadata_values();
  return null;
end;
$$;

create trigger trg_refresh_metadata
after insert or update on incidents
for each statement
execute function auto_refresh_metadata();



-- ============================================================
-- 5. GROUPED VIEW (SINGLE JSON OUTPUT)
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
-- 6. INITIAL BUILD
-- ============================================================

select refresh_metadata_values();



-- ============================================================
-- 7. SUPABASE REST QUERY
-- ============================================================

-- GET:
-- /rest/v1/metadata_values_grouped?select=metadata
--
-- Returns:
-- [
--   {
--     "metadata": [
--        {
--          "field_name": "severity",
--          "values": [
--              { "value": "critical", "count": 12 },
--              { "value": "high", "count": 34 }
--          ]
--        },
--        ...
--     ]
--   }
-- ]
--
