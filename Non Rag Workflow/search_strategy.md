# Search Strategy for Incident Management

> **Last Updated**: February 2026  
> **Purpose**: Defines _what_ to search, _when_ to search, _which tool_ to use, and _how to configure_ it in n8n.

---

## The 4 Types of Search in an Incident System

Don't think of search as just "Google". There are 4 fundamentally different layers:

| #   | Type                        | Purpose                                           | Examples                                |
| --- | --------------------------- | ------------------------------------------------- | --------------------------------------- |
| 1   | **Internal RAG**            | Have we seen this before?                         | Supabase Vector Store, past incidents   |
| 2   | **Structured Threat Intel** | Known CVEs, IOCs, malware hashes                  | NVD, CISA KEV, VirusTotal, MITRE ATT&CK |
| 3   | **Vendor Docs / Community** | Version-specific bugs, error codes, workarounds   | GitHub Issues, Stack Overflow, AWS Docs |
| 4   | **General Web Search**      | Emerging threats, zero-days, no structured source | Google Grounding, SerpAPI, Tavily       |

> **Critical Rule**: Search should not always be enabled. Each layer triggers only when the previous layer fails to produce a confident answer.

---

## Recommended Architecture — Layered Search

```
Incident Alert
      │
      ▼
┌─────────────────────────────────────┐
│  Layer 1: Internal RAG (Always Run) │  ← Supabase Vector Store + Metadata Filter
│  "Have we seen this before?"        │  ← Similarity threshold: 0.4
└────────────────┬────────────────────┘
                 │ No match (< 0.4 similarity)
                 ▼
┌─────────────────────────────────────┐
│  Layer 2: Structured Threat Intel   │  ← NVD API, CISA KEV, VirusTotal
│  (Triggered by CVE/IP/hash/version) │  ← Direct API — not web search
└────────────────┬────────────────────┘
                 │ Still insufficient
                 ▼
┌─────────────────────────────────────┐
│  Layer 3: Web Search                │  ← Choose tool based on need (see below)
│  (Only when previous layers fail)   │  ← Max 5 queries, cache results
└────────────────┬────────────────────┘
                 │
                 ▼
        Rerank → Generate Triage Note
```

---

## Layer 2 — Structured Threat Intel APIs

For security incidents, these are **far better than web search** for CVE/IOC data.

### When to Call Which API

| Trigger Pattern in Alert          | API to Call                                    | Why                                           |
| --------------------------------- | ---------------------------------------------- | --------------------------------------------- |
| Contains `CVE-YYYY-NNNNN`         | **NVD API**                                    | Official CVSS score, affected products, patch |
| Contains IP address               | **AbuseIPDB** or **VirusTotal**                | Reputation, abuse reports, malware            |
| Contains file hash (MD5/SHA)      | **VirusTotal**                                 | Malware classification, VirusTotal score      |
| Security category = unknown       | **AlienVault OTX**                             | Threat intel pulses, IoCs                     |
| Confirmed CVE, check if exploited | **CISA KEV** (Known Exploited Vulnerabilities) | Is this actively exploited in the wild?       |
| Attacker technique pattern        | **MITRE ATT&CK API**                           | Technique ID, mitigations                     |

### API Quick Reference

| API                | Endpoint                                                                              | Free Tier           | Auth             |
| ------------------ | ------------------------------------------------------------------------------------- | ------------------- | ---------------- |
| **NVD (NIST)**     | `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-...`                      | Free (rate-limited) | Optional API key |
| **CISA KEV**       | `https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json` | Free, no auth       | None             |
| **AbuseIPDB**      | `https://api.abuseipdb.com/api/v2/check?ipAddress=...`                                | 1K/day free         | API key          |
| **VirusTotal**     | `https://www.virustotal.com/api/v3/files/{hash}`                                      | 500 req/day free    | API key          |
| **AlienVault OTX** | `https://otx.alienvault.com/api/v1/indicators/...`                                    | Free                | API key          |
| **ExploitDB**      | `https://www.exploit-db.com/search?cve=...`                                           | Free (scraping)     | None             |
| **MITRE ATT&CK**   | `https://attack.mitre.org/api/` or STIX bundle                                        | Free                | None             |

> **n8n Implementation**: Use HTTP Request nodes for all of these. No special nodes needed.

---

## Layer 3 — Web Search Tool Comparison

Only reach for web search when structured threat intel APIs don't have the answer.

### When to Use Which Web Search Tool

