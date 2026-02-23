# Embedding Model Selection Guide: MTEB vs RTEB

## Executive Summary

For your **Incident Response RAG** system, **RTEB (Retrieval)** is the most critical benchmark to focus on.

Your current implementation uses `models/gemini-embedding-001`. **Recommendation:** Upgrade to Google's newer **`text-embedding-004`** immediately for a significant performance boost without changing providers. If you need absolute state-of-the-art performance, consider **Voyage AI** (specialized for RAG) or **OpenAI text-embedding-3-large**.

---

## 1. Understanding the Benchmarks

### MTEB (Massive Text Embedding Benchmark)

- **The "Decathlon"**: Tests models across 8 diverse tasks: Classification, Clustering, Pair Classification, Reranking, Retrieval, STS (Semantic Textual Similarity), Summzarization, and Bitext Mining.
- **Relevance to you**:
  - **High**: For your goal of "Finding incident cohorts" (Clustering) and general similarity. `text-embedding-004` is excellent here.
  - **Medium**: For pure "Find me similar incidents" (Retrieval).

* **Pros**: Comprehensive view of a model's "general intelligence".
* **Cons**: A model might be #1 overall but mediocre at Retrieval specifically.

### RTEB (Retrieval Text Embedding Benchmark)

- **The "Sprint"**: A specialized sub-benchmark (often beta/new) focusing _exclusively_ on **Retrieval** (finding the right document given a query). It often includes harder, enterprise-centric datasets (Code, Law, Finance).
- **Relevance to you**:
  - **Critical**: This directly measures how well your system will find "Server outage" past tickets when you search "Connection refused".
  - **Context**: Incident Response is a domain-specific retrieval task. RTEB's focus on "out-of-domain" generalization is very relevant here.
- **Important Note**: On this specific benchmark, older models like `gemini-embedding-001` or `voyage-large-2` sometimes outscore newer "generalist" models like `text-embedding-004` or `text-embedding-3-large`. This is common in retrieval-specific tasks where "denser" older models might memorize patterns better.

**Verdict**: Prioritize **RTEB/Retrieval** scores first, then check **MTEB** to ensure the model isn't "dumb" at clustering (for your cohort analysis).

---

## 2. Interpreting Your Screenshots

You shared screenshots of the RTEB Leaderboard. Here is what they tell us:

1.  **Top Tier**: `voyage-3-large` and `voyage-code-2` are essentially undisputed kings of retrieval. If you want the absolute best retrieval, use Voyage.
2.  **The Gemini Anomaly**: You likely noticed `gemini-embedding-001` (Rank ~8) is higher than `text-embedding-004` (Rank ~32).
    - **Why?**: `gemini-embedding-001` is a very dense, high-dimensional model that specifically excels at "hard retrieval". `004` is a "distilled" model made to be faster, cheaper, and better at _everything else_ (Clustering, Classification, etc.), but it took a hit on pure retrieval accuracy in this specific benchmark.
    - **Decision**:
      - If you care **ONLY** about finding similar tickets: `gemini-embedding-001` (what you have) is actually quite good!
      - If you care about **Clustering** (Incident Cohorts) + Retrieval: `text-embedding-004` is better overall.
      - **Winner**: `voyage-3-large` beats both.

---

## 3. Model Tier List (2025 Context)

### 🥇 Tier S: The Specialists (Best for RAG)

- **Voyage AI (`voyage-large-2` / `voyage-code-2`)**
  - Built mainly for RAG. Excellent context window.
  - _Why_: Often beats OpenAI on retrieval-specific benchmarks. `voyage-code-2` might be excellent for technical incident logs.
- **Cohere (`embed-english-v3.0` / `embed-multilingual-v3.0`)**
  - Native "Matryoshka" embeddings (can be truncated). Optimized for search.
  - _Why_: Very strong enterprise track record.

### 🥈 Tier A: The Generalists (Balanced & Strong)

- **OpenAI (`text-embedding-3-large`)**
  - The standard. Very easy to use.
  - _Why_: Good balance of performance and price. "Just works".

* **Google Gemini (`text-embedding-004`)**
  - **Current User Status**: You are using `001`. `004` is a massive leap forward generally.
  - _Why_: **Easiest upgrade path.** It supports elastic embedding dimensions (like Matryoshka).
  - _Trade-off_: Performs worse than `001` on pure RTEB retrieval, but better on MTEB (Clustering/Classification).

