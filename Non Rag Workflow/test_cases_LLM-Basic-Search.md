# Non-RAG Incident Response - Test Cases (LLM Basic Search)

Use these realistic **System Alerts** to test the "LLM + Basic Search" workflow. Paste these into the chat as if they were automated notifications.

> **STRATEGY:**
>
> - **LLM + Basic Search** (Gemini Grounding) should succeed on "Unknowns" (Hard/Edge) by finding live data.
> - **Goal:** Measure the "Search Delta" — value added by real retrieval vs. pre-trained knowledge alone.
> - **All hard test cases use real, NVD/AWS/GitHub-verified data.** The ground truth answers are included so you can grade the model's output objectively.

---

## 🟢 Easy / Common Scenarios (Baseline)

_Standard incidents where internal knowledge is usually sufficient. Search might add minor context._

### 1. Classic Infrastructure Failure (Disk Full)

**Goal:** Verify workflow provides standard mitigation steps. No search needed.

```text
[ALERT] Filesystem /var/lib/mysql is 98% full
Severity: High
Host: db-prod-01
Mount: /dev/sda1
Message: no space left on device. Write operations failing.
```

- **Expectation:** Internal knowledge resolves this. Steps: identify large files (`du -sh /var/lib/mysql/*`), purge binary logs (`PURGE BINARY LOGS BEFORE NOW()`), increase disk or move data directory. At most one search call to confirm safe cleanup syntax.

### 2. Common Security Pattern (SSH Brute Force)

**Goal:** Verify security categorization and IP reputation lookup.

```text
[ALERT] Suspicious Login Activity detected
Source IP: 45.132.89.21 (Russia)
User: root
Events: 240 failed password attempts in 60 seconds
Protocol: SSH
```

- **Expectation:** Classify as Brute Force (MITRE T1110). Recommend: block IP via `iptables`/`ufw`, set `PermitRootLogin no`, deploy `fail2ban`. Search might verify IP reputation on AbuseIPDB.

---

## 🟡 Medium Complexity (Context / Ambiguity)

_Incidents requiring synthesis or specific configuration knowledge._

### 3. Nginx Config Syntax Error

**Goal:** Test code analysis. Search should NOT be needed — it's a plain typo.

```text
[ERROR] Nginx failed to start
Service: nginx.service
Message: [emerg] unknown directive "ssl_certificate_keyy" in /etc/nginx/sites-enabled/default:14
State: failed
```

- **Expectation:** Identify typo `ssl_certificate_keyy` → `ssl_certificate_key`. Internal knowledge resolves it — no search needed. If search fires, it's over-triggering.

### 4. Java OOM — Memory Leak vs. Spike

**Goal:** Test reasoning with conflicting symptoms.

```text
[ALERT] Java Application OOM
Error: java.lang.OutOfMemoryError: Java heap space
Context: Heap set to -Xmx8g. Server has 64GB RAM. Usage is flat at 2GB, then spikes instantly on batch job trigger.
```

- **Expectation:** Distinguish Memory Leak (gradual growth) vs. Massive Allocation (instant spike on trigger). Recommend: heap dump (`jmap -dump:format=b,file=heap.hprof <pid>`), check batch chunk size. Internal knowledge sufficient; search confirms JVM flag syntax if needed.

---

## 🟠 Version-Specific Cases (Search Is Useful)

_Search adds value for version-specific bugs where internal knowledge may be stale._

### 5. Real Version-Specific Bug — Node.js v22 V8 Crash

**Goal:** Test whether search can find a **real** GitHub-tracked regression in Node.js v22.

```text
[ALERT] Node.js service crash loop
Error: FATAL ERROR: v8::Object::GetCreationContextChecked No creation context available
Node.js version: v22.5.0 (upgraded yesterday, no code changes)
Crash pattern: Process restarts every few minutes. npm scripts fail immediately on that version.
```

- **Expectation:** Search should return GitHub issue nodejs/node #53900 (opened July 2024) — a confirmed regression in v22.5.0 where `fs.closeSync` using a V8 fast API caused crashes. Fix: downgrade to v22.4.0 or upgrade past the patch release. `npm rebuild` may also help for native addons.

#### 🔬 Fact-Check (GitHub-Verified)

> ✅ **This is a real, documented regression.**
>
> - **Issue**: nodejs/node#53900 — "Node 22.5.0 started to crash and hangs on different cases"
> - **Error**: `FATAL ERROR: v8::Object::GetCreationContextChecked No creation context available`
> - **Root cause**: Regression in `fs.closeSync` using V8 fast API — reverted in a patch release
> - **Affected**: Node.js v22.5.0
> - **Fix**: Downgrade to v22.4.0 or upgrade to the next patched release; `npm rebuild` for native addon ABI issues
> - **Reported**: July 17, 2024

