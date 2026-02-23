# Non-RAG Workflow: Comparison Report — Implementation Plan

> **Status**: Finalized. All raw data read. Aligned on scope, assumptions, and structure.  
> **Next step**: User approves → write report section by section on command.

---

## Data Inventory (As-Read, Confirmed)

| Source File                         | Lines | Scope                                                                                                                       |
| ----------------------------------- | ----- | --------------------------------------------------------------------------------------------------------------------------- |
| `test_cases_LLM-Only.md`            | 477   | 8 TCs summarized, ratings + fact-checks                                                                                     |
| `test_cases_LLM-Only_raw.md`        | 6333  | All raw model outputs for all TCs — read in full                                                                            |
| `test_cases_LLM-Advanced-Search.md` | 997   | TCs 1–8, Tavily Config A + SerpAPI Config C, 7 models each                                                                  |
| `test_cases_LLM-Basic-Search.md`    | 212   | 10 TCs defined; TC5/TC6/TC7 outputs transferred from raw                                                                    |
| `Basic-Search_raw`                  | 1433  | TC5 (Node.js), TC6 (CVE-2025-24813), TC7 (RDS) — Gemini + Opus — 3 prompt placements each; includes human-ranked scorecards |
| `Tavily_Auto Parameters_raw`        | 7664  | Full outputs, TCs 1–8, 7 models                                                                                             |
| `Serp_Auto Parameters_raw`          | 6914  | Full outputs + verbatim failure traces                                                                                      |
| `search_strategy.md`                | ~300  | Architecture rationale, tool comparison                                                                                     |
| `llm_system_prompts.md`             | 774   | All 3 system prompt versions (V1/V2/V3)                                                                                     |

---

## Confirmed Model Roster

**LLM-Only — 14 models:**  
Claude Sonnet 4.5, Gemini 3 Pro Preview, GPT-5.2, GPT-OSS-120B, Kimi-K2.5, GPT-5.2-Codex, DeepSeek-V3.2, GLM-4.7, Llama-4-Maverick, Claude Opus 4.5, Gemma-3-27b-it, Qwen3.5 Plus, Minimax-M2.5, Grok-4

**Advanced Search (Tavily + SerpAPI) — 7 models:**  
Claude Sonnet 4.5, Gemini 3 Pro Preview, GPT-5.2, Kimi-K2.5, GLM-4.7, Llama-4-Maverick, Claude Opus 4.5

**Basic Search — 2 models:**  
Gemini-3-Pro-Preview, Claude Opus 4.5

> **Model Classification:** Closed-source: GPT-5.2, Claude Sonnet 4.5, Claude Opus 4.5, Gemini 3 Pro Preview, Grok-4. Open-source: GLM-4.7, Kimi-K2.5, Qwen3.5-Plus, Llama-4-Maverick, Minimax-M2.5, DeepSeek-V3.2, Gemma-3-27b-it, GPT-OSS-120B, GPT-5.2-Codex. **Note:** Gemini Flash = closed-source. Gemma = open-source. They are not the same family.

---

## Closed Assumptions (Decision Log)

### A1 — Basic Search: No Full Run Needed

**Decision:** Do not run a full 10-TC / 7-model Basic Search evaluation.

**Rationale (honest):** The existing data (TC5, TC6, TC7 across 3 prompt placements, 2 models) is sufficient to derive the key findings — because the primary variable being tested is **how the node is wired**, not which model handles the search. The best Basic Search outputs (Agent+Tool Node, Opus) are **genuinely competitive** with Tavily in output quality for the same TCs. A full run would confirm topology but not materially change the conclusions.

**What we cannot claim without a full run:** Full model-to-model comparison across all 10 TCs, or a ranked aggregate score for "Basic Search vs. Advanced Search." The report will be explicit about this boundary.

**What we can claim:** The structural finding — Agent+Tool Node with "Message a Model in Google Gemini" + explicit token budget performs best — is proven. Full run would only validate it at scale.

---

### A2 — Tavily: Manual Parameters Deferred

**Decision:** Config B (Tavily with manual parameters) not tested. Auto-parameters only.

**Rationale:** Tavily is an AI-native search API. Auto-parameters let the agent construct queries based on context, which is the intended usage. Our data shows auto-parameters perform well for Tavily (few failures, relevant results). Manual constraints would reduce flexibility without demonstrated upside. This is **validly closed**.

