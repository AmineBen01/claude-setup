#!/bin/bash
# SessionStart hook (this Mac only): checks the setup's descriptions against what is really there,
# and prints only what has drifted, so the session fixes it first. Silent when all is in order.
# Fast and offline (no network): it runs before every session.
#
# Checks:
#  1. The project map ("## Mes projets" in ~/.claude/CLAUDE.md) names every folder of ~/Projects
#     that is linked to GitHub, and every folder it names in backticks at the start of a line's
#     description still exists.
# A new check goes here, with a line above saying what it compares.

cat >/dev/null # the hook's input isn't needed
projects="$HOME/Projects"
claude_md="$HOME/.claude/CLAUDE.md"
[ -d "$projects" ] && [ -f "$claude_md" ] || exit 0 # cloud session: nothing to compare

map=$(awk '/^## Mes projets/{on=1; next} /^## /{on=0} on' "$claude_md")
problems=()

# 1a. Every GitHub-linked folder is named in the map.
for dir in "$projects"/*/; do
  name=$(basename "$dir")
  [ -e "$dir/.git" ] || continue
  git -C "$dir" remote get-url origin 2>/dev/null | grep -q "github.com" || continue
  grep -q "\`$name\`" <<<"$map" || problems+=("Le dossier \`$name\` (GitHub) n'est pas dans la carte des projets.")
done

# 1b. Every folder the map names in a project position still exists: a backticked name right after
# "**…** (" or in a comma-separated list of folders ("`a`, `b`"), i.e. a lowercase slug. Repo names
# that differ from their folder are written "repo `x`" and skipped.
while read -r name; do
  [ -d "$projects/$name" ] || problems+=("La carte nomme \`$name\`, mais ~/Projects/$name n'existe plus.")
done < <(grep -oE '(^|[(:,] |et )`[a-z0-9][a-z0-9.-]*`' <<<"$map" | grep -oE '`[^`]+`' | tr -d '`' | sort -u \
  | while read -r n; do grep -qE "(repo|branche) \`$n\`" <<<"$map" || echo "$n"; done)

[ ${#problems[@]} -eq 0 ] && exit 0
echo "Dérive détectée par ~/.claude/hooks/check-drift.sh : à corriger avant le reste de la session (CLAUDE.md global, « Mes projets ») :"
printf -- '- %s\n' "${problems[@]}"
exit 0
