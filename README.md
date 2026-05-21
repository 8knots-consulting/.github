# 8knots-consulting/.github

Org-level repo for shared GitHub Actions workflows and the org profile
README.

- [`.github/workflows/node-ci.yml`](.github/workflows/node-ci.yml) —
  reusable lint + typecheck + build workflow for all 8knots apps.
- [`profile/README.md`](profile/README.md) — shown on the org page at
  https://github.com/8knots-consulting.

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
    uses: 8knots-consulting/.github/.github/workflows/node-ci.yml@main
    with:
      package-manager: npm
      run-lint: false        # flip to true once an `npm run lint` script exists
```

The `working-directory` input lets you point the workflow at a
subdirectory if you ever go monorepo.
