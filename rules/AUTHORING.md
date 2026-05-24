# Elytrus Rule Authoring Guide

Elytrus rules are YAML files that define what to check, how to check it, and how to communicate the result. This guide explains the complete rule schema with examples.

## Rule Schema

Every rule lives in a YAML file under a `rules:` list. A complete rule looks like this:

```yaml
rules:
  - id: ETR-MYFAMILY-001
    version: "2026.01"
    title: Short description of what this rule checks
    family: ETR-MYFAMILY
    severity: high
    status: stable

    default_outcome_mode:
      local: warn
      strict: fail
      release: fail

    objective: >
      One or two sentences describing the security or quality objective
      this rule enforces.

    risk_statement: >
      One or two sentences describing the risk if this rule is violated.
      What can go wrong? What is the attacker's opportunity?

    applies_to:
      stacks: [go, node, python, all]
      files: ["**/*.go", "**/*.js"]

    tools:
      primary: [gosec]
      secondary: [semgrep]

    technical_checks:
      - gosec -include=G401 ./...

    pass_condition: No weak cryptographic algorithms detected.
    fail_condition: Weak cryptographic algorithm (MD5, SHA1) found in source.
    warn_condition: Potential weak algorithm; manual review recommended.

    evidence:
      raw: [raw/gosec.json]
      normalized: [findings.json]

    exception:
      allowed: true
      requirements: [rule_id, file, line, reason, risk_owner, approver, expires_at, compensating_control]

    mappings:
      iso27001: [A.8.24]
      cwe: [CWE-327]
      owasp: [A02:2021]

    remediation:
      summary: Replace the weak algorithm with SHA-256 or stronger.
      steps:
        - Replace MD5 or SHA1 usage with crypto/sha256 or crypto/sha512.
        - For password hashing use bcrypt, scrypt, or argon2 instead.
        - Run `gosec -include=G401 ./...` to verify no weak algorithms remain.
      references:
        - https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html

    implementation:
      status: planned
```

---

## Required Fields

| Field | Description |
|-------|-------------|
| `id` | Unique rule identifier. Format: `ETR-FAMILY-NNN`. Must be globally unique across all loaded rules. |
| `version` | Rules pack version this rule targets. Use `"2026.01"` for the current pack. |
| `title` | Short, clear description of what the rule checks. |
| `family` | Rule family. Must match the `ETR-*` prefix pattern. |
| `severity` | One of: `critical`, `high`, `medium`, `low`, `info`. |
| `status` | One of: `stable`, `experimental`, `deprecated`. |
| `objective` | What the rule enforces and why. |
| `risk_statement` | What goes wrong if this rule is violated. |
| `pass_condition` | When the rule passes (plain English). |
| `fail_condition` | When the rule fails (plain English). |
| `remediation.summary` | One sentence: what to do to fix the finding. |
| `remediation.steps` | Ordered list of fix steps. |
| `remediation.references` | At least one reference URL. |

---

## Severity Guidelines

| Severity | Use when |
|----------|----------|
| `critical` | Directly exploitable vulnerability, secret exposure, authentication bypass |
| `high` | High-risk pattern, known vulnerable dependency, PII exposure |
| `medium` | Code quality issue with security implications, missing best practice |
| `low` | Documentation gap, minor style issue |
| `info` | Informational observation, no immediate action required |

---

## Outcome Modes

```yaml
default_outcome_mode:
  local: warn      # elytrus gate (default): warn but don't block
  strict: fail     # elytrus gate --strict: block the gate
  release: fail    # elytrus gate --release: block the gate
```

Use `warn` in `local` mode for findings that are informational during development but should block before merge or release. Use `fail` in `strict` mode for anything that genuinely blocks a merge.

---

## Stack Targeting

```yaml
applies_to:
  stacks: [go]              # Only run on Go repos
  stacks: [node, react]     # Run on Node.js and React repos
  stacks: [all]             # Run on all repos regardless of stack
  files: ["**/*.go"]        # Only scan these file patterns
  files: ["**/*"]           # Scan all files
```

