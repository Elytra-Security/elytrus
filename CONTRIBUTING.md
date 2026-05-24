# Contributing to Elytrus Rules

Thank you for contributing to the Elytrus rules pack. Community rules are reviewed by Elytra Security before inclusion.

## What You Can Contribute

- New rules in `rules/contributed/`
- Improvements to existing Elytra rules (via issue or pull request)
- Bug reports for false positives or missed detections
- Documentation improvements

## Rule Contributions

1. **Read [rules/AUTHORING.md](rules/AUTHORING.md)** — it explains the complete rule schema, required fields, and validation requirements.

2. **Create your rule YAML** in `rules/contributed/your-family/etr-yourfamily.yaml`.

3. **Validate your rule** before submitting:
```bash
   elytrus rules validate --rules rules/contributed/
```

4. **Open a pull request** with:
   - The rule YAML file
   - A brief description of what the rule detects and why it matters
   - An example of a finding the rule would produce

## Pull Request Checklist

- [ ] Rule passes `elytrus rules validate`
- [ ] Rule ID follows the `ETR-FAMILY-NNN` format
- [ ] All required fields are present (see AUTHORING.md)
- [ ] Remediation block includes summary, steps, and at least one reference
- [ ] ISO 27001 mapping included where applicable
- [ ] No duplicate rule IDs

## Reporting False Positives

Open an issue with:
- The rule ID
- The code pattern that triggered the false positive
- Why it is not a real finding
- A suggested fix to the rule

## Contact

info@elytrasecurity.com
