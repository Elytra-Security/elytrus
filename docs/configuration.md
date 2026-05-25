# Configuration Guide

## .elytrus.yaml Reference

Elytrus is configured with a `.elytrus.yaml` file at the root of
your repository. Run `elytrus init` to generate a starter config
with stack-specific settings and discovered exclude paths.

## Global Excludes

Paths excluded from all packs:

```yaml
global:
  exclude_paths:
    - "test-results/**"     # previous scan outputs
    - "db/migrations/**"    # migration files
    - "docs/**"             # documentation
    - "generated/**"        # generated code
    - "vendor/**"           # vendored dependencies
```

`elytrus init` discovers common false-positive directories and
asks for your consent before adding them.

## Stack-Specific Configuration

### Go

```yaml
# No extra config needed for Go at root.
# If go.mod is in a subdirectory, Elytrus detects it automatically.
```

### Node.js

```yaml
global:
  exclude_paths:
    - "sidecar/tests/**"      # test fixtures with synthetic data
    - "sidecar/migrations/**" # if sidecar has migrations
```

### Python

```yaml
# bandit, ruff, pytest, pip-audit run automatically on detection.
# No extra config needed.
```

### React / Frontend JS

```yaml
# ETR-DATA-001 scans client-side paths for sensitive data patterns.
# If you use httpOnly cookies: no findings expected.
# If you use localStorage tokens: create a rule-level exception.
# See docs/handling-findings.md for exception format.
```

### Go + HTMX (server-rendered templates)

```yaml
global:
  exclude_paths:
    - "web/static/**"    # static assets, not client JS
    - "templates/**"     # Go HTML templates
```

## Privacy Classifications

Define what counts as personal and sensitive data in your project:

```yaml
privacy:
  enabled: true
  classifications:
    personal:
      - name
      - email
      - phone
      - address
      - ip_address
      - user_id
    sensitive:
      - password
      - token
      - totp
      - mfa_secret
      - jwt
      - session
      - api_key
```

## Design Layer Enforcement

Enforce architectural boundaries:

```yaml
design:
  enabled: true
  layers:
    - name: routes
      paths: ["routes/**", "handlers/**"]
    - name: middleware
      paths: ["middleware/**"]
    - name: database
      paths: ["db/**", "models/**", "store/**"]
  forbidden_imports:
    - from: "routes/**"
      to: "db/**"
      severity: high
      reason: "Routes must not access database directly."
  required_entrypoint_guards:
    - paths: ["routes/**"]
      must_reference: ["requireAuth", "requireTenant"]
      severity: high
```

## Exception Governance

```yaml
governance:
  enabled: true
  require_policy_hash: true
  require_evidence_hashes: true
  max_exception_days: 90    # exceptions expire after 90 days
```

## Policy Thresholds

```yaml
policy:
  block_high: true      # gate --strict blocks on high findings
  block_medium: false   # medium findings do not block by default
  require_sbom: true
```

## Multi-tenant Projects

```yaml
project:
  multi_tenant: true

migration:
  tenant_scope_fields:
    - tenant_id
    - org_id
  block_destructive_in_strict: true
```
