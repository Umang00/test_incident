# Non-RAG Incident Response - Test Cases (LLM Only)

Use these realistic **System Alerts** to test the "LLM-Only" workflow. Paste these into the chat as if they were automated notifications.

> **STRATEGY:**
>
> - **LLM-Only** should fail gracefully on "Unknowns" (Hard/Edge).
> - **Goal:** Verify internal knowledge base and reasoning capabilities without external tools.

---

## 🟢 Easy / Common Scenarios (Baseline)

_Standard incidents where internal knowledge is sufficient._

### 1. Classic Infrastructure Failure (Disk Full)

**Goal:** Verify workflow provides standard Linux mitigation steps.

```text
[ALERT] Filesystem /var/lib/mysql is 98% full
Severity: High
Host: db-prod-01
Mount: /dev/sda1
Message: no space left on device. Write operations failing.
```

- **LLM-Only:** Should suggest `apt-get clean`, check binlogs, expand volume.

#### 📊 Analysis Results (LLM-Only)

**Did anyone suggest `apt-get clean`?**

- **NO.** None of the 10 models suggested `apt-get clean`. They correctly identified this is a database partition (`/var/lib/mysql`) issue, not an OS package cache issue.
- **Verdict:** Models showed high context awareness.

| Model                  | Rating       | Key Strengths                                                                         | Weaknesses                                                                                                                             |
| ---------------------- | ------------ | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Gemini 3 Pro**       | 🟢 **Best**  | Found inode exhaustion (`df -i`), excellent emergency fallback scenarios.             | Slightly verbose.                                                                                                                      |
| **Claude Sonnet 4.5**  | 🟢 **Best**  | Production-ready logic (`logrotate` config), specific query for large tables.         | Suggested `rm` on log files (unsafe).                                                                                                  |
| **GPT-5.2 (temp 0.3)** | 🟢 **Great** | Smart first step (`read_only=ON`), found `lsof +L1` (deleted-but-open files).         | Repetitive structure.                                                                                                                  |
| **GPT-5.2 (no temp)**  | 🟢 **Great** | Explicitly checks replica status before purging.                                      | Verbose.                                                                                                                               |
| **Kimi-k2.5**          | 🟢 **Great** | Good identifying zombie files, robust log rotation config.                            | Risky `find ... xargs` suggestion.                                                                                                     |
| **Opus 4.5**           | 🟢 **Great** | Great UX, Quick Reference section.                                                    | Aggressive purge suggestion.                                                                                                           |
| **Qwen3.5-plus**       | 🟢 **Great** | Best MITRE mapping (T1070 disk-fill as log evasion). Suggested pausing ETL first.     | Restart suggested without safety check.                                                                                                |
| **GLM-4.7**            | 🟢 **Great** | Only model to address `ibtmp1` correctly. Suggested `innodb_temp_data_file_path` cap. | `PURGE BINARY LOGS BEFORE NOW()` without replica check — very risky.                                                                   |
| **Gemini Flash**       | 🟡 Good      | Most concise (2k tokens), cheap, good enough for basic triage.                        | Missed deeper checks (inodes, lsof).                                                                                                   |
| **GPT-5.2 (temp 0.5)** | 🟡 Good      | Good coverage.                                                                        | Risky `RESET SLAVE ALL` suggestion.                                                                                                    |
| **GPT-OSS-120b**       | 🟡 Good      | Clean table format for cleanup options.                                               | Aggressive "stop MySQL" step.                                                                                                          |
| **GPT-5.2 Codex**      | 🟡 Good      | Very concise.                                                                         | Shallow coverage.                                                                                                                      |
| **deepseek-v3.2**      | 🟡 Good      | `SHOW ENGINE INNODB STATUS` for deadlock detection — unique.                          | Showed `rm` on binlogs as option; `rm -rf ibtmp1` while running is dangerous.                                                          |
| **minimax-m2.5**       | 🟡 Good      | Clean prevention table.                                                               | `OPTIMIZE TABLE` on a full disk will fail; wildcard `find -delete` inside DB dir is risky.                                             |
| **Grok-4**             | 🟡 Good      | `lsof +L1` + `smartctl` for hardware fault — unique.                                  | Suggested copying binlogs to backup on the same 98%-full disk. Hardcoded 2023 date.                                                    |
| **llama-4-maverick**   | 🔴 **Bad**   | Concise.                                                                              | `mysqlcheck --auto-repair --optimize` on a full disk is actively harmful. No replica awareness, no inode check, no emergency fallback. |

> **Key Learning:** Temperature 0.3 is the "sweet spot" for SRE/Ops tasks. High temp (0.5+) introduced risky commands (e.g., `RESET SLAVE ALL`). Also: `llama-4-maverick` is the only model that would actively worsen the incident.

---

### 2. Common Security Pattern (SSH Brute Force)

**Goal:** Verify security categorization without hallucination.

```text
[ALERT] Suspicious Login Activity detected
Source IP: 45.132.89.21 (Russia)
User: root
Events: 240 failed password attempts in 60 seconds
Protocol: SSH
```

- **Expectation:** Identify Brute Force. Recommend blocking IP and `PermitRootLogin no`.

#### 📊 Analysis Results (LLM-Only)

**Did anyone suggest `PermitRootLogin no`?**

- **YES — All 7 models.** This is the baseline expectation and every model met it.

**Did anyone check for successful logins first?**

- **YES — All 7 models.** Every model correctly prioritized checking `auth.log` for "Accepted" before taking action. This is the most important step.

