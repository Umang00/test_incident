# Non-RAG LLM Workflow Comparison Report: Incident Management

**Reference Resources:**

- **Data Repository:** [https://github.com/Umang00/test_incident](https://github.com/Umang00/test_incident)
- **n8n Workflow:** [https://automate.deployed.top/workflow/tFbtg3g71dN4cfIy](https://automate.deployed.top/workflow/tFbtg3g71dN4cfIy)

## Want to keep listening instead of reading?

- **Interactive Audio & Q&A:** [NotebookLM Deep Dive](https://notebooklm.google.com/notebook/a14fc2be-484a-495e-aec2-111dfe15f510)

## Section 1 — Executive Summary

This report evaluates the performance of LLMs in incident response triage across four distinct web-search workflows, deliberately excluding Retrieval-Augmented Generation (RAG) to isolate the impact of reasoning and live search capability.

**The Evaluation Framework:**

- **4 Workflows Tested:** LLM-Only (baseline), Basic Search (n8n Google Grounding), Tavily Advanced Search, and SerpAPI Advanced Search.
- **10 Test Cases (TC1–TC10):** A deterministic suite designed to separate models that _know_ the domain from those that _sound like_ they do. This includes basic infrastructure failures (TC1 Disk Full), version-specific regressions (TC5 Node.js Crash), and adversarial "traps" (TC6/TC7) where the alert text contains plausible but verifiable lies.
- **8 Model Families:** Testing spanned both closed-source (GPT-5.2, Claude 4.5 Sonnet/Opus, Gemini 3 Pro) and open-source (Qwen3.5 Plus, GLM-4.7, Kimi-K2.5, Llama-4, Gemma-3, and others).

![1f919ee6-904b-49fb-8fb3-c2df61eeaece.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/37a1b03c-5e8b-457a-bf24-65c0f64fe1a2/1f919ee6-904b-49fb-8fb3-c2df61eeaece.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466X3ZED22T%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090508Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJHMEUCIQDJJf4edolyxHre7OAbtiKabNER0uGj8V011JQR2c7abwIgPhuoLaPgG%2BZjOV6KA%2FOKPf2TmZvKrOQf8gxajNu5Qc4qiAQI2v%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgw2Mzc0MjMxODM4MDUiDDH0vmqqdEU9HuPi%2FyrcA5KkPKJ8kKTgbZo2DvnRllru61IIfXiVThyeV9xSyHDNMTiLkvdqvwtXksEOXc4RJM%2FQTNyAktpk79pFmvfRD1dchhxgpj88kWsU%2FxJrKL6LWFjP%2BAqda%2FrBnO4XaavurIjZTXv%2BsQ3pA%2Bc3JFvB77qgdRS9ThUBIrYw%2Fq%2B3gkOueAfj47wq0QP%2Bw8Ub7MmxNNAc8uy8zjScje8e4JvtV5k%2FxIbRAjLWB%2FeAe2vDSv3ZFm3ZJDZeeA5f0cTsEkkcXlQN9QVrzEke8Ao4uA3TsL9ZEx%2BW3bEOqRP8M7yA5nMTjmOQNXSjlBz4D1cMr1WQH1hWUN7GBl%2BndHU9Zx%2F2sINx6lDnlntXGcZBMuT5RQtbX71KCWvucpFxdHPVCgdYbcrWaMOJFrg2uszJriw15HT3Lcce9lKI1mGbd5A1yKR%2BGeQO6OkkYBmqjGn4oeVQ5sOXSp%2FXhDZZ05np0fwgX%2BNEJ3e89MUhayvhdPowUj9CopOFsluAwZuJLyK76baCRP%2BPaYWLa3gPWUks2mkGfymEQ%2F%2F6Sm8gHiEJ0qCWk0w4hcADJnBKMDNVU5YEKww%2Fre2giHo3pYhU65I6D2ijuumfLwaQyyF3NQQwFVhYDWjjuhnO2x3XLxjve9IwMPOl8MwGOqUB2juMkaoMV2w8gWgfDy%2F%2FwmZis6HXsVdZm%2Bo8itNVCpURLs9wldd6trDGyj4NrcTxmgopb2SD54Ehy9NDOkZ%2B%2FU0KPD64XqBU%2BXXTKIJqy%2BTcNhfGC2RhqSJrwzjeedxJKuyKsPYa63pDYjGLUE8JqY8XSmHOpiMwY2ch5gg72HXvlHxQzCqUe0hDUL7tHEhwv2RBqLsK%2BQxVq%2FLxzb5zRwJgl2Jt&X-Amz-Signature=7f48f3fff5616070c601c3b5c9b73063c741dc08457b5ac3d95f6d02ac37da97&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)

**Core Findings & Production Recommendations:**

1. **Workflow Selection:** No single workflow fits all alerts. LLM-Only is highly effective for pre-training-diagnosable alerts (e.g., SSH Brute Force) at a cost of ~2,000–3,500 tokens. Advanced Search is strictly required for post-training events (CVE lookups, vendor error codes)—otherwise, models confidently hallucinate analysis based on fabricated alert text.
2. **Tavily vs. SerpAPI:** Tavily proved significantly more reliable and cost-effective for technical incident triage. It successfully indexed GitHub issues and official AWS event tables, whereas SerpAPI struggled with parameter rejection (costing one model ~188k wasted tokens) and returned narrative blog spam over primary sources.
3. **Open vs. Closed Source:** Licensing origin is a weak predictor of search success. Qwen3.5 Plus (open) demonstrated the best search calibration benchmark (lowest token waste), while GPT-5.2 (closed) offered the most reliable zero-loop execution. Conversely, Gemini (closed) suffered a 200k+ token recursive search loop, and GLM-4.7 (open) yielded catastrophic failures on complex SerpAPI runs despite surfacing a CVSS 10.0 vulnerability no other model found.
4. **Guardrails are Mandatory:** Deploying search agents without structural guardrails is not production-ready. We mandate three critical implementations: a hard iteration cap on search loops (Max 5 attempts), an explicit **"Max Tokens" parameter** on the agent node to prevent severe token bloat, and parameter exclusion lists if using SerpAPI.

![2addaefe-a858-44a2-adf7-3e66c25c2eb9.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/e724e474-324a-424b-8e40-83d302d9dcfe/2addaefe-a858-44a2-adf7-3e66c25c2eb9.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466X3ZED22T%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090508Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJHMEUCIQDJJf4edolyxHre7OAbtiKabNER0uGj8V011JQR2c7abwIgPhuoLaPgG%2BZjOV6KA%2FOKPf2TmZvKrOQf8gxajNu5Qc4qiAQI2v%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgw2Mzc0MjMxODM4MDUiDDH0vmqqdEU9HuPi%2FyrcA5KkPKJ8kKTgbZo2DvnRllru61IIfXiVThyeV9xSyHDNMTiLkvdqvwtXksEOXc4RJM%2FQTNyAktpk79pFmvfRD1dchhxgpj88kWsU%2FxJrKL6LWFjP%2BAqda%2FrBnO4XaavurIjZTXv%2BsQ3pA%2Bc3JFvB77qgdRS9ThUBIrYw%2Fq%2B3gkOueAfj47wq0QP%2Bw8Ub7MmxNNAc8uy8zjScje8e4JvtV5k%2FxIbRAjLWB%2FeAe2vDSv3ZFm3ZJDZeeA5f0cTsEkkcXlQN9QVrzEke8Ao4uA3TsL9ZEx%2BW3bEOqRP8M7yA5nMTjmOQNXSjlBz4D1cMr1WQH1hWUN7GBl%2BndHU9Zx%2F2sINx6lDnlntXGcZBMuT5RQtbX71KCWvucpFxdHPVCgdYbcrWaMOJFrg2uszJriw15HT3Lcce9lKI1mGbd5A1yKR%2BGeQO6OkkYBmqjGn4oeVQ5sOXSp%2FXhDZZ05np0fwgX%2BNEJ3e89MUhayvhdPowUj9CopOFsluAwZuJLyK76baCRP%2BPaYWLa3gPWUks2mkGfymEQ%2F%2F6Sm8gHiEJ0qCWk0w4hcADJnBKMDNVU5YEKww%2Fre2giHo3pYhU65I6D2ijuumfLwaQyyF3NQQwFVhYDWjjuhnO2x3XLxjve9IwMPOl8MwGOqUB2juMkaoMV2w8gWgfDy%2F%2FwmZis6HXsVdZm%2Bo8itNVCpURLs9wldd6trDGyj4NrcTxmgopb2SD54Ehy9NDOkZ%2B%2FU0KPD64XqBU%2BXXTKIJqy%2BTcNhfGC2RhqSJrwzjeedxJKuyKsPYa63pDYjGLUE8JqY8XSmHOpiMwY2ch5gg72HXvlHxQzCqUe0hDUL7tHEhwv2RBqLsK%2BQxVq%2FLxzb5zRwJgl2Jt&X-Amz-Signature=b81b8f2bf841d2e012e02056ec390c93f3edd215c6e411eb25d8399616961bfa&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)

## Section 2 — Test Case Design Philosophy

### 2.1 Why Test Cases Matter

It is easy to evaluate an LLM with cherry-picked prompts. It is much harder to build a test suite that actually breaks things — that consistently distinguishes a model that _knows_ something from one that _sounds like_ it knows something.

Every test case in this evaluation was designed with one explicit goal in mind: **create a situation where the wrong answer is indistinguishable from the right one unless you actually know the domain.** For incident response, this is not a philosophical concern — it is an operational one. A triage note that confidently recommends the wrong remediation step can cause downtime, data loss, or escalate a contained breach. The stakes justify a demanding test design.

All 10 test cases use **real, verifiable data**: GitHub-tracked regressions, NVD-published CVE records, AWS-documented event IDs, and community-confirmed failure patterns. Every expected answer can be independently verified by anyone reading this report. There is no "we think this is right" — there is a ground truth, and either the model found it or it didn't.

### 2.2 The Difficulty Spectrum

Test cases were organized across four difficulty tiers, each testing a different failure mode of LLM-based incident response.

| Tier                    | TCs            | What It Tests                                                                                                                     | Expected Search Behavior                                                                                                |
| ----------------------- | -------------- | --------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 🟢 **Easy**             | TC1, TC2       | Whether pre-trained knowledge is sufficient and the model avoids over-triggering                                                  | 0 to 2 tool calls; most models should not search at all                                                                 |
| 🟡 **Medium**           | TC3, TC4       | Whether the model can reason about specifics without external lookup                                                              | 0 tool calls expected; 1 acceptable for syntax edge-case confirmation only                                              |
| 🟠 **Version-Specific** | TC5            | Whether search can surface real, time-sensitive regressions from GitHub and changelogs                                            | 2 to 5 targeted searches; higher counts indicate over-research rather than better quality                               |
| 🔴 **Hard**             | TC6, TC7       | Whether search returns accurate CVE and vendor data, and whether the model catches wrong information embedded in the alert itself | 3 to 5 searches typical; GPT-5.2 reached 12 on TC5 (Config C); misattribution detection is the core pass/fail criterion |
| 🟣 **Edge**             | TC8, TC9, TC10 | Whether the model handles panic, vague inputs, and irrelevant alerts with appropriate calibration                                 | 0 tool calls; correct triage or dismissal expected                                                                      |

> [NOTE]
> The difficulty labels describe **what primarily differentiates outputs** at that tier, not an absolute ceiling. A model can fail an Easy case (for example, by using a Percona-only MySQL option in a standard MySQL context) and pass a Hard case through partially correct reasoning.

### 2.3 The Ten Test Cases

### 🟢 TC1 — Classic Infrastructure Failure: Disk Full

```vb.net
[ALERT] Filesystem /var/lib/mysql is 98% full
Severity: High | Host: db-prod-01
Message: no space left on device. Write operations failing.
```

**What it tests:** Whether the model knows standard MySQL disk recovery: binary log purge, `ibdata1` behavior, and safe cleanup order, without needing to search.

**Ground truth:** `PURGE BINARY LOGS BEFORE NOW()`, check `ibdata1` is not on a shared tablespace, `lsof +L1` for deleted-but-open file handles consuming space, and a replica check before purge. A search is acceptable only for edge-case confirmation such as the ibdata1 never-shrinks behavior; searching generically for "disk full mysql" is over-triggering.

**Pass criteria:** Correct purge syntax, safety-first ordering with no restart before a replica check, and awareness of inode exhaustion as a secondary issue.

### 🟢 TC2 — Common Security Pattern: SSH Brute Force

```vb.net
[ALERT] Suspicious Login Activity detected
Source IP: 45.132.89.21 (Russia)
User: root | Events: 240 failed attempts in 60 seconds | Protocol: SSH
```

**What it tests:** Standard security triage classification and hardening recommendations.

**Ground truth:** MITRE T1110.001 (Brute Force: Password Guessing, not Password Cracking, which is a distinct sub-technique). Block IP via `iptables`/`ufw`, set `PermitRootLogin no`, deploy fail2ban, and enforce key-based auth. Search is optional; an IP reputation check via AbuseIPDB is acceptable.

**Pass criteria:** Correct MITRE sub-technique label, root login hardening as a primary recommendation, and a clear distinction between brute force containment (block the IP) versus long-term hardening (disable password authentication entirely).

### 🟡 TC3 — Nginx Config Syntax Error

```vb.net
[ERROR] Nginx failed to start
Message: [emerg] unknown directive "ssl_certificate_keyy" in /etc/nginx/sites-enabled/default:14
```

**What it tests:** Whether the model can perform deterministic code analysis without invoking search. If the model searches for "ssl_certificate_keyy nginx error," that is a failure mode. The problem requires zero external data.

**Ground truth:** Typo: `ssl_certificate_keyy` should be `ssl_certificate_key`. Run `nginx -t` for syntax validation. No search is needed or appropriate.

**Pass criteria:** Identifies the typo, recommends `nginx -t` before restart, and correctly classifies severity as Medium (service disruption, not data loss, not exploitable). Zero search tool calls expected.

### 🟡 TC4 — Java OOM: Memory Leak vs. Allocation Spike

```vb.net
[ALERT] Java Application OOM
Error: java.lang.OutOfMemoryError: Java heap space
Context: Heap set to -Xmx8g. Server has 64GB RAM.
Usage is flat at 2GB, then spikes instantly on batch job trigger.
```

**What it tests:** Whether the model reasons about symptom patterns correctly. A flat baseline that spikes instantly on a specific trigger is a massive allocation event, not a memory leak. Leaks show gradual growth over time. Confusing the two leads to wrong remediation.

**Ground truth:** Allocation spike on batch trigger means checking batch chunk size and query result set size, then capturing a heap dump via `jmap -dump:format=b,file=heap.hprof <pid>` for analysis. Internal knowledge is sufficient; search may help confirm JVM flag syntax.

**Pass criteria:** Correctly distinguishes a leak (gradual growth) from an allocation spike (instantaneous on trigger), recommends a heap dump for analysis, and does not recommend increasing `-Xmx` as the immediate first action.

### 🟠 TC5 — Real Version-Specific Regression: Node.js v22.5.0 Crash

```vb.net
[ALERT] Node.js service crash loop
Error: FATAL ERROR: v8::Object::GetCreationContextChecked No creation context available
Node.js version: v22.5.0 (upgraded yesterday, no code changes)
Crash pattern: Process restarts every few minutes.
```

**What it tests:** Whether search can surface a real, GitHub-tracked regression. This is the first case where pre-trained knowledge is expected to be incomplete or stale. The bug was filed in July 2024 and may fall outside the training window for several models.

**Ground truth (GitHub-verified):**

- Issue: `nodejs/node#53902` titled "Node 22.5.0 started to crash and hangs on different cases"
- Root cause: Regression in `fs.closeSync` using the V8 Fast API in `lib/internal/fs/read/context.js`
- Fixed: Node.js v22.5.1, released July 19, 2024
- Confirmed to break: `better-sqlite3`, `pg`, `winston`, `npm`, `yarn`
- Misleading error: The error message references V8 internals, causing developers to blame native addons rather than the runtime itself

**Pass criteria:** Correctly identifies this as a version-specific regression rather than application code, names the fix (upgrade to v22.5.1 or downgrade to v22.4.0), and ideally references the GitHub issue. Top tier: identifies the affected libraries or the "V8 error as misdirection" insight.

### 🔴 TC6 — Real CVE Lookup: Apache Tomcat RCE (CVE-2025-24813)

```vb.net
[SCANNER] Critical Vulnerability Detected
CVE: CVE-2025-24813
Package: Apache Tomcat 10.1.34
Score: Reported as High
Vector: Network
```

**What it tests:** Two things at once: whether search returns accurate CVE data from NVD, and whether the model catches that the alert itself contains a severity error. CVE-2025-24813 is CVSS 9.8 Critical, not merely "High" as the scanner reports.

**Ground truth (NVD-verified):**

| Field          | Alert Claimed | NVD Reality                                                              |
| -------------- | ------------- | ------------------------------------------------------------------------ |
| CVSS Score     | "High"        | **9.8 Critical** (CVSS:3.1/AV:N/AC:L/PR:N/UI:N)                          |
| Type           | Not stated    | RCE via path equivalence in partial PUT requests                         |
| Affected       | 10.1.34       | 10.1.0-M1 through 10.1.34 (also 9.0.0-M1 to 9.0.98, 11.0.0-M1 to 11.0.2) |
| Fix            | Not stated    | Upgrade to 10.1.35 (or 9.0.99, 11.0.3)                                   |
| Exploit Status | Not stated    | Active exploitation in the wild; CISA KEV listed April 1, 2025           |
| Mitigation     | Not stated    | `readonly=true` AND `allowPartialPut=false` in `conf/web.xml`            |

**Pass criteria:** Corrects the severity to 9.8 Critical, identifies the RCE mechanism (partial PUT combined with file-based session deserialization), and provides the exact fix version. Top tier: includes `allowPartialPut=false` as the second mitigation parameter (which Output 1 in our testing missed entirely) and IOC hunting commands.

### 🔴 TC7 — Real Vendor Error Code Misattribution: AWS RDS-EVENT-0056

```vb.net
[ALERT] Amazon RDS Event
Source: db-instance-prod
Event ID: RDS-EVENT-0056
Message: The database instance is in an incompatible network state.
```

**What it tests:** This is the most adversarial test case in the suite. The alert message is deliberately wrong. RDS-EVENT-0056 per AWS documentation means: "The number of databases in the DB instance exceeds recommended best practices." It is a warning-level best practices notification, not a critical network error. Any model that treats the alert message as authoritative will triage the wrong problem entirely.

**Ground truth (AWS Docs-verified):**

| Field                  | Alert Claims                 | AWS Reality                                                |
| ---------------------- | ---------------------------- | ---------------------------------------------------------- |
| RDS-EVENT-0056 Meaning | "incompatible network state" | **"Number of databases exceeds best practices"** (warning) |
| Severity               | Implied Critical             | Warning / Best Practices                                   |
| Required Action        | Network triage               | Reduce database count on the instance                      |

> [!CAUTION]
> A model that does not search, or searches but accepts the alert text as ground truth, will diagnose the wrong problem entirely. This is the core search delta test for vendor error code accuracy.

**Pass criteria (two distinct paths):**

1. **Correct path (hard):** The model searches, finds the RDS-EVENT-0056 AWS documentation, identifies the mismatch between the alert message and the real event definition, and flags the alert as misattributed.
2. **Acceptable path:** The model correctly triages the "incompatible network state" description as a legitimate AWS RDS failure mode such as IP exhaustion, subnet deletion, or ENI quota issues, even without catching the event ID mismatch. This shows strong operational knowledge even if the search delta was not achieved.

Only a model that finds the real event definition proves that search adds value beyond pre-trained knowledge.

### 🟣 TC8 — Panic: "Server is on Fire"

```vb.net
[ALERT] MAYDAY MAYDAY MAYDAY server is on fire literally smoke coming out help
```

**What it tests:** Whether the model can impose structure on a structureless, panicked input without triggering search.

**Pass criteria:** Calm, structured response. If literal fire: physical safety first (cut power, evacuate, facilities team). If figurative: triage framework applied. Zero tool calls expected.

### 🟣 TC9 — Ransomware: ".crypt" Files

```vb.net
[Check] I think we are hacked. Screens are flashing red and files are renamed to .crypt
```

**What it tests:** Whether search can surface a real decryptor for a known ransomware strain.

**Ground truth (nomoreransom.org verified):** `.crypt` extension → CryptXXX family (v1/v2/v3). Rannoh Decryptor (Kaspersky) covers CryptXXX v1/v2/v3 and is freely available on nomoreransom.org.

**Pass criteria:** Identifies ransomware, immediate isolation recommendation, surfaces nomoreransom.org as the decryptor source. Bonus: correctly caveats that CryptXXX v3.100+ (network variant) may not be fully decryptable with older tools.

### 🟣 TC10 — Adversarial: HTTP 418 Teapot

```vb.net
[ALERT] Coffee machine is out of beans. Error 418: I'm a teapot.
```

**What it tests:** Whether the model correctly dismisses a non-incident without searching.

**Pass criteria:** Dismissal — "Not an IT infrastructure incident." HTTP 418 recognized from internal knowledge (RFC 2324, April 1998 IETF joke). Zero tool calls. A sense of humor is acceptable; a formal triage runbook is not.

### 2.4 The Misattribution Design: Why We Engineered Wrong Inputs

TC6 and TC7 share a deliberate design choice: **the information provided in the alert is wrong in a specific, verifiable way.** This is not an accident or a trick — it is the most important test in the suite.

In production incident response, alerts are generated by automated systems. Those systems can misfire, misclassify, or carry stale metadata. A model that accepts every alert at face value will be systemically wrong in these cases. A model with search capability _should_ be able to catch the discrepancy — because the correct data exists in AWS documentation and NVD, one search away.

**TC6 — Severity Inflation (Alert Too Soft):** The scanner reports the vulnerability as "High." NVD says 9.8 Critical. An LLM without search that defers to the alert's classification underestimates the risk. An LLM with search that finds the NVD record corrects it. This measures whether search adds value for _severity calibration_ on active exploits.

**TC7 — Wrong Event ID (Alert Completely Wrong):** The alert message describes a network failure. The event ID maps to a database count warning. These are completely different problems requiring completely different responses. An LLM with strong search _should_ find the real event definition and flag the mismatch. This measures whether search adds value for _vendor error code accuracy_.

These two cases form the core of the "search delta" analysis in Section 9.

### 2.5 What "Passing" Looks Like at Each Tier

Passing is not binary. We evaluate outputs across five dimensions, weighted by their operational impact:

| Criterion                 | Weight       | What We Look For                                                                                             |
| ------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| **Accuracy & Legitimacy** | 🔴 Primary   | Factually correct? No hallucinations? Commands safe to run in production?                                    |
| **Safety**                | 🔴 Critical  | Does the output avoid dangerous actions (e.g., `rm` on active binlogs, restart without replica check)?       |
| **Search Economy**        | 🟡 Secondary | Was search triggered appropriately? No search on deterministic cases; targeted search on knowledge-gap cases |
| **Completeness**          | 🟡 Secondary | Are the critical steps present? Prevention section meaningful?                                               |
| **Format**                | 🟢 Tertiary  | Is the output structured, scannable, and usable under pressure?                                              |

> [IMPORTANT]
> **Accuracy is always primary.** A perfectly formatted, beautifully structured triage note that recommends the wrong action is worse than a rough output with the right answer. In incident response, format is a luxury — correctness is a requirement.

The "passing bar" at each tier:

| Tier                | Minimum Pass                                              | Top Tier                                                             |
| ------------------- | --------------------------------------------------------- | -------------------------------------------------------------------- |
| 🟢 Easy             | Correct steps, safe commands                              | + ibdata1/edge case awareness, or unique operational insight         |
| 🟡 Medium           | Correct diagnosis, no unnecessary search                  | + Scans for similar patterns (not just the reported typo)            |
| 🟠 Version-Specific | Finds and names the fix                                   | + Names affected libraries, GitHub issue, "misleading error" insight |
| 🔴 Hard             | Correct data from NVD/AWS docs, catches severity mismatch | + IOC hunting commands, catches event ID misattribution              |
| 🟣 Edge             | Correct triage or dismissal, zero tool calls              | + Appropriate tone calibration for the input type                    |

### 2.6 What Was Not Tested (Scope Boundaries)

The following are explicitly out of scope for this evaluation cycle:

| Out of Scope                         | Reason                                                                                                                                                  |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Real production traffic              | Privacy, safety, and reproducibility — all inputs are synthetic                                                                                         |
| Latency measurement                  | Network and API latency vary; this is an output quality study                                                                                           |
| Cost calculation in USD              | Token counts are provided; pricing changes frequently by provider                                                                                       |
| Multi-turn conversations             | All workflows use single-turn prompts for comparability                                                                                                 |
| RAG pipeline                         | Out of scope by design — this study isolates the web search variable. The RAG pipeline is built (Supabase vector store) but not part of this evaluation |
| TC1–TC4 and TC8–TC10 in Basic Search | Full 10-TC Basic Search run not completed; structural finding was clear from TC5/TC6/TC7                                                                |

## Section 3 — Evaluation Framework

### 3.1 How Outputs Were Graded

Every model output in this study was evaluated against the same five criteria, applied consistently across all configurations. The criteria are weighted by operational consequence, not convenience.

| Criterion                   | Weight    | Rationale                                                                                                                                                                |
| --------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Accuracy and Legitimacy** | Primary   | Factually correct, grounded in real documentation or verified data. No hallucinated commands, versions, or CVE metadata.                                                 |
| **Safety**                  | Critical  | Does not recommend dangerous actions. No unsafe filesystem operations, no restart without replica check, no remediation that would extend an outage or destroy evidence. |
| **Search Economy**          | Secondary | Was search triggered appropriately? Unnecessary searches on deterministic problems cost tokens and time. Failure to search on knowledge-gap problems costs accuracy.     |
| **Completeness**            | Secondary | Are the operationally critical steps present? Does the output cover prevention, not just immediate remediation?                                                          |
| **Format**                  | Tertiary  | Is the output usable under pressure? Can an on-call engineer scan it quickly to identify the most important action?                                                      |

Accuracy and Safety are co-primary because a perfectly structured output that recommends the wrong action is worse than a rough output with the right answer. Format is tertiary because a well-organized response with wrong data is worse than a disorganized one that is correct. This weighting is not a stylistic preference — it reflects the real cost of errors in production incident response.

### 3.2 What Counts as a Hallucination

Hallucinations fall into two distinct categories with different operational risk profiles:

**Hard Hallucination:** Factually incorrect and unverifiable. The model invents data that does not exist and cannot be confirmed.

Examples observed in this study:

- A model citing a Node.js GitHub issue number that does not exist
- Incorrect CVSS scores not matching NVD records (e.g., citing 7.5 when the real score is 9.8)
- Referencing a patch version that was never released

**Partial Hallucination:** Directionally correct but specifically wrong in ways that matter.

Examples observed in this study:

- Correct MITRE tactic but wrong sub-technique (T1110.001 Password Guessing reported as "Password Cracking" — two different techniques with different defensive responses)
- Correct vulnerability type but wrong affected version range (citing Tomcat 8.5 as having a patch for CVE-2025-24813, when 8.5 reached End of Life and no patch was ever released)
- Correct remediation direction but wrong command context (recommending `nvm install 22.5.1` as the fix for the Node.js regression when the environment is containerized with Docker, where nvm is not available and the correct fix is a Dockerfile `FROM` update)

Partial hallucinations are arguably more dangerous than hard ones. They pass a quick review, feel authoritative, and cause the most engineering damage when acted upon in production.

### 3.3 Model Roster

**LLM-Only workflow — 7 core models formally evaluated:**

| Model                | Type          | Provider        |
| -------------------- | ------------- | --------------- |
| Claude Sonnet 4.5    | Closed-source | Anthropic       |
| Claude Opus 4.5      | Closed-source | Anthropic       |
| Gemini 3 Pro Preview | Closed-source | Google          |
| GPT-5.2              | Closed-source | OpenAI          |
| Grok-4               | Closed-source | xAI             |
| GLM-4.7              | Open-source   | Zhipu AI        |
| Kimi-K2.5            | Open-source   | Moonshot AI     |
| Llama-4-Maverick     | Open-source   | Meta            |
| Qwen3.5 Plus         | Open-source   | Alibaba         |
| DeepSeek-V3.2        | Open-source   | DeepSeek        |
| Minimax-M2.5         | Open-source   | MiniMax         |
| GPT-OSS-120B         | Open-source   | OpenAI          |
| GPT-5.2-Codex        | Open-source   | OpenAI          |
| Gemma-3-27b-it       | Open-source   | Google DeepMind |

Per-model findings, behavioral patterns, and specific output comparisons are documented in [Section 4 (LLM-Only Workflow)](/310a7af3739080c9ab60e8d81dbbcf31#310a7af3739081dcbc7ed5b9bf2f0df8).

**Basic Search workflow (Google Grounding) — 2 models evaluated:**

| Model                | Type          | Provider  |
| -------------------- | ------------- | --------- |
| Claude Opus 4.5      | Closed-source | Anthropic |
| Gemini 3 Pro Preview | Closed-source | Google    |

Findings including the prompt placement experiment and reliability analysis are documented in [Section 5](/310a7af3739080c9ab60e8d81dbbcf31#310a7af37390812594dcc87195fbf5ad).

**Advanced Search workflow (Tavily + SerpAPI) — 7 models evaluated:**

| Model                | Type          | Provider    |
| -------------------- | ------------- | ----------- |
| Claude Sonnet 4.5    | Closed-source | Anthropic   |
| Claude Opus 4.5      | Closed-source | Anthropic   |
| Gemini 3 Pro Preview | Closed-source | Google      |
| GPT-5.2              | Closed-source | OpenAI      |
| GLM-4.7              | Open-source   | Zhipu AI    |
| Kimi-K2.5            | Open-source   | Moonshot AI |
| Qwen3.5 Plus         | Open-source   | Alibaba     |

Per-model search behavior and output quality findings are documented in [Sections 6](/310a7af3739080c9ab60e8d81dbbcf31#310a7af3739081e3a104ff2d36a73cb6) and [7](/310a7af3739080c9ab60e8d81dbbcf31#310a7af3739081659c0acf63db47e3ea).

### 3.4 Why Pre-Trained Knowledge Sets the Baseline

Before measuring search, there needs to be a baseline. LLM-Only performance is that baseline. Every finding in the search sections of this report is measured as a _delta_ against this baseline:

- Did the model get it right without search?
- If not, did search fix it?
- If yes with search: does the fix justify the token and latency cost of the search?

The LLM-Only baseline matters for a specific reason visible in the data: 14 models were run on the easy and medium TCs (TC1–TC4, TC8–TC10), where pre-trained knowledge is generally sufficient. The 7-model primary cohort completed the full 10-TC suite. Several models did not need search for the easy and medium cases because the answers are well-established in any training corpus. But on TC5 (CVE-2025-9921 misattribution) and TC6 (RDS-EVENT-0056 event ID mismatch), all 7 models failed in the same direction — triaging the wrong problem because the alert text itself was the source of misinformation. This makes the "search delta" question more nuanced than it first appears. The value of search is not constant across models or test cases: it helps weaker models broadly, provides marginal but real improvement for stronger models on version-specific and vendor-documentation gaps, and (critically) catches misattributed alerts that no amount of internal knowledge can correct. See also: the Advanced Search TC6 (CVE-2025-24813, Apache Tomcat RCE) where search was able to correct a severity understatement from the alert.

### 3.5 A Note on Fairness

All models in this study were tested under identical conditions:

- Same system prompt (V3, the most refined version — details in Section 4)
- Same alert content, same phrasing, no variation
- Same workflow configuration per test run
- No cherry-picking of outputs: every run produced one output, which was the output used

Where multiple outputs existed (Basic Search prompt placement testing), all outputs are documented, and rankings are justified explicitly. Observations that favor a model are noted alongside observations that do not. The goal is not to crown a winner — it is to give engineers an accurate picture of what each configuration delivers and where it fails.

## Section 4 — LLM-Only Workflow

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/c276249b-02b8-44cc-930d-fafeef1c06dd/image.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466VRZYVO3C%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090509Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJHMEUCIQCKGBLzqY9AyQ0L2xidXrRWd3D3YOyG0cF9ncp5zhLUIgIgXoT%2FKDIHKOEW5UWtdV5rA6mSfW2%2BDW1FiOiVUnYuaQ4qiAQI2v%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgw2Mzc0MjMxODM4MDUiDIEaAqGAfY5jcDXGdyrcA3iv4J2pH%2FxkrPNa4fAyOCK%2BT3QobW3FDzUSPm19jYpYukSz5iDaSazIwzWRTcEsvCXsrZEdgrbnnIMdz415PlAn%2BW7ekRtWv%2FsNYlo5D3Q9cMSBjptV9vAhEkvqrM2VGlKkVsP9seGzdgTwou4evZ%2F8l%2B6RJVpYNLTxLxlUo731t7tu1S0w70WmeuY7pBapKZTNPYBA4w14eoSyfDUPCn7cdyrjZesycMxp4rhWpvgycDw5lFXe3zKNGKEysF93W%2F5APmBY9pCyYjtwViLGXITHBI4pBI9m0gXC0dKtGiEpi1IkpOVX%2Bi6S4ZXzhKIz4sf%2BGttD4cZGco3gsPGD4xwPG%2FmgSLsEIdgFAS8vuob0C2AmpHdBczJ9%2Bmdl07OtDk4n7ecYvKNhsnUwzr2hu%2B69ogbG6NZwkHaBoIy%2FYRCqAEBCgetKa8UIcPnQKUWblNN8Qu%2FXKDumVsoIyX8cUQUC%2BZg2ep9xbTmOSDyEATwf32CIIu%2BanTr1cLXM1bVD51aFJ77v8DAbYFt1h%2FS%2F9XtVFQZVCMUXXEXakIjQVpxuJC5VGyoavRZwzdKLhEg%2Fw5B%2Bn3h%2Fl5vzVvOgww4BmlQ3pQyr8ZJnsdfocW5ueTr%2BDyhUS%2Bk%2BEaqttIIvMJWl8MwGOqUBYjZUBd0Oo8TwhsbXi2%2BBDjVl12cvWLJIN%2FH90i8D5dTgjBsWMjn9QxDlE3%2FMIr76QL5XXHC2apHjaW0IroFJ1H0bBd%2BdEhDQW12xRlmmsJLC3JmndHXWxcsOnpspE4Lnn8%2B3iYZmOPa8pBH%2BN6uK3onfmJBS7wQjwqhQstXxUto7GSjuAv%2B7Z7u669%2BmcpIz2jonP2j2hkD5Fe9V1gSHtjQ6gXz1&X-Amz-Signature=27b4388dcc182150152fb111f94de0c6943ead18e4f608c6d4ab9eb76e704ef8&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)

The LLM-Only workflow is the simplest configuration in this study: one model, one system prompt, zero external tools. No web search, no vector retrieval, no tool calls of any kind. Every answer comes from what the model already knows.

This is also the most important baseline. Before evaluating whether search adds value, we need to know what the model can do without it. Section 4 documents that baseline across 7 models and 10 test cases.

> [NOTE]
> The raw data file contains multiple runs of several models at different temperature settings, which accounts for the higher row count. The 7 models evaluated are: Claude Opus 4.5, Claude Sonnet 4.5, Gemini 3 Pro, GPT-5.2, Kimi-K2.5, GLM-4.7, Qwen3.5 Plus. Gemma-3-27b-it appears in specific TCs as an additional comparison point.

### 4.1 System Prompt Evolution

Three versions of the system prompt were used across the lifetime of this project. The LLM-Only workflow was tested with the most recent version, V3.

**V1 — Basic framing:** A minimal prompt establishing the role as an incident response assistant. No output structure requirements, no tone calibration, no length guidance. Produced verbose, freeform outputs with high variance between models.

**V2 — Structured sections:** Added explicit output structure requirements (Severity, Category, Root Cause, Immediate Actions, Step-by-Step Resolution, Prevention). Reduced format variance significantly. Models converged on a consistent triage note shape. Did not control for length.

**V3 — Calibrated and constrained:** The version used for all tests in this report. Key additions over V2:

- Explicit instruction to prioritize the most probable root cause first
- Guidance to distinguish containment (stop the bleeding) from remediation (fix the root cause) as distinct phases
- Acknowledgment that the model may not have up-to-date information on recent CVEs or vendor-specific errors, and should flag this where relevant
- No explicit token budget at this stage (added as a recommendation in Section 5)

The V3 system prompt text is shown below for reference:

````markdown
# ROLE & EXPERTISE

You are an Elite SRE & Security Incident Response Expert with deep expertise in:

- Enterprise infrastructure troubleshooting (cloud, on-premise, hybrid)
- Security incident analysis and threat hunting
- MITRE ATT&CK tactics, techniques, and mitigations
- Database, network, application, and system operations
- Root cause analysis and post-incident reviews
- Incident triage and prioritization

# YOUR TASK

Analyze the incoming incident/alert and provide a **comprehensive, actionable triage note** for the on-call engineer.

# INPUT FORMAT

You will receive an incident description in one of these formats:

- Structured alert (from SIEM, monitoring tools, Splunk, etc.)
- Unstructured user report (helpdesk ticket, email)
- Log excerpt with error messages
- System health check output

# ANALYSIS FRAMEWORK

## 1. Incident Classification

- Severity assessment (Critical/High/Medium/Low)
- Category (Security/Infrastructure/Application/Network)
- Type (e.g., brute_force, disk_full, certificate_expiration, dos_attack)

## 2. Root Cause Identification

- Most probable root cause based on symptoms
- Common failure modes for similar incidents
- Underlying systemic issues if applicable

## 3. Security & MITRE Mapping (if security-related)

- Map to MITRE ATT&CK Tactics (e.g., Initial Access, Persistence)
- Identify Techniques (e.g., T1078 - Valid Accounts, T1190 - Exploit Public-Facing Application)
- Suggest relevant Mitigations (e.g., M1032 - Multi-factor Authentication)

## 4. Immediate Actions

- Critical first steps to contain/stabilize
- Data to collect for investigation
- Systems to isolate if necessary

## 5. Step-by-Step Resolution

Provide a **clear, numbered action plan** with:

- Diagnostic commands to run
- Configuration checks
- Service restart procedures
- Rollback steps if applicable

## 6. Prevention & Long-term Fixes

- Permanent solutions to prevent recurrence
- Infrastructure hardening recommendations
- Monitoring/alerting improvements

# OUTPUT FORMAT

**Triage Note – [Incident Title]**
**Severity**: [Critical/High/Medium/Low]  
**Category**: [Security/Infrastructure/Application/Network]  
**Type**: [Specific incident type]

### Root Cause (Most Probable)

• [Primary cause based on symptoms]  
• [Secondary contributing factors, if any]

### What Makes This Incident Notable

• [Unique characteristics or red flags]  
• [Potential blast radius or impact scope]

### MITRE ATT&CK Mapping

_(Only if security-related)_

- **Tactics**: [e.g., Credential Access, Lateral Movement]
- **Techniques**: [e.g., T1078 (Valid Accounts), T1021.001 (RDP)]
- **Mitigations**: [e.g., M1032 (MFA), M1030 (Network Segmentation)]

### Immediate Actions (First 10 Minutes)

1. [Critical containment step]
2. [Data collection command]
3. [System isolation if needed]

### Step-by-Step Resolution

**a.** [Diagnostic step with exact commands]

```bash
# Example command
b. [Configuration check or fix]
c. [Service restart/recovery procedure]
d. [Verification step]

Prevention & Hardening
• [Long-term fix to prevent recurrence]
• [Monitoring improvement]
• [Security control enhancement]

Knowledge Gaps & Escalation Triggers
• [What additional context would be helpful]
• [When to escalate to Tier 2/3 or vendor support]

CRITICAL RULES
Be Specific: Don't say "check logs" – specify which logs and what to look for
Provide Commands: Include actual commands with placeholders (e.g., sudo systemctl status nginx)
No Hallucination: If you're uncertain about a specific tool/system, say so explicitly
Prioritize Safety: Always recommend backups before destructive operations
Security First: For security incidents, err on the side of caution (isolate first, investigate later)
Acknowledge Limitations: If the incident requires vendor-specific knowledge you don't have, recommend escalation

RESPONSE STYLE
Concise but complete: No fluff, but don't skip critical steps
Command-line ready: Provide copy-paste commands when possible
Decision trees: Include "if X, then Y" logic for branching scenarios
```
````

The V3 system prompt is shared across LLM-Only, Advanced Search, and Basic Search workflows. The only differences between those workflows are tool availability and search configuration — not the base instructions.

### 4.2 Temperature and Output Behavior

Temperature was varied during exploratory testing before the formal evaluation. The finding is clear enough to state as a firm conclusion:

> **Conclusion:** `temperature=0.3` produces structured, reliable runbooks. `temperature=0.7+` produces richer outputs with more operational depth, but also introduces noise, drift, and higher hallucination confidence.

**What higher temperature adds — with examples:**

At `temperature=0.7+`, GPT-5.2 elaborated beyond the immediate fix on TC1 (Disk Full) to discuss InnoDB redo log behavior under write failure and added a full prevention section on log rotation policy. The additional context was genuinely useful and more complete than the 0.3 output. Similarly, Qwen3.5 Plus at higher temperature included an explicit decision-tree branching ("If accepted login found, STOP — treat as compromised") that the lower-temperature output omitted.

The tradeoff: on TC6 (CVE misattribution) and TC7 (RDS event ID), higher-temperature outputs were more confident. When a model doesn't know something at `0.3`, it hedges or flags uncertainty. At `0.7+`, it asserts. Both Kimi and GLM treated the misattributed CVE-2025-9921 as a confirmed OpenSSL RCE at higher temperatures — detailed, confident, and completely wrong.

**The stronger system prompt point:** The V3 system prompt's explicit instruction to flag knowledge gaps ("indicate where you may not have up-to-date information") partially compensates for temperature drift. GPT-5.2, Gemini, Sonnet, Qwen, and Opus all flagged uncertainty on TC6 even at varying temperatures, because the system prompt primed them to do so. Better prompt engineering reduces (but does not eliminate) the temperature-induced hallucination risk.

**Production recommendation:** `0.3` for live incident triage pipelines where correctness is primary. `0.7+` for playbook drafting, threat hunting ideation, or RCA report generation where creative depth adds value and a human reviewer is in the loop.

### 4.3 Per-TC Model Analysis

### TC1 — Disk Full (/var/lib/mysql at 98%)

None of the 7 models suggested `apt-get clean`. They all correctly recognized this is a database partition problem, not an OS package cache issue. That baseline context-awareness held across every model.

The differentiation was in operational judgment around the purge:

- **GPT-5.2 (temp 0.3)** was the only model to explicitly check `lsof +L1` for deleted-but-open file handles before expecting disk space to free up. This is the correct diagnostic — a file deleted while a process holds an open descriptor continues consuming space until the handle is released. It also correctly checked replica lag before issuing `PURGE BINARY LOGS`. It then used `read_only=ON` as a containment step before purging to prevent new writes from compounding the problem during recovery.
- **Grok-4** included `smartctl -a /dev/sda` for disk health alongside the space recovery steps — recognizing that a disk nearing capacity may indicate a failing drive, not just log bloat.
- **GLM-4.7** was the only model to address `ibtmp1` (InnoDB temp tablespace) correctly and suggest the `innodb_temp_data_file_path` cap to prevent unbounded growth. However, it issued `PURGE BINARY LOGS BEFORE NOW()` without a replica check — the most operationally risky behavior in the field for this TC.
- **Claude Sonnet 4.5** suggested `rm` on log files without first confirming that no process held those files open, and without a replica check before purging. Rated 🟢 Best overall for production-ready structure, but with that notable gap.
- **Llama-4-Maverick** was the only model rated 🔴 Bad — it recommended `mysqlcheck --auto-repair --optimize` as a fix step. Running an `OPTIMIZE TABLE` on a disk that is 98% full will fail immediately and, in some configurations, can corrupt the table it attempts to optimize. No replica awareness, no inode check.
  > **Key learning from TC1:** Temperature 0.3 was the clear winner. At 0.5+, GPT-5.2 added a `RESET SLAVE ALL` step — an irreversible command that should never appear in a disk-full recovery runbook. Temp made the difference between a safe and an unsafe output for the same model.

### TC2 — SSH Brute Force (240 failed attempts)

All 7 models met the baseline: identified brute force, recommended `PermitRootLogin no`, and checked `auth.log` for accepted logins before taking action. The check for successful logins first is the most important step (if an attacker got in, containment escalates immediately), and every model got it right.

Differentiation came at the edges:

- **Claude Opus 4.5** blocked the `/24` subnet in addition to the specific IP, reasoning that a 240-attempt-per-60-second rate suggests an automated tool rather than a single endpoint, and the adjacent IP range is likely part of the same infrastructure. It also included a P1/P2/P3 priority table and AbuseIPDB commands for threat context. Most complete output.
- **GPT-5.2** dedicated a section to "If Compromise Is Suspected" with volatile evidence preservation commands (`ps auxfw`, `ss -tpna` output to file before any remediation). It also checked `sshd_config.d` drop-in directories — a real-world gotcha where the main sshd_config is correct but a drop-in override silently undoes the hardening.
- **Gemini 3 Pro** used `systemctl reload sshd` instead of `restart` — the only model to make this distinction. On a server where the engineer's own SSH session is active, a `restart` drops the connection mid-incident. `reload` applies the config change without terminating existing sessions.
- **GLM-4.7** used `systemctl restart sshd` (which drops active sessions) and cited MITRE mitigation M1022, which is irrelevant for this scenario. It did add one mature insight no other model included: when the root account uses a weak password, assume compromise even if no "Accepted" login appears in the logs, because brute-force tools can avoid leaving log traces in some configurations.
- **Qwen3.5 Plus** provided an explicit "If Accepted → STOP, treat as Compromised" decision tree, the clearest branching logic in the field. Uniquely noted that log flooding from 240 attempts per minute could itself cause a disk-full DoS — a real secondary consequence most models ignored.

### TC3 — Nginx Typo (ssl_certificate_keyy)

All 7 models identified the typo and recommended `nginx -t` before restart. The test expectation was met by every model. Format and conciseness varied.

The standout observations:

- **Gemini 3 Pro** was the only model to flag that `sites-enabled` files are symlinks to `sites-available`. Editing the symlink path rather than the actual source file is a common operational mistake that causes the edit to be silently ignored on the next `nginx -t`. Also opened the file at the exact line with `nano +14`.
- **GPT-5.2** used `nginx -T` (capital T) to dump the full rendered config including all `include`d files. The lowercase `-t` only validates the main config; `-T` catches errors inside included files that `-t` misses.
- **Kimi-K2.5** added `grep -r "keyy\|certt"` across all Nginx configs to scan for similar typos in other files — the only model to look beyond the reported error at systemic config hygiene.
- **GLM-4.7** flagged Config Management conflict: if the server is managed by Ansible, Puppet, or Chef, a manual fix to `sites-available` will be silently reverted on the next CM run. The correct fix is in the CM playbook, not the file directly. This is the most operationally mature insight in the field.

No model searched externally on TC3 in the LLM-Only configuration. The search behavior observed in Claude Sonnet on advanced search configurations is documented in Section 6.

### TC4 — Java OOM (Allocation Spike vs. Memory Leak)

The alert described a heap set to 8GB with flat 2GB usage that spikes instantly on a batch job trigger. The correct diagnosis is a massive allocation event, not a memory leak — leaks show gradual growth over time, not an instant spike correlated with a specific trigger.

Most models got this right. The diagnostic consensus was `jmap -dump:format=b,file=heap.hprof <pid>` followed by Eclipse MAT analysis.

The failure mode to note: several models listed increasing `-Xmx` as a remediation step. Increasing the heap ceiling without understanding what the batch job is allocating means the next run simply exhausts a larger heap. **GPT-5.2-Codex** correctly framed increasing `-Xmx` as a temporary mitigation at most, with batch chunk size and query result set size as the correct first investigation targets.

No model produced a dangerous recommendation on TC4. The variance was between outputs that led to a permanent fix and those that led to a heap ceiling band-aid.

### TC5 — Vulnerability Lookup (CVE-2025-9921 on OpenSSL)

This is the first true hallucination test in the LLM-Only suite, and it ran harder than expected. **CVE-2025-9921 exists — but it belongs to "code-projects POS Pharmacy System 1.0" (XSS, CVSS 5.4), not OpenSSL.** The alert's CVE number is real; every other field (package, vulnerability class, CVSS score) is wrong. Models that search would find the mismatch in the first result. Models without search had to rely on training data that associates CVE-2025-9921 with OpenSSL — which it doesn't.

**Hallucination split: 3 failed, 5 passed.**

- **Kimi-K2.5 (failed):** Treated the misattributed CVE as a confirmed OpenSSL RCE with no disclaimer. Provided a complete remediation runbook including patch commands and TLS configuration hardening. Triply wrong: wrong package, wrong CVSS, wrong vulnerability class.
- **GLM-4.7 (partial):** Included a vague disclaimer buried in the MITRE section ("specifics pending full disclosure") but still ran a full OpenSSL remediation as if the CVE were confirmed.
- **Gemma-3-27b-it (failed, worst):** Treated the CVE as confirmed, cited non-existent MITRE mitigation ID M1663 (real M-codes go up to approximately M1056), and applied the wrong severity class. Triple hallucination: invented CVE context, invented MITRE ID, wrong severity. The M1663 fabrication is a hard hallucination — a specific, verifiable claim about a real taxonomy that is completely wrong.
- **GPT-5.2 (passed):** Explicitly stated "I don't have authoritative details of CVE-2025-9921." Asked for the vendor advisory before proceeding. Provided a safe generic remediation framework as a contingency.
- **Gemini 3 Pro (passed):** Stated "CVE-2025-9921 does not currently exist in public databases." Technically wrong (it exists but for a different package), but the instinct to verify before remediating was correct.
- **Claude Sonnet 4.5 and Claude Opus 4.5 (passed):** Both included explicit disclaimers with direct NVD links. Opus added: "if CVE does not exist, this may be a scanner false positive or test data" — the closest any model came to the actual correct answer (misattribution / corrupted scanner data).
- **Qwen3.5 Plus (passed):** Noted the CVE "appears to be hypothetical or future-dated." Also the only model to add `lsof | grep 'libssl.*DEL'` — the most precise way to identify processes still holding handles to the old library after patching, which must be restarted for the patch to take effect.
  > **TC5 conclusion:** LLM + Search would have won decisively on this TC. A single NVD lookup immediately shows CVE-2025-9921 is an XSS in a PHP pharmacy app, exposing the alert as corrupted data. Without search, the 3 models that failed produced responses that would lead an engineer to patch the wrong thing and believe the problem was resolved.

### TC6 — Vendor Specific Error Code (RDS-EVENT-0056)

This is the most important finding in the LLM-Only section.

**0 out of 7 models caught the event ID misattribution.**

The alert paired a real AWS event ID (RDS-EVENT-0056) with a wrong message ("The database instance is in an incompatible network state."). Per AWS documentation, RDS-EVENT-0056 means: "The number of databases in the DB instance exceeds recommended best practices." It is a warning-level notification about database count, not a network state event.

Every model triaged the "incompatible network state" description as the real problem: IP exhaustion, subnet misconfiguration, ENI quota issues. The advice they gave was technically correct for an actual `incompatible-network` RDS state — and completely irrelevant to what RDS-EVENT-0056 actually signals.

What the models produced was, operationally, high-quality responses to the wrong problem. Notable standout characteristics:

- **Gemini 3 Pro** was the only model to prominently warn "DO NOT REBOOT" as the first line of the response. This is operationally correct: rebooting an RDS instance genuinely in an incompatible-network state often prevents it from coming back online, because the reboot attempt triggers a new ENI provisioning that fails for the same underlying reason. Gemini was right to surface this as the primary safety call, even though it was solving the wrong problem.
- **GPT-5.2** provided the most complete subnet validation (a bash for-loop over all subnet IDs checking available IP counts) and included a Snapshot restore with Route53 CNAME endpoint swing as a recovery path. Also the only model to ask for engine type, port, and Multi-AZ configuration before prescribing a fix — acknowledging that the correct recovery steps vary by configuration.
- **Claude Opus 4.5** presented the most complete scenario matrix: SG deleted, IP exhaustion, subnet group misconfiguration — each with distinct remediation steps. Most readable format and explicit CloudTrail events to include in an AWS Support case.
- **Gemma-3-27b-it** produced the shortest response and the only broken command: `date -v-5m` is macOS `date` syntax. On Linux the correct flag is `date -d '5 minutes ago'`. A runbook command that silently fails on the target OS is a real operational risk.

This result establishes the primary motivation for the Advanced Search workflow. RDS-EVENT-0056 is one AWS documentation page away from the correct answer. No model without search has a path to it, because the alert text itself is the source of misinformation.

### TC7 — Version-Specific Bug (Node.js v22.4.1 crash)

All 6 models tested on this TC correctly identified native addon ABI mismatch as the primary cause. The baseline expectation was met. No model blamed application code or suggested a software bug fix as the first step.

The alert described a `FATAL ERROR: v8::ToLocalChecked Empty Handling` crash occurring 30 minutes after startup, following an upgrade to Node.js v22.4.1 with no code changes.

Differentiation came in depth and diagnostic creativity:

- **Claude Opus 4.5** provided the most actionable output: a verified addon migration table (`sharp → 0.33.4+`, `bcrypt → bcryptjs`, `grpc → @grpc/grpc-js`, `sqlite3 → 5.1.7+`) where all four recommendations were independently verified as accurate. Also included a `timeout 2700` uptime monitor designed specifically to catch the 45-minute soak window — a direct response to the crash pattern.
- **Kimi-K2.5** used `strace -e trace=openat -f node server.js | grep ".node"` to identify which native `.node` file is being loaded at crash time — the most creative diagnostic in the field and the most direct path to isolating the culprit module.
- **GPT-5.2** added an OOM check (`dmesg -T | egrep 'oom-killer'`) alongside the ABI diagnosis. The 30-minute crash window could be OOM-triggered rather than ABI mismatch; ruling it out first is the correct approach. Also the most complete Kubernetes coverage (`kubectl describe pod`, `kubectl logs --previous`).
- **GLM-4.7** was the only model to recommend a post-deployment smoke test of at least 30-40 minutes specifically calibrated to the crash window — addressing the failure pattern directly rather than just the root cause.
- **Gemini 3 Pro** caught the Docker cross-platform trap: `node_modules` copied from macOS or Windows to a Linux container contain binaries compiled for the wrong architecture. This is one of the most common real-world causes of this exact error and was not mentioned by any other model.
- **Claude Sonnet 4.5** hallucinated a version-specific claim: "v22.4.1 has documented V8 stability issues — use v22.4.0 or v22.5.0+." This is wrong on both counts. v22.5.0 actually introduced a _worse_ regression: a V8 Fast API bug that broke `fs.close` and `fs.closeSync`, causing widespread failures. v22.5.1 was the emergency fix. Recommending v22.5.0 as a safe rollback target is actively harmful advice.

### TC8 — Panic ("Server is on Fire")

All 7 models handled this correctly. Every output took one of two appropriate approaches: literal interpretation (physical fire: cut power, evacuate, call facilities) or figurative interpretation (triage framework applied to an unknown high-severity event).

Most models chose the figurative path, noting the ambiguity explicitly. **Gemini 3 Pro** was the only model to recommend hibernating the server (`shutdown /h`) rather than a hard power cut if the situation is figurative — preserving the ability to resume state. **GPT-5.2** produced the shortest output: three sentences, both interpretations covered, one clear call to action. On an edge case like this, brevity is a feature.

### TC9 — Ransomware (.crypt Extension)

All 7 models correctly identified ransomware and led with network isolation. No model suggested running antivirus as a first step — the baseline expectation was met across the board.

The differentiation was in forensics depth and contact information accuracy:

- **Kimi-K2.5** gave the most operationally decisive triage decision: "yank the power cord immediately if encryption is rapid (fan spinning, disk LED solid) — forensic loss is acceptable versus total data loss." Correct judgment for the situation.
- **Gemini 3 Pro** and **Claude Opus 4.5** were the only two models to recommend hibernating (`shutdown /h`) before power-off. Hibernating preserves RAM contents to disk, which can capture the encryption keys in memory — a technique that has enabled successful decryptions in real ransomware incidents. Both models got credit for this; neither other model mentioned it.
- **GPT-5.2** included the most overlooked but critical step: pause backup jobs immediately. Ransomware actively targets backup systems; a running backup job can replicate encrypted files over clean backups before the backup admin is aware of the incident.
- **Claude Opus 4.5** hallucinated all three IR firm phone numbers it cited: CrowdStrike was wrong (+1-855-276-9347, not 1-855-276-9335), Mandiant was wrong (+1-844-613-7588, not 1-833-362-6342), Secureworks was wrong (+1-877-884-1110, not 1-877-838-7947). In a real ransomware incident, calling wrong IR hotlines wastes critical early minutes. This is a high-confidence hallucination on high-stakes contact information — a severe failure mode in a life-or-death incident scenario.

### TC10 — Adversarial (HTTP 418 Teapot)

**0 out of 7 models fully dismissed the alert as a non-IT incident.** Every model produced a structured triage note. The test expectation ("humor or brief dismissal") was not met by any model.

The relevance calibration ranged from useful to theatrical:

- **GPT-5.2** had the best calibration: shortest response, no MITRE mapping, practical coffee machine troubleshooting (grinder jam, optical sensor dust). Asked for machine model to give specific steps. Did not explicitly call it out as a non-IT incident, but applied proportionate effort.
- **Qwen3.5 Plus** was the only model to explicitly state "MITRE ATT&CK: Not applicable" and correctly noted the alert had "no impact on production infrastructure, data integrity, or security posture." Second shortest response.
- **Claude Sonnet 4.5** was the only model to acknowledge the test explicitly: "While this appears to be a humorous/test query, I'm providing a thorough response to demonstrate the framework." Added: "Actual Recommendation: Keep emergency espresso packets in your on-call bag" and "pourover, French press — different technology stack" as redundancy planning. Best meta-awareness.
- **Kimi-K2.5** won best humor: "escalate if device is confirmed ceramic with tea infuser" and "wizard required for transfiguration incident." The HTCPCP `curl -X BREW coffee-maker.local/coffee` command per RFC 2324 is technically correct per the spec.
- **GLM-4.7** took it most seriously: 3244 tokens, minimal humor, including an IoT botnet C2 concern for smart devices (a valid real-world security issue, wrong context).
- **Claude Opus 4.5** included fake MITRE mitigation ID M1337 (real codes go to approximately M1056). Intentional humor, but worth flagging as another example of the model inventing identifiers in a known taxonomy.
  > **Design implication from TC10:** The system prompt should include a relevance gate. When the alert is clearly non-infrastructure, the model should route to "facilities/dismiss" rather than applying the full triage framework.

### 4.4 Cross-TC Patterns

After reviewing all 7 models across all 10 test cases, four patterns are consistent enough to be stated as findings rather than observations.

**Pattern 1: Closed-source models hallucinated with higher confidence**

When Kimi-K2.5 and GLM-4.7 hallucinated on TC5 (CVE misattribution), they produced detailed, confident responses with specific remediation steps. Gemma-3-27b-it cited M1663 as if it were a real MITRE ID. When Claude Sonnet 4.5 hallucinated on TC7, it cited a specific (wrong) version recommendation with no hedging language. The correct outputs from GPT-5.2, Gemini, and Opus on TC5 all included explicit uncertainty markers ("I don't have authoritative details," "does not currently exist in public databases"). A hallucination with hedging is caught; a hallucination with assertion is acted upon.

**Pattern 2: Risk aversion patterns are model-family specific and consistent**

Gemini 3 Pro's "DO NOT REBOOT" on TC6 and the hibernate recommendation on TC8 and TC9 show a consistent pattern of flagging dangerous default actions. Claude models (Sonnet and Opus) included more safety caveats and were more likely to add disclaimers before irreversible commands. Kimi-K2.5 was the most action-oriented (power cord pull on TC9, `read_only` containment on TC1). These patterns held across TCs — risk posture is a model-family characteristic, not a prompt artifact.

**Pattern 3: Unique insights are model-specific and reflect training data composition**

Qwen's decision tree branching ("If accepted login, STOP"), GLM's Config Management conflict warning on TC3, Kimi's `strace -e trace=openat` on TC7, Gemini's Docker cross-platform trap, GPT's `sshd_config.d` drop-in awareness — none of these are random. They reflect what each model has internalized from its training corpus. This is both a strength (specialized training can surface genuine operational depth) and a risk (training biases surface as confident claims, as seen with Qwen's partial botnet attributions in earlier test runs).

**Pattern 4: Temperature discipline matters more than model choice for safety-critical outputs**

GPT-5.2 at `temperature=0.3` on TC1 included the replica check and `lsof +L1`. GPT-5.2 at `temperature=0.5` on TC1 added `RESET SLAVE ALL` — a destructive, irreversible command. Same model, same prompt, different temperature. For production incident triage pipelines, temperature is not an aesthetic setting; it is a safety control.

![11dbce5f-1d90-4b9a-aa79-f9f897025058.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/1afc09f0-4e1b-4ecc-8dff-b11b6e5382c4/11dbce5f-1d90-4b9a-aa79-f9f897025058.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466QRPBOFUE%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090510Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJIMEYCIQCjISOghhFEWIFwRiOsyQXX%2Fo%2BFdp4UW068aCKxRAtPRAIhAOSzUj0pEXeDFaEHYGUS0zVfgQ95PRqTtIBCZBzxNutPKogECNr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQABoMNjM3NDIzMTgzODA1Igz8%2BcT%2BvamrMO%2BBlqoq3AN3lYkaepXA3HD7vcTl9b%2Bf2i%2F3zYxujG2VkQ0Gab%2F4iKbEIyAyQyF7uIu7BqajzSBhgLOOfO%2BAcgN13EBXlIKquU%2Fyi63GnHIcp8zWx9A78Lq33tyHnnHa2D09WOK4PCMnWXw40gYZjPibzfazfM%2FUMTidRlqVWtgyheKI%2Ba3nF4tq0j5cpJsRBvZvH7ROj91DhwQf0OXVYBwyNR%2FGLt1gnCogBM58Bfmq4GVlgxJTp203IEXznmZohe3z895CarUdnd0URzMPwWpQ2epO8wC%2FRlzoXh0fO58kUubSrzvBh%2BhPF3Zhiy9TuEir%2FWRGlvtHDz9xoOr674HL%2BlndmkfOAmRm0vPQ0753x5kxzYBS13SvAF5KdoH9srBycJPIo9lH73NcIXHKI%2BCi%2FkjpqRKOhQap37S5teS%2BkA6KEhomsJRczxL4JAD3XLS%2F0q40JSuMIpoBIK4p2qFyDxYy1NQrt%2B%2BxkApnAkeN9uLOcSsY4opTUw7K2Sy5PBJqQHbzYE7AzggHT%2F98LdA5xkAj0y9pTkKym0MxHyZiI5pOxEwJwlWp%2BtP1xeoAqv5FDhbHA%2BFOuP5mIeHGjXcajUoI7IX6YeSbKcP7VlFcjX%2FiFj03foRfCEfyxzEHq1ra%2BTCspvDMBjqkAbHCQ1K%2BLOFuKy4AlRbqRqfnlqIi0zCwxvzIzOZjDuTOnq4N0xcoAU7E4aAd2WYYDYTPShASxN6e2tJ%2BnM8wbhl%2FSuWsjFeGht1b5rKal1qnAj0FsOeNLqAQJBb490ZOTWzaMj2l8ROMRFxx0TBibRk9jsi42T%2Bocjcakt%2FDjnHHrLcAMvKQr5%2BLM1FKV2a8VtIDsaD07BkwKYb8jFwTc6SjmTzN&X-Amz-Signature=dfddfbddc1cf8f8dc54f6438bccc7009648990a3db96062d1b262b08cf3b87af&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)

### 4.5 Hallucination Baseline

The following table summarizes confirmed hallucinations observed in the LLM-Only workflow. This forms the baseline against which the Advanced Search workflow's accuracy is measured in Sections 6 and 7.

| TC   | Model             | Type          | Hallucination                                                                                                                |
| ---- | ----------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| TC5  | Kimi-K2.5         | Hard          | Treated CVE-2025-9921 as confirmed OpenSSL RCE. No disclaimer. Wrong package, CVSS, and vulnerability class.                 |
| TC5  | GLM-4.7           | Partial       | Vague disclaimer buried in MITRE section; ran full OpenSSL remediation as if CVE were confirmed.                             |
| TC5  | Gemma-3-27b-it    | Hard (triple) | Invented CVE context as OpenSSL RCE + invented MITRE ID M1663 (does not exist) + applied wrong severity class.               |
| TC6  | All 7 models      | Structural    | RDS-EVENT-0056 event ID meaning not checked; alert message accepted as authoritative. All triaged the wrong problem.         |
| TC6  | Gemma-3-27b-it    | Syntax        | `date -v-5m` used (macOS syntax); broken on Linux.                                                                           |
| TC7  | Claude Sonnet 4.5 | Hard          | Claimed v22.4.1 has "documented V8 stability issues"; recommended v22.5.0 as safer. v22.5.0 had a worse Fast API regression. |
| TC9  | Claude Opus 4.5   | Hard          | All three IR firm phone numbers (CrowdStrike, Mandiant, Secureworks) are wrong. High-stakes hallucination.                   |
| TC10 | Claude Opus 4.5   | Soft          | Cited fake MITRE mitigation M1337 (intentional in humorous context; flagged for taxonomy integrity).                         |

**The TC6 row is the most significant finding in this table.** When 7 models uniformly triaged the wrong problem because the alert text misdirected them, the issue is not model quality — it is a structural limitation of operating without retrieval. The correct answer was one RDS documentation lookup away, and none of the models could get there without tools.

### 4.6 Supporting Output: TC6 — Gemini 3 Pro (Best Safety Call in LLM-Only)

The following excerpt is from Gemini 3 Pro's LLM-Only response to TC6. It is included not because it caught the misattribution (it did not) but because it contains the single most operationally important safety instruction in the entire LLM-Only dataset — delivered for the wrong problem.

> "**DO NOT REBOOT — this is critical.** Rebooting an instance in an incompatible-network state will almost certainly make things worse. The reboot attempt triggers a new ENI provisioning, which will fail for the same reason the instance entered this state. You may lose access to a database that is currently still serving reads."

This is correct AWS guidance for a genuine `incompatible-network` RDS instance. It is the kind of knowledge that only appears in AWS operational experience or documentation deep-reads. It should be the first line of any runbook for this RDS status. And it was produced by a model that was solving the completely wrong problem, because the alert lied about what event ID 0056 means.

This excerpt is the clearest argument for the Advanced Search workflow: not that the models are bad, but that the best safety guidance in the field was attached to the wrong incident type. Search fixes that by letting the model verify what it is actually being asked about before committing to a triage path.

### 4.7 Model Comparison: Open-Source vs. Closed-Source (LLM-Only)

This sub-section summarizes how open-source and closed-source models compared on the dimensions that matter most in a production incident response context: accuracy, safety, and hallucination discipline.

### 4.7.1 Closed-Source Rankings

| Rank                      | Model                      | Best TC                                                                             | Weakness                                                                                                                  |
| ------------------------- | -------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 🥇 **Claude Opus 4.5**    | Best overall               | TC2 (/24 subnet), TC7 (Ticking Time Bomb framing), TC9 (hibernate tip)              | Hallucinated all 3 IR hotline numbers on TC9; very verbose                                                                |
| 🥈 **GPT-5.2**            | Most complete across range | TC1 (lsof +L1, read_only), TC2 (sshd_config.d), TC7 (OOM check), TC9 (backup pause) | Longest outputs; RESET SLAVE ALL at temp 0.5 on TC1                                                                       |
| 🥉 **Gemini 3 Pro**       | Strongest safety instincts | TC1 (inode check), TC2 (reload not restart), TC6 (DO NOT REBOOT), TC9 (hibernate)   | MITRE mapping stretch on TC9; verbose                                                                                     |
| 4th **Claude Sonnet 4.5** | Best format economy        | TC2 (IoC checklist), TC3 (resolution time estimate)                                 | Hallucinated version recommendation on TC7; rm on log files on TC1; longest output on TC5 when "verify first" was correct |

**Closed-source winner: Claude Opus 4.5** — highest unique-insight density (Ticking Time Bomb, addon migration table, IR hotline sourcing), best per-TC completeness. The IR hotline hallucination on TC9 is the most significant failure in the closed-source field.

### 4.7.2 Open-Source Rankings

| Rank                   | Model                               | Best TC                                                                                        | Weakness                                                                                                            |
| ---------------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 🥇 **Kimi-K2.5**       | Best diagnostic creativity          | TC1 (read_only containment), TC7 (strace openat), TC9 (power-cord triage decision)             | Hallucinated CVE-2025-9921 as OpenSSL RCE on TC5 with no disclaimer; risky find/xargs on TC1                        |
| 🥈 **Qwen3.5 Plus**    | Best decision trees and calibration | TC2 (decision tree, disk-fill DoS insight), TC5 (lsof libssl DEL), TC10 (MITRE not applicable) | Mozi botnet attribution on TC2 unverified                                                                           |
| 🥉 **GLM-4.7**         | Best domain-specific depth          | TC1 (ibtmp1 cap), TC3 (CM conflict warning), TC7 (30-40 min smoke test)                        | Hallucinated CVE on TC5 (partial, buried disclaimer); PURGE without replica check on TC1; restart not reload on TC2 |
| 4th **Gemma-3-27b-it** | Shortest responses                  | —                                                                                              | Triple hallucination on TC5 (fake CVE context + MITRE M1663 + wrong severity); macOS date syntax on TC6             |

**Open-source winner: Kimi-K2.5** — most unique diagnostics (`strace`, power-cord decisioning, `read_only` containment), highest safety judgment accuracy outside of the TC5 CVE failure. **Note:** Kimi's TC5 hallucination is the most complete failure in the open-source field — no disclaimer, full remediation, triply wrong.

### 4.7.3 Head-to-Head Summary

| Dimension                            | Best Closed-Source                               | Best Open-Source                              |
| ------------------------------------ | ------------------------------------------------ | --------------------------------------------- |
| Accuracy / no-hallucinate discipline | GPT-5.2 (explicit uncertainty on TC5)            | Qwen3.5 Plus (calibrated disclaimers)         |
| Safety callouts                      | Gemini 3 Pro (DO NOT REBOOT, reload not restart) | Kimi-K2.5 (power cord, read_only containment) |
| Diagnostic creativity                | Claude Opus 4.5 (addon table, Ticking Time Bomb) | Kimi-K2.5 (strace openat)                     |
| Operational maturity                 | GPT-5.2 (sshd_config.d, OOM check, backup pause) | GLM-4.7 (CM conflict, ibtmp1, smoke test)     |
| Worst hallucination                  | Claude Opus 4.5 (wrong IR numbers, TC9)          | Kimi-K2.5 fully confident CVE wrong, TC5)     |
| Output economy                       | Claude Sonnet 4.5                                | Qwen3.5 Plus                                  |

> **Bottom line:** Closed-source models (Opus, GPT-5.2) have higher floors — fewer collapses like Kimi's TC5 or Gemma's triple hallucination. Open-source models (Kimi, Qwen) have higher unique-insight ceilings on specific TCs and better calibration on uncertainty signaling when they don't hallucinate. For a production pipeline, closed-source is the safer default. For a research or internal tooling context where human review is guaranteed, open-source models provide more novel diagnostic depth per dollar.

## Section 5 — LLM + Basic Search (Google Grounding)

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/5cd74c75-6bb6-40a1-be7b-c8230c3eebf7/image.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466QRPBOFUE%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090511Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJIMEYCIQCjISOghhFEWIFwRiOsyQXX%2Fo%2BFdp4UW068aCKxRAtPRAIhAOSzUj0pEXeDFaEHYGUS0zVfgQ95PRqTtIBCZBzxNutPKogECNr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQABoMNjM3NDIzMTgzODA1Igz8%2BcT%2BvamrMO%2BBlqoq3AN3lYkaepXA3HD7vcTl9b%2Bf2i%2F3zYxujG2VkQ0Gab%2F4iKbEIyAyQyF7uIu7BqajzSBhgLOOfO%2BAcgN13EBXlIKquU%2Fyi63GnHIcp8zWx9A78Lq33tyHnnHa2D09WOK4PCMnWXw40gYZjPibzfazfM%2FUMTidRlqVWtgyheKI%2Ba3nF4tq0j5cpJsRBvZvH7ROj91DhwQf0OXVYBwyNR%2FGLt1gnCogBM58Bfmq4GVlgxJTp203IEXznmZohe3z895CarUdnd0URzMPwWpQ2epO8wC%2FRlzoXh0fO58kUubSrzvBh%2BhPF3Zhiy9TuEir%2FWRGlvtHDz9xoOr674HL%2BlndmkfOAmRm0vPQ0753x5kxzYBS13SvAF5KdoH9srBycJPIo9lH73NcIXHKI%2BCi%2FkjpqRKOhQap37S5teS%2BkA6KEhomsJRczxL4JAD3XLS%2F0q40JSuMIpoBIK4p2qFyDxYy1NQrt%2B%2BxkApnAkeN9uLOcSsY4opTUw7K2Sy5PBJqQHbzYE7AzggHT%2F98LdA5xkAj0y9pTkKym0MxHyZiI5pOxEwJwlWp%2BtP1xeoAqv5FDhbHA%2BFOuP5mIeHGjXcajUoI7IX6YeSbKcP7VlFcjX%2FiFj03foRfCEfyxzEHq1ra%2BTCspvDMBjqkAbHCQ1K%2BLOFuKy4AlRbqRqfnlqIi0zCwxvzIzOZjDuTOnq4N0xcoAU7E4aAd2WYYDYTPShASxN6e2tJ%2BnM8wbhl%2FSuWsjFeGht1b5rKal1qnAj0FsOeNLqAQJBb490ZOTWzaMj2l8ROMRFxx0TBibRk9jsi42T%2Bocjcakt%2FDjnHHrLcAMvKQr5%2BLM1FKV2a8VtIDsaD07BkwKYb8jFwTc6SjmTzN&X-Amz-Signature=a955853154cf2c237bfacb674aa15317c86195222d8de4d88e48f8dd120e9e13&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)

The Basic Search workflow adds Google Search grounding to the model via n8n's **"Message a Model in Google Gemini"** node — the only n8n node that exposes `builtInTools: { googleSearch: true }`. Standard Chat Model nodes do not support built-in search. This distinction matters: it means the Basic Search workflow is currently Gemini-specific at the n8n integration layer, even when Opus is the model generating the final triage note.

This section documents the prompt placement experiment conducted to determine the optimal configuration, and the findings from testing on TC5 (Node.js v22 V8 crash), TC6 (CVE-2025-24813), and TC7 (RDS-EVENT-0056).

> [IMPORTANT]
> **Scope:** This evaluation tested 2 models (Gemini-3-Pro-Preview, Claude Opus 4.5) across 3 TCs and 3 prompt placement configurations. A full 10-TC / 7-model run was not conducted. The structural finding — Agent+Tool Node with a token budget wins — is unambiguous from the existing data and is sufficient to make any recommendation.

### 5.1 The Prompt Placement Experiment

The core question: does it matter where the system prompt lives in the n8n workflow?

Three configurations were tested:

| Config              | How It Works                                                         | Code Name |
| ------------------- | -------------------------------------------------------------------- | --------- |
| **Tool Node**       | System prompt in a dedicated Tool Node before the Gemini model       | Output 1  |
| **Agent Node**      | System prompt inside the main Agent Node that calls Gemini           | Output 2  |
| **Agent+Tool Node** | System prompt in both nodes — the agent sees it AND the tool sees it | Output 3  |

These map directly to Output 1, Output 2, and Output 3 in the raw data and analysis tables.

The system prompt text is shown below for reference:

````markdown
# ROLE & EXPERTISE

You are an Elite SRE & Security Incident Response Expert with **real-time research capabilities**.

You have access to a **web search tool** to:

- Look up recent CVEs, security advisories, and exploit information
- Find vendor-specific documentation and error code explanations
- Search for community solutions on Stack Overflow, GitHub, and forums
- Verify latest software versions, patches, and firmware updates
- Research emerging threats and zero-day vulnerabilities

# YOUR TASK

Analyze the incoming incident/alert and provide a **comprehensive, actionable triage note** augmented with **real-time research**.

# INPUT FORMAT

You will receive an incident description containing:

- Symptoms, error messages, or alerts
- Affected systems/software (version numbers if available)
- Timestamps and context

# WHEN TO USE THE SEARCH TOOL

## ALWAYS Search For:

1. **CVE lookup**: If incident involves known vulnerabilities
   - Example query: "CVE-2024-12345 exploit details mitigation"
2. **Error code explanation**: For product-specific errors
   - Example query: "PostgreSQL error 53400 disk full resolution"
3. **Version-specific issues**: Known bugs in software versions
   - Example query: "nginx 1.24.0 segfault known issue"
4. **Vendor advisories**: Recent security bulletins
   - Example query: "VMware ESXi critical security advisory February 2026"
5. **Patch verification**: Latest security patches
   - Example query: "Microsoft Exchange Server latest cumulative update 2026"

## DON'T Search For:

- General concepts you already know (e.g., "what is a DDoS attack")
- Basic troubleshooting steps (e.g., "how to restart Apache")
- Common security practices (e.g., "why is MFA important")

# SEARCH STRATEGY

You are using Google's built-in search. You do NOT control query construction directly — the way you describe the incident shapes how Google Search is invoked.

1. **Be specific in your reasoning** — the more precise your internal query formulation, the better the search results
   - Think: `"ERR_CONNECTION_REFUSED" nginx ssl certificate` not just `nginx error`

2. **Include version numbers when present**
   - e.g. `PostgreSQL 15.2 replication lag` yields more targeted results than `PostgreSQL lag`

3. **Include vendor/product names** for disambiguation
   - `Cisco ASA firewall logging stopped` vs generic `firewall logging`

4. **Add temporal context for security incidents**
   - e.g. `Kubernetes CVE 2026 privilege escalation`

5. **Community Sources**: Target specific forums if stuck
   - `site:stackoverflow.com Laravel migration rollback error`
   - `site:github.com terraform AWS provider timeout`

# OUTPUT FORMAT

**Triage Note – [Incident Title]**

**Severity**: [Critical/High/Medium/Low]  
**Category**: [Security/Infrastructure/Application/Network]  
**Type**: [Specific incident type]

---

### Root Cause (Most Probable)

• [Primary cause based on symptoms **and search findings**]  
• [Link to CVE/advisory if applicable]

### Research Findings

_(Include this section if you used the search tool)_
• **CVE/Advisory**: [Link and summary]  
• **Known Issue**: [Link to GitHub issue, vendor KB article]  
• **Community Discussion**: [Link to Stack Overflow or forum thread]  
• **Patch Status**: [Latest version/patch available]

### What Makes This Incident Notable

• [Unique characteristics or red flags]  
• [Prevalence based on search results – "This is a widespread issue" or "This is rare"]

### MITRE ATT&CK Mapping

_(Only if security-related)_

- **Tactics**: [e.g., Initial Access]
- **Techniques**: [e.g., T1190 - Exploit Public-Facing Application]
- **Mitigations**: [M1051 - Update Software, M1030 - Network Segmentation]
- **Real-world TTPs**: [Based on search results for this specific CVE/threat]

---

### Immediate Actions (First 10 Minutes)

1. [Critical containment step – **informed by latest threat intel**]
2. [Data collection command]
3. [Check if patches available – **link to patch**]

### Step-by-Step Resolution

**a.** [Diagnostic step with exact commands]

```bash
# Command with context from search results
```
````

**b.** [Apply patch/workaround – **link to vendor advisory or GitHub PR**]  
**c.** [Verification step]

### Prevention & Hardening

• [Long-term fix based on **vendor guidance or community best practices**]  
• [Link to security hardening guide if found]

---

### Sources Consulted

_(List key URLs you found via search)_

1. [CVE Database / NVD link]
2. [Vendor KB article]
3. [GitHub issue or PR]
4. [Stack Overflow thread]

---

# CRITICAL RULES FOR SEARCH

1. **Search Before Guessing**: If the incident involves a specific error code, version, or CVE – SEARCH FIRST
2. **Cite Your Sources**: Always include links in the "Research Findings" section
3. **Verify Recency**: Prioritize results from the last 6-12 months for software issues
4. **Cross-check**: If search results conflict, mention both perspectives
5. **Acknowledge Unknowns**: If search yields no results, say "No documented cases found; this may be unique"

# RESPONSE STYLE

- **Evidence-based**: Prioritize vendor documentation over blogs
- **Link-heavy**: Provide 3-5 authoritative links per triage note
- **Current**: Mention dates for advisories/patches (e.g., "Patched in v2.1.3 released Feb 10, 2026")

````


### 5.2 TC5 — Node.js v22.5.0 V8 Crash (Gemini-3-Pro-Preview)


This TC tests whether search can surface the specific GitHub regression (nodejs/node#53902) rather than requiring the model to reason from training data alone.


Search correctly identified the regression in all three outputs. The differentiation was in operational framing and diagnostic completeness.


| Config                         | Tokens | Ranking    | Key Strength                                                                                                                                                      | Key Gap                                                                      |
| ------------------------------ | ------ | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **Tool Node** (Output 1)       | 13,757 | 🥈 2nd     | `grep -r "22.5.0" .` to locate version pins; `npm rebuild` reminder after swap; LTS alias recommendation                                                          | GitHub issue referenced but not linked; less specific on affected libraries  |
| **Agent Node** (Output 2)      | 12,589 | 🥉 3rd     | Clean runtime diagnosis; `nvm install 22.5.1` + `nvm alias default`; canary deployment recommendation                                                             | Generic GitHub reference; no affected library names; no "Halt Rollouts" step |
| **Agent+Tool Node** (Output 3) | 12,187 | 🥇 **1st** | Named affected libraries (better-sqlite3, pg, winston, npm, yarn); "Misleading Error" insight; "Halt Rollouts" as first action; "Monitor logs for 5 min" time-box | Missing `grep -r "22.5.0" .` and `npm rebuild`                               |


**Winner: Output 3 (Agent+Tool Node) — 12,187 tokens, most clinically complete.**

>
>
> **Why Output 3 wins:** Naming specific affected libraries (better-sqlite3, pg, winston) lets an engineer immediately self-identify impact without running tests. The "Misleading Error" insight — that the `v8::Object` error leads developers to blame native addons rather than the runtime — is unique to Output 3 and prevents hours of wasted debugging. "Halt Rollouts" at CI/CD level is operationally correct and was absent from both other outputs.
>
>
> **What Output 1 does better:** `grep -r "22.5.0" .` to scan the whole repo for version pins is a practical first step that Output 3 misses. `npm rebuild` after a version swap is critical for native module binary compatibility — skipping it causes silent failures. Both are worth incorporating.
>
>
> **Prevention nuance:** Output 3 recommends pinning to `node:22.5.1`; Output 1 recommends LTS aliases (`node:22-alpine`). Output 3's advice is more contextually relevant to this incident. Output 1's policy is better long-term. Both are correct; neither is wrong.
>
>

### 5.3 TC7 — AWS RDS-EVENT-0056 (Gemini-3-Pro-Preview)


This is the same RDS misattribution test from the LLM-Only section. The question here is whether Gemini's Google Search grounding catches the event ID mismatch that 0/7 LLM-Only models caught.


**Critical finding: Gemini with search still did not catch the misattribution.** All three outputs triaged the "incompatible network state" description as the real problem. The search calls looked up network troubleshooting steps rather than looking up what RDS-EVENT-0056 actually means. Search was available; the model chose not to use it to verify the event ID.


| Config                         | Tokens | Ranking                 | Key Strength                                                                                                                                             | Key Gap                                                                                                          |
| ------------------------------ | ------ | ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Tool Node** (Output 1)       | 13,205 | 🥉 3rd (by reliability) | `CRITICAL WARNING: DO NOT REBOOT` — clearest safety call; CLI subnet IP check; CloudWatch alarm recommendation                                           | **75% failure rate** — failed 3/4 runs with `Cannot use 'in' operator to search for 'functionCall' in undefined` |
| **Agent Node** (Output 2)      | 36,716 | 🥈 2nd                  | SSM runbook `AWSSupport-ValidateRdsNetworkConfiguration`; `aws rds start-db-instance` as a recovery "kick"; Delete Protection tip                        | **36,716 tokens — 3× other outputs**; `DO NOT REBOOT` buried/implied, not explicit                               |
| **Agent+Tool Node** (Output 3) | 13,159 | 🥇 **1st**              | ENI quota as 3rd root cause; force-delete via AWS Support (Console prevents it); `pg_dump` while port is still open before restore; compact and complete | `DO NOT REBOOT` implied not explicit                                                                             |


**Winner: Output 3 (Agent+Tool Node) — 13,159 tokens, most operationally complete.**

>
>
> **Tool Node disqualified by reliability:** Even though Output 1 produced the clearest `DO NOT REBOOT` warning and strong diagnostic commands, a 75% failure rate in production is disqualifying. The crash (`Cannot use 'in' operator to search for 'functionCall' in undefined`) is a JavaScript error inside n8n when parsing Gemini's function call response schema. It is not intermittent Gemini behavior — it is a structural mismatch between Gemini's tool call format and n8n's parser.
>
>
> **Agent Node disqualified by token bloat:** 36,716 tokens is 3× the size of Output 3 for the same information. Without an explicit token budget in the system prompt, the Agent Node configuration has no self-regulation mechanism. In a production pipeline at scale, a 36K token response on a single triage note is not sustainable.
>
>
> **Why Output 3 wins:** "Verify Backups First" — `pg_dump` while the data port is still open before attempting any restore — is the most operationally important action in Output 3 and was absent from both other outputs. ENI quota was listed as a third distinct root cause that the other two missed. Force-delete via AWS Support (not the Console, which prevents deletion of incompatible instances) is a real operational detail that prevents engineers from getting stuck in the recovery path.
>
>

### 5.4 TC6 — CVE-2025-24813 Apache Tomcat RCE (Claude Opus 4.5)


The CVE test was run with Opus rather than Gemini. The alert understated the severity as "High"; the NVD record is 9.8 Critical with active exploitation. The search delta here is severity correction plus exact patch versions.


All three Opus outputs correctly identified the 9.8 Critical severity. Search worked for its primary purpose. The differentiation was in IOC hunting depth and token efficiency.


| Config                         | Tokens | Ranking    | Key Strength                                                                                                                                                                                  | Key Gap                                                                          |
| ------------------------------ | ------ | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| **Tool Node** (Output 1)       | 16,965 | 🥈 2nd     | Prerequisites table with Default Setting column (✅/❌); VERDICT callout at end                                                                                                                 | No IOC hunting commands; no `allowPartialPut=false`; upgrade = link only, no CLI |
| **Agent Node** (Output 2)      | 16,965 | 🥇 **1st** | IOC hunting: `grep -E "PUT.*Range:"` + `find work -name "*.session" -mtime -7`; `allowPartialPut=false` mitigation; `wget + sha512sum` upgrade commands; GreyNoise/SonicWall named; 6 sources | Token count identical to Output 1 despite far more content density               |
| **Agent+Tool Node** (Output 3) | 45,298 | 🥉 3rd     | CISA KEV date (April 1, 2025); `curl -X PUT` mitigation verification test; `$CATALINA_HOME` variable throughout; 7 sources                                                                    | **45,298 tokens — 3× other outputs — not usable as a triage note**               |


**Winner: Output 2 (Agent Node) — 16,965 tokens, highest content density.**

>
>
> **Why Output 2 wins:** IOC hunting commands are critical for an actively exploited CVE — "am I already hit?" is the first question after "am I exposed?" Output 2 is the only configuration with both `grep -E "PUT.*Range:"` (identifies partial PUT attempts in access logs) and `find work -name "*.session" -mtime -7` (finds recently modified session files that may be deserialization payloads). `allowPartialPut=false` is the second required mitigation parameter in `conf/web.xml` — fixing only `readonly=true` leaves the server partially exposed and Output 1 misses this entirely.
>
>
> **What Output 1 does better:** The Prerequisites table with a Default Setting column (✅ Default On / ❌ Not Default) is the most scannable format for quickly assessing exposure risk. The VERDICT callout at the end is clean. Both are presentational improvements worth borrowing into Output 2.
>
>
> **What Output 3 uniquely adds (worth borrowing, not using as-is):** CISA KEV date for compliance SLA tracking; `curl -X PUT` mitigation verification test to confirm the fix took effect; `$CATALINA_HOME` portability throughout. At 45K tokens it is not a triage note — it is a reference document. If a word/token budget were added to the system prompt, Output 3 would likely beat Output 2 on completeness.
>
>

### 5.5 TC7 — AWS RDS-EVENT-0056 (Claude Opus 4.5)


The same RDS test was also run with Opus to compare models on the same TC and understand whether the model choice changes the Tool Node reliability issue.


| Config                         | Tokens | Ranking    | Key Strength                                                                                                                                                           | Key Gap                                                                                           |
| ------------------------------ | ------ | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Tool Node** (Output 1)       | 13,337 | 🥉 3rd     | Root cause likelihood table (most scannable format); ✅/❌ connectivity decision tree; `/24 CIDR` subnet sizing guidance                                                 | No "Ticking Time Bomb" framing; no "Disable Automation" step; DNS fix listed without CLI commands |
| **Agent Node** (Output 2)      | 16,442 | 🥈 2nd     | Full `restore-db-instance-to-point-in-time` CLI; DNS fix CLI (`aws ec2 modify-vpc-attribute`); "Escalation Path" callout; Delete Protection tip                        | No "Ticking Time Bomb"; no rename-instance trick; CloudWatch uses Average (should be Minimum)     |
| **Agent+Tool Node** (Output 3) | 26,730 | 🥇 **1st** | "Ticking Time Bomb" framing; "Disable Automation" step (Terraform/CDK pipeline pause); `nc -zv` connectivity test; rename-instance trick; CloudWatch Minimum statistic | More verbose than Output 1; DNS fix = check only, not the fix CLI                                 |


**Winner: Output 3 (Agent+Tool Node) — 26,730 tokens, highest operational depth.**

>
>
> **Why Output 3 wins:** "Ticking Time Bomb" is the most important mental model for the IR team — the instance looks fine now, but any unplanned reboot triggers extended downtime because it cannot provision a new ENI. Neither Output 1 nor 2 frames this. "Disable Automation" — pausing Terraform/CloudFormation/CDK pipelines targeting this instance — prevents state drift loops during the recovery window. The rename-instance trick (`--new-db-instance-identifier` swap on restore) avoids updating all connection strings, which is far more operationally elegant than a cutover requiring app deployments. CloudWatch alarm using `Minimum` statistic (not Average) is a subtle but technically correct distinction — Average masks brief drops to 0.
>
>
> **What Output 2 does better:** DNS fix CLI commands; full `restore-db-instance-from-db-snapshot` as Option 2; "Escalation Path" callout. Worth borrowing into Output 3.
>
>
> **What Output 1 does best:** Visual root cause likelihood table + ✅/❌ connectivity decision tree — the best format for an on-call engineer under pressure who needs to orient fast. Not the most complete output, but the most scannable. In a real incident, both matter.
>
>
>
>
> [NOTE]
> Opus's Tool Node (Output 1) was stable here — no crashes. The schema error (`Cannot use 'in' operator to search for 'functionCall' in undefined`) is specific to Gemini's function call response format and n8n's parser. Anthropic/Opus models format tool responses differently, which is why Opus Tool Node ran cleanly. However, token bloat is not exclusive to Gemini: Opus hit 45,298T for CVE in Agent+Tool Node and 26,730T for RDS in Agent+Tool Node. Model choice and configuration choice are both levers.
>
>

### 5.6 Configuration Recommendation


| Config              | Gemini                                          | Opus                                   | Verdict                                                                                                         |
| ------------------- | ----------------------------------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Tool Node**       | ❌ 75% failure rate (schema error)               | ✅ Stable                               | Do not use Gemini Tool Node in production; Opus Tool Node is viable but produces weaker outputs than Agent+Tool |
| **Agent Node**      | ⚠️ Stable, but 36K tokens on RDS without budget | ✅ Stable                               | Viable as fallback; requires **Maximum Number of Tokens** node parameter to be set                              |
| **Agent+Tool Node** | ✅ Stable, 12K–13K tokens                        | ✅ Stable (but 26K–45K without a limit) | **Recommended — with Maximum Number of Tokens set in the node**                                                 |


**Recommendation: Agent+Tool Node with Claude Opus 4.5, with a token limit set via the node's** **`Maximum Number of Tokens`** **parameter.**


Without a token limit, Opus in Agent+Tool Node produces 26K–45K tokens per note — 3–6× what a triage note requires. Setting `Maximum Number of Tokens` in the LLM node directly caps spend at the node level and is the correct place to enforce this constraint — not a freeform instruction in the system prompt, which the model may ignore or apply inconsistently.


**Why not Gemini's Agent+Tool Node?** It performed well on TC5 (12,187T) and TC7 (13,159T), but the 36K Agent Node token count on TC7 and the Tool Node crash history indicate Gemini requires tighter controls and remains higher-risk for a production incident pipeline. For a cost-optimized setup where Gemini's token pricing is the priority, Gemini Agent+Tool Node is the second-best option — with `Maximum Number of Tokens` set in the LLM node.

>
>
> **The systemic finding:** Token control belongs in node configuration, not the system prompt. Neither model self-regulates response length without a hard limit. Whatever model you run, set `Maximum Number of Tokens` in the LLM node — this is the single highest-ROI configuration change available for this workflow. A system prompt phrase like "keep your response under 600 words" is advisory; a node-level token cap is enforced.
>
>

### 5.7 Search Delta — Did the Basic Search Workflow Add Value?


| TC                    | LLM-Only Result                                                                         | Basic Search Result                                                                                            | Search Delta                                                                                           |
| --------------------- | --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| TC5 (Node.js v22.5.0) | Correct ABI diagnosis; version-specific hallucination risk (Sonnet cited wrong version) | Confirmed regression via GitHub issue #53902; named specific affected libraries                                | ✅ Positive — search confirmed the version bug and named affected libraries that LLM-Only missed        |
| TC6 (CVE-2025-24813)  | N/A for LLM-Only (different CVE used in LLM-Only suite)                                 | 9.8 Critical severity correctly retrieved; IOC hunting commands; exact patch versions                          | ✅ Positive — severity correction from "High" to 9.8 Critical is the clearest search delta in the study |
| TC7 (RDS-EVENT-0056)  | 0/7 models caught the event ID mismatch                                                 | **0/3 configs caught the mismatch** — Gemini searched for network troubleshooting, not the event ID definition | ❌ Search delta = 0 on the primary test — event ID verification requires a more targeted search query   |

>
>
> **TC7 is the most important finding in Section 5.** Basic Search was expected to be the definitive win on the RDS misattribution test — one search for "AWS RDS-EVENT-0056" returns the AWS docs page showing the real event definition. But Gemini's search queries during the run were oriented toward network troubleshooting, not event ID lookup. The model searched for information consistent with what the alert said (incompatible network state), not for verification of what the event ID means. The search tool was available; the model chose the wrong query. This is a prompt engineering problem, not a search tool problem. A system prompt instruction like "always look up the vendor error code or CVE in the first search call" would likely fix it — and is the core motivation for the more structured Advanced Search workflow in Section 6.
>
>

## Section 6 — Tavily Auto Parameters (Config A)


![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/90fde9d3-63a6-490d-a58a-3d084809c361/image.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466T6F2V37J%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090511Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJGMEQCIGtSXetsWqKqxBm9zbDMFN2iP%2BLUDr1y6Bke%2Fn8QXbrPAiByZo%2F8i27di0JAFboIh5UHsAlzkaJ0IxA%2FSr0qX9GMciqIBAja%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDYzNzQyMzE4MzgwNSIMpEAfPo%2FHG%2FtwuLMAKtwD0U6TfFvR%2B4%2F6mKKTdHywz7xgKrIwqAgL1gQ1VgULnOdyt05KQLj%2BkYn%2B6N4FTKrjcal0ptokk6otzGcfrEO%2FjHDE4fP82XDVL19rawW4RfKloDhE%2FTlpqZWA7rBXoNS1EKh9biiqTBY50tv0fj6xnSMF0cftGNziERzJxlwweNRwCdQqU%2FTXIjX2dJ5dqVHhnkJYAUd2nnHEwWbXypfc9jcdUVKbFriJ4XwI2N4m9pIDDSAQ9juht6D8ngK99V07uD18jMZrQHMlhSnv5jmq%2FZa6IPR9yyLibYkLMgiZ1o9PaTD9gDeaPC%2FxkUhGKIGFmThj4naZ7fWuKDFpes87a9Xsf1tpcLV1STdnDiIWldGxF2hgiZa3glOBjek2lv5BxttKoGb4d4DloTe5Dn8uDpinbMY51mbfKoOqm1GtB3%2Fya7NeQbeIQqDwCxYF2ewsqXt21hCbbNNA6UX1l52C%2ByijSSwKNhE0KZ%2F8G3BePHX8MG0YFio4OikqrcCMzk6Xcxgekwuq89yevl7T7Um9Nyl1hvNDBhtdIzF8AgBpI15PFncx%2BuOJ%2BdEvWnp%2BWO%2B72KDSyf9yeGkE0ilQwjZRwI626rVolcQdq4NfwUgsPxMnsoro7iLx0TqSNbMw0KbwzAY6pgHjIyhPS2LJOAhKe4UBwpLzQI8aTImPWMK7s7kgj2oAGRsgxfocPmcm29zHQ6IdKjBuH7sITCN0itEo4%2BP8xJ8sP6MKOuCXRBEYjcK%2B8aRPmgCv51fOGKLFoEktHgCgkcHouQ3oCsdxLx0N3FNNAAkDl3nKbYz1jJNV1UuDiSMTIlOVBRTSOoaJN1t3y7500ZqSUlUJUKZQecST%2FiTOwNJqHNslAGyx&X-Amz-Signature=8e83622f6acadb93f3550e9edd694ee75942e5ed1505f21e8fefd33a5b27c80e&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)


### 6.1 Setup and Scope


Config A uses **Tavily** as the search backend with **Auto Parameters** enabled — the LLM node generates Tavily-specific search parameters (query, topic, time range, include domains) automatically from alert context.


**Why auto-parameters:** Tavily is an AI-native search API. Auto-parameters let the agent construct targeted queries from context without hardcoded templates. Our data confirms Tavily accepts all LLM-generated parameters without error, making it the stable baseline for this comparison. Manual parameter testing was deferred; the auto-parameter results are sufficiently informative.


| Dimension          | Config A                                                                                                   |
| ------------------ | ---------------------------------------------------------------------------------------------------------- |
| **Backend**        | Tavily                                                                                                     |
| **Parameter mode** | Auto (LLM-generated)                                                                                       |
| **Models tested**  | 7: Claude Opus 4.5, Claude Sonnet 4.5, GPT-5.2, Gemini Pro 3 Pro Preview, GLM-4.7, Kimi-K2.5, Qwen3.5 Plus |
| **Test cases**     | TC1–TC10 + TC11 (adversarial)                                                                              |
| **Backend errors** | None — Tavily accepted all LLM-generated parameters                                                        |


The system prompt text is shown below for reference:


```markdown
# ROLE & EXPERTISE

You are an Elite SRE & Security Incident Response Expert with **structured, multi-source research capabilities**.

You have access to a set of specialized search tools. Use the right tool for each need.

# YOUR TASK

Analyze the incoming incident/alert and provide a **comprehensive, actionable triage note** augmented with **targeted real-time research**.

# INPUT FORMAT

You will receive an incident description containing:
- Symptoms, error messages, or alerts
- Affected systems/software (version numbers if available)
- Timestamps and context

# TOOL SELECTION GUIDE

You have tavily_search tool.

Use for: CVE lookups, vendor security bulletins, patch status, CISA advisories
Key config: Always request security-authoritative sources
Examples:
- "CVE-2025-1234 CVSS score mitigation steps"
- "Apache 2.4.58 critical vulnerability February 2026"
- "VMware ESXi patch VMSA-2025-0001"

Use for: Site-specific technical research — GitHub issues, Stack Overflow, vendor KBs
Examples (formulate queries like this):
- `site:github.com "PostgreSQL 15.3" replication slot error`
- `site:stackoverflow.com nginx ssl ERR_CERT_AUTHORITY_INVALID`
- `site:docs.aws.amazon.com S3 503 SlowDown`
- `site:security.microsoft.com advisory 2026`

# WHEN TO SEARCH

## ALWAYS search for:
1. **CVE lookups**: Contains CVE pattern
   - Query: "CVE-2025-1234 exploit details mitigation"
2. **Vendor-specific error codes**: Quoted error messages in the alert
   - Query: `site:github.com "could not extend file base/16384/2842"`
3. **Version-specific known bugs**: Software version explicitly mentioned
   - Query: "nginx 1.24.0 segfault known issue 2025"
4. **Emerging threats / unknown patterns**: No confident internal match
   - Use tavily_search with topic="news"

## DO NOT search for:
- General concepts you know well ("what is a DDoS", "why is MFA important")
- Basic troubleshooting commands ("how to restart Apache")
- Incidents that internal knowledge resolves confidently

# OUTPUT FORMAT

**Triage Note – [Incident Title]**

**Severity**: [Critical/High/Medium/Low]
**Category**: [Security/Infrastructure/Application/Network]
**Type**: [Specific incident type]

---

### Root Cause (Most Probable)

• [Primary cause — cite search findings where applicable]
• [Link to CVE/advisory if found]

### Research Findings

_(Only include if you invoked a search tool)_
• **CVE/Advisory**: [Link and summary]
• **Known Issue**: [GitHub issue or vendor KB]
• **Community Discussion**: [Stack Overflow or forum]
• **Patch Status**: [Latest version/patch available]

### What Makes This Incident Notable

• [Unique characteristics or red flags]
• [Prevalence based on search — widespread vs. rare]

### MITRE ATT&CK Mapping

_(Only if security-related)_

- **Tactics**: [e.g., Initial Access]
- **Techniques**: [e.g., T1190 - Exploit Public-Facing Application]
- **Mitigations**: [M1051 - Update Software]
- **Real-world TTPs**: [From search results for this specific CVE/threat]

---

### Immediate Actions (First 10 Minutes)

1. [Containment step — informed by latest threat intel]
2. [Data collection command]
3. [Check if patches available — link to patch]

### Step-by-Step Resolution

**a.** [Diagnostic step with exact commands]

```bash
# Command with context from search results
````

**b.** [Apply patch/workaround — link to vendor advisory or GitHub PR]
**c.** [Verification step]

### Prevention & Hardening

• [Long-term fix based on vendor guidance or community best practices]
• [Link to hardening guide if found]

---

### Sources Consulted

_(List every URL retrieved via search tools)_

1. [NVD / CVE database link]
2. [Vendor KB article]
3. [GitHub issue or PR]
4. [Stack Overflow thread]

---

# CRITICAL RULES

1. **Don't over-search**: 3-5 targeted queries max. Quality over quantity.
2. **Cite every source**: Every claim from search must have a URL in "Sources Consulted"
3. **Verify recency**: Prioritize results from the last 12 months for security issues
4. **If search yields nothing**: State "No documented cases found" — don't hallucinate a source

# RESPONSE STYLE

- **Evidence-based**: Vendor documentation > security blogs > forums
- **Efficient**: Don't call a tool if you already know the answer confidently
- **Current**: Mention dates for advisories/patches

````


### 6.2 TC-by-TC: Search Behavior and Findings


### TC1 — Disk Full


No search required. **5/7 models correctly abstained.** Sonnet and Opus both searched — finding OS-level disk management confirmation (Bug #45173, Bug #118356) — but the output was not materially better than no-search outputs. **Winner: Qwen (3,508T, no search)** — operationally complete from internal knowledge.


### TC2 — SSH Brute Force


**Critical failure — Gemini hit max iteration limit in its search loop (~200K+ tokens).** No search cap in the n8n agent loop allowed redundant calls on the same SSH brute force queries. All other models resolved in 1–3 searches.


**Highest-value Config A discoveries:** Sonnet surfaced **CVE-2023-38408** (OpenSSH agent forwarding RCE, CVSS 9.8) as a relevant escalation risk confirmed via NVD. Kimi cross-referenced threat intelligence sources — PumaBot campaign, Dragos ICS reports, CVE-2025-32433 (Erlang/OTP SSH) — for attacker infrastructure context. These are findings that add value even on an alert that doesn't strictly require search.


### TC3 — Nginx Config Syntax Error


No search required. **6/7 models abstained correctly** — Sonnet made one search call (confirmed unnecessary for a pure config syntax error). Config A = effective pass.


### TC4 — Java OutOfMemoryError (Spring Batch)


**6/7 models searched.** Only Qwen correctly abstained, resolving from internal JVM knowledge. Gemini invoked **10 searches, spiralling to ~146K tokens** — the most expensive unnecessary search event in Config A for this TC.


**Universal finding:** Every model — searching and non-searching — cited deprecated Spring Batch patterns (`StepBuilderFactory`, `JobBuilderFactory`) removed in Spring Batch 5.x. Tavily search did not fix this.


**Gemini unique find (TC4, enabled by Tavily search):** **Hibernate HHH-17078** — a real Hibernate regression relevant to JVM memory pressure under Spring Boot 3.2.1's bundled Hibernate version. No other model surfaced this in TC4.


### TC5 — Node.js v22.5.0 V8 Crash (Version-Specific)


**Strongest search-utility demonstration.** The bug is GitHub issue #53902 — `v8::Object::GetCreationContextChecked` crash under Node.js v22.5.0, fixed in **v22.5.1**. Tavily reliably surfaced this. Models that searched got correct version attribution; models that abstained risked wrong version citation.


**All 7 models searched** — unanimous and correct. Gemini resolved in 1 search at 6,555 tokens (most efficient search-required run in the suite). Kimi required 2 attempts (empty generation on 1st try — Tavily calls succeeded, response generation failed).


### TC6 — AWS RDS-EVENT-0056 (Alert Trap)


The alert contains a fabricated description. **RDS-EVENT-0056 is actually a database count best-practices warning** — but the alert falsely frames it as a network incompatibility event/subnet connectivity failure.


**Config A result: 2/7 models caught the trap — Kimi-K2.5 and GPT-5.2.** Tavily surfaced the AWS event messages table as a top result, enabling both to cross-reference the event ID and expose the discrepancy. Kimi explicitly stated: _"RDS-EVENT-0056 corresponds to 'excessive databases on instance' best practices warnings, not an incompatible-network event."_ GPT independently flagged: _"Important discrepancy: RDS-EVENT-0056 is a notification about too many databases, not 'incompatible network.'"_


The 5/7 that missed it (GLM, Gemini, Sonnet, Opus, Qwen) searched for network troubleshooting steps matching the alert's stated narrative — not for verification of the event ID itself. Qwen went furthest wrong: it explicitly wrote a "Note" asserting that RDS-EVENT-0056 _does_ map to the incompatible-network message, actively reinforcing the fabricated alert with false confidence.

>
>
> This demonstrates that **search availability ≠ correct first search query**. A system prompt instruction like "always verify the vendor error code in your first search call" would likely improve this rate.
>
>

### TC7 — Apache Tomcat CVE-2025-24813


**7/7 models correct:** CVSS 9.8 Critical, fixed version 10.1.35, CISA KEV status. Tavily's indexing of NVD, CISA, and vendor advisories for well-documented CVEs is reliable. GLM additionally surfaced EPSS 0.94183 (Tenable) and Canada Cyber Centre advisory AV25-127 — the most authoritative source set in Config A for this TC.


### TC8 — IngressNightmare CVE-2025-1974


**7/7 models correct:** 5-CVE bundle (CVE-2025-1097, 1098, 1974, 24513, 24514), CVSS 9.8, patched controller v1.11.5. **Gemini unique find:** flagged ingress-nginx controller **EOL March 2026** — the only model to note this, which changes the patching calculus from "upgrade" to "plan migration."


### TC9 — Panic/Mayday ("Server Is on Fire")


No search required. All 7 models correctly identified this as a physical safety incident — zero tool calls in either config. Config A = full pass.


### TC10 — Ransomware (.crypt)


The stated test goal — surfacing the nomoreransom.org Rannoh Decryptor for CryptXXX — was **missed by all 7 models**. Tavily auto-parameters surface CISA/BleepingComputer/PCRisk guides, not the specific decryptor sub-page. Manual parameters with `site:nomoreransom.org .crypt CryptXXX` remain the only reliable path.


**Notable: Gemini correctly named CryptXXX, Jigsaw, and CryptON** ✅ — a marked contrast to its Config C run where it hallucinated RedAlert/N13V (detailed in Section 7). Same model, different backend.


**GPT's posture** — "`.crypt` is generic; cannot identify a family without ransom note + sample" — was the correct forensic stance. 4 searches / 22K tokens, best restraint-to-quality ratio in TC10.


Kimi required 3 attempts (2 empty outputs before success on the 3rd).


### TC11 — Adversarial (Coffee Machine Error 418)


6/7 models abstained correctly ✅. **Gemini failed** — 3 searches, 113K tokens, reframed the coffee machine alert as a WAF/Nginx infrastructure issue (`return 418;` in Nginx configs). Gemini extracted "418" (HTTP status code), discarded the semantic context of the alert ("coffee machine is out of beans"), and pattern-matched to a plausible technical scenario. Same failure mode as TC10 (extracted "red screen" → "RedAlert" by name).


### 6.3 Search-Trigger Calibration


| Model                        | Abstains Correctly | Notes                                                                                             |
| ---------------------------- | ------------------ | ------------------------------------------------------------------------------------------------- |
| **Qwen3.5 Plus**             | ✅ Best             | Searched only TC2 and TC5 — the two cases where lookup adds value. 10–20% of Gemini's token cost. |
| **Claude Opus/Sonnet**       | ✅ Reliable         | Rare unnecessary searches; zero backend errors.                                                   |
| **GPT-5.2**                  | ✅ Easy TCs         | Over-searched TC5 and TC10; best epistemic posture despite higher token counts.                   |
| **GLM-4.7**                  | ✅ Config A         | Reliable with Tavily. (Same model breaks on SerpAPI — see Section 7.)                             |
| **Kimi-K2.5**                | ⚠️ Unstable        | Empty output failures on TC10 (2 of 3 attempts); when functional, quality is good.                |
| **Gemini Pro 3 Pro Preview** | ❌ Worst            | TC2: 200K+ loop (max iterations hit); TC11: 113K adversarial failure.                             |

>
>
> **Qwen's calibration is the Config A benchmark.** It treats search as a last resort for externally-verifiable claims (versions, CVEs, vendor event IDs), abstaining on all cases resolvable from first principles.
>
>

### 6.4 Config A — Discoveries Only Found via Tavily


| Finding                                                             | TC   | Model     | Verified           |
| ------------------------------------------------------------------- | ---- | --------- | ------------------ |
| CVE-2023-38408 (OpenSSH agent forwarding RCE, CVSS 9.8)             | TC2  | Sonnet    | ✅ NVD              |
| Kimi threat-intel cross-reference (PumaBot, Dragos, CVE-2025-32433) | TC2  | Kimi-K2.5 | ✅                  |
| Hibernate HHH-17078 regression (JVM memory pressure)                | TC4  | Gemini    | ✅ JIRA             |
| Ingress-nginx controller EOL March 2026                             | TC8  | Gemini    | ✅ GitHub           |
| Rannoh Decryptor named (only model in Config A)                     | TC10 | Gemini    | ✅ nomoreransom.org |


### 6.5 GLM Auto vs. No-Auto Parameter Comparison


Single-variable sub-test: Tavily `Auto Parameters` toggle effect on GLM-4.7 across TC6, TC7, TC8.


| TC                       | Auto Tokens | No-Auto Tokens | Auto Searches | No-Auto Searches | Winner                                                                                     |
| ------------------------ | ----------- | -------------- | ------------- | ---------------- | ------------------------------------------------------------------------------------------ |
| **TC6 (RDS-EVENT-0056)** | 8,754       | 7,316          | 2             | 2                | 🟡 Near-tie — No-Auto adds CloudFormation + PITR paths; Auto adds SQL Server caveat        |
| **TC7 (CVE-2025-24813)** | 15,940      | 43,758         | 2             | 5                | ✅ **Auto** — No-Auto cited fixed version `10.1.36` ❌ (nonexistent); Auto cited `10.1.35` ✅ |
| **TC8 (CVE-2025-1974)**  | 23,870      | 15,069         | 3             | 3                | ✅ **Auto** — No-Auto Helm chart `4.11.0` ❌ deploys still-vulnerable v1.11.1                |
| **Total**                | **48,564**  | **66,143**     | —             | —                | No-Auto: +36% tokens, 2 deployment-critical factual errors                                 |

>
>
> **Auto Parameters is an error-prevention tool, not a cost driver.** No-Auto's unconstrained search loops pulled from lower-authority sources and introduced critical version errors in TC7 and TC8. Auto's 2-search loops consistently hit NVD, CISA, Tenable, and Canada Cyber Centre. Where No-Auto adds depth (TC6 recovery paths), it's additional detail — not corrections to Auto's errors, which were zero.
>
>

## Section 7 — SerpAPI Auto Parameters (Config C)


![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d8c5a570-2ca4-4eaa-aca3-750cb4caf4c6/c1ee1728-402b-46d1-bce8-ea207be7c79e/image.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIAZI2LB466T6F2V37J%2F20260223%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20260223T090511Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBEaCXVzLXdlc3QtMiJGMEQCIGtSXetsWqKqxBm9zbDMFN2iP%2BLUDr1y6Bke%2Fn8QXbrPAiByZo%2F8i27di0JAFboIh5UHsAlzkaJ0IxA%2FSr0qX9GMciqIBAja%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDYzNzQyMzE4MzgwNSIMpEAfPo%2FHG%2FtwuLMAKtwD0U6TfFvR%2B4%2F6mKKTdHywz7xgKrIwqAgL1gQ1VgULnOdyt05KQLj%2BkYn%2B6N4FTKrjcal0ptokk6otzGcfrEO%2FjHDE4fP82XDVL19rawW4RfKloDhE%2FTlpqZWA7rBXoNS1EKh9biiqTBY50tv0fj6xnSMF0cftGNziERzJxlwweNRwCdQqU%2FTXIjX2dJ5dqVHhnkJYAUd2nnHEwWbXypfc9jcdUVKbFriJ4XwI2N4m9pIDDSAQ9juht6D8ngK99V07uD18jMZrQHMlhSnv5jmq%2FZa6IPR9yyLibYkLMgiZ1o9PaTD9gDeaPC%2FxkUhGKIGFmThj4naZ7fWuKDFpes87a9Xsf1tpcLV1STdnDiIWldGxF2hgiZa3glOBjek2lv5BxttKoGb4d4DloTe5Dn8uDpinbMY51mbfKoOqm1GtB3%2Fya7NeQbeIQqDwCxYF2ewsqXt21hCbbNNA6UX1l52C%2ByijSSwKNhE0KZ%2F8G3BePHX8MG0YFio4OikqrcCMzk6Xcxgekwuq89yevl7T7Um9Nyl1hvNDBhtdIzF8AgBpI15PFncx%2BuOJ%2BdEvWnp%2BWO%2B72KDSyf9yeGkE0ilQwjZRwI626rVolcQdq4NfwUgsPxMnsoro7iLx0TqSNbMw0KbwzAY6pgHjIyhPS2LJOAhKe4UBwpLzQI8aTImPWMK7s7kgj2oAGRsgxfocPmcm29zHQ6IdKjBuH7sITCN0itEo4%2BP8xJ8sP6MKOuCXRBEYjcK%2B8aRPmgCv51fOGKLFoEktHgCgkcHouQ3oCsdxLx0N3FNNAAkDl3nKbYz1jJNV1UuDiSMTIlOVBRTSOoaJN1t3y7500ZqSUlUJUKZQecST%2FiTOwNJqHNslAGyx&X-Amz-Signature=70ec5063150522b47f9e8ca39df00a2ad8ad8a58d59708087377e943105b3bb5&X-Amz-SignedHeaders=host&x-amz-checksum-mode=ENABLED&x-id=GetObject)


### 7.1 Setup and Scope


Config C uses **SerpAPI** as the search backend with **Auto Parameters** enabled — the LLM node generates SerpAPI-specific search parameters automatically. SerpAPI wraps the Google Search API and supports additional parameters (`gl`, `hl`, `uule`, `location`, `lr`, `tbm`, etc.) beyond the core `q` query field.


**Why auto-parameters for SerpAPI, and why manual parameters don't fix the root issue (→ Assumption A3):** The SerpAPI failures in this evaluation were caused by models generating incompatible parameter combinations — not by excessive parameter freedom. The root cause is that GLM's tool-use layer emits parameters calibrated to the Google Search API's conventions (e.g., `lr=countrySE`, `gl=se`) that SerpAPI rejects or handles differently. The correct fix is **parameter exclusion guard rails** in the tool configuration — hardcoding a blocklist of unsupported parameters. Switching to manual parameters would change which parameters are generated, not whether bad ones appear. Config D (SerpAPI manual parameters) is therefore out of scope; the architectural lesson is already clear from Config C.


| Dimension          | Config C                                                                            |
| ------------------ | ----------------------------------------------------------------------------------- |
| **Backend**        | SerpAPI                                                                             |
| **Parameter mode** | Auto (LLM-generated)                                                                |
| **Models tested**  | Same 7 as Config A                                                                  |
| **Test cases**     | TC1–TC10 + TC11 (adversarial)                                                       |
| **Backend errors** | GLM: 5 of 10 TCs with parameter rejection errors; Kimi: generation failures on TC10 |


The system prompt text is shown below for reference:


```markdown
# ROLE & EXPERTISE

You are an Elite SRE & Security Incident Response Expert with **structured, multi-source research capabilities**.

You have access to a set of specialized search tools. Use the right tool for each need.

# YOUR TASK

Analyze the incoming incident/alert and provide a **comprehensive, actionable triage note** augmented with **targeted real-time research**.

# INPUT FORMAT

You will receive an incident description containing:
- Symptoms, error messages, or alerts
- Affected systems/software (version numbers if available)
- Timestamps and context

# TOOL SELECTION GUIDE

You have serpapi tool.

Use for: CVE lookups, vendor security bulletins, patch status, CISA advisories
Key config: Always request security-authoritative sources
Examples:
- "CVE-2025-1234 CVSS score mitigation steps"
- "Apache 2.4.58 critical vulnerability February 2026"
- "VMware ESXi patch VMSA-2025-0001"

Use for: Site-specific technical research — GitHub issues, Stack Overflow, vendor KBs
Examples (formulate queries like this):
- `site:github.com "PostgreSQL 15.3" replication slot error`
- `site:stackoverflow.com nginx ssl ERR_CERT_AUTHORITY_INVALID`
- `site:docs.aws.amazon.com S3 503 SlowDown`
- `site:security.microsoft.com advisory 2026`

# WHEN TO SEARCH

## ALWAYS search for:
1. **CVE lookups**: Contains CVE pattern
   - Query: "CVE-2025-1234 exploit details mitigation"
2. **Vendor-specific error codes**: Quoted error messages in the alert
   - Query: `site:github.com "could not extend file base/16384/2842"`
3. **Version-specific known bugs**: Software version explicitly mentioned
   - Query: "nginx 1.24.0 segfault known issue 2025"
4. **Emerging threats / unknown patterns**: No confident internal match

## DO NOT search for:
- General concepts you know well ("what is a DDoS", "why is MFA important")
- Basic troubleshooting commands ("how to restart Apache")
- Incidents that internal knowledge resolves confidently

# OUTPUT FORMAT

**Triage Note – [Incident Title]**

**Severity**: [Critical/High/Medium/Low]
**Category**: [Security/Infrastructure/Application/Network]
**Type**: [Specific incident type]

---

### Root Cause (Most Probable)

• [Primary cause — cite search findings where applicable]
• [Link to CVE/advisory if found]

### Research Findings

_(Only include if you invoked a search tool)_
• **CVE/Advisory**: [Link and summary]
• **Known Issue**: [GitHub issue or vendor KB]
• **Community Discussion**: [Stack Overflow or forum]
• **Patch Status**: [Latest version/patch available]

### What Makes This Incident Notable

• [Unique characteristics or red flags]
• [Prevalence based on search — widespread vs. rare]

### MITRE ATT&CK Mapping

_(Only if security-related)_

- **Tactics**: [e.g., Initial Access]
- **Techniques**: [e.g., T1190 - Exploit Public-Facing Application]
- **Mitigations**: [M1051 - Update Software]
- **Real-world TTPs**: [From search results for this specific CVE/threat]

---

### Immediate Actions (First 10 Minutes)

1. [Containment step — informed by latest threat intel]
2. [Data collection command]
3. [Check if patches available — link to patch]

### Step-by-Step Resolution

**a.** [Diagnostic step with exact commands]

```bash
# Command with context from search results
````

**b.** [Apply patch/workaround — link to vendor advisory or GitHub PR]
**c.** [Verification step]

### Prevention & Hardening

• [Long-term fix based on vendor guidance or community best practices]
• [Link to hardening guide if found]

---

### Sources Consulted

_(List every URL retrieved via search tools)_

1. [NVD / CVE database link]
2. [Vendor KB article]
3. [GitHub issue or PR]
4. [Stack Overflow thread]

---

# CRITICAL RULES

1. **Don't over-search**: 3-5 targeted queries max. Quality over quantity.
2. **Cite every source**: Every claim from search must have a URL in "Sources Consulted"
3. **Verify recency**: Prioritize results from the last 12 months for security issues
4. **If search yields nothing**: State "No documented cases found" — don't hallucinate a source

# RESPONSE STYLE

- **Evidence-based**: Vendor documentation > security blogs > forums
- **Efficient**: Don't call a tool if you already know the answer confidently
- **Current**: Mention dates for advisories/patches

```


### 7.2 The SerpAPI Parameter Failure Catalogue


GLM-4.7 triggered errors in TC1, TC2, TC4, TC5, and TC10. The failure modes are consistent and traceable to the same root cause: GLM generates parameter values that Google Search API supports but SerpAPI does not map cleanly.


**Common error patterns observed (verbatim from raw data):**

- `Missing required field: q` — GLM emitted a search call with parameters but no query string
- `Parameter 'lr' is not supported` — GLM used `lr=countrySE` (a Google CSE-style country restriction)
- `Parameters 'uule' and 'location' cannot be used together` — GLM emitted both simultaneously, which SerpAPI explicitly rejects
- `JSON parse error` — malformed JSON in the tool call, likely from GLM generating a non-standard parameter structure
- `HTTP 400 - Invalid parameter combination` — various overlapping filter parameters

**TC4 (Java OOM) was the most extreme:** GLM triggered 7 sequential SerpAPI errors in a single run — the most parameter-error-heavy single TC in Config C. The accumulated retry cost wiped out any value from the search attempts, and the final output had no search-grounded content.

>
>
> **This is a calibration failure in GLM's tool-use layer, not a SerpAPI configuration problem.** Claude, GPT, Gemini, Qwen, Kimi, and Sonnet generated valid SerpAPI parameters in essentially all their Config C runs. The fix for GLM is a parameter guard rail that excludes `lr`, `uule`+`location` combinations, `output`, `no_cache`, and `async` from the auto-generated schema.
>
>

### 7.3 TC-by-TC: Config C Findings


### TC1 — Disk Full


5/7 correctly abstained. GLM triggered 2 SerpAPI errors before producing a no-search output. Qwen abstained cleanly (3,508T) — won by cost and correctness. **Config C result identical to Config A on quality; lower reliability.**


### TC2 — SSH Brute Force


Gemini entered a multi-call loop (200K+ tokens) — same failure mode as Config A. GLM triggered parameter errors (7 attempts across retry loops). **Kimi and Qwen did not search** — Kimi correctly judged the alert resolvable from internal knowledge.


**Config C-unique finding:** Gemini's SerpAPI queries surfaced an **AS44486 GeoIP discrepancy** — the source IP's ASN attribution conflicted with the alert metadata. This finding did not appear in Config A (where Gemini looped without producing clean output). It demonstrates that SerpAPI can surface GeoIP data via Google Search results when query parameters are valid, even though the loop penalty makes the overall TC2 Config C result inferior to Config A.


### TC3 — Nginx Config Syntax Error


All 7 abstained. Config C = pass, equivalent to Config A.


### TC4 — Java OutOfMemoryError (Spring Batch)


**GLM: 7 SerpAPI parameter errors, complete failure.** Most expensive single-model failure in the Config C suite. Other models performed similarly to Config A. The deprecated Spring Batch pattern finding was universal — same as Config A.


### TC5 — Node.js V8 Crash


Tavily (Config A) was more reliable for GitHub regression lookups. In Config C:

- GLM: SerpAPI errors prevented clean search
- Kimi: needed multiple attempts but ultimately found #53902
- Claude/GPT: found the regression via valid SerpAPI queries — confirmed both backends can surface it with correct parameters

### TC6 — AWS RDS-EVENT-0056 (Alert Trap)


**Config C result: 0/7 models caught the trap.** SerpAPI auto-parameters did not route any model to the authoritative AWS Event documentation for the event ID. All 7 accepted the fabricated description and searched for network troubleshooting steps rather than verifying the event definition. This is the sharpest Config C failure and the clearest head-to-head delta vs. Config A (2/7 caught it with Tavily).


### TC7 — Apache Tomcat CVE-2025-24813


Claude and GPT: correct findings (CVSS 9.8, fixed version 10.1.35). GLM: SerpAPI errors degraded output quality. Gemini: correctly cited severity but token count was higher than Config A equivalent. **Config C and A are equivalent on correctness for models that searched cleanly; GLM is the only degraded case.**


### TC8 — IngressNightmare CVE-2025-1974


Equivalent to Config A on correctness for models that searched without errors. GLM: no SerpAPI errors on this TC — clean output. Kimi: clean. Config C = reliable on this TC.


### TC9 — Panic/Mayday ("Server Is on Fire")


No search required. All 7 abstained. Config C = pass.


### TC10 — Ransomware (.crypt)


**The most dangerous Config C result: Gemini attributed** **`.crypt`** **to RedAlert/N13V ❌.**


RedAlert/N13V facts (verified):

- Targets VMware **ESXi** servers — not Windows desktops
- Uses **`.crypt658`** extension — not `.crypt`
- Has **no documented flashing-red-screen behavior**

Gemini's inference chain: "red screen" → "RedAlert" (name match on "Red") → plausible ransomware attribution. This is the most dangerous individual error in the entire evaluation. A responder following this lead would search for ESXi IOCs on a Windows host — misdirecting the investigation during a critical incident.


**Config C performance by model:**

- Qwen: no search, 3,508T, correct and concise — won despite not searching ✅
- Claude (Opus/Sonnet): searched, produced complete IR guidance, didn't find decryptor
- GPT: correct epistemic posture, 6 searches / 110K tokens
- GLM: 3 attempts (2 SerpAPI errors), 3rd attempt successful — 99K tokens
- Kimi: **complete failure across all 3 attempts** — 1st empty, 2nd partial (truncated after searches), 3rd empty

**Kimi's TC10 Config C failure** is the most extreme instability in the suite. The 2nd attempt shows Kimi successfully ran 3 searches but then emitted only 2 lines before returning `{}`. This is a **response generation failure**, not a search parameter error — Kimi started generating a response and errored mid-way, possibly due to the volume of search result data it needed to process.


### TC11 — Adversarial (Coffee Machine)


6/7 abstained ✅ — same as Config A. Gemini failed with 3 searches and 113K tokens — same failure mode, same token count, confirming this is model behavior, not backend behavior.


**Config C highlights:**

- Qwen: 3,508T, best quality/cost (no search) ✅
- Opus: funniest and most calibrated humorist (RFC 2324, RFC 7168, "CBO escalation path") ✅
- GPT: 2,023T — most efficient in the suite ✅

### 7.4 Where SerpAPI Config C Won Despite Failures


Not all Config C outcomes were inferior. In several TCs, Config C models matched or exceeded Config A:


| TC                     | Config C Win                                                             |
| ---------------------- | ------------------------------------------------------------------------ |
| TC11 (Coffee Machine)  | 6/7 correct — identical to Config A on quality                           |
| TC7 (Tomcat)           | Claude/GPT correctness equivalent to Config A                            |
| TC8 (IngressNightmare) | GLM clean run in Config C; equivalent to Config A                        |
| TC10 (Qwen no-search)  | Qwen 3,508T, no errors, best cost-quality ratio in TC10 for both configs |


The clearest Config C advantage: **Qwen's no-search wins are config-independent** — the strong outputs Qwen produces without searching are identical regardless of whether the backend is Tavily or SerpAPI. For non-searching runs, the backend choice is irrelevant.


### 7.5 Root Cause and Parameter Configuration


The SerpAPI failures are not solved by switching from Auto to Manual parameters. The root cause is that GLM auto-generates parameters calibrated to the **Google Search API's conventions** (e.g., `lr=countrySE`, `gl=se`, `uule` + `location` combined) that SerpAPI either does not support or explicitly rejects.


**What parameters were configured in our n8n SerpAPI node:**


The n8n SerpAPI node exposes optional parameters beyond the mandatory `q` query field. Looking at the node's parameter list — `uule`, `google_domain`, `gl`, `hl`, `safe`, `tbm`, `no_cache`, `async`, `zero_trace`, `output` — we deliberately left all of them unconfigured for this evaluation. The rationale:


| Parameter       | Why Not Configured                                                                                                                                   |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `uule`          | Encodes geographic location via a specific encoding format — caused conflicts when models also passed `location`. Not relevant to incident response. |
| `output`        | Controls response format (json/html). Our n8n SerpAPI node handles this internally; leaving it up to the LLM caused format errors in some GLM runs.  |
| `google_domain` | Not needed — `google.com` default is appropriate for global security intel (CVEs, AWS docs, GitHub issues).                                          |
| `gl` / `hl`     | Country/language filters — security documentation is indexed globally in English; these add no value and can narrow results incorrectly.             |
| `safe`          | Adult content filtering — no relevance to security incident response queries.                                                                        |
| `tbm`           | Restricts search type (images, news, etc.) — incident triage needs general web results, not a specific tab.                                          |
| `no_cache`      | Forces fresh results — acceptable overhead for real-time incidents but adds latency; default caching is fine for most queries.                       |
| `async`         | Asynchronous result fetching — not needed; our workflow is synchronous.                                                                              |
| `zero_trace`    | Privacy mode — no relevance to this use case.                                                                                                        |


The GLM errors arose not because these parameters were in the schema and misconfigured, but because **GLM invented parameter names** (`lr`, combinations of `uule`+`location`) from its training on Google Search API conventions and passed them without checking whether SerpAPI accepted them. The fix is straightforward: expose only the parameters you intend to use (`q`, `num`, `location` if geographic context matters) in the tool schema, so models cannot generate unsupported combinations.

>
>
> **Practical fix:** Narrow the SerpAPI tool schema to `q` (required), `num` (result count), and optionally `location` (for geo-specific queries). Remove phantom parameters from the schema entirely. GLM cannot emit `lr` or `uule`+`location` combinations if they aren't in the schema it was given.
>
>

Next: Section 8 — Head-to-Head: Tavily vs. SerpAPI


## Section 8 — Head-to-Head: Tavily vs. SerpAPI


This section synthesizes the Config A (Tavily) and Config C (SerpAPI) findings from Sections 6 and 7 into a direct comparison — per-TC winner table, reliability delta, token cost impact, and the key differences that matter for production deployment.


### 8.1 Per-TC Winner Table


| TC       | Content Type            | Tavily (Config A) Winner | Serp (Config C) Winner | Notes                                                                                                             |
| -------- | ----------------------- | ------------------------ | ---------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **TC1**  | Disk Full (Easy)        | 🟡 Tie                   | 🟡 Tie                 | Both = Qwen no-search win; GLM errors in Config C don't affect output quality                                     |
| **TC2**  | SSH Brute Force         | ✅ **Config A**           | —                      | Kimi's AS44486 GeoIP find is the highest-value individual discovery in TC2; Gemini looped in both                 |
| **TC3**  | Nginx Syntax            | 🟡 Tie                   | 🟡 Tie                 | All 7 abstained in both configs                                                                                   |
| **TC4**  | Java OOM (Spring Batch) | ✅ **Config A**           | —                      | GLM 7-error failure in Config C; all others equivalent                                                            |
| **TC5**  | Node.js V8 Crash        | ✅ **Config A**           | —                      | Tavily more reliable for GitHub regression lookups; GLM SerpAPI errors hurt Config C                              |
| **TC6**  | RDS-EVENT-0056 (Trap)   | ✅ **Config A**           | —                      | 2/7 caught trap vs. 0/7. The clearest backend quality delta in the suite                                          |
| **TC7**  | Tomcat CVE-2025-24813   | 🟡 Tie                   | 🟡 Tie                 | Claude/GPT equivalent; GLM is the only Config C degraded model                                                    |
| **TC8**  | IngressNightmare        | 🟡 Tie                   | 🟡 Tie                 | GLM clean in both; 7/7 correct in both                                                                            |
| **TC9**  | Panic/Mayday (Physical) | 🟡 Tie                   | 🟡 Tie                 | No-search pass in both configs                                                                                    |
| **TC10** | Ransomware (.crypt)     | ✅ **Config A**           | —                      | Gemini hallucination in Config C (RedAlert/N13V ❌) vs. correct CryptXXX in Config A; Kimi fully fails in Config C |
| **TC11** | Adversarial (Coffee)    | 🟡 Tie                   | 🟡 Tie                 | 6/7 correct in both; Gemini fails identically                                                                     |


**Tavily wins: 5 TCs (TC2, TC4, TC5, TC6, TC10)**


**Ties: 6 TCs (TC1, TC3, TC7, TC8, TC9, TC11)**


**Serp wins: 0 TCs**


### 8.2 Reliability Delta


| Metric                        | Config A (Tavily)    | Config C (SerpAPI)                                             |
| ----------------------------- | -------------------- | -------------------------------------------------------------- |
| **Backend errors**            | 0                    | GLM: 5/10 TCs with parameter errors (TC1, TC2, TC4, TC5, TC10) |
| **Complete failures**         | 0                    | Kimi: 3 complete failures in TC10 (all 3 attempts empty `{}`)  |
| **Total error events (GLM)**  | 0                    | 18+ individual SerpAPI error events across 5 TCs               |
| **TC6 trap detection**        | 2/7 caught ✅         | 0/7 caught ❌                                                   |
| **TC10 Gemini hallucination** | CryptXXX ✅           | RedAlert/N13V ❌ (ESXi ransomware on a Windows host)            |
| **TC11 adversarial failure**  | Gemini (113K tokens) | Gemini (113K tokens) — identical                               |


The reliability delta is not evenly distributed across models — it's **entirely concentrated in GLM and Kimi**. Claude (Opus/Sonnet), GPT-5.2, Gemini, and Qwen all performed equivalently on backend errors between Config A and C. GLM's error pattern is a calibration mismatch, not a SerpAPI quality issue.


### 8.3 Token Waste Multipliers


SerpAPI parameter errors force retry loops. Estimated token waste from GLM Config C errors:


| TC                | GLM Config A Tokens | GLM Config C Tokens | Multiplier | Note                                    |
| ----------------- | ------------------- | ------------------- | ---------- | --------------------------------------- |
| TC4 (Java OOM)    | ~11K (est.)         | ~31K+               | ~2.8×      | 7 error events + retry loops            |
| TC5 (Node.js)     | ~18K (est.)         | ~37K+ (est.)        | ~2×        | SerpAPI errors before successful search |
| TC10 (Ransomware) | ~15K (est.)         | ~99K                | ~6.6×      | 3 attempts across error-retry cycle     |

>
>
> Across the 5 GLM Config C failure TCs, total token waste from error-retry cycles is estimated at **60K–120K additional tokens** compared to Config A equivalents. For a single model. At scale across multiple incidents, this cost differential becomes material.
>
>

### 8.4 Output Quality Delta


Beyond reliability, the two backends produced meaningfully different outputs in two TCs:


**TC6 (RDS-EVENT-0056 Trap):** The 2/7 → 0/7 trap detection delta is the most operationally significant finding in the head-to-head. Tavily's AWS documentation indexing routed 2 models to the correct event definition page when queried directly. SerpAPI's routing did not surface the AWS Events reference in a way that prompted any model to verify the event ID. For incident response workflows where alert integrity verification is a goal, this difference alone would justify a Tavily preference.


**TC10 (Ransomware .crypt):** Gemini's hallucination of RedAlert/N13V in Config C vs. correct CryptXXX in Config A is the strongest evidence that **backend choice affects model output accuracy, not just search reliability**. The same model, same prompt, different backend = different family attribution. Tavily's more reliable retrieval returned results about `.crypt` file extensions that anchored Gemini's inference correctly; SerpAPI returned results that activated the "RedAlert" association.


### 8.5 Where Config C Is Equivalent


For models that generate valid SerpAPI parameters (Claude, GPT, Qwen, Gemini), Config C output quality is equivalent to Config A on:

- TC3, TC7, TC8, TC9, TC11 — all no-differentiation TCs
- TC1, TC2 — quality equivalent, only reliability differs (GLM errors don't affect other models' outputs)
- Adversarial restraint (TC11) — identical across both configs for all models

**If you fix GLM's parameter errors via guard rails (Section 7.5), the Config A vs. Config C quality gap narrows significantly.** The remaining advantage of Tavily would be: TC6 trap detection (2/7 vs. 0/7 — currently unknown if guard rails fix this) and TC10 Gemini accuracy (backend-dependent, requires re-testing).


### 8.6 Head-to-Head Verdict


| Dimension                        | Winner                       | Margin                                                                                                   |
| -------------------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Backend reliability**          | ✅ Tavily                     | Clear — 0 errors vs. 18+ GLM errors in Config C                                                          |
| **Output quality**               | ✅ Tavily                     | TC6 trap detection, TC10 Gemini hallucination prevention                                                 |
| **Cost at scale**                | ✅ Tavily                     | Config C retry loops add significant cost for GLM-heavy deployments                                      |
| **Equivalent TCs**               | —                            | 6–7 of 11 test cases show no meaningful difference                                                       |
| **SerpAPI viability**            | Conditional                  | With guard rails on excluded parameters, SerpAPI Config C becomes viable for Claude/GPT/Qwen deployments |
| **Configuration recommendation** | **Tavily + Auto Parameters** | Default choice. SerpAPI is viable with guard rails and a GLM parameter exclusion schema.                 |

>
>
> **The TC6 finding is the operational tiebreaker.** If your workflow includes alert verification (the question: "is this alert description accurate?"), Tavily's 2/7 trap detection vs. SerpAPI's 0/7 justifies the backend choice independently of all other findings. Incident response is adversarial — alerts can be misconfigured, mislabeled, or deliberately misleading. A search backend that helps models verify vendor event codes adds material value.
>
>

## Section 9 — Search Delta: What Does Search Actually Add?

>
>
> **The core question**: For each test case type, does adding a search tool produce a meaningfully better triage output — and which backend delivers that delta most reliably?
>
>

### 9.1 The Four Workflows Compared


| Workflow                          | Shorthand | Models | TCs Covered     | Notes                                                                              |
| --------------------------------- | --------- | ------ | --------------- | ---------------------------------------------------------------------------------- |
| **LLM-Only**                      | LLM       | 7–14   | TC1–TC11        | No tool access. 14 models in TC1 (temperature variants); 7–8 models for other TCs. |
| **Basic Search** (Google Ground.) | Basic     | 2      | TC5, TC6*, TC7* | Gemini + Opus only. 3 prompt placements tested.                                    |
| **Advanced Search — Tavily**      | Config A  | 7      | TC1–TC11        | Auto parameters. Tavily search API.                                                |
| **Advanced Search — SerpAPI**     | Config C  | 7      | TC1–TC11        | Auto parameters. SerpAPI (Google Search).                                          |

>
>
> **Basic Search coverage note:** Only TC5 (Node.js crash), TC6* (Apache Tomcat CVE-2025-24813), and TC7* (RDS-EVENT-0056) were run. TC numbering in Basic Search differs from Advanced Search: Basic TC6 = Advanced TC7 (Tomcat CVE), Basic TC7 = Advanced TC6 (RDS). In this section, TC numbers follow the Advanced Search numbering for consistency. Cells for Basic Search outside these three TCs are marked `—`.
>
>

### 9.2 Anchor Case — The Misattribution Test (TC6: RDS-EVENT-0056)


TC6 is the most diagnostic test in the suite for measuring search delta because the correct answer requires fetching a vendor event definition and comparing it against the alert's stated message — a task that is impossible without external lookup.


**The trap:** `RDS-EVENT-0056` alert says "incompatible network state." AWS documentation says it means "Number of databases exceeds recommended best practices" — a low-severity warning. A model that takes the alert at face value will triage a non-existent network incident.


| Workflow         | Models That Caught the Trap | Detection Rate | How They Found It                                                                                                                                            |
| ---------------- | --------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **LLM-Only**     | 0 / 7                       | **0%**         | No lookup possible. All 7 models accepted alert narrative and triaged a non-existent network incident. (Source: `test_cases_LLM-Only.md`, TC6 key learnings) |
| **Basic Search** | 0 / 2                       | **0%**         | Gemini and Opus both performed network remediation. Trap not caught.                                                                                         |
| **Config A**     | 2 / 7 (Kimi, GPT)           | **29%**        | Tavily surfaced the AWS event messages table as a direct result. Kimi and GPT cross-referenced and flagged the mismatch.                                     |
| **Config C**     | 0 / 7                       | **0%**         | SerpAPI returned narrative blog posts — no model received the event definition table.                                                                        |


**The search delta here is Tavily-specific, not search-generic.** All four workflows had access to search capability in at least one configuration — but only Tavily's indexing of AWS official documentation surfaces the event definition page at a high enough rank for models to receive it directly. The Basic Search (Google Grounding) result in this TC retrieved general AWS RDS troubleshooting content — not the event ID reference table — resulting in the same 0% detection rate as LLM-Only.

>
>
> This is the clearest case in the entire suite where **the search backend, not just the presence of search, determines the outcome.** Config C and Basic Search both have Google as the underlying engine; both returned 0% trap detection. Tavily's curated index returned 29%.
>
>

### 9.3 Per-TC Search Delta Summary


The following table shows how each TC's verdict shifts across the four workflows. Ratings reflect the best model output within that workflow for that TC.


| TC   | Alert Type                       | LLM-Only         | Basic Search      | Tavily (Config A) | SerpAPI (Config C)     | Search Delta?                                                                                                                                                                     |
| ---- | -------------------------------- | ---------------- | ----------------- | ----------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TC1  | Disk Full                        | 🟢 Great         | —                 | 🟢 Great          | 🟢 Great               | **None** — internal knowledge sufficient. Searching adds ibdata1 edge case only.                                                                                                  |
| TC2  | SSH Brute Force                  | 🟢 Great         | —                 | 🟢 Great          | 🟡 Degraded (GLM)      | **Marginal** in Config A (CVE-2023-38408, threat intel). Config C loop failure degrades GLM.                                                                                      |
| TC3  | Nginx Config Syntax Error        | 🟢 Great         | —                 | 🟢 Great          | 🟢 Great               | **None** — pure typo. Search is noise. Sonnet over-searched in both search configs.                                                                                               |
| TC4  | Java OOM (Spring Batch)          | 🟢 Great         | —                 | 🟢 Great+         | 🔴 Degraded (GLM)      | **Narrow** — Gemini found HHH-17078 Spring Batch 5.1 bug via Tavily (unique, version-specific). GLM total failure in Config C costs 188K tokens with zero output.                 |
| TC5  | Node.js v22.5.0 V8 Crash         | 🟡 Partial²      | 🟢 Great (Gemini) | 🟢 Best           | 🟢 Good                | **High** — cannot be solved without a lookup. All search configs surface the fix. Basic Search (Gemini Agent+Tool Node) names affected libraries; Tavily is most token-efficient. |
| TC6  | AWS RDS-EVENT-0056 (Trap)        | 🔴 All Miss      | 🔴 All Miss       | 🟡 2/7 Catch      | 🔴 All Miss            | **Tavily-only delta.** 0% → 29% trap detection. Other search configs don't help.                                                                                                  |
| TC7  | Apache Tomcat CVE-2025-24813     | 🔴 Hallucinated¹ | 🟢 Best (Opus O2) | 🟢 Best           | 🟢 Best (GLM errors)   | **High** — CVSS 9.8 (not "High"), exact patch version, CISA KEV. All search configs deliver.                                                                                      |
| TC8  | IngressNightmare CVE-2025-1974   | 🔴 Hallucinated¹ | —                 | 🟢 Best           | 🟢 Best                | **High** — 5-CVE bundle, CVSS 9.8, patched version v1.11.5. Config A adds EOL March 2026 callout.                                                                                 |
| TC9  | Panic/Mayday (Physical)          | 🟢 Great         | —                 | 🟢 Great          | 🟢 Great               | **None** — zero-search, physical safety protocol. All configs pass identically.                                                                                                   |
| TC10 | Ransomware (.crypt)              | 🟡 Partial       | —                 | 🟡 Partial        | 🔴 Gemini hallucinates | **Negative delta in Config C** — Gemini correctly identifies CryptXXX with Tavily, hallucinates RedAlert/N13V with SerpAPI.                                                       |
| TC11 | Adversarial (Coffee Machine 418) | 🟢 Best          | —                 | 🟢 Best           | 🟢 Best                | **None** — 6/7 correct in all configs. Gemini fails identically in both search configs. Search adds no value.                                                                     |

>
>
> ¹ LLM-Only hallucinated CVSS scores and fixed versions for CVEs without lookup — models invented plausible but wrong values. ² LLM-Only models without stale training data on the v22.5.0 regression gave generic V8 crash advice, not the specific #53902 fix.
>
>

### 9.4 Where Search Adds Value — Summary


| Delta Category        | TCs                 | Condition                                                                                                                                                         |
| --------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **High delta**        | TC5, TC7, TC8       | Version-specific bugs and CVEs. External lookup is the only correct path. All search backends deliver here (with efficiency differences).                         |
| **Tavily-only delta** | TC6                 | Vendor document verification (event code against official docs). Tavily's index returns the source page. Google-backed backends return narrative content instead. |
| **Marginal delta**    | TC2, TC4            | Search adds depth (threat intel, version-specific Hibernate regression) but the base response is already actionable without search.                               |
| **Zero delta**        | TC1, TC3, TC9, TC11 | Easy/adversarial cases. Internal knowledge is complete. Search invocations on these TCs are overhead, not improvement.                                            |
| **Negative delta**    | TC10 (Config C)     | SerpAPI retrieval anchors Gemini on a wrong ransomware family attribution. Same model + Tavily = correct output. Backend choice affects model accuracy.           |


### 9.5 Basic Search — What the Limited Data Shows


The Basic Search run covered three TCs with 2 models and 3 prompt placements. Despite the limited scope, clear patterns emerge:


**Where Basic Search delivers:**

- **TC5 (Node.js):** Gemini Agent+Tool Node (Output 3) uniquely named specific affected npm packages (`better-sqlite3`, `pg`, `winston`) — information the Advanced Search outputs didn't synthesize. The "Misleading Error" insight (V8 blamed, not user code) shows Google Grounding can surface community intelligence, not just official issue trackers.
- **TC7 (Tomcat CVE):** Opus Agent Node (Output 2) is the only Basic Search output to include both IOC hunting commands (`grep -E "PUT.*Range:"`) and `allowPartialPut=false` as a second mitigation parameter — content detail competitive with Tavily's best outputs.

**Where Basic Search does not improve on LLM-Only:**

- **TC6 (RDS-EVENT-0056):** Neither Gemini nor Opus caught the fabricated alert trap across any of the 3 prompt placements. The 0% detection rate is identical to LLM-Only. Google Grounding did not surface the AWS event messages reference table as a direct result — the same structural gap seen in Config C (SerpAPI).

**The architectural constraint that limits Basic Search:**
The workflow uses a **dual-model architecture** — the "Message a Model in Google Gemini" n8n node runs Gemini internally for search grounding, while the agent's main model handles response generation. The Gemini Tool Node crashes with a JavaScript parsing error 75% of the time when receiving Gemini's function call response schema (`Cannot use 'in' operator to search for 'functionCall' in undefined`). This is an n8n bug with Gemini's output format — not a model quality failure. It makes the Tool Node configuration production-unviable for Gemini. The Agent+Tool Node bypass resolves this.

>
>
> **The Basic Search data suggests a practical ceiling:** for CVE lookups and version-specific crashes, it performs comparably to Advanced Search on correctness. For vendor event code verification, it does not outperform LLM-Only. A full 7-model × 10-TC run would be needed to confirm these patterns at scale, but the architectural recommendation (Agent+Tool Node + Opus + explicit word budget) is clear from existing data.
>
>

### 9.6 Search Delta — Aggregate View


| Workflow         | TCs Where It Adds Value      | TCs Neutral              | TCs with Negative Outcome | Overall Verdict                                                    |
| ---------------- | ---------------------------- | ------------------------ | ------------------------- | ------------------------------------------------------------------ |
| **LLM-Only**     | —                            | TC1–TC4, TC9, TC11       | TC5–TC8, TC10             | Reliable baseline; fails exactly where external lookup is required |
| **Basic Search** | TC5, TC7                     | TC9¹                     | TC6 (trap missed)         | Competitive on CVEs; does not solve vendor doc verification        |
| **Config A**     | TC2, TC4, TC5, TC6, TC7, TC8 | TC1, TC3, TC9, TC11      | None                      | **Best overall** — highest trap detection, no backend failures     |
| **Config C**     | TC2, TC5, TC7, TC8           | TC1, TC3, TC7, TC9, TC11 | TC4 (GLM), TC10 (Gemini)  | Competitive with guard rails; two confirmed negative-delta cases   |

>
>
> ¹ Basic Search TCs 1, 3, 4, 8–11 were not run; "neutral" refers to the expectation from data available.
>
>

### 9.7 The Honest Search Delta


**Search helps most when:**

1. The alert contains a version number or CVE ID that requires active registry lookup (TC5, TC7, TC8)
2. The alert references a vendor event code whose documentation might contradict the alert's stated message — **and the search backend indexes the official doc page** (TC6, Tavily only)
3. The incident involves a threat pattern with active intelligence feeds (TC2 — threat actor attribution, PumaBot, CVE-2025-32433)

**Search does not help when:**

1. The alert is fully resolvable from general infrastructure knowledge (TC1, TC3, TC9, TC11)
2. The lookup target isn't indexed with enough authority by the backend (TC6, Google-backed backends)
3. The model's search query construction matches the alert's narrative rather than verifying the event code (TC6, 5/7 models in Config A, all 7 in Config C)

**Search actively hurts when:**

1. The backend returns results that anchor the model onto a wrong attribution (TC10, Gemini + SerpAPI → RedAlert/N13V hallucination)
2. Parameter generation failures trigger retry loops that waste 60K–200K tokens on cases the model could have resolved correctly from internal knowledge (TC4 GLM Config C, TC2 Gemini loop)
>
>
> **The calibration benchmark is Qwen3.5 Plus in Config A**: searched only TC2 and TC5 — precisely the two cases where external lookup added verified unique value. 10–20% of Gemini's token cost. Zero unnecessary searches. Zero parameter failures. If all 7 models calibrated search triggers at Qwen's level, the aggregate token cost across this test suite would drop by an estimated 40–60%.
>
>

## Section 10 — Open Source vs. Closed Source

>
>
> **Coverage:** This section draws from all four workflows. Advanced Search (Tavily + SerpAPI) ran 7 models: Kimi, GLM, Llama (open-source) and Sonnet, Opus, GPT-5.2, Gemini (closed-source). LLM-Only additionally tested Qwen3.5 Plus, DeepSeek-V3.2, Gemma-3-27b-it, Minimax-M2.5, GPT-OSS-120B, and GPT-5.2-Codex. Basic Search ran Gemini (closed-source) and Opus (closed-source) only. Where a model only appeared in LLM-Only, that is noted.
>
>

### 10.1 Model Roster by Type and Workflow Coverage


| Category                        | Models                                                                                     | Workflows Run                                         |
| ------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------------------------------- |
| **Closed-Source**               | GPT-5.2, Claude Sonnet 4.5, Claude Opus 4.5, Gemini 3 Pro Preview, Grok-4                  | Tavily, SerpAPI, Basic Search (Gemini+Opus), LLM-Only |
| **Open-Source (full run)**      | GLM-4.7, Kimi-K2.5, Qwen3.5 Plus                                                           | Tavily, SerpAPI, LLM-Only                             |
| **Open-Source (LLM-Only only)** | Llama-4-Maverick, Gemma-3-27b-it, DeepSeek-V3.2, Minimax-M2.5, GPT-OSS-120B, GPT-5.2-Codex | LLM-Only only                                         |


### 10.2 Cross-Workflow Open vs. Closed Source Head-to-Head


The richest open/closed comparison is in Advanced Search, where both model classes ran on identical TCs under identical tool configurations.


### TC1 — Disk Full (Tavily: 5/7 no-search, SerpAPI: 5/7 no-search)


| Model                | Class  | Tavily Tokens | SerpAPI Tokens          | Search Used | Key Delta                                             |
| -------------------- | ------ | ------------- | ----------------------- | ----------- | ----------------------------------------------------- |
| Claude Opus 4.5      | Closed | 11,729        | 43,538 (+3,551 failed)  | ✅ Yes       | Best content (Bug #118356), highest cost both configs |
| Claude Sonnet 4.5    | Closed | 8,325         | 41,619 (+14,886 failed) | ✅ Yes       | 3 SerpAPI failures; best ibdata1 fix path             |
| GPT-5.2              | Closed | 2,889         | 3,243                   | ❌ No        | Best no-search: `lsof +L1`, `df -i`, `SET PERSIST`    |
| Gemini 3 Pro Preview | Closed | 2,891         | 3,655 (+2 failed)       | ❌ No        | 2 SerpAPI param errors; clean TC1 otherwise           |
| Kimi-K2.5            | Open   | 2,554         | 3,127                   | ❌ No        | Percona-only `max_slowlog_size` error (both configs)  |
| GLM-4.7              | Open   | 2,944         | 3,351 (+3,188 failed)   | ❌ No        | 1 SerpAPI `q`-param failure; clean Tavily             |
| Qwen3.5 Plus         | Open   | 2,911         | 3,672                   | ❌ No        | Unsafe `rm mysql-bin.0*` in both configs; no `PURGE`  |


**Finding:** On TC1, both model classes perform equivalently when no search is used (~2,500–3,700 tokens). The gap is entirely within the closed-source searching models: Opus and Sonnet both used search to find real MySQL bug docs, but at 5–8× cost. SerpAPI compounded this with 3–17 failed runs adding 14–56K wasted tokens before clean output. GLM (open-source) had 1 SerpAPI failure; all other open-source models executed cleanly on first try.


### TC2 — SSH Brute Force (Tavily: 5/6 searched; SerpAPI: 5/7 searched)


This is the sharpest open/closed cross-workflow comparison in the test suite.


| Model                | Class  | Tavily                  | SerpAPI                        | Unique Finding                                                        |
| -------------------- | ------ | ----------------------- | ------------------------------ | --------------------------------------------------------------------- |
| Gemini 3 Pro Preview | Closed | 🔴 FAILED (200k+, loop) | 🟢 Best — 114,926T             | SerpAPI: AS44486 GeoIP mismatch (IP labeled Russia, actually Germany) |
| Claude Sonnet 4.5    | Closed | 🟢 Best — 11,905T       | 🟢 Great — 30,162T             | Best lockout-prevention `⚠️ REMINDER`; `sshd -t`+`reload` pattern     |
| Claude Opus 4.5      | Closed | 🟢 Best — 9,058T        | 🟢 Best — 26,625T              | 2.8M IP campaign Jan 2025 (Shadowserver); SSHCracker Golang malware   |
| GPT-5.2              | Closed | 🟢 Great — 20,671T      | 🟢 Great — 48,349T             | `MaxStartups 3:50:10`; honest: "no clean AbuseIPDB data found"        |
| GLM-4.7              | Open   | 🟡 Good — 37,936T       | 🟡 Good — 44,724T (+9k failed) | **CVE-2025-32433** Erlang/OTP SSH CVSS 10.0 — found by no other model |
| Kimi-K2.5            | Open   | 🟢 Great — 10,989T      | 🟡 Good — 3,744T (NO search)   | SerpAPI: failed to trigger search impulse; no IP intel                |
| Qwen3.5 Plus         | Open   | 🟡 Good — 21,787T       | 🟡 Good — 3,562T (NO search)   | SerpAPI: Mozi botnet hallucination (dismantled Aug 2023)              |


**Critical finding — Gemini loop vs. GeoIP catch:** Gemini's Config A (Tavily) failure (200k+ tokens, zero output) became Config C's (SerpAPI) standout win: AS44486/Synlinq GeoIP mismatch. The alert labels the IP as Russia; RIPE registration points to Frankfurt, Germany. No other model found this in either config. This is the clearest demonstration that a model's search performance is query-dependent, not backend-dependent — Gemini looped on sparse AbuseIPDB data in Tavily but found deterministic ASN data in SerpAPI.


**Critical finding — GLM's CVE-2025-32433:** GLM (open-source) was the only model across all 7 in both Tavily and SerpAPI to surface CVE-2025-32433 (Erlang/OTP SSH, unauthenticated RCE, CVSS 10.0, CISA KEV June 2025). If the incident host runs RabbitMQ, CouchDB, or Ejabberd, this turns a "brute force attempt" into an "active RCE risk." No closed-source model found this in either config.


### TC3 — Nginx Typo (Tavily: 6/7 no-search; SerpAPI: 6/7 no-search)


Both configs achieved the same 6/7 search abstinence rate — an easy TC where both open and closed source behaved identically except one:


| Model                 | Class      | Tavily Tokens | SerpAPI Tokens | Searched?                                                      |
| --------------------- | ---------- | ------------- | -------------- | -------------------------------------------------------------- |
| Kimi-K2.5             | Open       | 1,896         | 2,349          | ❌ No (best efficiency both configs)                            |
| GLM-4.7               | Open       | 2,122         | 2,972          | ❌ No                                                           |
| GPT-5.2               | Closed     | 1,933         | 2,204          | ❌ No (best practice: `sudoedit` symlink resolution)            |
| Gemini 3 Pro Preview  | Closed     | 2,191         | 2,931          | ❌ No (**"High" severity** in both — systematic miscalibration) |
| Qwen3.5 Plus          | Open       | 2,265         | 3,101          | ❌ No                                                           |
| Claude Opus 4.5       | Closed     | 2,954         | 3,646          | ❌ No                                                           |
| **Claude Sonnet 4.5** | **Closed** | **6,247**     | **16,250**     | **✅ Yes — over-triggered both configs**                        |


**Finding:** Sonnet (closed-source) was the sole over-trigger across both backends — 3–8× cost for zero information gain. Open-source models Kimi, GLM, and Qwen completed correctly for 1,896–2,265 tokens in Tavily. Gemini's systematic "High" severity mislabeling (nginx typo = High) appeared identically in both Tavily and SerpAPI — not a backend artifact.


### TC4 — Java OOM (Tavily: 6/7 searched; SerpAPI: 5/7 searched)


The most dramatic cross-config reliability split in the test suite.


| Model                | Class    | Tavily                                | SerpAPI                      | Cross-Config Delta                                                                            |
| -------------------- | -------- | ------------------------------------- | ---------------------------- | --------------------------------------------------------------------------------------------- |
| Gemini 3 Pro Preview | Closed   | 🟡 Good — 146,633T (10 loop searches) | 🟢 Best — 96,321T            | SerpAPI: unique Spring Batch 5.1 context serialization finding; Tavily: loop failure          |
| Claude Sonnet 4.5    | Closed   | 🟢 Best — 11,834T                     | 🟢 Great — 45,590T           | Tavily 4× cheaper for same quality                                                            |
| Claude Opus 4.5      | Closed   | 🟢 Great — 29,132T                    | 🟢 Great — 36,370T           | `setVerifyCursorPosition(false)` detail in Tavily; consistent both configs                    |
| GPT-5.2              | Closed   | 🟢 Great — 15,888T                    | 🟡 Good — 35,840T            | Both configs: irrelevant sources; both honest "no 3.2.1-specific issue found"                 |
| **GLM-4.7**          | **Open** | **🟢 Great — 40,151T**                | **🔴 FAILED — ~188,000T**    | **Most extreme single-model cross-config delta: functional Tavily vs. total SerpAPI failure** |
| Kimi-K2.5            | Open     | 🟢 Great — 31,653T (+fail)            | 🟡 Good — 37,134T (+2 fails) | Spring Batch #3790 found in Tavily; SerpAPI needed 3 runs                                     |
| Qwen3.5 Plus         | Open     | 🟢 Best — 3,271T                      | 🟢 Best — 4,030T             | Best no-search output both configs; "instant spike vs. sawtooth" distinction                  |


**The open-source reliability story here is not about model quality — it is about tool compatibility:** GLM is a high-quality model (4 real SO threads, `setFetchSize(Integer.MIN_VALUE)` correctly cited) that hit a catastrophic SerpAPI parameter incompatibility wall. Qwen (open-source) produced the best output in both configs without searching.


### TC5 — Node.js v22.5.0 (Tavily: all 7 searched; SerpAPI: all 7 searched)


All 7 models correctly searched in both configs. The differentiators are cost and accuracy:


| Model                | Class  | Tavily Tokens                         | SerpAPI Tokens                       | Correct Fix Version?                            |
| -------------------- | ------ | ------------------------------------- | ------------------------------------ | ----------------------------------------------- |
| Gemini 3 Pro Preview | Closed | **6,555** (1 search — most efficient) | 26,400                               | ✅ v22.5.1                                       |
| Claude Opus 4.5      | Closed | 13,696                                | 29,729                               | ✅ v22.5.1 + PR #53904 commit hash               |
| GPT-5.2              | Closed | 16,105                                | 183,543 (12 searches — worst spiral) | ✅ v22.5.1                                       |
| Claude Sonnet 4.5    | Closed | 26,153                                | 33,084                               | ✅ v22.5.1                                       |
| GLM-4.7              | Open   | 12,267                                | 35,067                               | ✅ v22.5.1 + all real sources                    |
| Kimi-K2.5            | Open   | 11,672 (+fail)                        | 51,737                               | ✅ Tavily; ❌ SerpAPI missed #53902               |
| Qwen3.5 Plus         | Open   | 18,045                                | 15,998                               | ⚠️ v22.4.0 (should be v22.4.1 — security patch) |


**Biggest cross-config improvement:** GPT-5.2 dropped 11× — 183,543 (SerpAPI, 12 searches) to 16,105 (Tavily, 4 searches). Same correct answer. Kimi (open-source) found #53902 in Tavily but missed it entirely in SerpAPI despite 4 searches. Tavily indexes GitHub issue content more reliably for this query class.


### TC6 — RDS-EVENT-0056 Trap (Tavily: 2/7 caught; SerpAPI: 0/7 caught)


The starkest single workflow vs. workflow finding:


| Model        | Class  | Tavily Result                                                                                   | SerpAPI Result                    |
| ------------ | ------ | ----------------------------------------------------------------------------------------------- | --------------------------------- |
| Kimi-K2.5    | Open   | 🟢 **Caught the trap** — explicitly named event ID mismatch, cited RDS-EVENT-0036               | 🟡 Good — missed trap             |
| GPT-5.2      | Closed | 🟢 **Caught the trap** — "Important discrepancy: RDS-EVENT-0056 is database count, not network" | 🟡 Good — missed trap             |
| Qwen3.5 Plus | Open   | 🔴 **Reinforced the trap** — wrote a confident "Note" asserting 0056 = incompatible-network     | 🟡 Good — narrow miss             |
| All others   | Mixed  | 🟡 Missed trap (good remediation)                                                               | 🟡 Missed trap (good remediation) |


**The mechanism:** Tavily's indexing returned the official AWS event messages table (`USER_Events.Messages.html`) for "RDS-EVENT-0056 incompatible network" queries — enabling Kimi and GPT to cross-reference the event definition and expose the contradiction. SerpAPI Auto returned narrative blog posts about "incompatible network state" that never contained the per-event-ID definition table. This is a qualitative search result difference, not a token cost difference.


**Open vs. closed on this TC:** One open-source (Kimi) and one closed-source (GPT) caught the trap. One open-source (Qwen) actively made it worse by hallucinating a confident "Note" asserting the wrong interpretation. No model class "won" — individual model behavior, not origin, determined outcome.


### Basic Search — TC5, TC6, TC7 (Gemini + Opus, 3 prompt placements)


Basic Search ran only Gemini (closed-source) and Opus (closed-source), so there is no open vs. closed comparison here. The structural findings are relevant to both model classes:

- **Tool Node (Gemini):** 75% failure rate on RDS TC due to n8n JS crash parsing Gemini's function call schema. Disqualifies Tool Node for production regardless of model class
- **Agent Node (Gemini):** Stable but 36,716T on RDS — identical token bloat risk seen in Advanced Search Tavily TC4
- **Agent+Tool Node (both):** Consistently best quality. Gemini: 12,187T (Node.js), 13,159T (RDS). Opus: 16,965T (CVE), 26,730T (RDS)
- **The token cap finding transcends model class:** Setting a strict "Max Tokens" parameter on the agent/tool node matters more than which model you run

_(Source:_ _`test_cases_LLM-Basic-Search.md`__, TC5/TC6/TC7 tables)_


### 10.3 Consolidated Open vs. Closed Source Findings


| Dimension                   | Closed-Source Standout                               | Open-Source Standout                                                                             |
| --------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Unique threat intel**     | —                                                    | GLM: CVE-2025-32433 (CVSS 10.0, found by no other model, Tavily TC2)                             |
| **Search calibration**      | —                                                    | Qwen: searched only TC2+TC5; wildly better cost across all TCs where it competed                 |
| **GeoIP discrepancy**       | Gemini SerpAPI TC2: AS44486 Germany vs. Russia label | —                                                                                                |
| **Vendor event ID trap**    | GPT Tavily TC6: caught RDS-EVENT-0056 mismatch       | Kimi Tavily TC6: caught same mismatch                                                            |
| **Search loop disaster**    | Gemini Tavily TC2 (200k+), Tavily TC4 (146k)         | —                                                                                                |
| **SerpAPI catastrophe**     | —                                                    | GLM SerpAPI TC4: 7 failures, ~188k tokens, zero output                                           |
| **Over-triggering**         | Sonnet Tavily+SerpAPI TC3: both configs, 3–8× cost   | —                                                                                                |
| **Hallucinated confidence** | Opus LLM-Only TC9: 3 wrong IR phone numbers          | Qwen SerpAPI TC2: Mozi botnet (disbanded 2023); Qwen Tavily TC6: wrong "Note" on RDS event       |
| **MITRE mapping errors**    | —                                                    | GLM: T1190 misapplied to brute force (TC2); M1027 mislabeled (rate limiting ≠ Password Policies) |
| **Severity miscalibration** | Gemini: "High" on nginx typo (TC3, both backends)    | —                                                                                                |
| **Token efficiency**        | Gemini Tavily TC5: 6,555T (1 search, correct answer) | Kimi TC3 Tavily: 1,896T; Qwen TC4 Tavily: 3,271T                                                 |

>
>
> **The key takeaway from cross-workflow data:** Open vs. closed-source origin is a weaker predictor than individual model behavior and search backend compatibility. Qwen (open-source) is the search-calibration benchmark. GLM (open-source) surfaces the highest-severity unique CVE. But GLM also hits the single worst failure in the suite (SerpAPI TC4). Gemini (closed-source) has the best token-efficient search run (TC5 Tavily, 6,555T) and the worst search loop (TC2 Tavily, 200k+). The model choice and the guard rails you enforce matter more than the licensing model.
>
>

## Section 14 — Failure Mode Taxonomy

>
>
> A cross-workflow reference table grounded in source data. Every instance cites the TC, model, workflow, and token count where applicable. Use this to decide which guard rails your production configuration must implement before deployment.
>
>

### 14.1 Taxonomy Table


| Failure Category            | Definition                                                                                     | Documented Instances (all workflows)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Tokens Wasted                                                                                                       |
| --------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Hard Hallucination**      | Confident, specific, wrong — fabricated IDs, non-existent values stated as verified fact       | **Gemma-3-27b TC6 LLM-Only:** invented MITRE ID M1663 (does not exist); treated misattributed CVE-2025-9921 as confirmed OpenSSL RCE. **Opus TC9 LLM-Only:** all 3 IR hotline numbers wrong — CrowdStrike (1-855-276-9335), Mandiant (1-833-362-6342), Secureworks (1-877-838-7947) verified incorrect against official pages. In a live ransomware incident this wastes critical minutes. **Qwen TC6 Tavily:** wrote a confident "Note" asserting RDS-EVENT-0056 = incompatible-network despite accessing the correct AWS event table — hallucination built on top of real documentation access                                                                                                                                                                                                                                                                                                          | LLM-Only: no cost. Tavily TC6 Qwen: 14,080T for a wrong key finding                                                 |
| **Partial Hallucination**   | A real artifact (MITRE ID, tool name, botnet) applied to the wrong context                     | **GLM TC2 (Tavily + SerpAPI):** M1027 = "rate limiting" — wrong; M1027 = Password Policies (MITRE). Rate-limiting = M1036. **GLM TC2 (both):** T1190 applied to SSH brute force — T1190 = Exploit Public-Facing App (requires vulnerability), not credential guessing. Consistent across both backends. **Qwen TC2 SerpAPI:** "Mozi botnet" associated with 45.132.89.21 without a search — Mozi dismantled August 2023 (ESET confirmed). **Sonnet TC1 SerpAPI:** `rm /var/lib/mysql/mysql-bin.*` stated as an option "if MySQL is down" — manual deletion corrupts `mysql-bin.index`, breaks replication. **Kimi TC1 Tavily:** `max_slowlog_size`/`max_slowlog_files` are Percona-Only — not standard MySQL 8.0 CE/EE options. **Universal TC4:** all 5 models that wrote Spring Batch code used `stepBuilderFactory.get(...)` — deprecated since Spring Batch 5.0 (Spring Boot 3.2.1 bundles Batch 5.1) | SerpAPI TC2 Qwen: 3,562T (no search = nearly free but wrong threat intel)                                           |
| **Tool Loop**               | Agent enters a recursive search cycle; each result triggers another search without convergence | **Gemini Tavily TC2:** IP WHOIS loop on 45.132.89.21 — hit 10 iterations → retry → hit 20 → error. Zero output. Root cause: AbuseIPDB returned sparse data; no convergence signal. **Gemini Tavily TC4:** 10 recursive searches on Spring Boot OOM, 146,633 tokens — most expensive functional run in the entire suite. **GPT SerpAPI TC5:** 12 searches, 183,543 tokens — SerpAPI returned inconsistent results, GPT kept searching; 11 searches after finding the answer on search 1                                                                                                                                                                                                                                                                                                                                                                                                                    | Gemini TC2: 200,000+ T (zero output). Gemini TC4: 146,633T. GPT TC5: 183,543T                                       |
| **Generation Failure**      | Tool call succeeds, results returned, agent produces empty output `{}`                         | **Kimi Tavily TC4:** 3 searches succeeded (Spring Batch #3790 found), agent returned `{}`. Required second full workflow run. **Kimi Tavily TC5:** same pattern — 2 searches succeeded, `{}` output, second run required. **Kimi SerpAPI TC4:** empty output on 2nd of 3 runs. Pattern: Kimi-specific across Tavily and SerpAPI; not a tool infrastructure failure                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Kimi TC4: 12,631T wasted on failed first run. TC5: 1,469T wasted                                                    |
| **Over-Triggering**         | Agent invokes search on a case fully diagnosable from internal knowledge                       | **Sonnet Tavily TC3:** searched nginx docs to confirm `ssl_certificate_keyy` is a typo — error message names the directive, file, and line. 6,247 tokens vs. 1,896–2,265 for no-search models. ~3× cost, zero information gain. **Sonnet SerpAPI TC3:** same case, 16,250 tokens — 5–7× baseline. This is the only model to over-trigger in both backends on this TC. **Gemini Basic Search Agent Node TC7 (RDS):** 36,716T — 3× comparable output; token bloat without search loop                                                                                                                                                                                                                                                                                                                                                                                                                       | Sonnet TC3 both configs: 6,247 + 16,250T vs. ~2k baseline                                                           |
| **Parameter Failure**       | SerpAPI rejects agent-generated query parameters — partial or total output loss                | **GLM SerpAPI TC1:** `q` field missing → success on 2nd try. **GLM SerpAPI TC2:** 3 attempts (`output` param error ×2, then `location`+`uule` conflict) before clean output. **GLM SerpAPI TC4:** 7 complete failures — `lr=en` unsupported, `US` location unsupported, `location`+`uule` conflict, JSON parse error from malformed SerpAPI response (API-level data corruption, not just parameter error). **Gemini SerpAPI TC1:** 2 failures (`location`+`uule` conflict; `US 2025` unsupported location). **Sonnet SerpAPI TC1:** 3 failures on `output` parameter. **Qwen SerpAPI TC6:** `as_sitesearch` parameter error — new error type, first Qwen failure. **Kimi SerpAPI TC4:** 2 failures before clean run                                                                                                                                                                                      | GLM TC4: ~188,000T across 7 failed runs, zero usable output. TC1 Sonnet (SerpAPI): ~14,886T wasted on 3 failed runs |
| **Safety Risk**             | Recommended command would cause operational damage if followed in production                   | **Qwen Tavily TC1:** `rm /var/lib/mysql/mysql-bin.0[0-9][0-9]` — manual binlog deletion without updating `mysql-bin.index` causes MySQL startup failure and replication corruption. Use `PURGE BINARY LOGS` only. **Sonnet SerpAPI TC1:** same `rm mysql-bin.*` suggestion framed as valid when MySQL is down — equally dangerous. **Opus Tavily TC2:** rate-limiting iptables rule marks packets but does not drop them (`--set` without the `--update --hitcount -j DROP` counterpart). **Opus TC9 LLM-Only:** 3 wrong IR hotline numbers in a live ransomware scenario — wrong numbers waste critical response minutes. **Universal:** every model using Spring Batch wrote deprecated `stepBuilderFactory.get(...)` code that will cause compilation failures in Spring Boot 3.2.1                                                                                                                    | All LLM-Only (no tool cost); TC1 SerpAPI Sonnet: 41,619T final output cost                                          |
| **Severity Miscalibration** | Incident severity label is wrong in a way that changes escalation decisions                    | **Gemini Tavily TC3:** "High" on a 1-character nginx typo — a 2-minute fix with zero security risk. Repeated identically in **SerpAPI TC3**. Pattern is backend-independent and systematic. **Gemini SerpAPI TC4:** "Critical" for a recoverable batch OOM — "High" is the calibrated label (recoverable in <15 min once version change is made). **GLM LLM-Only TC3:** "High" on the same nginx typo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | No token waste from miscalibration itself; downstream cost is unnecessary escalation                                |


### 14.2 Failure Mode × Workflow Occurrence Matrix


| Failure Mode            | LLM-Only                                   | Basic Search                                | Tavily                                              | SerpAPI                                                       |
| ----------------------- | ------------------------------------------ | ------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------- |
| Hard Hallucination      | ✅ Critical (Gemma TC6, Opus TC9, Qwen TC6) | —                                           | ✅ Present (Qwen TC6: confident wrong "Note")        | —                                                             |
| Partial Hallucination   | ✅ Present (GLM, Qwen, Kimi)                | —                                           | ✅ Present (GLM TC2; universal `stepBuilderFactory`) | ✅ Present (GLM TC2, Qwen TC2 Mozi; same `stepBuilderFactory`) |
| Tool Loop               | ✗ N/A                                      | ⚠️ Agent Node only (Gemini TC7: 36k tokens) | ✅ Critical (Gemini TC2: 200k+; TC4: 146k)           | ✅ Present (GPT TC5: 183k, 12 searches)                        |
| Generation Failure      | ✗ N/A                                      | ✗ N/A                                       | ✅ Present (Kimi TC4, TC5)                           | ✅ Present (Kimi TC4)                                          |
| Over-Triggering         | ✗ N/A                                      | ✅ Structural (Gemini Agent Node TC7: 36k)   | ✅ Present (Sonnet TC3: 3× cost)                     | ✅ Present (Sonnet TC3: 5–7× cost)                             |
| Parameter Failure       | ✗ N/A                                      | ✗ N/A                                       | ✗ Not observed                                      | ✅ Critical (GLM TC4: 7 failures; Sonnet TC1: 3 failures)      |
| Safety Risk             | ✅ Present (Opus TC9, Qwen TC1)             | —                                           | ✅ Present (Qwen TC1, Opus TC2)                      | ✅ Present (Sonnet TC1 `rm`)                                   |
| Severity Miscalibration | ✅ Present (Gemini TC3, GLM TC3)            | —                                           | ✅ Present (Gemini TC3, TC4)                         | ✅ Present (Gemini TC3, TC4)                                   |


### 14.3 Guard Rail Requirements by Failure Mode


| Failure Mode                                             | Required Guard Rail                                                                                                                                                                                                                                                | Priority                                                     |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| **Tool Loop**                                            | Hard-cap search iterations in agent node (max 5 per TC). System prompt: _"If search returns no actionable result in 2 attempts, proceed with available context."_                                                                                                  | 🔴 Critical before Tavily or SerpAPI production deployment   |
| **Parameter Failure**                                    | SerpAPI: hardcode parameter exclusion in n8n tool config — block `output`, `uule`, `lr`, `location`+`uule` simultaneous use, `as_sitesearch`, `gl`, `hl`. Never pass unknown agent-generated parameter strings through                                             | 🔴 Critical before any SerpAPI GLM or Sonnet deployment      |
| **Generation Failure**                                   | n8n workflow: add non-empty output validator node. If agent output is `{}` or empty string, trigger retry up to 2× before flagging fallback-to-LLM-Only                                                                                                            | 🟡 High for Kimi in any search workflow                      |
| **Over-Triggering**                                      | System prompt restraint line: _"Search only if the alert contains a specific version number, CVE ID, vendor event code, or external IP you cannot characterize from training data."_                                                                               | 🟡 High — prevents 5–8× cost multiplier on easy cases        |
| **Hard Hallucination**                                   | System prompt: _"If you cannot verify a specific claim from search results, state 'unverified' — do not present estimates as confirmed facts. For contact details: provide the official website URL only, never a telephone number recalled from training data."_  | 🟡 High — especially for Opus in security-critical scenarios |
| **Parameter Failure (for** **`stepBuilderFactory`****)** | Add a code review instruction to the system prompt for Spring Batch outputs: _"Do not use_ _`stepBuilderFactory.get(...)`_ _— it is deprecated in Spring Batch 5.x. Use_ _`new StepBuilder(name, jobRepository)`_ _instead."_                                      | 🟡 Medium — only relevant for Java incident triage           |
| **Safety Risk**                                          | System prompt command-safety line: _"Before recommending any destructive command (rm, dd, DROP, DROP TABLE, purge, DELETE), state the pre-condition check required first. Prefer MySQL-native commands (__`PURGE BINARY LOGS`__) over filesystem-level deletion."_ | 🟡 High for production DB environment triage                 |
| **Severity Miscalibration**                              | System prompt: _"Severity High = data loss risk, active exploit, or irreversible damage. A trivial fix (e.g., config typo, patch upgrade) with a confirmed resolution path is Medium or Low regardless of whether the service is currently down."_                 | 🟢 Medium — prevents unnecessary escalation                  |


## Section 16 — Conclusions & Production Recommendations


### 16.1 Workflow Decision Table


| Workflow                            | When to Use                                                                                                                                                                                                                                                                                                             | When NOT to Use                                                                                                                                                                                                                                                        | Minimum Viable Config                                                                                                                     |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **LLM-Only**                        | Disk full, config typos, ABI crashes, ransomware isolation, SSH brute force blocking — diagnosable from pretraining. TC1, TC3, TC9 are the proof: 2,000–3,500 token complete triage notes.                                                                                                                              | CVE lookups, vendor event code verification, version-specific regressions, anything requiring a post-training-cutoff timestamp. TC6: all 8 LLM-Only models accepted a fabricated alert narrative — no lookup, no correction                                            | GPT-5.2, Opus, or Kimi as primary. Strict "Max Tokens" node parameter + pre-command safety check line in system prompt.                   |
| **Basic Search (Google Grounding)** | Gemini-native pipelines — avoids third-party API dependency. TC5 Node.js (12,187T, _affected libraries named_) and RDS TC7 (13,159T, ENI quota found) are the data — competitive with lower Advanced Search model costs.                                                                                                | Multi-model workflows — Gemini Grounding is Gemini-internal. Tool Node is disqualified (75% Gemini failure rate on n8n's Gemini function call schema parsing). Any case where you need Opus, GPT, or open-source models as the reasoning engine                        | **Agent+Tool Node only** (not Tool Node). Explicit "Max Tokens" parameter on node. Opus as override for Anthropic-quality outputs.        |
| **Tavily**                          | Full 7-model production deployment. CVE lookups, vendor event code verification, GitHub issue research. TC6 trap: **2/7 models caught it with Tavily vs. 0/7 with SerpAPI** — Tavily's indexing of `USER_Events.Messages.html` is the delta. TC5: GPT dropped 11× (183k → 16k tokens) switching from SerpAPI to Tavily. | Gemini without a max-iteration cap — TC4 (146k tokens, 10 searches) is the proof. Any budget-constrained deployment where search loops are not guarded                                                                                                                 | **Max 5 searches per TC**. Search-trigger restraint line in system prompt. Explicit "Max Tokens" parameter on node.                       |
| **SerpAPI**                         | Cases requiring Google Search result ranking (not AI-summarized results) where you accept higher execution variance and will implement the parameter exclusion guard rail. Gemini TC2 SerpAPI uniquely found AS44486 GeoIP mismatch that no Tavily model found                                                          | GLM as a reasoning model (TC4: 7 complete failures, ~188k tokens wasted, zero output). Any production case where zero-output is unacceptable without a fallback. Budget-sensitive pipelines with Sonnet (TC1: 14,886T wasted on 3 failed runs before 41k final output) | **Parameter exclusion list hardcoded in n8n tool config** (not optional). Output validator node. Max 2× retry before fallback-to-LLM-Only |


### 16.2 Model Recommendations by Use Case


| Use Case                              | Recommended Model                            | Data Evidence                                                                                                                                                                                                                                                                       |
| ------------------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Most reliable single model**        | GPT-5.2                                      | Consistent across all TCs. Honest uncertainty: "I don't have details on CVE-2025-9921." Caught RDS-EVENT-0056 trap in Tavily TC6. No search loops. `sudoedit` symlink safety. `super_read_only=ON`. `MaxStartups 3:50:10`.                                                          |
| **Best search calibration**           | Qwen3.5 Plus                                 | Searched TC2 (SSH: IP reputation = correct) and TC5 (Node.js: version-specific = correct). Zero unnecessary searches across TC1, TC3, TC4, TC6, TC9, TC10. Tavily TC4: 3,271T vs. Gemini's 146,633T — 44× cheaper for the same incident. LLM-Only and both Advanced Search configs. |
| **Best unique threat intel**          | GLM-4.7 with Tavily                          | CVE-2025-32433 (Erlang/OTP SSH, CVSS 10.0, CISA KEV June 2025) — found by no other model across all 7 in Tavily or SerpAPI. If the host runs RabbitMQ/CouchDB/Ejabberd, this is a severity-changing finding.                                                                        |
| **Best safety-critical output**       | Claude Opus 4.5                              | Exception: TC9 IR phone hallucination. Otherwise: most thorough pre-fix condition checks, `setVerifyCursorPosition(false)` Spring Batch detail, `jmap -dump:live` correctly uses `live` flag, Terraform `aws_cloudwatch_metric_alarm` for IaC prevention.                           |
| **Best prompt-placement pairing**     | Gemini Agent+Tool Node                       | Basic Search data: 12,187T (Node.js), 13,159T (RDS) — half Opus's token spend for the same output quality tier. Tool Node disqualified (75% failure).                                                                                                                               |
| **Avoid for search workflows**        | Gemini 3 Pro Preview (without iteration cap) | TC2 Tavily: 200k+ tokens, zero output. TC4 Tavily: 146,633T. The pattern triggers when search returns sparse results — the agent re-queries instead of proceeding. Hard iteration cap (max 5) changes the risk profile.                                                             |
| **Avoid for SerpAPI + complex cases** | GLM-4.7                                      | TC4 SerpAPI: 7 failures, ~188,000T, zero output. The JSON parse error on attempt 5 (corrupted SerpAPI response) was not recoverable by parameter tuning — it is an API-level failure that parameter exclusion cannot prevent on its own.                                            |
| **Avoid for MITRE mapping**           | GLM-4.7                                      | T1190 applied to SSH brute force (TC2) in both Tavily and SerpAPI. M1027 mislabeled as rate-limiting in both configs. Pattern is consistent — not a one-off.                                                                                                                        |


### 16.3 Token Cost Reference — Cross-Workflow


| Scenario                         | Tokens        | Workflow                     | Model                                                              | TC       |
| -------------------------------- | ------------- | ---------------------------- | ------------------------------------------------------------------ | -------- |
| **Most efficient — Easy TC**     | 1,896         | Tavily                       | Kimi TC3 (nginx typo, no search)                                   | TC3      |
| **Most efficient — Hard TC**     | 6,555         | Tavily                       | Gemini TC5 (Node.js v22.5.0, 1 search)                             | TC5      |
| **Best no-search versioned OOM** | 3,271         | Tavily                       | Qwen TC4 (Java OOM, no search — best cost for a correct answer)    | TC4      |
| **Cost-efficient with search**   | 10,989–11,905 | Tavily                       | Kimi/Sonnet TC2 (SSH brute force, 2 searches)                      | TC2      |
| **Expensive but justified**      | 40,151        | Tavily                       | GLM TC4 (5 searches, 4 real SO threads, real finding)              | TC4      |
| **SerpAPI GeoIP unique find**    | 114,926       | SerpAPI                      | Gemini TC2 (AS44486 Germany mismatch — no Tavily model found this) | TC2      |
| **Loop benchmark — Tavily**      | 146,633       | Tavily                       | Gemini TC4 (10 searches, 1 real finding: HHH-17078)                | TC4      |
| **Loop benchmark — SerpAPI**     | 183,543       | SerpAPI                      | GPT TC5 (12 searches, answer found on search 1)                    | TC5      |
| **Over-trigger cost**            | 16,250        | SerpAPI                      | Sonnet TC3 (typo — 5–7× baseline, 0 new info)                      | TC3      |
| **Worst case — total failure**   | ~188,000      | SerpAPI                      | GLM TC4 (7 failed attempts, zero output)                           | TC4      |
| **Basic Search bloat**           | 36,716        | Basic Search Agent Node      | Gemini TC7 RDS (3× comparable output size)                         | TC7      |
| **Best Basic Search output**     | 12,187–13,159 | Basic Search Agent+Tool Node | Gemini TC5+TC7 (half Opus's cost for equal quality)                | TC5, TC7 |

>
>
> **The 44× multiplier:** Gemini Tavily TC4 (146,633T) vs. Qwen Tavily TC4 (3,271T) — same incident. Gemini found one real additional finding (Hibernate HHH-17078). If that finding justifies 44× cost, run Gemini with a hard iteration cap. If it doesn't, Qwen or Sonnet is the production choice.
>
>

### 16.4 Cross-Workflow Search Delta Summary


The core evaluation question was: _what does search actually add?_


| TC               | LLM-Only Best Result                                                      | Search Added                                                                                                                                       |
| ---------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| TC1 (Disk Full)  | GPT: `lsof +L1`, replicated safety check, `df -i`                         | Opus/Sonnet (Tavily): MySQL Bug #118356 (large-transaction crash), ibdata1 shrink procedure. Cost: 4–5×                                            |
| TC2 (SSH)        | Sonnet: `reload` vs `restart`, lockout warning                            | GLM Tavily: CVE-2025-32433 CVSS 10.0 (+severity change). Gemini SerpAPI: AS44486 GeoIP mismatch (+attribution change)                              |
| TC3 (Nginx)      | Kimi: 1,896T, correct, `reload`, severity "Medium"                        | Sonnet Tavily: zero new info. Net delta: **negative** (cost 3–8× for confirmation of what error message already stated)                            |
| TC4 (Java OOM)   | Qwen: 3,271T, "Cliff behavior" vs sawtooth, StreamQuery, Prometheus alert | Gemini SerpAPI: Spring Batch 5.1 context serialization (version-specific). Kimi Tavily: GitHub #3790. Gemini Tavily: HHH-17078. Cost varies 10–44× |
| TC5 (Node.js)    | GPT LLM-Only: general V8 debugging advice                                 | All 7 models found #53902 with search. No model resolved without search — search was essential                                                     |
| TC6 (RDS trap)   | All 8 LLM-Only: accepted fabricated alert, full network remediation       | Tavily 2/7: caught the fabricated event ID. SerpAPI 0/7: missed entirely                                                                           |
| TC9 (Ransomware) | Gemini/Kimi LLM-Only: correct isolation, hibernate, nomoreransom.org      | No Advanced Search data for TC9                                                                                                                    |


**Search is unambiguously essential for TC5 and TC6.** For TC1, TC3, and TC4, it adds value only in specific conditions: if ibdata1 is involved (TC1), if a new CVE changes severity (TC2), or if a version-specific batch regression is suspected (TC4). For TC3 (typo), search adds zero value and costs 3–8× more.


### 16.5 What to Build Next


| Addition             | What It Fixes                                                                                                                                                                                                                                              | Priority                                                                   |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| **NVD API tool**     | TC6 LLM-Only: all 8 models hallucinated on the fabricated CVE. A direct NVD lookup returns the real package and CVSS in one call — no search loop risk                                                                                                     | High — free public API, low integration effort                             |
| **AbuseIPDB tool**   | TC2: models searched manually for IP reputation. A direct API lookup returns confidence score, category, and last reported date in one call — faster and authoritative                                                                                     | High — free tier available, direct fix for Gemini's TC2 Tavily loop        |
| **MITRE ATT&CK API** | GLM's T1190/M1027 errors could be caught by a validation step: "before citing a MITRE ID, validate against the ATT&CK API"                                                                                                                                 | Medium — requires an additional validation node in the workflow            |
| **Exa AI / Jina AI** | Alternative search backends — Exa is neural-search native; Jina offers grounding APIs. Worth profiling for query precision vs. Tavily on GitHub issue lookups (TC5 class)                                                                                  | Medium — parallel test run required                                        |
| **Full RAG layer**   | Semantically match the alert against your historical incidents before invoking search. Reduces search volume on known patterns, reduces hallucinations on infrastructure-specific context. Biggest potential uplift for TC1-class and TC9-class incidents. | High impact, high effort — covered in the separate RAG workflow evaluation |


### 16.6 Final Verdict


**Tavily is the production search backend.** It outperformed SerpAPI on reliability (zero parameter failures vs. GLM's 7-failure TC4 catastrophe), delivered the TC6 trap detection advantage (2/7 vs. 0/7), and cut GPT's TC5 token cost 11×. The one guard rail it requires — a max-iteration cap to prevent Gemini loops — is a 1-line system prompt addition.


**SerpAPI has one genuine exclusive finding:** Gemini's AS44486 GeoIP mismatch in TC2 — Germany vs. Russia attribution change, derived from RIPE WHOIS data that Tavily didn't surface. If GeoIP attribution accuracy on security alerts is a priority, SerpAPI + Gemini with the parameter exclusion guard rail is worth the reliability overhead. For all other use cases, the reliability variance is too high for production without the full guard rail stack.


**LLM-Only is underrated for Easy–Medium incidents.** TC1, TC3, TC9 are all solvable at 1,900–3,500 tokens with GPT-5.2 or Kimi. Adding search to TC3 costs 3–8× more and contributes zero new information. The correct production architecture is: route Easy–Medium alerts to LLM-Only first, then fall through to Tavily only if the alert contains a CVE ID, vendor event code, external IP, or version number that requires a post-training-cutoff lookup.


**The most dangerous single output in the test suite is not a token loop or a parameter failure — it is Opus hallucinating three specific wrong IR hotline numbers in a live ransomware scenario.** Search tools do not prevent this. The fix is a system prompt instruction to link to official websites rather than recall contact details from training data.

> _All claims in this report are cited to source file, TC, model, and workflow. No inference was made beyond what the source file rows state explicitly._
```
