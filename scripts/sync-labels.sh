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
REPOS=("${@:-one expense liqui recharge odoo-timesheets shared ki}")
# Wenn ohne Argumente aufgerufen, expandiert ${@:-...} zu einem String -> splitten:
[ "$#" -eq 0 ] && REPOS=(one expense liqui recharge odoo-timesheets shared ki)

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
