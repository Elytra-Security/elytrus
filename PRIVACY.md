# Privacy Statement

## Local-First

Elytrus runs entirely on your machine. It does not:

- Send telemetry or usage data
- Upload source code or evidence bundles
- Call external APIs (LLM or otherwise)
- Require an account or registration
- Phone home on any schedule

## What Elytrus Reads

Elytrus reads files in your repository to perform its checks. It writes evidence bundles to `.elytrus/runs/` in your repository directory. Nothing is sent outside your machine.

## External Tool Calls

Elytrus invokes external security tools (govulncheck, trivy, gitleaks, etc.) on your machine. These tools may make network requests to fetch vulnerability databases (e.g. the Go vulnerability database at vuln.go.dev, or the GitHub Advisory Database via trivy). These requests are made by the tools themselves and are governed by their respective privacy policies.

## Evidence Bundles

Evidence bundles written to `.elytrus/runs/` are stored locally and never uploaded by Elytrus. You control retention. Detected secrets are redacted in human-readable reports.

## Contact

info@elytrasecurity.com