| Scenario                               | Best Tool                         | Why                                                |
| -------------------------------------- | --------------------------------- | -------------------------------------------------- |
| Quick CVE check                        | **Google Grounding**              | Fast, zero setup, Gemini integrates natively       |
| Vendor advisory for known product      | **Tavily** (`includeDomains`)     | Pin to vendor security pages                       |
| Specific error code from logs          | **SerpAPI** with `site:` operator | e.g. `site:github.com "pg_replication_slot" error` |
| Version-specific bugs on GitHub        | **SerpAPI**                       | Direct site targeting                              |
| Emerging threat / novel attack pattern | **Exa AI** (neural)               | Semantic understanding vs. keyword matching        |
| Read full content of a known URL       | **Jina AI**                       | Extracts clean text from any advisory/KB page      |
| CVE deep research with synthesis       | **Tavily** (Research operation)   | Multi-search + structured report                   |

---

### 3a. Google Gemini Grounding (Built-in)

**Node**: `Message a Model in Google Gemini` → `builtInTools: googleSearch: true`

```json
{
  "modelId": "models/gemini-2.0-flash",
  "builtInTools": { "googleSearch": true },
  "options": { "temperature": 0.3 }
}
```

**Dynamic Retrieval Threshold** (Gemini 1.5 Flash only — not 2.0+):

```json
{
  "dynamicRetrievalConfig": {
    "mode": "MODE_DYNAMIC",
    "dynamicThreshold": 0.3
  }
}
```

- `0.0` = always search | `0.3` = default | `1.0` = almost never search
- Response includes `groundingMetadata.webSearchQueries` — use this to log what Gemini actually searched

**Best for**: Quick CVE checks, patch verification, simple vendor advisory lookup  
**Not for**: Site-specific searches, GitHub issue digging, results you need to parse structurally

---

### 3b. SerpAPI (Built-in LangChain Tool)

**Node**: `SerpApi (Google Search)` — connect to AI Agent as a tool

```json
{
  "options": {
    "country": "us",
    "device": "desktop",
    "googleDomain": "google.com",
    "language": "en",
    "explicitArray": false
  }
}
```

**Power feature — Agent can construct targeted queries:**

```
site:github.com "PostgreSQL 15.3 replication lag"
site:docs.aws.amazon.com S3 503 SlowDown error
site:stackoverflow.com nginx ssl ERR_CONNECTION_REFUSED
site:security.microsoft.com advisory February 2026
```

**Best for**: Technical deep-dives, GitHub issues, version-specific bugs  
**Pricing**: ~$50/mo for 5K searches — use selectively

---

### 3c. Tavily (Community Node — Recommended Primary)

**Install**: Settings → Community Nodes → `n8n-nodes-tavily`

```json
{
  "query": "{{ query }}",
  "topic": "general",
  "searchDepth": "advanced",
  "maxResults": 5,
  "timeRange": "year",
  "includeAnswer": true,
  "includeDomains": [
    "nvd.nist.gov",
    "cve.mitre.org",
    "cisa.gov",
    "exploit-db.com"
  ],
  "excludeDomains": ["pinterest.com", "quora.com"],
  "chunksPerSource": 3
}
```

**Key differentiator**: `includeDomains` + `includeAnswer` — always hits security-authoritative sources and pre-synthesizes an answer for the LLM.

**Operations available:**
| Operation | Incident Use Case |
|---|---|
| `Search` | CVE lookups, advisory searches |
| `Extract` | Pull full content from a known advisory URL |
| `Research` | Deep-dive report on a threat actor or APT |

**Pricing**: Free 1K/mo → $20/mo for 10K

---

### 3d. Exa AI (Community Node — Best Semantic Search)

**Install**: Settings → Community Nodes → `n8n-nodes-exa` (n8n-verified)

```json
{
  "query": "brute force SSH attack detection evasion techniques 2025",
  "searchType": "neural",
  "autoprompt": true,
  "numResults": 10,
  "filters": {
    "startPublishedDate": "2025-01-01",
    "category": "research paper"
  },
  "contents": {
    "highlights": true,
    "summary": true,
    "liveCrawl": "always"
  }
}
```

**Key differentiator**: `neural` search understands concepts, not just keywords. `autoprompt` rewrites your query to get better results. Date filters keep results fresh.

**Best for**: Finding similar incidents, understanding novel attack patterns, threat actor research  
**Pricing**: Free 1K/mo → $25/mo

