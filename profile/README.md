# 8knots Consulting

Internal web apps for our consulting workflows around employees, customers,
and projects. Backend is mostly our Odoo 19 instance. Frontends are thin
Next.js apps on a Hetzner VPS, talking to Odoo via JSON-2 (or legacy
JSON-RPC, depending on the app's migration state).

## App portfolio

| Repo | Purpose |
|---|---|
| [`one`](https://github.com/8knots-consulting/one) | Intranet hub / service catalog / central admin |
| [`expense`](https://github.com/8knots-consulting/expense) | Spesen-App for `hr.expense`, Vision-OCR for receipts |
| [`odoo-timesheets`](https://github.com/8knots-consulting/odoo-timesheets) | Freelancer timesheets for `account.analytic.line` |
| [`liqui`](https://github.com/8knots-consulting/liqui) | Cash + T&M forecast (GF only) |
| [`recharge`](https://github.com/8knots-consulting/recharge) | Vacation requests for `hr.leave` |
| [`shared`](https://github.com/8knots-consulting/shared) | Shared TypeScript packages: `@8knots/odoo`, `@8knots/auth`, `@8knots/env` |

## Reusable CI

All apps use the [`node-ci`](.github/workflows/node-ci.yml) reusable
workflow for lint / typecheck / build. Consumer pattern:

```yaml
jobs:
  ci:
    uses: 8knots-consulting/.github/.github/workflows/node-ci.yml@main
    with:
      package-manager: npm    # or "pnpm" for the shared workspace
      run-lint: false         # set true once the app has a lint script
```