| Model                 | Rating       | Key Strengths                                                                                                                                                                               | Weaknesses                                                                                                                                           |
| --------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Opus 4.5**          | 🟢 **Best**  | Post-Incident Checklist (checkbox format). Blocked `/24` subnet, not just single IP. AbuseIPDB + `whois` threat intel commands. P1/P2/P3 priority table.                                    | Slightly verbose (3099 tokens).                                                                                                                      |
| **GPT-5.2**           | 🟢 **Best**  | Dedicated "If Compromise Is Suspected" section with volatile evidence preservation (`ps auxfw`, `ss -tpna` to file). Checked `sshd_config.d` drop-in directory. Used `sed -i` (scriptable). | Longest response (3421 tokens).                                                                                                                      |
| **Gemini 3 Pro**      | 🟢 **Great** | Used `systemctl reload sshd` (not restart) — preserves active sessions. Noted sshd CPU load as secondary risk. Clean structure.                                                             | Less depth on compromise investigation.                                                                                                              |
| **Kimi-k2.5**         | 🟢 **Great** | `ip route add blackhole` as iptables alternative. Checked `rpm -Va`/`debsums` for modified binaries. Blocked entire `/16` subnet.                                                           | Complex bash loop may confuse junior engineers.                                                                                                      |
| **Qwen3.5-plus**      | 🟢 **Great** | Best decision tree: explicit "If Accepted → STOP. Treat as Compromised" branching. Unique: noted log flooding could cause disk-full DoS.                                                    | Less depth on post-compromise investigation.                                                                                                         |
| **Claude Sonnet 4.5** | 🟡 Good      | Good IoC checklist (bash_history, authorized_keys, cron, new users). Suggested `auditd`.                                                                                                    | Port change listed as "Immediate (24h)" — it's noise reduction, not a security control. `apt-get update` on a potentially compromised host is risky. |
| **GLM-4.7**           | 🟡 Good      | `sed -i` for config changes. Correctly noted: weak root password = assume compromise even without "Accepted" log.                                                                           | Used `systemctl restart sshd` (not `reload`) — drops active sessions. Irrelevant MITRE mitigation (M1022).                                           |

> **Key Learnings:**
>
> 1. **All models passed the baseline** — every model identified brute force, suggested `PermitRootLogin no`, and checked for successful logins first.
> 2. **Differentiator**: Top models (Opus, GPT-5.2) went beyond containment into forensics — subnet blocking, volatile evidence preservation, and `sshd_config.d` awareness.
> 3. **Safety detail**: Only Gemini 3 Pro used `systemctl reload` instead of `restart` — critical for not dropping the engineer's own SSH session mid-incident.
> 4. **GLM-4.7 insight**: Assuming compromise when root password is weak (even without log evidence) is a mature security posture most models missed.

---

## 🟡 Medium Complexity (Context/Ambiguity)

_Incidents requiring synthesis or specific configuration knowledge._

### 3. Syntax/Configuration Error

**Goal:** Test code analysis capabilities.

```text
[ERROR] Nginx failed to start
Service: nginx.service
Message: [emerg] unknown directive "ssl_certificate_keyy" in /etc/nginx/sites-enabled/default:14
State: failed
```

- **Expectation:** Identify typo `ssl_certificate_keyy` -> `ssl_certificate_key`.

#### 📊 Analysis Results (LLM-Only)

**Did everyone identify the typo correctly?**

- **YES — All 7 models.** Every model correctly identified `ssl_certificate_keyy` → `ssl_certificate_key` and suggested `nginx -t` before restart.

| Model                 | Rating       | Key Strengths                                                                                                                                                                            | Weaknesses                                                               |
| --------------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| **Kimi-k2.5**         | 🟢 **Best**  | "DO NOT restart yet" warning (prevents log-spam loops). Scanned for similar typos across all configs (`grep -r "keyy\|certt"`). Verified SSL handshake with `openssl s_client`.          | No symlink awareness.                                                    |
| **Gemini 3 Pro**      | 🟢 **Best**  | Only model to flag `sites-enabled` as a **symlink** — edit the actual file. `nano +14` opens directly at line 14. Flagged unauthorized edits as potential malicious DoS.                 | Verbose (3018 tokens).                                                   |
| **Qwen3.5-plus**      | 🟢 **Great** | Only model with a **Rollback Procedure** section. Suggested differentiating alerts between "Service Down" vs "Config Error". Mentioned `nginx-lint` IDE plugins.                         | No symlink awareness.                                                    |
| **Claude Opus 4.5**   | 🟢 **Great** | Quick Verification Checklist (checkbox). Checked `git log` in `/etc/nginx` for recent changes. Scanned for other unknown directives post-fix.                                            | No symlink awareness.                                                    |
| **GPT-5.2**           | 🟢 **Great** | Used `nginx -T` (capital T) to dump full rendered config — catches issues in included files. Used `sudoedit` (more secure than `sudo nano`). Anticipated cert path as follow-on failure. | No rollback procedure.                                                   |
| **Claude Sonnet 4.5** | 🟡 Good      | Included Estimated Resolution Time (5-10 min) and Impact Window — useful for incident comms.                                                                                             | Used deprecated `netstat` instead of `ss`. No unique technical insights. |
| **GLM-4.7**           | 🟡 Good      | Flagged Config Management conflict (Ansible/Puppet will overwrite manual fix). Checked Load Balancer health after fix.                                                                   | Highest tokens (2866) for a medium case.                                 |

> **Key Learnings:**
>
> 1. **All models passed baseline** — typo identified, `nginx -t` before restart, backup before edit.
> 2. **Symlink trap**: Only Gemini 3 Pro caught that `sites-enabled` files are symlinks — editing the symlink vs. the actual file is a real-world gotcha.
> 3. **`nginx -T` vs `-t`**: GPT-5.2's use of capital `-T` (full config dump) is superior for catching errors in `include`d files that `-t` alone misses.
> 4. **Process gap awareness**: GLM-4.7's Config Management conflict warning is the most operationally mature insight — a manual fix on a CM-managed file will be silently reverted.

### 4. Application Logic Error (Java OOM)

**Goal:** Test reasoning with conflicting symptoms.

```text
[ALERT] Java Application OOM
Error: java.lang.OutOfMemoryError: Java heap space
Context: Heap is set to 8GB. Server has 64GB RAM. Usage is flat at 2GB, then spikes instantly.
```

- **Expectation:** Investigate "Memory Leak" vs "Massive Allocation".

---

## 🟡 Medium / Version-Specific Cases

_Incidents requiring runtime/ecosystem knowledge._

### 7. Version-Specific Bug (Node.js V8 Crash)

**Goal:** Test version-specific runtime knowledge and native addon ABI understanding. Can models correctly diagnose a `v8::ToLocalChecked` fatal error after a Node.js upgrade?

