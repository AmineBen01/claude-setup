# claude-setup

Mon setup Claude Code, versionné directement dans `~/.claude` (le `.gitignore` ne garde
que ce qui suit) :

- `CLAUDE.md` — mes consignes pour tous les projets.
- `settings.json` — réglages et permissions.
- `skills/` — mes skills maison : `nouveau-projet`, `verifier`, `mise-en-ligne`, `pwa`.
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