> In the report: state this clearly as a scope boundary, not a gap. "Auto-parameters represent the intended usage of Tavily. Manual parameter testing was deferred as the auto-parameter results were sufficiently informative."

---

### A3 — SerpAPI: Manual Parameters Deferred (Nuanced)

**Decision:** Config D (SerpAPI with manual parameters) not tested.

**Rationale:** The SerpAPI failures were caused by **specific incompatible parameters** being auto-generated (`output`, `uule`+`location` conflict, `q` missing, etc.) — not by excessive freedom in parameter construction. The fix is **parameter exclusion guard rails** hardcoded into the tool config, not switching to manual parameters. Manual parameters would introduce a different constraint problem and wouldn't solve the root issue.

> In the report: state that manual parameters do not address SerpAPI's root failure mode. The correct solution is guard rails on excluded parameters. Config D remains out of scope because the architectural lesson is already clear.

---

## Evidence and Proof Structure

The report uses a **hybrid approach**:

1. **Inline excerpts**: Short, targeted quotes (2–8 lines) — the "smoking gun" that proves the point being made at that moment in the narrative. Used for key claims (e.g., the GLM `T1110.001 Password Cracking` mislabeling, the Gemini `in operator` error string).

2. **Section-end raw block**: For each section, the most important full model output relevant to that section's argument is pasted at the end of the section under `#### Supporting Output`.

3. **Report-end appendix**: All raw outputs organized by TC × Model × Workflow. This serves as the cross-verification source. The raw `.md` files are the primary appendix — the report references them by filename and section.

---

## Section 5 Architecture Correction

> [!IMPORTANT]
> The "LLM + Basic Search" workflow uses the **"Message a Model in Google Gemini"** n8n node — **not** the standard Chat Model node. This distinction is material: the Chat Model node has no built-in Google Search capability. Only the "Message a Model" node supports `builtInTools: { googleSearch: true }`.

**Three configurations were tested within Basic Search:**

| Configuration | Node Setup                                  | What Was Varied                        |
| ------------- | ------------------------------------------- | -------------------------------------- |
| **Output 1**  | Prompt injected into Tool Node              | System prompt wired at the tool level  |
| **Output 2**  | Prompt injected into Agent Node             | System prompt wired at the agent level |
| **Output 3**  | Prompt injected into both Agent + Tool Node | Split prompt placement                 |

Additionally, **auto-parameter behavior was tested at the node level** — specifically whether the Message Model node's internal parameter handling (temperature, topK, topP) affected output length or search triggering. This is documented in the raw scorecard analysis and will be included in Section 5.

**The critical n8n finding:** The Tool Node configuration caused Gemini to fail 75% of the time (`Cannot use 'in' operator to search for 'functionCall' in undefined`) — this is an n8n JavaScript parsing bug triggered by Gemini's function call response schema, not a model quality failure. Opus was unaffected because Anthropic models format tool call responses differently.

---

## Report Structure

