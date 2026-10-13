# Skills externes

Installées dans `~/.claude/skills/`, **sur appel seulement** (`disable-model-invocation: true`
ajouté à leur en-tête) : elles ne se chargent que quand je tape leur commande.
Elles ne sont **pas** dans ce repo (licence de transitions.dev : pas de redistribution de
la bibliothèque) ; `scripts/install-third-party-skills.sh` les réinstalle à l'identique.

| Skill | Source | Version (commit) | Licence | Relue le |
|---|---|---|---|---|
| `/transitions-dev` | github.com/Jakubantalik/transitions.dev `skills/transitions-dev` | 9398105c07dafe877e43197b71c15a10a3b0e3f6 | Transitions.dev (usage libre, pas de redistribution) | 2026-10-13 |
| `/transitions-polish` | idem, `skills/transitions-polish` | idem | idem | 2026-10-13 |
| `/transitions-ui-generation` | idem, `skills/transitions-ui-generation` | idem | idem | 2026-10-13 |
| `/anatomy` | github.com/wheresryan22/anatomy (dépôt entier sauf `.git`, `.github`) | e6600ffc4e8e6620eeb45bf49bcdbd5e4b84163f | MIT | 2026-10-13 |

Écartée : `transitions-agent` (même dépôt) — commerciale, lance un programme non figé et
envoie le code à api.transitions.dev.

**Relecture faite** : pas de téléchargement d'instructions à l'exécution, pas d'envoi de
code ou de données. anatomy lance seulement Chrome sans fenêtre et Node en local ; sa
publication dans la galerie (`scripts/publish.mjs`) n'a lieu que sur demande et demande
confirmation avant tout push.

**Mettre à jour** : ne jamais suivre `main` à l'aveugle. Relire le diff entre l'ancien et
le nouveau commit, puis changer le commit ici et dans le script.

## Plugins et serveurs MCP (portée utilisateur)

- `typescript-lsp@claude-plugins-official` (Anthropic) — nécessite
  `npm install -g typescript-language-server typescript`.
- `frontend-design@claude-plugins-official` (Anthropic).
- `playwright-iphone` : `npx -y @playwright/mcp@0.0.83 --browser webkit --device "iPhone 15" --headless --isolated`
- `playwright-android` : `npx -y @playwright/mcp@0.0.83 --browser chromium --device "Pixel 7" --headless --isolated`
- Navigateurs : `npx playwright@1.64.0-alpha-1790635538000 install webkit chromium`
  (version de Playwright embarquée par @playwright/mcp 0.0.83).