---

### 3e. Jina AI (Built-in — URL Extractor)

**Node**: `Jina AI Tool` — already built into n8n, no installation needed

**Primary Role**: Not a search engine — it **reads and cleans content from URLs** for LLM consumption.

**Pattern**: Use search (Tavily/SerpAPI) to find the URL → use Jina to read the full page

```
SerpAPI → "Advisory URL: https://vendor.com/advisory/SA-2025-001"
Jina AI Reader → Extracts clean full text from that URL → LLM synthesizes
```

**Also has Search mode:**

```json
{
  "operation": "search",
  "query": "CVE-2025-1234 CVSS score mitigation",
  "options": { "returnFormat": "markdown" }
}
```

**Pricing**: Free 1M tokens/month (very generous)

---

## Search Trigger Rules (Conditional Logic for n8n)

Define these in your workflow with an IF node **before** calling any external search:

```javascript
// Triggers for Layer 2 (Threat Intel APIs) — check FIRST
const alert = $json.incidentDescription;

const triggers = {
  cvePattern: /CVE-\d{4}-\d{4,}/i.test(alert),
  ipAddress: /\b(?:\d{1,3}\.){3}\d{1,3}\b/.test(alert),
  fileHash: /\b[a-f0-9]{32,64}\b/i.test(alert),
  versionNumber: /v?\d+\.\d+\.\d+/.test(alert),
  quotedError: /"[^"]{10,}"/.test(alert),
  noInternalMatch: $("RAG Node").item.json.similarity < 0.4,
  securityAndUnknown: $json.category === "security" && !$json.knownType,
};

// Trigger web search only when needed
const needsWebSearch =
  triggers.quotedError || (triggers.noInternalMatch && !triggers.cvePattern);
```

---

## Caching Strategy

Cache responses to avoid redundant API calls and cost scaling:

| Cache Target           | TTL      | Storage                              |
| ---------------------- | -------- | ------------------------------------ |
| CVE lookups (NVD/CISA) | 24 hours | n8n workflow static data or Supabase |
| Vendor advisories      | 12 hours | Supabase table                       |
| Common error codes     | 7 days   | Supabase table                       |
| Web search results     | 1 hour   | In-memory or Supabase                |

> **Tip**: Key your cache by `{query_hash}_{source}`. Before calling any external API, do a cache lookup first.

---

## Decision Matrix by Project Maturity

### 🟢 Current / Short Term (LLM Basic Search Workflow)

```
✅ Internal RAG (Supabase)          ← already built
✅ Google Grounding (built-in)      ← already in use
✅ Add: NVD API call for CVEs       ← replaces web search for known CVEs
```

### 🟡 Mid-Term (Production Level)

```
✅ All of the above +
✅ Tavily (replace SerpAPI as primary web search)
✅ Jina AI Tool (for URL content extraction)
✅ CISA KEV + AbuseIPDB for security incidents
✅ Similarity threshold gate (< 0.4 → escalate)
✅ Search result caching in Supabase
```

### 🔴 Long-Term (Enterprise SOC Tool)

```
✅ All of the above +
✅ Exa AI (neural/semantic for complex incidents)
✅ SerpAPI for GitHub/vendor KB targeted search
✅ Hybrid search (keyword + vector in Supabase)
✅ Multi-source confidence scoring
✅ Source trust ranking (NVD > blog > forum)
✅ AlienVault OTX + VirusTotal integration
```

---

## Summary — Final Recommendation

| Priority  | Action                               | Reason                                          |
| --------- | ------------------------------------ | ----------------------------------------------- |
| **Now**   | Keep Google Grounding                | Zero cost, zero setup                           |
| **Now**   | Add NVD API direct call for CVEs     | Better than web search for known CVEs           |
| **Soon**  | Install Tavily, set `includeDomains` | Best AI-native search, free tier sufficient     |
| **Soon**  | Install Jina AI Tool                 | Reads full advisory pages for LLM               |
| **Later** | Install Exa AI                       | Neural search for complex research              |
| **Later** | Add CISA KEV + AbuseIPDB             | Free structured threat intel                    |
| **Keep**  | SerpAPI (as fallback)                | For site-specific GitHub/vendor queries         |
| **Avoid** | Defaulting to web search             | Increases cost, latency, and hallucination risk |

> **Core Principle**: Precision over breadth. Internal RAG first, structured APIs second, web search last — and only when conditionally triggered.
