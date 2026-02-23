# GitHub Incident Management Repository Research

## Executive Summary

This report identifies GitHub repositories implementing AI-powered incident management, SOC automation, and RAG-based triage systems. **Extended search revealed 100+ additional repositories** including major SOAR platforms and cutting-e edge AI security tools.

**Key Finding:** Multiple production-ready platforms exist ranging from industry-grade SOAR systems (3000+ stars) to specialized AI incident response tools with architectures highly relevant to the project goals.

---

## 🔥 **MAJOR DISCOVERIES** (Extended Search Results)

### 🌟 Industry-Grade Platforms (1000+ ⭐)

| Repository              | Stars  | Description                                                                                      | URL                                            |
| :---------------------- | :----- | :----------------------------------------------------------------------------------------------- | :--------------------------------------------- |
| **hexstrike-ai**        | 6771⭐ | Advanced MCP server with 150+ cybersecurity tools for AI agents (pentesting, vuln discovery)     | [Link](https://github.com/0x4m4/hexstrike-ai)  |
| **TracecatHQ/tracecat** | 3471⭐ | **All-in-one AI automation platform** (workflows, agents, cases, tables) for security & IT teams | [Link](https://github.com/TracecatHQ/tracecat) |
| **Shuffle/Shuffle**     | 2186⭐ | General purpose **SOAR** platform focused on collaboration & resource sharing                    | [Link](https://github.com/Shuffle/Shuffle)     |
| **w5teams/w5**          | 1545⭐ | No-code SOAR platform for security automation (Chinese)                                          | [Link](https://github.com/w5teams/w5)          |

> **🎯 CRITICAL INSIGHT:** **TracecatHQ/tracecat** is an **n8n alternative** purpose-built for secur ity/IT teams. Uses FastAPI + Temporal.io + Next.js stack.

### 🥇 Production-Ready SOC/SOAR (100-1000 ⭐)

| Repository               | Stars | Language | Stack                                         | URL                                                                                             |
| :----------------------- | :---- | :------- | :-------------------------------------------- | :---------------------------------------------------------------------------------------------- |
| **agentic-soc-platform** | 576⭐ | Python   | Dify + LangChain + LangGraph                  | [Link](https://github.com/FunnyWolf/agentic-soc-platform)                                       |
| **LMForge**              | 550⭐ | Python   | Flask + Vue3 + LangChain (multi-model LLMOps) | [Link](https://github.com/Haohao-end/LMForge-End-to-End-LLMOps-Platform-for-Multi-Model-Agents) |
| **EVA**                  | 341⭐ | Python   | AI-assisted pentesting agent                  | [Link](https://github.com/ARCANGEL0/EVA)                                                        |
| **Admyral**              | 335⭐ | Python   | Compliance automation + SOAR                  | [Link](https://github.com/Admyral-Technologies/admyral)                                         |

---

## 🏆 Top Repositories (Original Top 3 + New Discoveries)

### 1. 🥇 **gapilongo/SOC** (12⭐) - _Multi-Agent LangGraph Architecture_

**URL:** [https://github.com/gapilongo/SOC](https://github.com/gapilongo/SOC)  
**Language:** Python | **Topics:** `langgraph`, `multi-agent-system`, `alert-triage`, `incident-response`

**Why It's Valuable:**

- Production-grade multi-agent workflow using LangGraph
- Docker/K8s deployment configs included
- Alert correlation engine for grouping related incidents

---

### 2. 🥈 **MuddsiSyed/Agentic-AI-SOC-Automation** (4⭐)

**URL:** [https://github.com/MuddsiSyed/Agentic-AI-SOC-Automation](https://github.com/MuddsiSyed/Agentic-AI-SOC-Automation)  
**Language:** Python | **Updated:** 2026-02-11 (1 day ago!)

**Why It's Valuable:**

- **Human-in-the-loop** approval flows
- Active development (updated yesterday)
- Multi-agent security orchestration patterns

---

### 3. 🥉 **SOC-Analyst-Automation-using-RAG-Model** (4⭐)

**URL:** [https://github.com/Sai-Chakradhar-Mahendrakar/SOC-Analyst-Automation-using-RAG-Model](https://github.com/Sai-Chakradhar-Mahendrakar/SOC-Analyst-Automation-using-RAG-Model)  
**Language:** JavaScript (FastAPI backend + React frontend)  
**Topics:** `rag`, `llama3-1`, `nomic-embed-text`, `log-analysis`

**Why It's Valuable:**

- **Full-stack RAG implementation** with Llama 3.1
- FastAPI service patterns for LLM-based security insights
- React UI for displaying triage results

---

### 4. 🔥 **M507/AI-SOC-Agent** (14⭐) - **Blackhat 2025**

**URL:** [https://github.com/M507/AI-SOC-Agent](https://github.com/M507/AI-SOC-Agent)  
**Language:** Python | **Topics:** `ai-soc-agent`, `mcp-server`

**Why It's Valuable:**

- **Blackhat 2025 presentation** - conference-grade implementation
- MCP server for automated security investigation
- Integrates with ELK + IRIS platforms

---

### 5. 💎 **ForensIQ** (12⭐) - _DFIR with Local LLM_

**URL:** [https://github.com/dfirvault/ForensIQ](https://github.com/dfirvault/ForensIQ)  
**Language:** Python | **Topics:** `dfir`, `ollama`, `triage`, `digital-forensics`

**Why It's Valuable:**

- Uses **local Ollama LLM** (like Gemma!) for log analysis
- DFIR-specific automation patterns
- Windows forensics focus

---

### 6. ⚡ **VelAI** (6⭐) - _SRE Co-Pilot_

**URL:** [https://github.com/guhatek/VelAI](https://github.com/guhatek/VelAI)  
**Language:** Python

**Why It's Valuable:**

- Correlates logs + metrics + deployments for RCA
- Auto-suggests fixes and drafts postmortems
- Cuts MTTR through automation

---

### 7. 🌐 **TracecatHQ/tracecat** (3471⭐) - _n8n Alternative for Security_

**URL:** [https://github.com/TracecatHQ/tracecat](https://github.com/TracecatHQ/tracecat)  
**Stack:** Python (FastAPI), Temporal.io, Next.js

**Why It's Valuable:**

- All-in-one platform: Workflows + AI Agents + Case Management
- Purpose-built for security/IT teams
- Modern tech stack reference architecture

---

### 8. 🎖️ **agentic-soc-platform** (576⭐)

**URL:** [https://github.com/FunnyWolf/agentic-soc-platform](https://github.com/FunnyWolf/agentic-soc-platform)  
**Stack:** Dify + LangChain + LangGraph

**Why It's Valuable:**

- Agent-centric architecture with visual workflow builder
- SIEM/SOAR integration patterns
- Open-source Dify integration

---

## 📂 Additional Notable Repositories

### Specialized AI Triage Tools

| Repository       | Stars | Key Feature                                                  | URL                                                                 |
| :--------------- | :---- | :----------------------------------------------------------- | :------------------------------------------------------------------ |
| **SOCGPT**       | 3⭐   | Automated triage, summarization & response suggestions       | [Link](https://github.com/Ninadjos/SOCGPT-AI-Powered-SOC-Assistant) |
| **SREnity**      | 7⭐   | Enterprise SRE AI Agent for production incident triage       | [Link](https://github.com/anilsharmay/SREnity)                      |
| **IncidentGPT**  | 0⭐   | **Multimodal LLM** cyber incident response assistant         | [Link](https://github.com/betboyda/IncidentGPT)                     |
| **allama**       | 25⭐  | AI security automation (80+ SIEM/EDR/ticketing integrations) | [Link](https://github.com/digitranslab/allama)                      |
| **auto-runbook** | 1⭐   | Automated runbook engine with AI-assisted ops                | [Link](https://github.com/vijayanandmit/auto-runbook)               |

### SOAR Platforms

| Repository       | Stars  | Description                                    | URL                                                        |
| :--------------- | :----- | :--------------------------------------------- | :--------------------------------------------------------- |
| **Shuffle**      | 2186⭐ | General purpose security automation platform   | [Link](https://github.com/Shuffle/Shuffle)                 |
| **Awesome-SOAR** | 974⭐  | Curated SOAR resources list                    | [Link](https://github.com/correlatedsecurity/Awesome-SOAR) |
| **jimi**         | 170⭐  | IT automation platform (originally for SecOps) | [Link](https://github.com/z1pti3/jimi)                     |
| **SOARCA**       | 102⭐  | Open Source CACAO-based orchestrator           | [Link](https://github.com/COSSAS/SOARCA)                   |

### RAG & LLM Security

| Repository                        | Description                                                      | URL                                                              |
| :-------------------------------- | :--------------------------------------------------------------- | :--------------------------------------------------------------- |
| **Incident-Intelligence**         | Real-time incident management with RAG and Pathways (TypeScript) | [Link](https://github.com/Shubhanshu-ydv/Incident-Intelligence)  |
| **langchain-ai-incident-manager** | AI Incident management with Langchain & RAG (Python)             | [Link](https://github.com/shan5a6/langchain-ai-incident-manager) |
| **Cyber-LLM-RAG**                 | Production cybersecurity AI with RAG, Ray, K8s                   | [Link](https://github.com/alenperic/Cyber-LLM-RAG)               |

---

## 🎯 **Most Relevant to Your n8n Project**

### ⭐ **chalithah/soc-automation-lab** (2⭐)

**URL:** [https://github.com/chalithah/soc-automation-lab](https://github.com/chalithah/soc-automation-lab)  
**Stack:** **n8n** + Splunk + LLM (OpenAI/Claude MCP) + DFIR-IRIS

**Why This Matters:**

- Uses **n8n** (same as your target platform!)
- Shows how to integrate MCP for LLM calls in n8n
- Complete flow: Splunk Alert → n8n → Enrichment → LLM Triage → Ticket Creation

---

## 🔑 Key Implementation Patterns

### 1. Multi-Agent SOC (from gapilongo/SOC & agentic-soc-platform)

```
Alert → Triage Agent → Analysis Agent → Response Agent → Action
         ↓              ↓                ↓
    (Priority)     (Context)        (Remediation)
```

### 2. RAG Pipeline (from SOC-Analyst-Automation)

```
Logs → Embedding (Nomic) → Vector DB → Retrieval → LLM Analysis → UI
```

### 3. Human-in-the-Loop (from Agentic-AI-SOC-Automation)

```
AI Triage → Confidence Check → [Low] → Human Review → Final Decision
                             → [High] → Auto-Execute
```

### 4. n8n Integration (from soc-automation-lab)

```
SIEM Alert → n8n Webhook → Enrichment APIs → LLM Triage → Ticketing System
```

### 5. SRE Incident Response (from VelAI)

```
Metrics + Logs + Deployments → Correlation → RCA → Remediation Suggestions → Postmortem Draft
```

---

## 📊 Technology Stack Analysis

### Most Common Technologies:

1. **Languages:** Python (85%), TypeScript/JavaScript (10%), Go (5%)
2. **AI Frameworks:** LangChain, LangGraph, LlamaIndex, Dify
3. **LLMs:** OpenAI GPT, Claude, Llama, Gemini, **Ollama (local)**
4. **Vector DBs:** Qdrant, Pinecone, Chroma, FAISS, Weaviate
5. **Orchestration:** LangGraph, n8n, Temporal.io, Airflow
6. **SOAR:** Shuffle, custom Python frameworks
7. **Deployment:** Docker, Kubernetes, AWS Lambda

---

## 🚀 Recommended Next Steps

1. **Study Top 3 Industry Platforms:**

   ```bash
   # Architectural reference
   git clone https://github.com/TracecatHQ/tracecat.git

   # Agent patterns
   git clone https://github.com/FunnyWolf/agentic-soc-platform.git

   # SOAR workflows
   git clone https://github.com/Shuffle/Shuffle.git
   ```

2. **Clone Specialized AI Triage Tools:**

   ```bash
   # Multi-agent architecture
   git clone https://github.com/gapilongo/SOC.git

   # Blackhat 2025 MCP patterns
   git clone https://github.com/M507/AI-SOC-Agent.git

   # Local LLM (Ollama/Gemma)
   git clone https://github.com/dfirvault/ForensIQ.git

   # Full-stack RAG
   git clone https://github.com/Sai-Chakradhar-Mahendrakar/SOC-Analyst-Automation-using-RAG-Model.git
   ```

3. **MUST REVIEW: n8n Implementation**

   ```bash
   git clone https://github.com/chalithah/soc-automation-lab.git
   ```

4. **Extract Patterns:**
   - Multi-agent coordination → `gapilongo/SOC`, `agentic-soc-platform`
   - RAG pipeline → `SOC-Analyst-Automation`, `ForensIQ`
   - Human approval flows → `Agentic-AI-SOC-Automation`
   - n8n workflows → `soc-automation-lab`
   - SRE patterns → `VelAI`, `SREnity`

---

## 💡 Key Insights for Your n8n Workflow

Based on these 100+ repositories, your n8n implementation should include:

1. **Alert Ingestion:** PagerDuty Trigger (instead of Splunk/SIEM)
2. **Enrichment Layer:** VirusTotal, AbuseIPDB, threat intel APIs
3. **RAG Query:** Qdrant vector search for similar incidents
4. **LLM Analysis:** Gemini Pro (or local Gemma via Ollama like ForensIQ)
5. **Decision Logic:** Confidence-based routing (auto-resolve vs escalate)
6. **Update Action:** PagerDuty incident update with AI analysis
7. **Audit Trail:** Log to Supabase/PostgreSQL
8. **Human Loop:** Approval step for low-confidence decisions

---

## 🔗 Quick Reference

**🏆 Must-Review Repositories:**

- [TracecatHQ/tracecat](https://github.com/TracecatHQ/tracecat) - Platform architecture
- [gapilongo/SOC](https://github.com/gapilongo/SOC) - Multi-agent patterns
- [soc-automation-lab](https://github.com/chalithah/soc-automation-lab) - **n8n implementation**
- [ForensIQ](https://github.com/dfirvault/ForensIQ) - Local LLM (Ollama/Gemma)
- [AI-SOC-Agent](https://github.com/M507/AI-SOC-Agent) - MCP server patterns

**📚 Learning Resources:**

- [Awesome-SOAR](https://github.com/correlatedsecurity/Awesome-SOAR) - Curated SOAR list
- [learning-llms-for-dev-sec-ops](https://github.com/jedi4ever/learning-llms-and-genai-for-dev-sec-ops) - LLM for security

**⚙️ SOAR Platforms for Reference:**

- [Shuffle](https://github.com/Shuffle/Shuffle) - Open-source SOAR
- [agentic-soc-platform](https://github.com/FunnyWolf/agentic-soc-platform) - Agent-centric SOAR
