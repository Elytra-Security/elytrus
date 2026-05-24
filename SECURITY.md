# Security Policy

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities in Elytrus.**

Email: info@elytrasecurity.com

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested mitigations

### Response Timeline

| Stage | Target |
|-------|--------|
| Acknowledgement | 2 business days |
| Initial assessment | 5 business days |
| Resolution plan | 30 days for critical issues |

We follow coordinated disclosure. Please allow us reasonable time to investigate before public disclosure.

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2026.01 | ✅ |

## Security in Elytrus Itself

Elytrus is developed using Elytrus. Every release passes `elytrus gate --strict` on the Elytrus codebase before publication. The attestation and evidence bundle for each release are available on the [Releases](https://github.com/Elytra-Security/elytrus/releases) page.