---

## 🔴 Hard / Specific Knowledge (The "Search Delta")

_Incidents requiring external data where pre-trained knowledge alone is insufficient or stale._

### 6. Real CVE Lookup — Apache Tomcat RCE (CVE-2025-24813)

**Goal:** Verify the model finds accurate, current CVE details from NVD — not hallucinated ones.

```text
[SCANNER] Critical Vulnerability Detected
CVE: CVE-2025-24813
Package: Apache Tomcat 10.1.34
Score: Reported as High
Vector: Network
```

- **Expectation:** Search NVD and return: CVSS **9.8 Critical** (not just "High"), RCE via partial PUT request, affected versions 9.0.0.M1–9.0.98 / 10.1.0-M1–10.1.34 / 11.0.0-M1–11.0.2, patch = upgrade to 10.1.35 or 11.0.3 or 9.0.99.

#### 🔬 Fact-Check (NVD-Verified)

> ✅ **CVE-2025-24813 — Apache Tomcat Remote Code Execution**
>
> | Field         | Real Value (NVD)                                                        |
> | ------------- | ----------------------------------------------------------------------- |
> | **CVSS**      | **9.8 Critical** (not just "High" as the alert states)                  |
> | **Type**      | RCE via improper handling of partial PUT requests                       |
> | **Affected**  | Tomcat 9.0.0.M1–9.0.98, 10.1.0-M1–10.1.34, 11.0.0-M1–11.0.2             |
> | **Patch**     | Upgrade to 9.0.99, 10.1.35, or 11.0.3                                   |
> | **Condition** | Default servlet write enabled AND partial PUT enabled (default on)      |
> | **CISA KEV**  | Check if added to known exploited list — actively discussed in the wild |
>
> **Search-Augmented Expected Behavior:** Single NVD lookup reveals the alert understates severity (9.8 not "High") and provides exact patch versions.

### 7. Real Vendor Error Code — AWS RDS-EVENT-0056

**Goal:** Test lookup of real vendor documentation vs. hallucination of the event message.

```text
[ALERT] Amazon RDS Event
Source: db-instance-prod
Event ID: RDS-EVENT-0056
Message: The database instance is in an incompatible network state.
```

- **Expectation:** Search AWS docs and identify that the alert message is **wrong**. RDS-EVENT-0056 real meaning: _"The number of databases in the DB instance exceeds recommended best practices. Consider reducing the number of databases."_ — a Warning, not a Critical network error.

#### 🔬 Fact-Check (AWS Docs Verified)

> ⚠️ **RDS-EVENT-0056 is intentionally misattributed in the alert.**
>
> | Field        | Alert Claimed                | AWS Reality (docs.aws.amazon.com)                            |
> | ------------ | ---------------------------- | ------------------------------------------------------------ |
> | **Message**  | "incompatible network state" | **"Number of databases exceeds recommended best practices"** |
> | **Severity** | Implied Critical             | **Warning / Best Practices Notification**                    |
> | **Action**   | Network triage               | Reduce database count on the instance                        |
>
> **A single AWS docs search immediately exposes the mismatch. This is the core "search delta" test for vendor error codes.**

---

## 🟣 Edge Cases & Stress Tests

_Vague, panicked, or adversarial inputs._

### 8. Panic / "Mayday"

**Goal:** Test calm, structured response to unstructured panic.

```text
[ALERT] MAYDAY MAYDAY MAYDAY server is on fire literally smoke coming out help
```

- **Expectation:** Acknowledge emergency. If literal fire: physical safety first (power cut, evacuate, facilities team). If figurative: triage framework. Do NOT search for "server fire mitigation." Zero tool calls expected.

### 9. "We Are Hacked" — Ransomware (.crypt)

**Goal:** Identify ransomware strain and find decryption tool via search.

```text
[Check] I think we are hacked. Screens are flashing red and files are renamed to .crypt
```

- **Expectation:** Identify as Ransomware (likely CryptXXX v1–v3). Immediate steps: isolate network. Search should surface **nomoreransom.org** — Rannoh Decryptor (Kaspersky) covers CryptXXX v1/v2/v3 and is freely available there.

#### 🔬 Fact-Check (nomoreransom.org Verified)

