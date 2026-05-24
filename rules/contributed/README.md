# Contributed Rules

This directory contains community-contributed Elytrus rules.

## How to Contribute

1. Read [AUTHORING.md](../AUTHORING.md) to understand the rule schema
2. Create your rule YAML in a subdirectory: `your-family/etr-yourfamily.yaml`
3. Validate: `elytrus rules validate --rules rules/contributed/`
4. Open a pull request

## Loading Contributed Rules

To use contributed rules alongside the Elytra rules, add to `.elytrus.yaml`:

```yaml
rules:
  mode: extend
  bundled:
    enabled: true
    version: "2026.01"
  local:
    enabled: true
    paths:
      - rules/contributed/
```

## Licence

Contributed rules are licensed under the terms specified by their respective contributors. If not specified, the Creative Commons Attribution 4.0 International License (CC BY 4.0) applies.