```text
[ALERT] Node.js service crash loop
Error: FATAL ERROR: v8::ToLocalChecked Empty Handling
Node.js version: v22.4.1 (upgraded yesterday, no code changes)
Crash pattern: Process restarts, runs ~30 minutes, then crashes again
```

- **LLM-Only:** Should identify native addon ABI mismatch as primary cause. Should recommend `npm rebuild` or rollback to Node 20 LTS. Should NOT hallucinate specific version-level bugs without verification.

#### 🔬 Fact-Check (Web-Verified)

> **The alert is technically legitimate.** `FATAL ERROR: v8::ToLocalChecked Empty Handling` is a real class of V8 fatal errors confirmed in Node.js v22.x GitHub issues.
>
> Key facts verified:
>
> - ✅ **`v8::ToLocalChecked Empty Handling`** — real error class, confirmed in Node.js v22.x and v23.x GitHub issues (Nov 2024, Jan 2025)
> - ✅ **v22.4.1 ships V8 v12.4.254.21** — confirmed via Node.js changelog
> - ✅ **Node.js v22 is "Current" (not LTS)** — all models correctly noted this; Node 20 LTS is the safe rollback target
> - ✅ **`npm rebuild`** — correct first fix for ABI mismatch between native addons and new V8 version
> - ✅ **`--report-on-fatalerror`** — real Node.js diagnostic flag, generates JSON crash report
> - ✅ **Opus's addon version table** — all recommendations verified accurate:
>
> | Addon                    | Recommendation                        | Verified? |
> | ------------------------ | ------------------------------------- | --------- |
> | `sharp` → `0.33.4+`      | Uses Node-API v9, Node 22 compatible  | ✅        |
> | `bcrypt` → `bcryptjs`    | Pure JS, no native bindings           | ✅        |
> | `grpc` → `@grpc/grpc-js` | Pure JS gRPC implementation           | ✅        |
> | `sqlite3` → `5.1.7+`     | Uses Node-API, not tied to V8 version | ✅        |
>
> - ❌ **Sonnet's claim: "v22.4.1 has documented V8 stability issues; use v22.4.0 or v22.5.0+"** — **WRONG on both counts:**
>   - No evidence v22.4.0 is specifically safer than v22.4.1 (both use V8 12.4.x)
>   - **v22.5.0 actually had a worse regression** — V8 Fast API integration broke `fs.close` and `fs.closeSync`, causing widespread failures. v22.5.1 was the emergency fix.
>   - Recommending v22.5.0 as a "safe" version is actively harmful advice.
> - ⚠️ **Gemini's `list rm -rf node_modules`** — `list` is not a valid command prefix; likely a copy-paste artifact. Harmless but sloppy.
> - ✅ **`strace -e trace=openat -f node server.js | grep ".node"`** (Kimi) — valid technique to identify which native module is being loaded at crash time

#### 📊 Analysis Results (LLM-Only)

**V8 Crash Diagnosis — Correct root cause? Right fix sequence? No version hallucinations?**

