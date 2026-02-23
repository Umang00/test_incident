# Incident & MITRE RAG System

## User Review Required

> [!IMPORTANT]
> **MITRE Data Source Decision**: You mentioned scraping the **MITRE Enterprise Techniques webpage**.
>
> - **Recommendation**: Scraping the _list_ page significantly limits quality (it's just a menu).
> - **Better Approach**: I will write a script to fetch the official **MITRE STIX/JSON data** (the source of truth). This gives us rich descriptions, detection methods, and mitigation steps for _every_ technique, formatted perfectly for embedding.
> - _Decision_: I will proceed with the "Rich Data" approach unless you strictly prefer scraping the list page.

> [!IMPORTANT]
> **Model Choice**: Based on previous analysis, I will set up the system to use **Voyage AI (`voyage-code-2`)** as the primary embedding model for its superior handling of technical/code data.

## Proposed Changes

### 1. Ingestion Script (`ingest_knowledge.py`)

I will create a NEW, unified ingestion script to handle both data sources.

#### A. Embedding [incidents.json](file:///c:/Users/umang/Incident%20Management/incident-response/incidents.json)

- **Strategy**: "Atomic Incident Chunking" (JSON -> Markdown).
- **Why**: Raw JSON is noisy. We will convert each incident into a clean, human-readable Markdown format before embedding.
- **Format**:

  ```markdown
  # Incident: [Title] (ID)

  **Type**: [Type] | **Severity**: [Severity]

  ## Description

  [Description text]

  ## Root Cause

  [RCA text]

  ## Resolution

  [Resolution steps]
  ```

- **Hybrid Search**: We will generate _sparse vectors_ (BM25/Splade) alongside dense embeddings to support keyword searches (e.g., "Error 500").

#### B. Embedding MITRE ATT&CK

- **Strategy**: Fetch official MITRE Enterprise STIX data.
- **Processing**:
  1.  Download latest Enterprise ATT&CK JSON.
  2.  Extract every **Technique**.
  3.  Convert to Markdown:

      ```markdown
      # Technique: [Name] (ID)

      ## Description

      [Description]

      ## Detection

      [Detection logic]
      ```

  4.  Embed these as reference documents.

### C. Data Normalization Strategy

**Recommendation**: Use [incidents_cleaned.json](file:///c:/Users/umang/Incident%20Management/incident-response/incidents_cleaned.json) directly.

- **Why**: The user has already standardized all fields with `null` for missing values. This ensures:
  - Consistent schema across all incidents (no missing key errors).
  - Easier form generation for incident managers.
  - Simpler ingestion code (no defensive null checks).
- **Future Automation**: For n8n integration, we can add a "Normalize JSON" node that:
  - Takes raw incident data from a webhook/form.
  - Applies schema validation.
  - Fills missing fields with `null`.
  - Outputs standardized JSON for embedding.
- **Code-Level Alternative**: If preferred, we can add a `normalize_incident()` function in Python that does this transformation, but since the cleaned file already exists, we'll use it directly for now.

### 2. Metadata Strategy

A robust RAG system lives and dies by its **filtering capabilities**.
We will extract the following metadata to allow queries like _"Find high severity database incidents from last year"_.

### A. Incidents Metadata

| Field                  | Source JSON Key              | Purpose                                                  | Type          |
| :--------------------- | :--------------------------- | :------------------------------------------------------- | :------------ |
| `incident_id`          | `incident_id`                | Unique ID / Reference.                                   | string        |
| `date`                 | `@timestamp`                 | Filtering by time (e.g., "last 3 months").               | datetime      |
| `severity`             | `severity`                   | Criticality filter (e.g., "Show me only HIGH/CRITICAL"). | categorical   |
| `status`               | `status`                     | Filter by state (open vs resolved).                      | categorical   |
| `category`             | `category`                   | High-level grouping (security vs engineering).           | categorical   |
| `type`                 | `type`                       | Specific incident type (ransomware, outage, phishing).   | categorical   |
| `affected_systems`     | `affected_systems`           | Filter by component (e.g., "database", "api").           | array[string] |
| `tags`                 | `tags`                       | Keyword filtering (e.g., "ransomware", "tor").           | array[string] |
| `detection_method`     | `detection_method`           | How detected (EDR, SIEM, DLP).                           | categorical   |
| `mitre_tactic_ids`     | `mitre_tactic_ids`           | Array of tactic IDs (e.g., ["TA0006", "TA0001"]).        | array[string] |
| `mitre_technique_ids`  | `mitre_technique_ids`        | Array of technique IDs (e.g., ["T1110.003"]).            | array[string] |
| `mitre_prevention_ids` | `mitre_prevention_ids`       | Array of prevention IDs (e.g., ["M1032"]).               | array[string] |
| `affected_users_count` | `affected_users_count`       | Impact scale (e.g., > 1000 users).                       | integer       |
| `estimated_cost`       | `estimated_cost`             | Financial impact (e.g., > $10k).                         | integer       |
| `sla_met`              | `sla_met`                    | Compliance status.                                       | boolean       |
| `year`                 | Calculated from `@timestamp` | Year (e.g., 2026).                                       | integer       |
| `quarter`              | Calculated from `@timestamp` | Quarter (e.g., "Q1").                                    | string        |
| `mttr`                 | `mttr`                       | Mean Time To Resolution (minutes).                       | integer       |
| `mtta`                 | `mtta`                       | Mean Time To Acknowledge (minutes).                      | integer       |

> [!NOTE]
> **Data Source**: We will use [incidents.json](file:///c:/Users/umang/Incident%20Management/incident-response/incidents.json) as the source of truth. The user has standardized all fields with `null` for missing values, ensuring consistent schema across all incidents.

### B. MITRE ATT&CK Metadata

| Field             | Source STIX                          | Purpose                                                |
| :---------------- | :----------------------------------- | :----------------------------------------------------- |
| `technique_id`    | `external_references[0].external_id` | Crucial linking (e.g., "T1059").                       |
| `tactic`          | `kill_chain_phases`                  | Filter by stage (e.g., "Initial Access" vs "Impact").  |
| `platform`        | `x_mitre_platforms`                  | Hard filter (e.g., "Show me Windows-only techniques"). |
| `is_subtechnique` | `x_mitre_is_subtechnique`            | Boolean flag.                                          |
| `url`             | `external_references[0].url`         | Link to official MITRE page.                           |

## 3. Retrieval Architecture

- **Embedding Model**: `voyage-code-2` (Chosen for technical content).
- **Search**: **Hybrid Search** (Vector + Keyword/Sparse).

* **Reranking**: **Yes, highly recommended.**
  - _Why_: When you search "slow database", you might get 50 incidents. A reranker (like Cohere Rerank or BGE) sorts them to find the _exact_ match.
  - _Implementation_: I will add a placeholder for Reranking (Cross-Encoder) in the search logic.

## Verification Plan

### Automated Tests

- **`test_ingestion.py`**:
  - Run the ingestion script on a small subset of incidents (5 items).
  - Verify distinct chunks are created in Qdrant.
  - Verify searching "brute force" returns the Brute Force incident.

### Manual Verification

1.  Run `python ingest_knowledge.py`.
2.  Run a CLI query tool:
    - Query: "How do I fix a ransomware attack?"
    - Expectation: Returns MITRE "Data Encrypted for Impact" AND the internal "Ransomware" incident.