---

## Tools

```yaml
tools:
  primary: [gosec]                    # Main tool that produces the finding
  secondary: [semgrep]                # Supplementary tools
```

Supported tools: `gosec`, `gitleaks`, `trivy`, `govulncheck`, `semgrep`, `staticcheck`, `bandit`, `ruff`, `npm`, `syft`.

If your rule uses Elytrus's internal analysis (no external tool), use:
```yaml
tools:
  primary: [elytrus-internal]
```

---

## ISO 27001 Mappings

Map your rule to the relevant ISO 27001:2022 Annex A controls where applicable:

| Control | Relevant for |
|---------|-------------|
| `A.5.34` | Privacy and PII protection |
| `A.8.8` | Technical vulnerability management |
| `A.8.11` | Data masking |
| `A.8.12` | Data leakage prevention |
| `A.8.15` | Logging |
| `A.8.24` | Use of cryptography |
| `A.8.25` | Secure development life cycle |
| `A.8.28` | Secure coding |
| `A.8.29` | Security testing |
| `A.9.4` | Access control |

---

## Validating Your Rule

```bash
elytrus rules validate
```

Or against a specific directory:

```bash
elytrus rules validate --rules rules/contributed/
```

A valid rule produces:
```
Validated 1 rules: 1 passed, 0 failed
```

Common validation failures:
- Missing required fields
- Invalid severity value
- Duplicate rule ID
- Malformed ISO 27001 control reference

---

## Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Rule ID | `ETR-FAMILY-NNN` | `ETR-CRYPTO-001` |
| Family | `ETR-FAMILY` uppercase | `ETR-CRYPTO` |
| File name | `etr-family.yaml` lowercase | `etr-crypto.yaml` |
| Directory | `family-name/` lowercase | `crypto/` |

---

## Example: Complete Contributed Rule

```yaml
# rules/contributed/crypto/etr-crypto.yaml

rules:
  - id: ETR-CRYPTO-001
    version: "2026.01"
    title: Weak cryptographic algorithm detected
    family: ETR-CRYPTO
    severity: high
    status: experimental

    default_outcome_mode:
      local: warn
      strict: fail
      release: fail

    objective: >
      Ensure that only cryptographically strong algorithms are used for
      hashing and encryption. MD5 and SHA-1 are no longer considered
      secure for cryptographic purposes.

    risk_statement: >
      Weak algorithms can be broken by an attacker to forge signatures,
      compromise stored password hashes, or decrypt protected data.

    applies_to:
      stacks: [go, python, node]
      files: ["**/*.go", "**/*.py", "**/*.js", "**/*.ts"]

    tools:
      primary: [semgrep]
      secondary: []

    technical_checks:
      - semgrep --config p/cryptography .

    pass_condition: No weak cryptographic algorithms detected in source files.
    fail_condition: MD5 or SHA1 used for cryptographic purposes.
    warn_condition: Potential weak algorithm detected; verify usage context.

    evidence:
      raw: [raw/semgrep.json]
      normalized: [findings.json]

    exception:
      allowed: true
      requirements: [rule_id, file, line, reason, risk_owner, approver, expires_at, compensating_control]

    mappings:
      iso27001: [A.8.24]
      cwe: [CWE-327, CWE-328]
      owasp: [A02:2021]

    remediation:
      summary: Replace the weak algorithm with SHA-256 or a purpose-appropriate modern algorithm.
      steps:
        - For general hashing replace MD5/SHA1 with SHA-256 (crypto/sha256 in Go, hashlib.sha256 in Python).
        - For password storage use bcrypt, scrypt, or argon2 — never MD5 or SHA1.
        - For HMAC use HMAC-SHA256 or HMAC-SHA512.
        - Search for all usages before removing to ensure none are missed.
      references:
        - https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html
        - https://pkg.go.dev/crypto/sha256

    implementation:
      status: experimental
```

---

## Questions

Open an issue or email info@elytrasecurity.com.
