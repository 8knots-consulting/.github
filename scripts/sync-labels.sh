#!/usr/bin/env bash
# sync-labels.sh — Product-Agentic-Workflow Label-Taxonomie (one/docs/26, Stufe 5.0).
# Erzeugt/aktualisiert die Label-Taxonomie in allen aktiven Repos (idempotent via --force).
#
#   ./scripts/sync-labels.sh            # alle Repos
#   ./scripts/sync-labels.sh one liqui  # nur genannte Repos
#
# Voraussetzung: gh auth login mit Repo-Scope.
set -euo pipefail

ORG=8knots-consulting
# Alle AKTIVEN Repos. `ki` ist raus (archiviert 2026-05 — `gh label create`
# scheitert auf archivierten Repos). Ergänzt 2026-08-03 (8KN-30): die vier
# Repos ohne Taxonomie (immo, itto-agent, n8n, monitoring-dashboard) plus
# `.github` und `devteam` — `.github` trägt die Cross-Repo-Backlog-Issues
# (#3 Audit-Backlog, #5 CSP-Cutoff) und war bislang selbst untaxonomiert.
DEFAULT_REPOS=(
  one expense liqui recharge odoo-timesheets shared
  immo itto-agent n8n monitoring-dashboard monitoring
  .github devteam
)
REPOS=("${@:-${DEFAULT_REPOS[@]}}")
# Wenn ohne Argumente aufgerufen, expandiert ${@:-...} zu einem String -> splitten:
[ "$#" -eq 0 ] && REPOS=("${DEFAULT_REPOS[@]}")

# name|color|description
LABELS=(
  # --- area (Persona-Besitz) — area:feature (singular!) löst die alte area:features ab
  "area:feature|0052CC|Persona: Feature-Agent"
  "area:architecture|FEF2C0|Persona: Architecture-Agent"
  "area:ux|BFD4F2|Persona: UX-Agent"
  "area:security|B60205|Persona: Security-Agent"
  "area:product|5319E7|Persona: Product-Owner / Triage-QA (Grooming & Triage)"
  # --- app
  "app:intranet|C5DEF5|Betrifft intranet (one)"
  "app:expense|C5DEF5|Betrifft expense"
  "app:liqui|C5DEF5|Betrifft liqui"
  "app:recharge|C5DEF5|Betrifft recharge"
  "app:timesheets|C5DEF5|Betrifft odoo-timesheets"
  # Ergänzt 2026-08-03 (8KN-30). Ohne diese Werte sind Issues zu den Repos
  # nicht routbar — genau daran ist 8KN-47 vorbeigelaufen: das Sweep-Issue
  # trug kein `app:monitoring`, also blieb monitoring-dashboard mit 4 offenen
  # HIGH-Advisories unsichtbar (siehe 8KN-78).
  "app:immo|C5DEF5|Betrifft immo (Kompass)"
  "app:itto-agent|C5DEF5|Betrifft itto-agent (Ingo)"
  "app:n8n|C5DEF5|Betrifft n8n (Workflows, Rechnungsimport)"
  # Bewusst präzise beschrieben: es gibt ZWEI monitoring-Repos. `app:monitoring`
  # meint die Next.js-App `monitoring-dashboard`, NICHT den Traefik/Uptime-Kuma-
  # Stack im Repo `monitoring`. Für letzteren `app:monitoring-stack`.
  "app:monitoring|C5DEF5|Betrifft monitoring-dashboard (die Next.js-App)"
  "app:monitoring-stack|C5DEF5|Betrifft das Repo monitoring (Traefik + Uptime-Kuma)"
  # `shared` fehlte, obwohl es Consumer-übergreifend bricht (z.B. 8KN-68,
  # flakiger Test in shared/auth — war unlabeled und damit nicht routbar).
  "app:shared|C5DEF5|Betrifft shared (Packages: auth, odoo)"
  # --- type (Form/Workitem-Art)
  "type:story|0E8A16|User Story / Feature"
  "type:bug|D73A4A|Fehlverhalten"
  "type:spike|FBCA04|Zeitlich begrenzte Untersuchung"
  "type:chore|EDEDED|Wartung/Deps/Infra, kein User-facing-Wert"
  # --- priority
  "priority:p0|B60205|Jetzt — Produktion/Compliance kaputt"
  "priority:p1|E99695|Nächster Sprint"
  "priority:p2|FBCA04|Backlog bald"
  "priority:p3|C2E0C6|Nice-to-have"
  # --- status (Lebenszyklus)
  "status:triage|EDEDED|Eingegangen, noch nicht eingeordnet"
  "status:grooming|FEF2C0|In Verfeinerung (PO-Agent)"
  "status:ready|0E8A16|DoR erfüllt — von Engineering-Persona aufnehmbar"
  "status:in-progress|1D76DB|In Bearbeitung"
  "status:review|D93F0B|PR offen, im Review"
  "status:blocked|5319E7|Wartet auf Entscheidung/Abhängigkeit"
  "status:done|0E8A16|Erledigt + deployed"
  # --- Autonomie
  "auto-ok|0E8A16|Sicher für scheduled-autonomous Pickup (setzt PO-Agent)"
)

for repo in "${REPOS[@]}"; do
  echo "== $ORG/$repo =="
  for entry in "${LABELS[@]}"; do
    IFS='|' read -r name color desc <<< "$entry"
    gh label create "$name" --repo "$ORG/$repo" --color "$color" --description "$desc" --force
  done
done

cat <<'EOF'

--- Manuelle Nacharbeit (bewusst NICHT automatisch, weil destruktiv) ---
Alt-Labels, die durch die neue Taxonomie ersetzt werden — pro Repo prüfen,
ob noch Issues daran hängen, dann umhängen und löschen:
  area:features        -> area:feature
  priority:high        -> priority:p1
  priority:medium      -> priority:p2
  priority:low         -> priority:p3
  ready-for-review     -> status:review
  blocked (alt)        -> status:blocked
  needs-decision       -> status:blocked  (oder behalten, falls bewusst getrennt)
Beispiel Umhängen:
  for i in $(gh issue list -R 8knots-consulting/one -l area:features --json number -q '.[].number'); do
    gh issue edit "$i" -R 8knots-consulting/one --add-label area:feature --remove-label area:features
  done
  gh label delete area:features -R 8knots-consulting/one --yes
EOF
