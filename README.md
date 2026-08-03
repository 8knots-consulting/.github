# 8knots-consulting/.github

Org-level repo for shared GitHub Actions workflows and the org profile
README.

- [`.github/workflows/node-ci.yml`](.github/workflows/node-ci.yml) —
  reusable lint + typecheck + build workflow for all 8knots apps.
- [`profile/README.md`](profile/README.md) — shown on the org page at
  https://github.com/8knots-consulting.
- [`scripts/sync-labels.sh`](scripts/sync-labels.sh) — rollt die
  Routing-Taxonomie (`area:`/`app:`/`type:`/`priority:`/`status:`) in alle
  aktiven Repos aus. Idempotent.
- [`docs/label-policy.md`](docs/label-policy.md) — **warum** diese Labels
  Pflicht sind und wie die Pflicht durchgesetzt wird (8KN-30). Kurzfassung:
  ein unlabeled Issue ist für Agents unsichtbar, und genau daran ist eine
  Live-App mit 9 HIGH-Advisories durch den Sweep gefallen.

## Wiring an app

In any app repo, create `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]
jobs:
  ci:
    # Immer auf einen SHA pinnen, nie @main (8KN-31).
    uses: 8knots-consulting/.github/.github/workflows/node-ci.yml@<sha>
    with:
      package-manager: npm
      run-lint: false        # flip to true once an `npm run lint` script exists
```

The `working-directory` input lets you point the workflow at a
subdirectory if you ever go monorepo.

## Pin, don't float (8KN-31)

`@main` means one commit here changes the CI gate of all 8 consumers at
once. Pin to a commit SHA instead and bump it per repo, deliberately:

```
gh api repos/8knots-consulting/.github/commits/main --jq .sha
```

## Two classes of gate (8KN-48)

`node-ci.yml` separates gates by whether their outcome depends only on
the commit, or also on the date:

| Gate | depends on | blocks |
|---|---|---|
| Lint, Typecheck, Test, Build | commit | always |
| Gitleaks, Trivy misconfig + secret rules | commit (rules ship in the pinned binary) | always |
| Trivy vulnerabilities | commit **and** the advisory DB of the day | only findings the PR introduces |
| `npm audit` | commit **and** the registry advisories of the day | never — report only |

A vulnerability DB refresh turns yesterday's green commit red without a
line changing. So the vuln gate compares the head scan against a scan of
the base commit inside the same job, against the same DB, and blocks only
the difference. Pre-existing findings show up as a warning plus a table
in the job summary.

Two consequences worth knowing:

- **"CI is green" is a statement about lint, typecheck, test and build.**
  It is not a claim that the dependency tree is free of advisories.
- **A scanner finding that is not from your diff does not get fixed in
  your PR.** It gets its own `area:security` ticket. This is the rule
  agent personas follow too — otherwise every PR grows into a dependency
  bump.
