# Label-Policy — Routing-Taxonomie für Linear + GitHub

Entschieden 2026-08-03 im Rahmen von **8KN-30**.

## Warum es diese Policy gibt

Das Routing-Modell der Agent-Personas liest drei Achsen:

| Achse | Bedeutung | Konsequenz wenn sie fehlt |
| --- | --- | --- |
| `area:` | welche Persona besitzt das Thema | kein Agent fühlt sich zuständig |
| `app:` | welches Repo ist betroffen | Cross-Repo-Sweeps übersehen das Repo |
| `auto-ok` + Ready | darf unbeaufsichtigt aufgenommen werden | kein autonomer Pickup |

**Ein unlabeled Issue ist für Agents unsichtbar.** Das ist kein theoretisches
Problem: `8KN-47` hat vier HIGH-`next`-Advisories „auf allen 6 Live-Apps"
geschlossen, trug aber kein `app:monitoring`. Ergebnis — `monitoring-dashboard`
blieb wochenlang öffentlich erreichbar mit 9 offenen HIGH-Advisories, ohne CI
und ohne Branch-Protection (`8KN-78`). Ein fehlendes Label, ein übersehenes
Live-System.

## Minimum (Definition of Ready)

Jedes **offene** Issue im Linear-Team `8KN` trägt mindestens:

```
area:<persona>   type:<form>   priority:<p0..p3>
```

Dazu `app:<repo>`, sobald klar ist, welches Repo betroffen ist. Cross-Repo-
Themen tragen **alle** betroffenen `app:`-Labels — nicht nur das
naheliegendste. Genau daran ist `8KN-47` gescheitert.

## Die Achsen

**`area:`** — `feature`, `architecture`, `ux`, `security`, `product`.
Bestimmt die Persona. Ein App-Bug ist `area:feature` (der Feature-Agent
besitzt die App), auch wenn `type:bug` ist.

**`type:`** — `story`, `bug`, `spike`, `chore`.

**`priority:`** — `p0` (Produktion/Compliance kaputt), `p1` (nächster Sprint),
`p2` (Backlog bald), `p3` (nice-to-have).

**`app:`** — ein Wert pro Repo. Achtung, zwei ähnliche Namen:
`app:monitoring` = die Next.js-App `monitoring-dashboard`,
`app:monitoring-stack` = das Repo `monitoring` (Traefik + Uptime-Kuma).

## Wie die Pflicht durchgesetzt wird

Linear **Triage Rules** wären der naheliegende Weg, brauchen aber den
Business-Tier — steht nicht zur Verfügung. Stattdessen drei Schichten:

1. **Templates setzen vor, was ohne Urteil feststeht.**
   GitHub: `.github/ISSUE_TEMPLATE/*.yml` setzen `type:` + `status:triage`
   bereits vor. Linear: dieselben Templates in der UI anlegen (manuell, die
   API deckt Templates nicht ab). `area:` und `priority:` bleiben bewusst
   offen — das ist Triage-Urteil, kein Default.

2. **Regel für alle, die Issues anlegen — Menschen und Agents.**
   Wer ein Linear-Issue erstellt, setzt `area:` + `type:` + `priority:`
   direkt mit. Für Agents gilt das als Teil der Persona-Guidance: ein Issue
   ohne diese drei Labels ist nicht fertig angelegt.

3. **Detektor als Netz — der einzige Teil, der wirklich hält.**
   Templates lassen sich umgehen, Regeln vergisst man. Ein periodischer
   Check „offene Issues ohne `area:`/`type:`/`priority:`" ist die einzige
   Schicht, die Drift *findet* statt sie zu verhindern. Vorgesehen als
   Anhang an den scheduled Sweep aus `8KN-41` bzw. den Telegram-Digest aus
   `8KN-45`. **Noch nicht gebaut** — bis dahin ist Schicht 2 die Absicherung.

Ehrlich benannt: ohne Schicht 3 verhindert diese Policy Drift nicht, sie
macht ihn nur unwahrscheinlicher.

## Taxonomie ausrollen

```bash
./scripts/sync-labels.sh              # alle aktiven Repos (idempotent)
./scripts/sync-labels.sh one liqui    # nur genannte
```

Neues Repo angelegt? In `DEFAULT_REPOS` in `scripts/sync-labels.sh`
eintragen **und** ein `app:`-Label dafür ergänzen — sonst ist es ab Tag eins
für Sweeps unsichtbar.

## Bekannte Lücke

Die Odoo-Custom-Modules (`~/Code/odoo-modules`, `~/Code/odoo-prod`) sind
**keine** GitHub-Repos in der Org. Odoo-seitige Arbeit — z.B. ACLs und
Record Rules in `8KN-61` — hat damit kein `app:`-Label und keinen Ort für
Issues/Reviews/CI. Aktuell behelfsweise über `app:n8n` (der Consumer)
gelabelt. Eigenes Thema, hier nur festgehalten.
