-- =====================================================
-- Metadata Values Table for Incident Management System
-- =====================================================
-- This table stores all unique metadata values to enable
-- fast lookups for metadata validation in the RAG pipeline
-- =====================================================

-- 1. Create the metadata_values table
CREATE TABLE IF NOT EXISTS metadata_values (
  id SERIAL PRIMARY KEY,
  field_name TEXT NOT NULL,
  field_value TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(field_name, field_value)
);

-- Create index for fast lookups
CREATE INDEX IF NOT EXISTS idx_metadata_field_name ON metadata_values(field_name);

-- =====================================================
-- 2. Function to refresh metadata values
-- =====================================================
-- This function scans the incidents table and populates
-- metadata_values with all unique values for each field

CREATE OR REPLACE FUNCTION refresh_metadata_values()
RETURNS void AS $$
BEGIN
  -- Clear existing data
  TRUNCATE TABLE metadata_values;
  
  -- Insert unique severity values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'severity', metadata->>'severity'
  FROM incidents
  WHERE metadata->>'severity' IS NOT NULL;
  
  -- Insert unique status values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'status', metadata->>'status'
  FROM incidents
  WHERE metadata->>'status' IS NOT NULL;
  
  -- Insert unique category values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'category', metadata->>'category'
  FROM incidents
  WHERE metadata->>'category' IS NOT NULL;
  
  -- Insert unique type values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'type', metadata->>'type'
  FROM incidents
  WHERE metadata->>'type' IS NOT NULL;
  
  -- Insert unique detection_method values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'detection_method', metadata->>'detection_method'
  FROM incidents
  WHERE metadata->>'detection_method' IS NOT NULL;
  
  -- Insert unique affected_systems (array elements)
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'affected_systems', jsonb_array_elements_text(metadata->'affected_systems')
  FROM incidents
  WHERE metadata->'affected_systems' IS NOT NULL
    AND jsonb_typeof(metadata->'affected_systems') = 'array';
  
  -- Insert unique tags (array elements)
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'tags', jsonb_array_elements_text(metadata->'tags')
  FROM incidents
  WHERE metadata->'tags' IS NOT NULL
    AND jsonb_typeof(metadata->'tags') = 'array';
  
  -- Insert unique mitre_tactic_ids (array elements)
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'mitre_tactic_ids', jsonb_array_elements_text(metadata->'mitre_tactic_ids')
  FROM incidents
  WHERE metadata->'mitre_tactic_ids' IS NOT NULL
    AND jsonb_typeof(metadata->'mitre_tactic_ids') = 'array';
  
  -- Insert unique mitre_technique_ids (array elements)
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'mitre_technique_ids', jsonb_array_elements_text(metadata->'mitre_technique_ids')
  FROM incidents
  WHERE metadata->'mitre_technique_ids' IS NOT NULL
    AND jsonb_typeof(metadata->'mitre_technique_ids') = 'array';
  
  -- Insert unique mitre_prevention_ids (array elements)
  -- Updated to match 'mitre_prevention_ids' key from data spec
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'mitre_prevention_ids', jsonb_array_elements_text(metadata->'mitre_prevention_ids')
  FROM incidents
  WHERE metadata->'mitre_prevention_ids' IS NOT NULL
    AND jsonb_typeof(metadata->'mitre_prevention_ids') = 'array';

  -- Insert unique affected_users_count values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'affected_users_count', metadata->>'affected_users_count'
  FROM incidents
  WHERE metadata->>'affected_users_count' IS NOT NULL;

  -- Insert unique estimated_cost values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'estimated_cost', metadata->>'estimated_cost'
  FROM incidents
  WHERE metadata->>'estimated_cost' IS NOT NULL;

  -- Insert unique sla_met values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'sla_met', metadata->>'sla_met'
  FROM incidents
  WHERE metadata->>'sla_met' IS NOT NULL;

  -- Insert unique mttr values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'mttr', metadata->>'mttr'
  FROM incidents
  WHERE metadata->>'mttr' IS NOT NULL;

  -- Insert unique mtta values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'mtta', metadata->>'mtta'
  FROM incidents
  WHERE metadata->>'mtta' IS NOT NULL;
  
  -- Insert unique year values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'year', metadata->>'year'
  FROM incidents
  WHERE metadata->>'year' IS NOT NULL;

  -- Insert unique quarter values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'quarter', metadata->>'quarter'
  FROM incidents
  WHERE metadata->>'quarter' IS NOT NULL;

  -- Insert unique date values
  INSERT INTO metadata_values (field_name, field_value)
  SELECT DISTINCT 'date', metadata->>'date'
  FROM incidents
  WHERE metadata->>'date' IS NOT NULL;
  
  -- Update timestamp
  UPDATE metadata_values SET updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. Initial Population
-- =====================================================
-- Run the function to populate the table for the first time
SELECT refresh_metadata_values();

-- =====================================================
-- 4. Verify the data
-- =====================================================
-- Check what was inserted
SELECT field_name, COUNT(*) as count, 
       string_agg(field_value, ', ' ORDER BY field_value) as values
FROM metadata_values
GROUP BY field_name
ORDER BY field_name;

-- =====================================================
-- 5. Query for n8n HTTP Node
-- =====================================================
-- The HTTP node will fetch all metadata values using:
-- GET https://your-project.supabase.co/rest/v1/metadata_values?select=field_name,field_value

-- Or get grouped by field_name (requires custom view):
CREATE OR REPLACE VIEW metadata_values_grouped AS
SELECT json_agg(t) AS metadata
FROM (
  SELECT
    field_name,
    json_agg(DISTINCT field_value) AS values
  FROM metadata_values
  GROUP BY field_name
) t;