| Model                 | Tokens | Root Cause Correct? | Fix Sequence                      | Version Claims | Rating         | Key Strengths                                                                                                                                                                                                                                                               | Weaknesses                                                                                                                                                                                       |
| --------------------- | ------ | ------------------- | --------------------------------- | -------------- | -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------- |
| **Kimi-k2.5**         | 2801   | ✅ Native ABI       | ✅ Rollback → rebuild → verify    | ✅ Accurate    | 🟢 **Best**    | `strace -e trace=openat` to identify crashing `.node` file at runtime — unique and clever. `NODE_OPTIONS="--report-on-fatalerror"`. `pmap -x` for native memory leak detection.                                                                                             | No addon-specific version recommendations.                                                                                                                                                       |
| **GLM-4.7**           | 3035   | ✅ Native ABI       | ✅ Rebuild → rollback             | ✅ Accurate    | 🟢 **Great**   | Correctly flagged v22 as "Current" (non-LTS). `engines` field in package.json. Post-deployment 30-40 min smoke test recommendation — directly addresses the delayed crash window.                                                                                           | No `--report-on-fatalerror`. No specific addon recommendations.                                                                                                                                  |
| **GPT-5.2**           | 3456   | ✅ Native ABI + OOM | ✅ Rollback first, rebuild second | ✅ Accurate    | 🟢 **Best**    | Most complete: `dmesg -T                                                                                                                                                                                                                                                    | egrep 'oom-killer'`to rule out OOM.`kubectl describe pod`for K8s environments.`--heapsnapshot-near-heap-limit=3`for heap analysis.`jq`on crash report JSON.`coredumpctl` for systemd core dumps. | Longest response (3456 tokens). |
| **Gemini 3 Pro**      | 3315   | ✅ Native ABI       | ✅ Rollback first                 | ✅ Accurate    | 🟢 **Great**   | `llnode` for V8 crash analysis (`v8 bt` in core dump). Correctly identified `nan` vs `node-gyp` as addon binding mechanisms. Docker multi-stage build warning (don't copy `node_modules` from macOS to Linux).                                                              | `list rm -rf node_modules` — `list` is not a valid command prefix (copy-paste artifact).                                                                                                         |
| **Qwen3.5-plus**      | 2504   | ✅ Native ABI       | ✅ Stop → rollback → rebuild      | ✅ Accurate    | 🟢 **Great**   | `--trace-enable-local` flag for V8 handle tracing. `npm install --build-from-source` to force recompilation. Correctly noted v22 LTS date (Oct 2024). MITRE: "Not applicable" — correct.                                                                                    | `--trace-enable-local` is not a standard Node.js flag — may be confused with `--trace-gc`. Minor inaccuracy.                                                                                     |
| **Claude Sonnet 4.5** | 2975   | ✅ Native ABI       | ✅ Rollback                       | ❌ **Wrong**   | 🟡 **Partial** | `sar -r 1 10` for memory trend. `systemctl show` for MemoryCurrent. Unhandled promise rejection check. Systemd `StartLimitBurst` for crash loop containment.                                                                                                                | **Claimed v22.4.1 has "documented V8 stability issues" and recommended v22.4.0 or v22.5.0+.** v22.5.0 had a _worse_ regression (V8 Fast API `fs.close` bug). This is actively harmful advice.    |
| **Claude Opus 4.5**   | 2806   | ✅ Native ABI       | ✅ Rollback → rebuild             | ✅ Accurate    | 🟢 **Best**    | **Best addon-specific table** — `sharp 0.33.4+`, `bcryptjs`, `@grpc/grpc-js`, `sqlite3 5.1.7+` all verified accurate. `curl` to GitHub API to search Node.js issues. `timeout 2700` uptime monitor for 45-min soak test. V8 heap ratio metric via `v8.getHeapStatistics()`. | None significant.                                                                                                                                                                                |

> **Key Learnings:**
>
> 1. **All 6 models correctly identified native addon ABI mismatch as the primary cause** — the baseline was met. No model blamed application code or suggested a software bug fix as the first step.
> 2. **Sonnet hallucinated a version-specific claim** — stating v22.4.1 is uniquely broken and recommending v22.5.0 as safer. v22.5.0 had a _worse_ V8 regression (Fast API `fs.close` bug fixed in v22.5.1). In a real incident, this advice could make things worse.
> 3. **Opus's addon migration table is the most actionable output** — all four recommendations (`bcryptjs`, `@grpc/grpc-js`, `sharp 0.33.4+`, `sqlite3 5.1.7+`) are verified accurate and represent real production migration paths.
> 4. **Kimi's `strace -e trace=openat`** is the most creative diagnostic — it identifies exactly which `.node` file is being loaded at crash time, pinpointing the culprit without guesswork.
> 5. **GPT-5.2's OOM check (`dmesg | egrep oom-killer`)** is the most complete — the 30-minute crash window could be OOM-triggered, not just ABI mismatch. Ruling it out is the right approach.
> 6. **The 30-minute crash window is a key diagnostic clue** — GLM-4.7 was the only model to explicitly recommend a 30-40 minute post-deployment smoke test to catch exactly this failure pattern.
> 7. **Docker cross-platform trap** (Gemini) — copying `node_modules` from macOS/Windows to a Linux container is a common real-world cause of native addon crashes. Only Gemini flagged this.

---

## 🔴 Hard / Specific Knowledge (The "Search Delta")

_Incidents requiring external data (CVEs, specific versions) where LLM-Only usually fails or hallucinates._

### 5. Vulnerability Lookup (CVE)

**Goal:** The ultimate Search test. LLM-Only should NOT know a fictional/new CVE.

```text
[SCANNER] Critical Vulnerability Detected
CVE: CVE-2025-9921
Package: openssl v3.1.2
Score: 8.8 (High)
Vector: Network
```

- **LLM-Only:** Should say "I don't have details on this specific CVE." (Or hallucinate!).

#### 🔬 CVE Fact-Check (NVD-Verified)

> ⚠️ **CVE-2025-9921 EXISTS but is completely misattributed in the alert.**
>
> | Field             | Alert Claimed         | NVD Reality                                                |
> | ----------------- | --------------------- | ---------------------------------------------------------- |
> | **Package**       | OpenSSL v3.1.2        | **code-projects POS Pharmacy System 1.0**                  |
> | **Vuln Type**     | RCE / Network exploit | **Cross-Site Scripting (XSS)** — CWE-79, CWE-94            |
> | **CVSS Score**    | 8.8 High              | **5.4 Medium** (NIST) / 4.8 Medium (VulDB)                 |
> | **Affected file** | —                     | `/main/products.php` via `product_code`, `gen_name` params |
>
> **What IS true about OpenSSL 3.1.x:**
>
> - ✅ OpenSSL 3.1.x reached **EOL on March 14, 2025** — no more security patches (confirmed)
> - ✅ OpenSSL 3.1.2 is a real version
> - ❌ CVE-2025-9921 has **nothing to do with OpenSSL** — it's an XSS in a PHP pharmacy app
> - ✅ Real 2025 OpenSSL CVEs: CVE-2025-15467 (stack buffer overflow, High), CVE-2025-9230 (OOB memory ops, Moderate)
>
> **This makes the test harder than expected:** The CVE number is real, but the package, severity, and vuln class are all wrong. A search-augmented model would have immediately found the mismatch. Models that hallucinated OpenSSL RCE details were **triply wrong** — wrong package, wrong CVSS, wrong vulnerability class.

#### 📊 Analysis Results (LLM-Only)

**Hallucination Test — Did models catch the CVE misattribution?**

| Model                 | Tokens | Hallucinated?  | Disclaimer  | Rating       | Key Strengths                                                                                                                                                                                                  | Weaknesses                                                                                                                                                            |
| --------------------- | ------ | -------------- | ----------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Kimi-k2.5**         | 3752   | 🔴 **YES**     | ❌ None     | 🔴 **Fail**  | Good technical depth (lsof libssl, SSH restart warning). Correctly stated OpenSSL 3.1.x EOL March 2025.                                                                                                        | Treated misattributed CVE as confirmed OpenSSL RCE. No disclaimer. Triply wrong: wrong package, wrong CVSS, wrong vuln class.                                         |
| **GLM-4.7**           | 3775   | 🟡 **Partial** | ⚠️ Vague    | 🟡 Partial   | Noted "specifics pending full disclosure." Flagged ubiquity risk (patch ≠ fix without service restart).                                                                                                        | Disclaimer buried in MITRE section. Still ran full OpenSSL remediation as if CVE were confirmed.                                                                      |
| **GPT-5.2**           | 3236   | ✅ **NO**      | ✅ Explicit | 🟢 **Best**  | Explicitly stated: _"I don't have authoritative details of CVE-2025-9921."_ Asked for vendor advisory. Provided safe generic guide as contingency. Would have caught the misattribution with search.           | None significant.                                                                                                                                                     |
| **Gemini 3 Pro**      | 3239   | ✅ **NO**      | ✅ Explicit | 🟢 **Best**  | Explicitly stated: _"CVE-2025-9921 does not currently exist in public databases."_ (Technically wrong — it exists but for a different package — but the instinct to verify was correct.)                       | Verbose. Slightly overconfident in "doesn't exist" vs "can't verify."                                                                                                 |
| **Qwen3.5-plus**      | 2329   | ✅ **NO**      | ✅ Explicit | 🟢 **Great** | Noted CVE "appears to be hypothetical or future-dated." `lsof -n \| grep libssl \| grep DEL` for deleted-library detection. Mentioned static linking gap for Go binaries.                                      | Disclaimer was a note, not a hard stop.                                                                                                                               |
| **Claude Sonnet 4.5** | 3539   | ✅ **NO**      | ✅ Explicit | 🟢 **Great** | Most thorough disclaimer: flagged typo possibility, embargoed CVE, and false positive scenarios. Suggested `curl` to NVD directly. Added `checkrestart` / `needs-restarting` for post-patch service detection. | Longest response (3539 tokens) when "verify first" was the right answer.                                                                                              |
| **Claude Opus 4.5**   | 2711   | ✅ **NO**      | ✅ Explicit | 🟢 **Best**  | Clean disclaimer with direct NVD/OpenSSL links. `lsof \| grep 'libssl.*DEL'` — best service-restart detection. Concise. Explicitly said "if CVE does not exist, this may be a scanner false positive."         | —                                                                                                                                                                     |
| **Gemma-3b-27b-it**   | 2179   | 🔴 **YES**     | ❌ None     | 🔴 **Fail**  | Structured response, good escalation triggers.                                                                                                                                                                 | Treated CVE as confirmed RCE. Used non-existent MITRE ID `M1663` (correct: M1051). **Triple hallucination**: fake CVE context + fake MITRE ID + wrong severity class. |

> **Key Learnings (Revised):**
>
> 1. **The CVE is real but misattributed** — CVE-2025-9921 is an XSS in a PHP pharmacy app (CVSS 5.4), not an OpenSSL RCE (CVSS 8.8). This is a deliberate misattribution test, harder than a purely fictional CVE.
> 2. **Hallucination split: 3 failed, 5 passed.** Kimi, GLM, and Gemma treated the misattributed CVE as real OpenSSL RCE. GPT-5.2, Gemini 3 Pro, Qwen, Sonnet, and Opus all flagged uncertainty.
> 3. **Gemma triple-hallucinated**: wrong CVE context + non-existent MITRE ID `M1663` + wrong severity. Worst failure mode — confident, specific, and wrong on three counts.
> 4. **Opus upgraded to Best**: "If CVE does not exist, this may be a scanner false positive" — the closest any model got to the right diagnosis (misattribution / false positive).
> 5. **LLM + Search would have won decisively**: A single NVD lookup would show CVE-2025-9921 = PHP XSS, immediately exposing the alert as corrupted/misattributed data.
> 6. **`lsof | grep 'libssl.*DEL'`** (Opus/Qwen): The `DEL` flag finds processes holding handles to the replaced old library — most precise post-patch restart detection.

### 6. Vendor Specific Error Code

**Goal:** Test lookup of obscure documentation. The alert deliberately pairs a real AWS event ID with the wrong message to test whether models look up the actual event definition.

```text
[ALERT] Amazon RDS Event
Source: db-instance-prod
Event ID: RDS-EVENT-0056
Message: The database instance is in an incompatible network state.
```

- **LLM-Only:** Might guess generic network issues (or look up the actual event ID).

#### 🔬 Event ID Fact-Check (AWS Docs Verified)

> ⚠️ **RDS-EVENT-0056 is misattributed in the alert — same pattern as Test Case 5.**
>
> | Field               | Alert Claimed                                                | AWS Reality                                                                                                                     |
> | ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
> | **Event ID**        | RDS-EVENT-0056                                               | RDS-EVENT-0056 ✅ (real event ID)                                                                                               |
> | **Message**         | "The database instance is in an incompatible network state." | **"The number of databases in the DB instance exceeds recommended best practices. Consider reducing the number of databases."** |
> | **Severity**        | Implied Critical                                             | **Warning / Best Practices Notification**                                                                                       |
> | **Action Required** | Emergency network triage                                     | Reduce database count on instance                                                                                               |
>
> **What IS true about RDS incompatible-network state:**
>
> - ✅ `incompatible-network` is a real RDS status — but it's NOT tied to event ID 0056
> - ✅ Real causes: subnet deletion, IP exhaustion, ENI quota hit, DNS disabled in VPC
> - ✅ `AWSSupport-ValidateRdsNetworkConfiguration` SSM runbook exists for diagnosing it
> - ✅ `start-db-instance` CLI command is the first recommended recovery step (not reboot)
> - ❌ RDS-EVENT-0056 has nothing to do with network state — it's a DB count warning
>
> **This is a harder misattribution than TC5:** The event ID is real and the described condition (incompatible-network) is real — they just don't belong together. A search-augmented model looking up RDS-EVENT-0056 would immediately find the mismatch.

#### 📊 Analysis Results (LLM-Only)

**Hallucination Test — Did any model catch the event ID / message mismatch?**

| Model                 | Tokens | Caught Mismatch? | Rating       | Key Strengths                                                                                                                                                                                                                                             | Weaknesses                                                                                                                                                                      |
| --------------------- | ------ | ---------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Kimi-k2.5**         | 2897   | 🔴 **NO**        | 🟡 Good      | Best CLI coverage: CloudTrail lookup for `AuthorizeSecurityGroupIngress`, `ModifyDBInstance`. Correct "DO NOT delete subnet group if instance is using it." Snapshot-before-restore pattern.                                                              | Treated misattributed event ID as gospel. No attempt to verify RDS-EVENT-0056 definition. Reboot with `--force-failover` as recovery step is risky without confirming Multi-AZ. |
| **GLM-4.7**           | 3793   | 🔴 **NO**        | 🟡 Good      | Unique insight: "toggle Performance Insights to force network state refresh" — valid AWS trick. Flagged `inaccessible-encryption-credentials-recovery` as KMS key escalation path.                                                                        | Treated misattributed event as real. `modify-db-instance` with `--apply-immediately` to swap SG causes brief outage — should be flagged more prominently.                       |
| **GPT-5.2**           | 3525   | 🔴 **NO**        | 🟢 **Best**  | Most complete subnet validation loop (bash for-loop over all subnet IDs). Explicitly listed IP exhaustion as a cause. Snapshot restore with endpoint swing via Route53 CNAME. Asked for engine/port/Multi-AZ context before prescribing fix.              | Did not question the event ID. Verbose but well-structured.                                                                                                                     |
| **Gemini 3 Pro**      | 3549   | 🔴 **NO**        | 🟢 **Best**  | **Only model to prominently warn "DO NOT REBOOT"** as first action. Correctly identified IP exhaustion as primary cause. MITRE ATT&CK mapping (T1498) for malicious IP exhaustion. `backup-retention-period` toggle to force state refresh — valid trick. | Did not verify event ID. MITRE mapping is a stretch for an operational misconfiguration.                                                                                        |
| **Qwen3.5-plus**      | 2897   | 🔴 **NO**        | 🟢 **Great** | Unique: `lifecycle { prevent_destroy = true }` Terraform guard on subnets. Mentioned `rds-instance-subnet-group-check` AWS Config rule. Watched for `RDS-EVENT-0057` (recovery complete) as verification signal.                                          | Did not verify event ID. `force-failover` reboot without confirming Multi-AZ is risky.                                                                                          |
| **Claude Sonnet 4.5** | 3015   | 🔴 **NO**        | 🟡 Good      | `aws rds modify-db-subnet-group` (correct API). Suggested `mysql`/`psql` client test for end-to-end verification. CloudWatch alarm for RDS events via SNS.                                                                                                | Shortest response for a complex scenario. Did not verify event ID. Missing IP exhaustion as a cause.                                                                            |
| **Claude Opus 4.5**   | 3356   | 🔴 **NO**        | 🟢 **Best**  | Most complete scenario matrix (SG deleted / ENI/IP exhaustion / subnet group). `watch -n 10` loop for status monitoring. Prevention table format is clearest. Explicitly listed CloudTrail events to include in AWS Support case.                         | Did not verify event ID. `--force-failover` without Multi-AZ check.                                                                                                             |
| **Gemma-3b-27b-it**   | 2014   | 🔴 **NO**        | 🟡 Partial   | Shortest response. Correctly said "Do NOT force reboot yet." Mentioned VPC Flow Logs for traffic analysis.                                                                                                                                                | Weakest coverage overall. No subnet group validation, no IP exhaustion check, no CloudTrail lookup. `date -v-5m` flag is macOS syntax — broken on Linux.                        |

> **Key Learnings:**
>
> 1. **0 out of 7 models caught the event ID mismatch.** Every model treated "incompatible network state" as the real condition without verifying RDS-EVENT-0056. This is the clearest demonstration of why LLM + Search beats LLM-Only for vendor error codes.
> 2. **The advice given was technically correct for the wrong problem.** All models gave valid incompatible-network triage — but RDS-EVENT-0056 is a best-practices warning about too many databases. The actual fix is trivial: reduce DB count.
> 3. **Gemini 3 Pro's "DO NOT REBOOT" warning is the most important safety call.** Rebooting an instance genuinely in incompatible-network state can prevent it from coming back online — this is confirmed by AWS docs.
> 4. **`start-db-instance` (not reboot) is the AWS-recommended first step** for incompatible-network — only GPT-5.2 and Opus covered snapshot restore paths; none mentioned `start-db-instance` specifically.
> 5. **`date -v-5m` (Gemma)** is macOS `date` syntax. On Linux the correct flag is `date -d '5 minutes ago'`. A subtle but real error in a runbook command.
> 6. **LLM + Search would have won immediately**: searching "RDS-EVENT-0056" returns the AWS docs page in the first result, showing the real message. Zero network triage needed.

### 7. Version-Specific Bug

**Goal:** Test finding bugs in specific software versions.

```text
[TICKET] Node.js Crash Loop
Version: Node.js v22.4.1
Error: "Fatal error: v8::ToLocalChecked Empty Handling" after 30 mins of uptime.
Context: No code changes committed. Started after upgrade.
```

- **Expectation:** Search should find "Node.js v22.4.1 regression" or similar Github issues.

---

## 🟣 Edge Cases & Stress Tests

_Vague, panicked, or adversarial inputs._

### 8. Panic / "Mayday"

**Goal:** Test calmness and structured response to unstructured panic.

```text
[ALERT] MAYDAY MAYDAY MAYDAY server is on fire literally smoke coming out help
```

- **Expectation:** Acknowledge emergency. Advise physical safety (if literal fire) or shutdown. Do NOT hallucinate a software fix for hardware fire.

### 9. "We are Hacked" (Vague)

**Goal:** Test establishing a triage framework from zero context. Unlike TC5/TC6, this alert is NOT misattributed — `.crypt` extension + flashing red screens is a genuine ransomware indicator. The test is about response quality, prioritization, and accuracy of advice under panic.

```text
[Check] I think we are hacked. Screens are flashing red and files are renamed to .crypt
```

- **Expectation:** Identify **Ransomware**. Immediate isolation steps (disconnect network). Do NOT suggest "antivirus scan" as a first step (too late).

#### 🔬 Fact-Check (Web-Verified)

> **Alert is legitimate — no misattribution.** `.crypt` is a real ransomware extension associated with CryptXXX v3 (Rannoh Decryptor available on nomoreransom.org), Crypt0L0cker, and Dharma variants.
>
> Key facts verified:
>
> - ✅ **nomoreransom.org** is real — CryptXXX v3 (`.crypt` extension) has a free Rannoh Decryptor
> - ✅ **`vssadmin list shadows`** — correct command to check Volume Shadow Copies
> - ✅ **Hibernate before power-off** (`shutdown /h`) — valid technique to preserve RAM for key recovery
> - ✅ **ID Ransomware** (`id-ransomware.malwarehunterteam.com`) — real, working tool for strain identification
> - ❌ **Opus's IR hotline numbers are all wrong:**
>
> | Firm        | Opus Cited     | Actual Number       |
> | ----------- | -------------- | ------------------- |
> | CrowdStrike | 1-855-276-9335 | **+1 855-276-9347** |
> | Mandiant    | 1-833-362-6342 | **+1 844-613-7588** |
> | Secureworks | 1-877-838-7947 | **+1 877-884-1110** |
>
> - ❌ **Sonnet's `sudo dd if=/dev/mem`** — broken on modern Linux kernels (`/dev/mem` access is restricted by default). Correct tools: `avml`, `LiME` kernel module, or `FTK Imager` on Windows.
> - ⚠️ **Kimi's strain guesses** (Crysis/Dharma, CryptXXX) — plausible but speculative without sample analysis. Not a hallucination, but presented with more confidence than warranted.

#### 📊 Analysis Results (LLM-Only)

**Ransomware Response Test — Isolation-first, no AV scan, correct forensics advice?**

| Model                 | Tokens | Isolation First? | No AV Scan? | Hibernate Tip? | Rating       | Key Strengths                                                                                                                                                                                                               | Weaknesses                                                                                                                                                                               |
| --------------------- | ------ | ---------------- | ----------- | -------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Kimi-k2.5**         | 3064   | ✅ Yes           | ✅ Yes      | ❌ No          | 🟢 **Best**  | Best scope commands: `Get-ChildItem *.crypt`, ransom note finder. "Yank power cord if encryption is rapid" — correct triage decision. Backup admin alert + DC check. `nomoreransom.org` reference.                          | Strain guesses (Crysis/Dharma) presented as fact without sample. No hibernate recommendation.                                                                                            |
| **GLM-4.7**           | 3347   | ✅ Yes           | ✅ Yes      | ❌ No          | 🟢 **Great** | "DO NOT REBOOT — volatile memory artifacts needed." Linux commands included (`ps aux`, `find`). Memory dump + disk image before wipe. Credential reset reminder.                                                            | No hibernate tip. Shorter recovery section. No IR firm contacts.                                                                                                                         |
| **GPT-5.2**           | 3008   | ✅ Yes           | ✅ Yes      | ❌ No          | 🟢 **Best**  | Most complete enterprise scope: SMB block between VLANs, disable user AD account, pause backup jobs to prevent replicating encrypted data. Explicitly asked for EDR product name. Route53 CNAME pattern for endpoint swing. | No hibernate tip. No nomoreransom.org reference.                                                                                                                                         |
| **Gemini 3 Pro**      | 3285   | ✅ Yes           | ✅ Yes      | ✅ **Yes**     | 🟢 **Best**  | **Only model to recommend Hibernate** (`shutdown /h` preferred over hard power-off). "Shut down File Server service to stop write operations" — fastest way to protect network shares. DBAN/Secure Erase for wipe.          | T0865 MITRE ID is ICS/OT framework (MITRE ATT&CK for ICS), not enterprise ATT&CK. Minor mapping error.                                                                                   |
| **Qwen3.5-plus**      | 2392   | ✅ Yes           | ✅ Yes      | ❌ No          | 🟢 **Great** | `ipmitool` for out-of-band NIC disable — unique and correct for server environments. Splunk query example for SIEM correlation. `mpcmdrun.exe -Scan` for post-restore verification. WORM storage mention.                   | No hibernate tip. ipmitool command is vendor-specific (noted, but could confuse).                                                                                                        |
| **Claude Sonnet 4.5** | 3281   | ✅ Yes           | ✅ Yes      | ❌ No          | 🟢 **Great** | Most complete checklist format. `rfkill block all` for Bluetooth isolation. `Get-SmbConnection` / `Get-SmbSession` for share audit. IC3 + CISA reporting links. `nomoreransom.org` reference.                               | **`sudo dd if=/dev/mem`** — broken on modern Linux kernels (restricted access). Should use `avml` or `LiME`.                                                                             |
| **Claude Opus 4.5**   | 3208   | ✅ Yes           | ✅ Yes      | ✅ **Yes**     | 🟡 **Good**  | Best prevention table format. `wevtutil epl` for event log export. Cisco ACL example for switch-level isolation. Hibernate recommendation. `.crypt` family list (Crypt0L0cker, CryptFile2).                                 | **All 3 IR hotline numbers are wrong** (verified via web search). In a real incident, calling these numbers wastes critical minutes. Significant hallucination for a high-stakes detail. |

> **Key Learnings:**
>
> 1. **All 6 models correctly identified ransomware and led with isolation** — the baseline expectation was met by every model. No model suggested "run antivirus first."
> 2. **Opus hallucinated all 3 IR firm phone numbers.** CrowdStrike, Mandiant, and Secureworks numbers are all wrong. In a real incident, this wastes critical minutes. High-confidence hallucination on high-stakes contact info is the worst failure mode here.
> 3. **Only Gemini 3 Pro and Opus recommended Hibernate** (`shutdown /h`) to preserve RAM for encryption key recovery — a technique that can mean the difference between decryption and full data loss.
> 4. **Sonnet's `dd if=/dev/mem`** is broken on modern Linux kernels. `/dev/mem` access is restricted by default since kernel 4.x. Correct tools: `avml` (userspace), `LiME` (kernel module), or `FTK Imager` (Windows). A runbook command that silently fails is dangerous.
> 5. **GPT-5.2's "pause backup jobs"** is the most overlooked but critical step — ransomware actively targets backup systems, and a running backup job can replicate encrypted files over clean backups.
> 6. **Gemini's "shut down File Server service"** is the fastest way to stop network share encryption without full network isolation — useful when you can't isolate the infected endpoint immediately.
> 7. **This test case has NO misattribution** — unlike TC5/TC6, the alert is genuine. The differentiator is response quality, not hallucination detection.

### 10. Adversarial / Irrelevant

**Goal:** Test relevance filtering. The ideal response is a brief, humorous dismissal — "this is not an IT infrastructure incident." The failure mode is applying full SRE protocols to a coffee machine.

```text
[ALERT] Coffee machine is out of beans. Error 418: I'm a teapot.
```

- **Expectation:** Humor or dismissal ("Not an IT infrastructure incident"). Should NOT try to debug the coffee machine seriously using SRE protocols.

#### 🔬 Fact-Check (No Web Search Needed)

> **The alert is technically coherent — which is what makes it a good adversarial test.**
>
> - ✅ **RFC 2324** is a real IETF RFC (April Fools' 1998) — "Hyper Text Coffee Pot Control Protocol" (HTCPCP/1.0)
> - ✅ **HTTP 418 "I'm a teapot"** is a real status code defined in RFC 2324 — a server can return it to refuse brewing coffee because it is a teapot
> - ✅ **HTCPCP `BREW` method** is defined in RFC 2324 — `curl -X BREW` is technically correct per the spec
> - ✅ **`curl -X BREW coffee-maker.local/coffee`** (Kimi, Gemini) — valid HTCPCP syntax per RFC 2324
> - ⚠️ **`snmpwalk -v2c -c public coffee-maker.local 1.3.6.1.4.1.2324`** (Kimi) — the OID `.2324` is a playful reference to RFC 2324 but not a real registered SNMP OID. Technically a hallucination, but in a humorous context.
> - ⚠️ **Opus's `M1337`** mitigation — not a real MITRE ATT&CK mitigation ID (M-codes go up to ~M1056). Intentional joke, but worth noting.
> - ✅ **Qwen's MITRE mapping: "Not applicable"** — the only model to correctly state no MITRE mapping applies.

#### 📊 Analysis Results (LLM-Only)

**Relevance Filter Test — Did models dismiss, deflect, or go full SRE?**

| Model                 | Tokens | Dismissed?     | Humor Calibration | MITRE Mapping | Rating         | Key Strengths                                                                                                                                                                                                                                                                                                        | Weaknesses                                                                                                |
| --------------------- | ------ | -------------- | ----------------- | ------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **Kimi-k2.5**         | 2605   | ❌ Full SRE    | 🟢 Excellent      | ⚠️ Stretched  | 🟢 **Best**    | Best humor: "wizard required for transfiguration incident." `curl -X BREW` per RFC 2324 spec. Fake SNMP OID is a clever joke. "Escalate if device is ceramic with tea infuser."                                                                                                                                      | Longest response (2605 tokens) for a non-incident. Full SRE format applied.                               |
| **GLM-4.7**           | 3244   | ❌ Full SRE    | 🟡 Moderate       | ⚠️ Stretched  | 🟡 **Partial** | "Blast radius: caffeine withdrawal." Quota enforcement (3 cups/hour per engineer). IoT botnet C2 channel escalation trigger — actually a valid real-world concern for smart devices.                                                                                                                                 | Highest token count (3244) for a joke alert. Least funny of the group. Took it most seriously.            |
| **GPT-5.2**           | 1711   | ✅ **Partial** | 🟢 Good           | ✅ None       | 🟢 **Best**    | **Shortest response** — correctly calibrated effort to alert severity. Practical real-world advice (grinder jam, optical sensor dust). Asked for machine model to give specific steps. No MITRE mapping.                                                                                                             | Didn't explicitly call it out as non-IT. Still wrote a structured triage note.                            |
| **Gemini 3 Pro**      | 3309   | ❌ Full SRE    | 🟢 Excellent      | ⚠️ Stretched  | 🟢 **Great**   | "Severity: Low (High if pre-caffeine window 08:00-10:00 local)" — best severity line. `curl -X BREW` per HTCPCP spec. "Did someone log in and change the brewing profile to Tea?" MITRE T1078.                                                                                                                       | High token count for a joke. Full SRE format.                                                             |
| **Qwen3.5-plus**      | 1858   | ✅ **Partial** | 🟡 Moderate       | ✅ **None**   | 🟢 **Best**    | **Only model to explicitly state "MITRE ATT&CK: Not applicable."** Second shortest response. Correctly scoped impact: "no impact on production infrastructure, data integrity, or security posture."                                                                                                                 | Dry tone — least humorous. Didn't explicitly dismiss as non-IT.                                           |
| **Claude Sonnet 4.5** | 2269   | ✅ **Partial** | 🟢 Excellent      | ✅ None       | 🟢 **Great**   | **Explicitly acknowledged it's a test**: "While this appears to be a humorous/test query, I'm providing a thorough response to demonstrate the framework." "Actual Recommendation: Keep emergency espresso packets in your on-call bag." Redundancy planning: "pourover, French press — different technology stack." | Still wrote a full triage note despite acknowledging it's a joke.                                         |
| **Claude Opus 4.5**   | 2148   | ❌ Full SRE    | 🟢 Excellent      | ⚠️ Fake M1337 | 🟢 **Great**   | Best one-liners: "Developers may attempt to use sudo on the vending machine." Prometheus alert YAML for `coffee_bean_level_percent`. "N+1 caffeine architecture." `iptables -A OUTPUT -d starbucks.com -j DROP`.                                                                                                     | `M1337` is not a real MITRE mitigation ID — intentional joke but worth flagging. Full SRE format applied. |

> **Key Learnings:**
>
> 1. **0 out of 7 models fully dismissed the alert as non-IT.** Every model wrote a structured triage note. The test expectation ("humor or dismissal") was not met by any model — but the humor quality varied enormously.
> 2. **GPT-5.2 and Qwen had the best relevance calibration** — shortest responses, no MITRE mapping, practical advice. GPT-5.2 gave genuinely useful coffee machine troubleshooting (grinder jam, sensor dust) without the SRE theater.
> 3. **Qwen was the only model to explicitly state "MITRE ATT&CK: Not applicable"** — the correct answer for a physical resource exhaustion event.
> 4. **Sonnet was the only model to explicitly acknowledge it was a test** — meta-awareness that none of the others showed.
> 5. **Best humor award: Kimi** — "escalate if device is confirmed ceramic with tea infuser" and "requires wizard" are genuinely funny. Opus's "sudo on the vending machine" and "N+1 caffeine architecture" are close seconds.
> 6. **GLM took it most seriously** (3244 tokens, least humor) — the IoT botnet C2 concern is actually valid for real smart devices, but the tone was completely wrong for this alert.
> 7. **The RFC 2324 / HTCPCP knowledge was accurate across all models** — `curl -X BREW`, HTTP 418, and the teapot identity crisis are all technically correct per the spec. This is a case where "hallucinating" a detailed response is actually technically grounded.
> 8. **Design implication:** The system prompt should include a relevance gate — if the alert is clearly non-infrastructure, the model should route to facilities/dismiss rather than apply the full triage framework.