### 🥉 Tier B: Open Source (Self-Hosted)

- **BGE-M3 (BAAI)**

* **E5-Mistral**
  - _Why_: If data privacy requires zero external API calls. Requires GPU management.

---

## 4. Domain-Specific Models (Cybersecurity/Logs)

You asked about "Cybersecurity specific" models.

- **The Academic Reality**: There are research models like **CyBERT** or **LogLMs**, but they are often:
  - Hard to deploy (no easy API).
  - Trained on _old_ data.
  - Not true "semantic" embedding models but rather "log parsers".
- **The Practical Winner: Voyage AI (`voyage-code-2` / `voyage-code-3`)**
  - **Why?**: Cybersecurity logs are 50% "Code" (Stack traces, error codes, JSON payloads, file paths).
  - **Voyage Code** models are trained specifically to understand structure in code and technical data better than standard text models.
  - **Recommendation**: If your incidents have lots of logs/JSON, `voyage-code-2` is effectively your "Domain Specific" model.

## 5. The Heavyweights (Octen/Qwen 8B)

You asked about **Octen-Embedding-8B** and **Qwen-Embedding-8B**.
*   **Performance**: **Incredible.** Octen-8B is currently **#1 on the RTEB Leaderboard** (Score ~0.80), beating almost everything.
*   **The Catch**: These are **8 Billion Parameter** models.
    *   **Self-Hosting**: You need a GPU with ~24GB VRAM (e.g., A10G, 3090/4090) to run them fast.
    *   **API Usage**: You can't run them on "standard" OpenAI/Google APIs. You must use specialized providers like **Fireworks AI**, **DeepInfra**, or **OpenRouter**.
*   **Verdict**: If you are okay with using a provider like **Fireworks AI**, these are the **best performing models currently in existence** for retrieval.

## 6. Specific Recommendations for `incident-management`

### Immediate Action: Choose Your Path

#### Option A: The "Google Ecosystem" Path (Easiest / Free-ish)
You are currently using Google GenAI.
*   **Action**: Change `gemini-embedding-001` to `text-embedding-004`.
*   **Pros**: Free/Cheap, no new keys, good *enough* for RAG.
*   **Cons**: We know `004` is weaker at pure retrieval than `001` (from your screenshots).

#### Option B: The "SaaS Specialist" Path (Best Commercial)
*   **Action**: Switch to **Voyage AI (`voyage-code-2`)**.
*   **Pros**: 
    *   **Native Code Support**: Best for purely technical logs.
    *   **Simple API**: Just like OpenAI/Google.
*   **Cons**: New API key, small cost.

#### Option C: The "Performance King" Path (Octen/Qwen)
*   **Action**: Sign up for **Fireworks AI** or **DeepInfra** and use `Octen-Embedding-8B`.
*   **Pros**: 
    *   **#1 Retrieval Score**.
    *   Open Weights (you aren't locked in, you *could* self-host later).
*   **Cons**: Requires setting up an OpenAI-compatible client pointing to a new Base URL.

**Final Call**: 
*   **Simplicity**: Go with **Voyage AI (`voyage-code-2`)**.
*   **Max Performance**: Go with **Octen-Embedding-8B** (via Fireworks AI).

## Summary Comparison

| Metric               | Google `text-embedding-004`    | OpenAI `text-embedding-3-large` | Voyage `voyage-large-2`  |
| :------------------- | :----------------------------- | :------------------------------ | :----------------------- |
| **MTEB Score**       | Very High                      | High                            | High                     |
| **RAG (Retrieval)**  | Excellent                      | Very Good                       | **Specialist/Best**      |
| **Cost**             | Low                            | Medium                          | High                     |
| **Effort to Switch** | **Zero** (Drop-in replacement) | Medium (New API Key/SDK)        | Medium (New API Key/SDK) |

**Final Call**:

1.  **For Best Retrieval**: Switch to **Voyage AI** (`voyage-3-large`). It is #1 on the leaderboard you shared for a reason.
2.  **For Best "Ecosystem"**: Stick with Google (`gemini-embedding-001` is actually superior for retrieval than `004`, so you might just want to **keep your current model** if retrieval is the only goal!).
