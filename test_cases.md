# Incident Response System - Test Cases

Use these realistic **System Alerts** to test the Retrieval Workflow. Paste these into the chat as if they were automated notifications from PagerDuty, Datadog, or SIEM.

> **Note:** These alerts use **different entity names, users, and values** than the reference data (`incidents.json`). The system must rely on **semantic similarity** (symptoms/patterns) rather than exact keyword matching to find the relevant past incidents.

## 🟢 Easy (Direct Similarity)

_Clear technical symptoms that map to known incident patterns._

**1. Database Crash (Prometheus/Grafana)**

```text
[ALERT] postgres_cluster_down
Severity: Critical
Instance: db-inventory-04
Message: Primary node unreachable. Filesystem /var/lib/postgresql is 100% full.
```

- **Expected Match**: `INC-2026-0209-002` (DB Cluster Failure)
- **Key Insight**: Recognizing "Disk full -> Crash" pattern, even if hostname differs.

**2. API Performance (Datadog/NewRelic)**

```text
[ALERT] latency_degradation
Service: checkout-service-v1
Environment: Production
Message: p99 latency spiked to 3500ms (normal: 400ms).
Deployment: v4.1.2 (deployed 15 mins ago)
```

- **Expected Match**: `INC-2026-0209-004` (Elevated API Response Times)
- **Key Insight**: Detecting "Post-deployment latency spike" pattern.

---

## 🟡 Medium (Contextual/Ambiguous)

_Alerts requiring correlation or distinguishing false positives._

**3. Account Lockout (SIEM/Okta)**

```text
[ALERT] Identity Threat Detected
User: s.jones@company.com
Event: 50+ Failed Login Attempts
Source IP: 198.51.100.45 (Flagged as Tor Exit Node)
```

- **Expected Match**: `INC-2026-0209-001` (Brute Force)
- **Key Insight**: Identifying "Tor Exit Node + Failed Logins" pattern regardless of user/IP.

**4. Data Transfer (DLP/CloudWatch)**

```text
[ALERT] Unusual Egress Traffic
Source: analytics-export-job@company.com
Destination: s3://unknown-archive-bucket-99
Volume: 60GB
Time: 04:15 UTC
```

- **Expected Match**: `INC-2026-0209-005` (Unusual Data Transfer)
- **Key Insight**: Recognizing the "High Volume S3 Transfer" pattern (potentially a False Positive/Backup).

---

## 🔴 Hard (Synthesis/Partial Match)

_Vague descriptions where the root cause is hidden._

**5. Malware Suspicions (EDR/User Report)**

```text
[TICKET] PC acting weird
User: b.wayne (Finance)
Description: I opened a resume attachment from an external email earlier, and now my fans are spinning loud and files are opening slowly.
```

- **Expected Match**: `INC-2026-0209-003` (Trojan detected)
- **Key Insight**: Linking "Attachment -> Slowness" to past Malware/Trojan incidents (Phishing vector).

**6. SSL Errors (Synthetics/Uptime Monitor)**

```text
[ALERT] Service Unavailable (503)
Target: https://legacy-crm.internal.local
Error: NET::ERR_CERT_DATE_INVALID
Timestamp: Just now
```

- **Expected Match**: `INC-2026-0208-015` (SSL Certificate Expiry)
- **Key Insight**: Identifying "Certificate Date Invalid" implies expiry, matching the SSL incident.

---

## 🟣 Stress Tests (Ambiguous/Safety)

_Tests for hallucination resistance and handling vague inputs._

**7. Generic Security Alert**

```text
[ALERT] We are under attack
```

- **Expected Match**: Multiple Security Incidents (Lateral Movement, Credential Stuffing, SQLi).
- **Key Insight**: The Agent should provide a "menu" of potential vectors and advise checking SIEM/WAF, rather than guessing a specific attack.

**8. Irrelevant/Safety Check**

```text
[ALERT] mayday mayday mayday
```

- **Expected Match**: "Sorry, no similar past incidents found."
- **Key Insight**: The Agent should **NOT hallucinate** when no relevant history exists.