> ✅ **`.crypt` extension is real and decryptors exist.**
>
> - CryptXXX v1, v2, v3 → **Rannoh Decryptor** (Kaspersky) available on nomoreransom.org
> - Trend Micro also provides a CryptXXX decryptor
> - Emsisoft offers a variant as well
> - **Important caveat:** CryptXXX v3.100+ (network share variant) may not be fully decryptable with older tools — always check nomoreransom.org for the latest tool version
>
> **Search-Augmented Expected Behavior:** Searching `.crypt nomoreransom.org` returns the decryptor page in the first result.

### 10. Adversarial / Irrelevant

**Goal:** Test relevance filtering — dismiss without searching.

```text
[ALERT] Coffee machine is out of beans. Error 418: I'm a teapot.
```

- **Expectation:** Dismissal ("Not an IT infrastructure incident"). Should NOT invoke search. Recognises HTTP 418 from internal knowledge (RFC 2324, IETF April Fools' 1998). Zero tool calls expected.

---

## 📊 Analysis Results — Tested Cases

> **Scope Note:** The following analysis was conducted for TC5, TC6, and TC7 only — across 2 models (Gemini-3-Pro-Preview and Claude Opus 4.5) and 3 prompt placement configurations (Output 1: Tool Node, Output 2: Agent Node, Output 3: Agent+Tool Node). A full 10-TC / 7-model run was not completed. The structural finding (Agent+Tool Node + Opus + token budget instruction wins) is clear from the existing data. See `test_cases_LLM-Basic-Search_testing_prompts_placement_raw.md` for full verbatim outputs.
>
> **Node architecture note:** This workflow uses the **"Message a Model in Google Gemini"** n8n node — not the standard Chat Model node. This is the only node that supports `builtInTools: { googleSearch: true }`. The standard Chat Model node has no built-in search capability.

---

### TC5 — Node.js v22 V8 Crash

**Model: Gemini-3-Pro-Preview | 3 prompt placements**

| Output       | Config          | Tokens | Key Strengths                                                                                                                                                                             | Gaps                                                                               |
| ------------ | --------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Output 1** | Tool Node       | 13,757 | `grep -r "22.5.0" .` to find version pins; `npm rebuild` reminder after swap; LTS alias recommendation                                                                                    | Issue #53902 referenced but not GitHub-linked; less specific on affected libraries |
| **Output 2** | Agent Node      | 12,589 | Clean runtime diagnosis; `nvm install 22.5.1` + `nvm alias default`; canary deployment hardening                                                                                          | Generic GitHub reference; no affected library names; no "Halt Rollouts" step       |
| **Output 3** | Agent+Tool Node | 12,187 | **Named affected libs** (better-sqlite3, pg, winston, npm, yarn); "Misleading Error" insight (V8 blamed, not runtime); "Halt Rollouts" as first action; "Monitor logs for 5 min" time-box | Missing `grep -r "22.5.0" .` and `npm rebuild`                                     |

**Ranking: Output 3 > Output 1 > Output 2**

> **Why Output 3 Wins:** Naming specific affected libraries (better-sqlite3, pg, winston) lets an engineer immediately self-identify impact without testing. The "Misleading Error" insight prevents hours of wasted debugging against native addons. "Halt Rollouts" at CI/CD level, not just the service, shows operational maturity. Most token-efficient at 12,187T.
>
> **What Output 1 Does Better:** `grep -r "22.5.0" .` to locate version pins across the repo is a practical first step missing from Output 3. `npm rebuild` is critical for native modules after version swap — skipping this causes silent binary mismatches.
>
> **Bottom Line:** Output 3 wins on conciseness, uniqueness of insights, and operational framing. To make it near-perfect: add `grep -r "22.5.0" .` to the diagnostic step and an `npm rebuild` reminder.

---

### TC7 — AWS RDS-EVENT-0056

**Model: Gemini-3-Pro-Preview | 3 prompt placements**

| Output       | Config          | Tokens | Key Strengths                                                                                                                                              | Gaps                                                                                                                                                                       |
| ------------ | --------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Output 1** | Tool Node       | 13,205 | `CRITICAL WARNING: DO NOT REBOOT` — clearest of all; CLI subnet IP check commands; CloudWatch alarm recommendation                                         | **Failed 3 out of 4 attempts** (`Cannot use 'in' operator to search for 'functionCall' in undefined` — n8n JS bug with Gemini's function call schema); output 2nd run only |
| **Output 2** | Agent Node      | 36,716 | AWS SSM runbook `AWSSupport-ValidateRdsNetworkConfiguration`; `aws rds start-db-instance` as a "kick"; Delete Protection tip                               | Token bloat: **36,716T (3× other outputs)**; `DO NOT REBOOT` buried/implied                                                                                                |
| **Output 3** | Agent+Tool Node | 13,159 | ENI Limit as 3rd root cause; Force-delete via AWS Support (Console prevents it); `Verify Backups First / pg_dump while port is open`; compact and complete | `DO NOT REBOOT` implied not explicit                                                                                                                                       |

**Ranking: Output 3 > Output 2 > Output 1**

> **Reliability First:** Output 1 failed 3 out of 4 attempts with the Gemini function call schema error. Even if it produced the best content, the 75% failure rate disqualifies the Tool Node configuration for production use with Gemini.
>
> **Why Output 3 Wins:** "Verify Backups First" (pg_dump while data port is open) is the most operationally correct first action — neither Output 1 nor 2 included this. ENI quota as a third root cause is a real AWS scenario others missed. Force-delete via AWS Support for stuck instances is a real-world operational detail.
>
> **What Output 2 Does Uniquely Well:** Delete Protection tip + the SSM runbook — worth borrowing into Output 3. But 36K tokens is 3× overkill for a triage note.

---

### TC6 — CVE-2025-24813 (Apache Tomcat RCE)

**Model: Claude Opus 4.5 | 3 prompt placements**

| Output       | Config          | Tokens | Key Strengths                                                                                                                                                                                                                       | Gaps                                                                                         |
| ------------ | --------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| **Output 1** | Tool Node       | 16,965 | Clearest Prerequisites table (Default Setting column with ✅/❌); VERDICT callout at end; structured format                                                                                                                         | No IOC hunting commands; no `allowPartialPut=false`; upgrade = just a link, no commands      |
| **Output 2** | Agent Node      | 16,965 | **IOC hunting:** `grep -E "PUT.*Range:"` + `find work -name "*.session"`; **`allowPartialPut=false`** mitigation (critical — Output 1 missed entirely); GreyNoise + SonicWall named; `wget + sha512sum` upgrade commands; 6 sources | Token count identical to Output 1 despite far more content density                           |
| **Output 3** | Agent+Tool Node | 45,298 | CISA KEV date (April 1, 2025); `curl -X PUT` mitigation verification test; `$CATALINA_HOME` variable throughout; 7 sources                                                                                                          | **45,298T — 3× other outputs — unsuitable as a triage note**; better as a reference document |

**Ranking: Output 2 > Output 1 > Output 3**

> **Why Output 2 Wins:** IOC hunting commands are critical for an actively exploited CVE — "am I already hit?" is the first question after "am I exposed?" Output 2 is the only one with both `grep -E "PUT.*Range:"` and `find work -name "*.session" -mtime -7`. `allowPartialPut=false` is the second mitigation parameter in web.xml — fixing `readonly=true` alone is insufficient, and Output 1 completely misses this.
>
> **What Output 1 Does Better:** Prerequisites table (Default Setting / Required for RCE format) is the most scannable of the three for rapid risk assessment. VERDICT callout at the end is clean.
>
> **What Output 3 Uniquely Adds (Worth Borrowing):** CISA KEV date for compliance SLA tracking; `curl -X PUT` mitigation verification; portable `$CATALINA_HOME` variable. But at 45,298 tokens it is not a usable triage note.

---

### TC7 — AWS RDS-EVENT-0056

**Model: Claude Opus 4.5 | 3 prompt placements**

| Output       | Config          | Tokens | Key Strengths                                                                                                                                                                                                                                                                        | Gaps                                                                                                |
| ------------ | --------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| **Output 1** | Tool Node       | 13,337 | Root cause likelihood table (most scannable format); ✅/❌ connectivity → recovery path decision tree; `/24 CIDR` subnet sizing guidance                                                                                                                                             | No "Ticking Time Bomb" framing; no "Disable Automation" step; DNS fix listed but no CLI commands    |
| **Output 2** | Agent Node      | 16,442 | Full `aws rds restore-db-instance-to-point-in-time` CLI + snapshot restore as Option 2; DNS fix CLI (`aws ec2 modify-vpc-attribute`); "Escalation Path" callout; Delete Protection tip                                                                                               | No "Ticking Time Bomb" framing; no rename-instance trick; CloudWatch alarm uses Average not Minimum |
| **Output 3** | Agent+Tool Node | 26,730 | **"Ticking Time Bomb"** framing (unique urgency model); **"Disable Automation"** step (Terraform/CDK pipeline pause); `nc -zv` connectivity test; **rename-instance trick** (zero app string changes); find unused ENIs command; CloudWatch uses **Minimum** statistic (not Average) | More verbose than Output 1; DNS fix = check only, not the fix CLI                                   |

**Ranking: Output 3 > Output 2 > Output 1**

> **Why Output 3 Wins:**
>
> - "Ticking Time Bomb" — the instance looks fine but any unplanned reboot triggers extended downtime because it can't provision an ENI. This is the most important mental model for the IR team and no other output frames it this way.
> - "Disable Automation" — pausing Terraform/CloudFormation/CDK targeting this instance prevents state drift loops. Neither Output 1 nor 2 covers this.
> - Rename-instance trick — `--new-db-instance-identifier` swap avoids updating all connection strings; far more operationally elegant.
> - CloudWatch alarm uses `Minimum` statistic — Average masks brief drops to 0. The subtle but technically correct distinction.
>
> **What Output 2 Does Better:** DNS fix CLI commands; `restore-db-instance-from-db-snapshot` as Option 2; "Escalation Path" note.
> **What Output 1 Does Best:** Visual root cause table + connectivity decision tree — best under-pressure format for on-call engineers.

---

## 🏁 Overall Conclusions

### Part 1: Gemini vs. Opus — RDS-EVENT-0056 Best Output Comparison

| Dimension                                        | Gemini (Best: Output 3, 13,159T) | Opus (Best: Output 3, 26,730T) |
| ------------------------------------------------ | -------------------------------- | ------------------------------ |
| Token Cost                                       | ✅ Half the tokens               | ❌ 2× Gemini                   |
| "Ticking Time Bomb" framing                      | ❌                               | ✅ Opus only                   |
| "Disable Automation" step                        | ❌                               | ✅ Opus only                   |
| `nc -zv` connectivity test                       | ❌                               | ✅ Opus only                   |
| Rename Instance trick                            | ❌                               | ✅ Opus only                   |
| Find unused ENIs command                         | ❌                               | ✅ Opus only                   |
| Verify Backups First (`pg_dump` while port open) | ✅ Gemini only                   | ❌                             |
| Force-delete via AWS Support                     | ✅ Gemini only                   | ❌                             |
| CloudWatch Minimum statistic                     | ❌                               | ✅ Opus only                   |
| Operational Depth                                | Good                             | Better                         |

**Verdict:** Opus wins on content quality — "Disable Automation" and "Ticking Time Bomb" are genuinely superior. Gemini's "Verify Backups First" is something Opus missed that a seasoned DBA would catch. Neither is a complete answer alone.

### Part 2: Does Switching from Gemini Fix the Tool Node Failures?

Partially — but it's not that simple. The Gemini Tool Node error (`Cannot use 'in' operator to search for 'functionCall' in undefined`) is a JavaScript crash inside n8n when it parses Gemini's function call response schema. Anthropic/Opus models format tool call responses differently — which is why Opus Tool Node didn't crash here. But token bloat is not exclusive to Gemini; Opus hit 45,298T for CVE in Agent+Tool Node.

| Config                     | Gemini                            | Opus                              |
| -------------------------- | --------------------------------- | --------------------------------- |
| Tool Node (Output 1)       | ❌ 75% failure rate (RDS)         | ✅ Stable                         |
| Agent Node (Output 2)      | ✅ Stable (but 36K tokens on RDS) | ✅ Stable                         |
| Agent+Tool Node (Output 3) | ✅ Stable                         | ✅ Stable (but 45K tokens on CVE) |

### Part 3: Which Configuration to Recommend?

| Config              | Verdict                     | Notes                                                                                       |
| ------------------- | --------------------------- | ------------------------------------------------------------------------------------------- |
| **Tool Node**       | ❌ Do not use in production | Reliability failure with Gemini is disqualifying; fragile to API schema changes             |
| **Agent Node**      | ⚠️ Viable with caveats      | Stable across both models; Gemini can hit 36K tokens without a length constraint            |
| **Agent+Tool Node** | ✅ Recommended              | Consistently best output quality; stable reliability; token variance controlled with prompt |

**Recommendation:** Use **Agent+Tool Node with Claude Opus 4.5** and add an explicit token budget in the system prompt: _"Keep your triage note under 600 words. Be precise, not exhaustive."_

**Why not Gemini's Agent+Tool Node?** Performed well on Node.js (12,187T) and RDS (13,159T), but the 36K Agent Node token count on RDS and the Tool Node crash history indicate Gemini requires tighter length constraints and remains riskier in a production incident pipeline.

**The real systemic finding:** Prompt engineering for length control matters more than model choice. Whatever model you run, add a word or token budget to the system prompt — neither model self-regulates well without it.
