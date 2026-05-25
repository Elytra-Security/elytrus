# Handling Findings in Elytrus

## Understanding Your Options

When Elytrus blocks your gate, you have four responses. Choosing the right one matters for your audit posture.

| Situation | Right Response | Audit Evidence |
|-----------|---------------|----------------|
| The finding is wrong — code is fine | Exclude the path or fix the rule | No exception needed |
| The finding is right, risk is accepted | Create an exception | Formal risk acceptance on record |
| The finding is right, will fix later | Create a baseline | Backlog acknowledged, no regression |
| The finding is right, fix now | Fix the code | Strongest posture |

Never suppress a finding without understanding which situation you are in.

---

## 1. True False Positives

A false positive is when Elytrus flags code that does not actually present the risk described.
Before concluding a finding is a false positive, read the rule:

    elytrus explain ETR-PRIVACY-002

### Common false positives and their fixes

**ETR-PRIVACY-002 on error variable names**

    // This is NOT logging PII — emailErr is an error object
    console.error('[auth] Email send failed:', emailErr.message);

Elytrus 2026.01+ uses word-boundary detection and will not flag this.

**ETR-SECRETS-001 on deployment templates**

    # config/database.env
    DB_PASSWORD=REPLACE_IN_DEPLOYMENT_ENV

This is a template, not a real secret. Add to `.elytrus.yaml`:

    global:
      exclude_paths:
        - "config/database.env"

**ETR-DATA-001 on server-side Node.js**

    // sidecar/routes/auth.js — server-side, not client-side
    const token = req.headers.authorization;

Elytrus 2026.01+ excludes server-side paths automatically.
Files in `routes/`, `handlers/`, `middleware/`, `sidecar/` are not scanned as client-side code.

**ETR-TEST-001 on migration directories**

SQL migration files cannot have unit tests. Add to `.elytrus.yaml`:

    test:
      exclude_paths:
        - "db/migrations/**"
        - "sidecar/migrations/**"

### Systematic false positives — use global excludes

If the same false positive fires across many files in a directory,
exclude the directory rather than creating individual exceptions:

    global:
      exclude_paths:
        - "compliance-skills/**"    # documentation, not code
        - "test-results/**"         # previous scan outputs
        - "generated/**"            # generated code
        - "vendor/**"               # vendored dependencies

Elytrus `init` discovers common false-positive directories automatically
and asks for your consent before adding them.

---

## 2. Accepted Risks

An accepted risk is a finding that is real — Elytrus is correct — but your team has assessed
the risk and decided to accept it, with a documented justification, compensating control,
and expiry date.

Accepted risks are **not** suppressions. They are formal governance records.

### When to accept a risk

- The fix requires significant architectural work planned for a future sprint
- The risk is mitigated by a control outside the codebase (network policy, WAF, etc.)
- The finding is in code that will be replaced or retired soon

### How to create an exception

Create or edit `.elytrus/exceptions/accepted-risks.json`:

    [
      {
        "id": "EXC-MYPROJECT-001",
        "rule_id": "ETR-DATA-001",
        "file": "frontend/web/static/dashboard.js",
        "line": 42,
        "reason": "JWT in localStorage — httpOnly cookie migration planned Q3 2026.",
        "risk_owner": "jane.smith",
        "approver": "john.doe",
        "approved_at": "2026-05-24T00:00:00Z",
        "expires_at": "2026-08-23T00:00:00Z",
        "compensating_control": "CSP headers configured. XSS prevention in place.",
        "status": "active"
      }
    ]

**Required fields — all must be present:**

| Field | What to write |
|-------|--------------|
| `id` | Unique ID: `EXC-PROJECTNAME-NNN` |
| `rule_id` | The ETR rule being accepted |
| `file` | Specific file, or `""` for all files |
| `line` | Specific line, or `0` for all lines in the file |
| `reason` | Why is this acceptable? What is the remediation plan? |
| `risk_owner` | Who is responsible for this risk |
| `approver` | Who approved the acceptance |
| `approved_at` | ISO 8601 timestamp of approval |
| `expires_at` | When this exception must be reviewed |
| `compensating_control` | What mitigates the risk in the absence of a fix |
| `status` | `active` |

### Rule-level exceptions

