# claude-setup

Mon setup Claude Code, versionné directement dans `~/.claude` (le `.gitignore` ne garde
que ce qui suit) :

- `CLAUDE.md` — mes consignes pour tous les projets.
- `settings.json` — réglages et permissions.
- `skills/` — mes skills maison : `nouveau-projet`, `verifier`, `mise-en-ligne`, `pwa`,
  `canal-corrections`.
- `hooks/` — `stop-session-processes.sh` (SessionEnd) : arrête ce qu'une session a laissé
  tourner dans son dossier.
- `THIRD_PARTY.md` + `scripts/install-third-party-skills.sh` — skills externes (non
  versionnées ici), plugins et serveurs MCP, avec leurs versions relues.

## Restaurer sur un autre Mac

```bash
cd ~/.claude
git init -b main
git remote add origin https://github.com/AmineBen01/claude-setup.git
git fetch origin && git checkout -f main
bash scripts/install-third-party-skills.sh
```

Puis les commandes « Plugins et serveurs MCP » de `THIRD_PARTY.md`.

## Dans les sessions cloud

Ce repo est **public** (rien de secret dedans) pour que les sessions cloud le lisent. Le script
d'installation de l'environnement cloud (claude.ai/code → environnement **Default** →
**Setup script**) télécharge `cloud/sync.sh` et le lance : il copie `CLAUDE.md` et `skills/`
dans `~/.claude` et pose un hook SessionStart qui refait la synchro à chaque session. Un push
ici arrive dans les nouvelles sessions en quelques minutes. `cloud/manifest.txt` (la liste des
fichiers copiés) est régénéré par le hook git `pre-commit` de ce Mac.
Limite : chaque session repart de l'instantané de l'environnement (refait environ chaque semaine,
ou quand on modifie le script d'installation). Une modification de la **logique** de `cloud/sync.sh`
ne s'applique donc qu'après cette reconstruction ; les fichiers qu'il copie, eux, sont à jour.

