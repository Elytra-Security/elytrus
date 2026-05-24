<div align="center">

# Elytrus

**Assurance before software moves forward.**

[![License: Binary](https://img.shields.io/badge/license-binary--free-blue)](LICENSE-BINARY.md)
[![Rules](https://img.shields.io/badge/rules-140-brightgreen)](rules/elytra)
[![SARIF](https://img.shields.io/badge/output-SARIF%202.1.0-orange)](docs/github-actions-example.yml)
[![ISO 27001](https://img.shields.io/badge/evidence-ISO%2027001%3A2022-blue)](docs/)

Elytrus is a free, local-first secure software assurance gate. It runs from the root of a repository, detects the software stack, executes deterministic quality, security, privacy, supply-chain, configuration, design, and release-readiness checks, then produces an evidence bundle and attestation before software moves forward.

**One command. Local evidence. Clear gate decision.**

</div>

---

## What Elytrus Does

Elytrus is not another scanner. It orchestrates industry-standard tools, applies a versioned rules pack, normalises findings into a unified schema, and produces a tamper-evident evidence bundle that auditors can verify.

```
elytrus gate --strict
```

```
Run ID:   2026-05-24T080646Z-4ef606
Evidence: .elytrus/runs/2026-05-24T080646Z-4ef606
Stacks:   Go, Node.js, migrations, scripts

PASS (critical=0 high=0 medium=12 low=3 info=2)
```

Every run produces:
- `attestation.json` — machine-readable gate result with commit identity, policy hash, and finding counts
- `findings.json` — normalised findings with evidence, ISO 27001 mappings, and remediation guidance
- `report.md` — human-readable report with How-to-fix for every finding
- `report.sarif` — SARIF 2.1.0 output for GitHub Security tab integration
- `sbom/` — CycloneDX and SPDX Software Bills of Materials
- `raw/` — unmodified tool outputs for independent verification

---

## Installation

### One-line install (Linux and macOS)

```bash
curl -sSfL https://raw.githubusercontent.com/Elytra-Security/elytrus/main/install.sh | sh
```

### Manual install

Download the binary for your platform from [Releases](https://github.com/Elytra-Security/elytrus/releases/latest):

| Platform       | Binary                        |
|----------------|-------------------------------|
| Linux x86-64   | `elytrus-linux-amd64`         |
| Linux arm64    | `elytrus-linux-arm64`         |
| macOS x86-64   | `elytrus-darwin-amd64`        |
| macOS arm64    | `elytrus-darwin-arm64`        |
| Windows x86-64 | `elytrus-windows-amd64.exe`   |

Verify the checksum:
```bash
sha256sum -c checksums.txt
```

Move to your PATH:
```bash
sudo mv elytrus-linux-amd64 /usr/local/bin/elytrus
sudo chmod +x /usr/local/bin/elytrus
```

### Required tools

Elytrus orchestrates external tools. Install the ones relevant to your stack:

```bash
elytrus doctor
```

| Tool          | Required for                    | Install                                    |
|---------------|---------------------------------|--------------------------------------------|
| `govulncheck` | Go vulnerability scanning       | `go install golang.org/x/vuln/cmd/govulncheck@latest` |
| `gosec`       | Go secure coding analysis       | `go install github.com/securego/gosec/v2/cmd/gosec@latest` |
| `staticcheck` | Go static analysis              | `go install honnef.co/go/tools/cmd/staticcheck@latest` |
| `trivy`       | Vulnerability, secret, config   | [aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| `gitleaks`    | Secret detection                | [gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) |
| `syft`        | SBOM generation                 | [anchore/syft](https://github.com/anchore/syft) |
| `semgrep`     | Semantic code analysis          | `pip install semgrep`                      |
| `npm`         | Node.js pack                    | [nodejs.org](https://nodejs.org)           |

---

## Quick Start

```bash
# Initialise Elytrus in your repository
cd your-project
elytrus init

# Run the assurance gate
elytrus gate --strict

# View the report
cat .elytrus/runs/$(ls -t .elytrus/runs/ | head -1)/report.md
```

---

## Commands

| Command | Description |
|---------|-------------|
| `elytrus init` | Initialise Elytrus, detect stacks, discover common exclude paths |
| `elytrus doctor` | Check required and optional tools are installed |
| `elytrus gate` | Run checks and return pass/blocked decision |
| `elytrus gate --strict` | Block on high findings and expired exceptions |
| `elytrus gate --release` | Add release-readiness checks (SBOM, checksums) |
| `elytrus inspect` | Run checks without a gate decision |
| `elytrus attest` | Print the latest attestation |
| `elytrus runs` | Show gate run history |
| `elytrus remediation` | Compare findings between two runs |
| `elytrus audit` | Generate an audit report for a period |
| `elytrus rules list` | List effective rules |
| `elytrus rules validate` | Validate rules YAML against the schema |
| `elytrus version` | Print version and build metadata |

---

## Supported Stacks

| Stack       | Checks |
|-------------|--------|
| **Go**      | Build, tests, go vet, gofmt, staticcheck, govulncheck, gosec, go.sum |
| **Node.js** | npm audit, ESLint, package-lock.json integrity |
| **Python**  | pytest, ruff, bandit, pip-audit |
| **React**   | Component patterns, browser security |
| **All**     | Secrets (gitleaks, trivy), SBOM (syft), vulnerabilities (trivy), semgrep, migrations, CI/CD, design, privacy, API, config, licence |

---

## GitHub Actions

Add Elytrus to your CI pipeline in minutes. Findings appear inline on pull requests via SARIF:

```yaml
name: Elytrus Security Gate

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  elytrus:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Elytrus
        run: |
          curl -sSfL https://raw.githubusercontent.com/Elytra-Security/elytrus/main/install.sh | sh

      - name: Run Elytrus gate
        run: elytrus gate --strict
        continue-on-error: true

      - name: Upload SARIF to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: .elytrus/latest.sarif
          category: elytrus
```

See [docs/github-actions-example.yml](docs/github-actions-example.yml) for a complete example.

---

## Rules

Elytrus ships with **140 rules** across 25 families maintained by Elytra Security:

| Family | Rules | Description |
|--------|-------|-------------|
| ETR-API | 6 | API security and contract checks |
| ETR-AUTH | 2 | Authentication and authorisation |
| ETR-BUILD | 5 | Build and test integrity |
| ETR-CICD | 3 | CI/CD pipeline security |
| ETR-CONFIG | 5 | Configuration security |
| ETR-DATA | 2 | Sensitive data in client-side code |
| ETR-DEPS | 3 | Dependency integrity and lock files |
| ETR-DESIGN | 10 | Architecture and layer boundaries |
| ETR-DOCS | 5 | Documentation completeness |
| ETR-EVID | 4 | Evidence bundle integrity |
| ETR-EXCEPT | 2 | Exception governance |
| ETR-GOV | 5 | Policy and governance |
| ETR-INTEGRITY | 6 | Rules pack and artifact integrity |
| ETR-LICENSE | 4 | Dependency licence compliance |
| ETR-LOG | 2 | Secret and PII in log statements |
| ETR-PRIVACY | 6 | Privacy-by-design |
| ETR-QUALITY | 5 | Code quality |
| ETR-RELEASE | 6 | Release readiness |
| ETR-SBOM | 3 | Software Bill of Materials |
| ETR-SECCODE | 8 | Secure coding patterns |
| ETR-SECRETS | 2 | Secret and credential detection |
| ETR-STACK | 2 | Stack and technology validation |
| ETR-TENANT | 2 | Multi-tenant isolation |
| ETR-TEST | 5 | Test coverage for sensitive code |
| ETR-VULN | 3 | Known vulnerability detection |

Community-contributed rules live in [rules/contributed](rules/contributed). See [rules/AUTHORING.md](rules/AUTHORING.md) to write your own.

---

## ISO 27001:2022

Elytrus evidence supports ISO 27001:2022 Annex A controls including A.8.25 (Secure Development Life Cycle), A.8.28 (Secure Coding), A.8.8 (Technical Vulnerability Management), A.5.34 (Privacy), and others. See the [ISO 27001 Evidence Guide](docs/) for details.

---

## What Elytrus Is Not

- A guarantee that software is defect-free or vulnerability-free
- A replacement for human code review or penetration testing
- A replacement for ISO 27001 certification
- A cloud service — all processing and evidence is local by default
- An AI system — Elytrus contains no LLM or agentic AI components

---

## Privacy

Elytrus runs locally. It does not send telemetry, upload source code, or call external APIs. See [PRIVACY.md](PRIVACY.md).

---

## Contributing

Contributions to the rules pack are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and [rules/AUTHORING.md](rules/AUTHORING.md).

---

## Security

To report a vulnerability in Elytrus, see [SECURITY.md](SECURITY.md).

---

## License

The Elytrus binary is free for commercial and non-commercial use. See [LICENSE-BINARY.md](LICENSE-BINARY.md).

---

<div align="center">
Built by <a href="https://elytrasecurity.com">Elytra Security</a> · info@elytrasecurity.com
</div>