For findings that fire across many files due to an architectural pattern,
use an empty `file` and `line: 0`:

    {
      "id": "EXC-MYPROJECT-002",
      "rule_id": "ETR-DATA-001",
      "file": "",
      "line": 0,
      "reason": "localStorage token pattern throughout frontend. Migration planned Q3 2026.",
      "risk_owner": "jane.smith",
      "approver": "john.doe",
      "approved_at": "2026-05-24T00:00:00Z",
      "expires_at": "2026-08-23T00:00:00Z",
      "compensating_control": "CSP headers, XSS prevention, short token lifetime (1 hour)",
      "status": "active"
    }

### Finding the file and line

Get exact values from the latest run:

    cat .elytrus/runs/$(ls -t .elytrus/runs/ | head -1)/findings.json | python3 -c "
    import sys, json
    for f in json.load(sys.stdin):
        if f.get('rule_id') == 'ETR-PRIVACY-002':
            print(f['file'], f['line'])
    "

### Expiry enforcement

In strict mode, an expired exception does not suppress its finding — the gate blocks.
Check expiring exceptions before they expire:

    elytrus audit    # exception register with expiry dates

The default maximum exception age is 90 days:

    governance:
      max_exception_days: 90

### Commit your exceptions

    git add .elytrus/exceptions/accepted-risks.json
    git commit -m "security: accept risk EXC-MYPROJECT-001 — localStorage tokens, Q3 migration"

Exceptions are team decisions, not individual suppressions.
Committing them creates a shared, reviewable governance record.

---

## 3. Technical Debt — Baseline Mode

If your codebase has many existing findings that are real but you cannot fix them all at once,
use baseline mode. This acknowledges existing state and commits to not making it worse.

    # See everything
    elytrus gate --strict

    # Snapshot where you are today
    elytrus baseline create

    # From now on, only new risk blocks
    elytrus gate --strict --new-only

After creating a baseline and running with `--new-only`:

    Baseline: .elytrus/baseline.json (96 findings, 2026-05-24)

    Finding states:
      New:       0    (these block the gate)
      Fixed:     3    (your backlog is shrinking)
      Reopened:  0
      Existing:  93

    PASS

**Commit the baseline so your team and CI share the same snapshot:**

    git add .elytrus/baseline.json
    git commit -m "chore: create Elytrus baseline — 96 findings to address"

Working down the backlog: fix findings, run the gate, watch the Fixed count grow.
`elytrus remediation` shows your progress. `elytrus audit` generates a report for auditors.

---

## 4. Deciding Which Approach to Use

Ask these questions in order:

**Is Elytrus actually wrong?**
Read `elytrus explain <RULE-ID>`. Check the evidence snippet.
If the code genuinely does not present the described risk, use a global exclude
or report the false positive.

**Is the risk real but mitigated?**
Document it as an accepted risk with an exception. Set an expiry that forces a review.

**Is the risk real and unmitigated, but you cannot fix it today?**
Create a baseline. Commit to fixing it.

**Can you just fix it?**
If the fix is straightforward — upgrade a dependency, add a timeout, run gofmt —
just fix it. This is always the strongest posture.

---

## 5. What Your Auditor Sees

- **Fixed findings** show that you found and remediated issues
- **Accepted risks** show formal governance: assessed, owned, time-limited
- **Baselines** show that existing debt is tracked and not growing
- **Expired exceptions renewed** show ongoing review

What auditors do not want to see: findings suppressed without documentation,
exceptions without owners or expiry dates, or no evidence that checks were
performed at all.

---

## Quick Reference

    elytrus gate --strict              # see everything
    elytrus explain ETR-RULE-001       # understand a finding
    elytrus baseline create            # snapshot existing debt
    elytrus gate --strict --new-only   # only block on new risk
    elytrus baseline status            # see debt progress
    elytrus audit                      # generate audit report
    elytrus attest --verify            # verify evidence integrity

---

## Reporting a False Positive

Open an issue at [github.com/Elytra-Security/elytrus](https://github.com/Elytra-Security/elytrus) with:

- The rule ID
- The code pattern that triggered it
- Why it is not a real finding
- A suggested fix

See [rules/AUTHORING.md](../rules/AUTHORING.md) to submit a fix directly.