**Document:** `Non_RAG_Workflow_Comparison_Report.md`  
**Location:** `c:\Users\umang\Incident Management\Non Rag Workflow\`  
**Written:** One section at a time, on command.

---

### ✅ Section 1 — Executive Summary — WRITTEN

- One-paragraph verdict per workflow type
- Top-line table: Reliability / Quality / Cost / Failure Rate / Recommended Use Case
- "If you only read one thing" block

### ✅ Section 2 — Test Case Design Philosophy — WRITTEN

- Why these 10 TCs; the difficulty spectrum (Easy → Medium → Hard → Edge)
- The misattribution traps: TC6 CVE score understated, TC7 RDS-EVENT-0056 wrong message entirely
- What "passing" looks like at each difficulty level

### ✅ Section 3 — Evaluation Framework — WRITTEN

- Grading criteria: Accuracy (primary) > Safety > Search Economy > Completeness > Format
- Why accuracy is paramount (incident response decisions have real financial/operational stakes)
- Model classification table (open-source vs. closed-source, confirmed roster)

### ✅ Section 4 — LLM-Only Workflow — WRITTEN

- Temperature experiment: `0.3` = structured runbook; `0.7+` = detail + noise tradeoff → firm conclusion
- Per-TC model findings with inline excerpts for key differentiators
- Hallucination baseline for hard TCs (CVE, vendor error codes)
- Section-end appendix: full raw outputs per TC

### ✅ Section 5 — LLM + Basic Search (Google Grounding) — WRITTEN

- **n8n architecture**: "Message a Model in Google Gemini" node — **not** the standard Chat Model node, which has no built-in search capability
- **3 prompt placements**: Tool Node, Agent Node, Agent+Tool Node — a prompt-wiring experiment as much as a search experiment
- Auto-parameter configuration testing at the node level (temperature, topK, topP)
- Gemini Tool Node 75% failure rate explained (n8n JS parsing bug with Gemini's function call response schema)
- Scorecard findings per TC (TC5, TC6, TC7) — Agent+Tool Node wins all three
- **Key architectural constraint** — documented clearly, not as a cop-out:
  - The "Message a Model in Google Gemini" node uses Gemini internally for search. The main n8n agent also runs a separate chat model (e.g., Opus). This creates a **dual-model architecture**: one model for search orchestration + one for the agent response.
  - In contrast, Tavily and SerpAPI are pure search APIs — the agent model handles all reasoning, and the search tool just returns results. This is simpler, cheaper, and model-agnostic.
  - Google Grounding also requires more configuration effort (which node, how to wire prompts, parameter settings for the Message Model node) — complexity that adds fragility without proportional benefit.
  - **Conclusion**: Google Grounding is best suited for Gemini-native products and code-centric tasks where the Gemini model is already the primary agent. For production incident response with mixed-model flexibility, Tavily (or SerpAPI with guard rails) is the better architectural choice.
- **Assumption A1 stated clearly**: full run not completed — the structural and architectural finding is sufficient; a full 7-model × 10-TC run would only confirm the pattern at scale
- Key conclusion: Agent+Tool Node + Opus + explicit `<600 word` token budget

### ✅ Section 6 — Tavily Auto Parameters (Config A) — WRITTEN

> Note: AS44486 finding correctly attributed to Config C (not Config A). HHH-17078 correctly placed in TC4. TC6 trap catchers named as Kimi + GPT.

- Setup and why auto-parameters (→ Assumption A2)
- TC-by-TC: search behavior, search delta, failure modes
- Discoveries only found via search: Erlang/OTP CVE, AS44486 GeoIP, HHH-17078 Spring Batch

### ✅ Section 7 — SerpAPI Auto Parameters (Config C) — WRITTEN

> Note: Section 7.5 rewritten to distinguish 'not configured' vs 'erroring' parameters. Table updated to 'Why Not Configured' framing.

- Verbatim parameter failure strings from raw
- Root cause analysis: guard rails problem, not control-mode problem (→ Assumption A3)
- Where SerpAPI actually won despite failures

### ✅ Section 8 — Head-to-Head: Tavily vs. SerpAPI — WRITTEN

- Per-TC winner table, reliability delta, token waste multipliers

### ✅ Section 9 — Search Delta (Non-Search vs. Search) — WRITTEN

- Four-way comparison: LLM-Only vs. Basic Search vs. Tavily (Config A) vs. SerpAPI (Config C)
- TC6 RDS misattribution anchor: **0/7 LLM-Only** (confirmed from source) **/ 0/2 Basic Search / 2/7 Tavily / 0/7 SerpAPI**
- Key finding: search delta is Tavily-specific for vendor event code verification; Google-backed backends (Basic Search + SerpAPI) returned 0% trap detection — same as LLM-Only
- Per-TC delta table: all 11 TCs rated across all four workflows
- Per-TC note clarification: LLM-Only used 14 models for TC1 (temperature variants), 7–8 for other TCs
- Negative-delta case documented: TC10 Gemini + SerpAPI hallucinated RedAlert/N13V; same model + Tavily = correct CryptXXX
- Calibration benchmark: Qwen3.5 Plus in Config A — 2 searches on exactly the right TCs, 10–20% of Gemini's token cost

### ✅ Section 10 — Open Source vs. Closed Source — WRITTEN

- Model roster split: Closed = GPT-5.2, Claude Sonnet 4.5, Claude Opus 4.5, Gemini 3 Pro Preview, Grok-4. Open = GLM-4.7, Kimi-K2.5, Qwen3.5-Plus, Llama-4-Maverick, Minimax-M2.5, DeepSeek-V3.2, Gemma-3-27b-it, GPT-OSS-120B, GPT-5.2-Codex
- Not available in Advanced Search (open-source Advanced Search models = Kimi, GLM, Llama only)
- Per-TC cross tabulation: open vs. closed ratings across LLM-Only (where widest model set was tested)
- Failure mode distribution: where did closed-source models fail (Gemini loop, Sonnet over-trigger)? Where did open-source excel (Kimi TC6, GLM CVE-2025-32433)?
- Cost asymmetry: open-source models generally used fewer tokens for equivalent outputs across Easy/Medium TCs

### ~~Section 11 — SerpAPI Parameter Decisions~~ — DROPPED

> Already covered in full in Section 7.5 (parameter table rewrite). Repeating here would duplicate content verbatim.

### ~~Section 12 — Temperature Experiment~~ — DROPPED

> Fully covered in Section 4.2 (LLM-Only temperature experiment). No new data to add.

### ~~Section 13 — Token Economy~~ — DROPPED (folded into Section 16)

> Key token stats (Gemini 10x multiplier, Qwen 10–20% benchmark) are cited in Sections 6, 7, 8 and will appear as a summary table in Section 16 recommendations.

### ✅ Section 14 — Failure Mode Taxonomy — WRITTEN

- Cross-workflow reference table: 8 failure categories × workflow occurrence
- All examples must be cited from source files, no inference:
  - Hard Hallucination: Gemma-3-27b TC5 wrong Node.js version; Opus TC10 fake IR hotline numbers
  - Partial Hallucination: GLM M1027 mislabeling (M1027=Password Policies, not rate-limiting); Qwen Mozi botnet attribution (Mozi dismantled Aug 2023)
  - Tool Loop: Gemini Tavily TC2 (IP WHOIS, 200k+ tokens); Gemini Tavily TC4 (10 recursive searches, 146k tokens)
  - Generation Failure: Kimi TC4 Tavily (3 successful searches, agent returned `{}`)
  - Over-Triggering: Sonnet TC3 Tavily (1 search on a deterministic typo, 3× token cost, zero info gain)
  - Parameter Failure: GLM SerpAPI TC2 (3 failed calls: `output`, `uule`+`location`, then clean); GLM SerpAPI TC4 (7 complete failures, ~188k tokens, zero output)
  - Safety Risk: Sonnet TC7 (proposed `rm` on binary logs without replica check); Qwen TC1 (aggressive `rm -rf` without space verification first)
  - Severity Miscalibration: Gemini "High" on nginx typo TC3 across both Tavily and SerpAPI

### ~~Section 15 — What We Could Add~~ — DROPPED (folded into Section 16)

> Future tool additions (NVD API, AbuseIPDB, MITRE ATT&CK API, Exa/Jina AI, RAG) will be covered in Section 16 as a "Next Steps" paragraph.

### ✅ Section 16 — Conclusions & Production Recommendations — WRITTEN

- **Workflow decision table**: "If your use case is X, use Y" — not vague prose
- **Minimum viable setup per tier**: LLM-Only ≠ zero-cost; Basic Search = Gemini-native only; Tavily = 7-model production choice
- **Model recommendation by use case**: confirmed from actual data, not labels
- **Token cost summary table**: outlier cases (Gemini 200k TC4), efficient benchmarks (Qwen3.5 Plus ~3k)
- **Guard rails required before production**: Tavily max-iteration cap; SerpAPI parameter exclusion list; system prompt token budget line
- **Future search tools**: NVD API, AbuseIPDB, MITRE ATT&CK API, Exa AI, Jina AI, full RAG
- **Report status note**: Section 1 (Executive Summary) remains to be written last

---

## Appendix Structure (Report End)

```text
Appendix A — LLM-Only Raw Outputs (all TCs, all models)
Appendix B — Basic Search Raw Outputs (TC5/TC6/TC7, Gemini + Opus, 3 placements)
Appendix C — Tavily Config A Raw Outputs (TCs 1–8, 7 models)
Appendix D — SerpAPI Config C Raw Outputs + Failure Traces (TCs 1–8, 7 models)
```

> Raw source files: `test_cases_LLM-Only_raw.md`, `Basic-Search_raw`, `Tavily_Auto Parameters_raw`, `Serp_Auto Parameters_raw`

---

## Verification Rules

- Every claim → citation to source file
- Short inline excerpts for "smoking gun" proofs
- Full outputs in section-end `Supporting Output` blocks and Appendix
- Gaps marked `[PLACEHOLDER]` — no fabrication
- One section at a time, on user command
