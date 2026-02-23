# Implementation Plan - Incident Response RAG System (As-Built)

## Implemented Architecture

### 1. Ingestion Workflow

**Goal**: Convert `incidents.json` into clean, noise-free Markdown chunks and store in Supabase.

#### Steps:

1.  **Trigger**: Manual Trigger.
2.  **Fetch Data**: `HTTP Request` (GitHub content).
3.  **Parse & Split**: Code Node (Parses JSON array).
4.  **Prepare Data (Code Node)**:
    - **Date Formatting**: `YYYY-MM-DD` (Time stripped).
    - **Metadata Cleaning**: Null/Empty values removed to keep Supabase metadata clean.
    - **Markdown Generation**: Conditional generation of sections (Analysis, MITRE) only if data exists.
5.  **Generate Embeddings**:
    - Node: `Embeddings Google Gemini`.
    - Model: `models/gemini-embedding-001`.
6.  **Store in Supabase**:
    - Node: `Supabase Vector Store`.
    - Function: `match_documents` (with 3072 dims).

### 2. Retrieval Workflow

**Goal**: AI Agent queries the knowledge base and formats a professional Triage Note.

#### Steps:

1.  **Trigger**: Chat Trigger.
2.  **AI Agent**:
    - **System Prompt**: Strict "Triage Note" format (Root Cause, Unique Factors, Action Items, History).
    - **Tool Strategy**: "Retrieve Documents (As Tool for AI Agent)" - Agent decides when to search.
3.  **Tools**:
    - **Vector Store Tool**: Supabase (via `match_documents`).

## Verification Results

### ✅ Automated/Manual Tests

- [x] **Ingestion**: `incidents` table populated with 3072-dim vectors.
- [x] **Retrieval Logic**:
  - **Easy Case (DB Crash)**: Correctly identified `INC-2026-0209-002` (Logrotate issue).
  - **Medium Case (Auth)**: Correctly matched `INC-2026-0209-001` (Tor IP/Credential Stuffing).
  - **Hard Case (Performance)**: Correctly identified `INC-2026-0209-004` (Missing Index) from a generic "Latency Spike" alert.
- [x] **Hallucination Check**: Agent correctly distinguishes between the _new_ alert entities (e.g., `checkout-service`) and the _retrieved_ entities (`payment-api`).
