#!/bin/bash
# SessionStart hook (this Mac only): checks the setup's descriptions against what is really there,
# and prints only what has drifted, so the session fixes it first. Silent when all is in order.
# Fast and offline (no network): it runs before every session.
#
# Checks:
#  1. The project map ("## Mes projets" in ~/.claude/CLAUDE.md) names every folder of ~/Projects
#     that is linked to GitHub, and every folder it names in backticks at the start of a line's
#     description still exists.
#  2. No memory (~/.claude/projects/*/memory/*.md) is past its `expires:` date: what it describes
#     may have changed, so the session re-checks it, then updates it (new date) or deletes it.
#  3. In an app made from the starter (a `.starter-version` file at its root, the starter commit it
#     has caught up with): the starter's code changes since then.
#  4. No project in the map is past its end of use (`fin d'usage : AAAA-MM-JJ` on its line).
# A new check goes here, with a line above saying what it compares.

input=$(cat)
cwd=$(python3 -c 'import json,sys; print(json.loads(sys.stdin.read() or "{}").get("cwd",""))' <<<"$input" 2>/dev/null)
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
done < <(grep -oE '(^ *|[(:,] |et )`[a-z0-9][a-z0-9.-]*`' <<<"$map" | grep -oE '`[^`]+`' | tr -d '`' | sort -u \
  | while read -r n; do grep -qE "(repo|branche) \`$n\`" <<<"$map" || echo "$n"; done)

# 2. Expired memories.
today=$(date +%F)
for f in "$HOME"/.claude/projects/*/memory/*.md; do
  [ -f "$f" ] || continue
  exp=$(awk '/^---$/{n++; next} n==1 && /^ *expires: *[0-9-]+/{print $2; exit}' "$f")
  [ -n "$exp" ] && [[ "$exp" < "$today" ]] && problems+=("La mémoire $(basename "$f") a expiré le $exp : revérifie ce qu'elle dit, puis mets-la à jour (nouvelle date \`expires\`) ou supprime-la (et sa ligne dans MEMORY.md).")
done

# 3. Starter changes the app in this session hasn't reviewed yet.
starter="$projects/starter"
dir="$cwd"
while [ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$projects" ] && [ ! -f "$dir/.starter-version" ]; do dir=$(dirname "$dir"); done
if [ -f "$dir/.starter-version" ] && [ "$dir" != "$starter" ] && [ -d "$starter/.git" ]; then
  since=$(tr -d '[:space:]' <"$dir/.starter-version")
  changes=$(git -C "$starter" log --format='  %h %s' "$since..HEAD" -- . ':!README.md' ':!CLAUDE.md' ':!CLAUDE.template.md' ':!claude-template' ':!scripts/new-app.mjs' ':!scripts/check-modules.mjs' 2>/dev/null | cut -c1-150)
  if [ -n "$changes" ]; then
    problems+=("Le starter a changé depuis la version que $(basename "$dir") a rattrapée (.starter-version) :
$(head -12 <<<"$changes")
  Propose à Amine ceux qui valent pour cette app (en une ligne chacun), applique ce qu'il accepte, puis écris $(git -C "$starter" rev-parse --short HEAD) (le commit revu) dans .starter-version.")
  fi
fi

# 4. Projects past their end of use; the project is the first backticked slug on that line.
while read -r line; do
  end=$(grep -oE "fin d'usage : [0-9]{4}-[0-9]{2}-[0-9]{2}" <<<"$line" | grep -oE '[0-9-]{10}')
  [[ "$end" < "$today" ]] || continue
  name=$(grep -oE '`[a-z0-9][a-z0-9.-]*`' <<<"$line" | head -1 | tr -d '`')
  problems+=("Le projet \`${name:-?}\` a passé sa fin d'usage ($end) : demande à Amine s'il continue (nouvelle date dans la carte) ou s'il passe « En sommeil » (déplace sa ligne, retire la date, mets ses mémoires à jour).")
done < <(grep -E "fin d'usage : [0-9]{4}-[0-9]{2}-[0-9]{2}" <<<"$map")

[ ${#problems[@]} -eq 0 ] && exit 0
echo "Dérive détectée par ~/.claude/hooks/check-drift.sh, à traiter avant le reste de la session :"
printf -- '- %s\n' "${problems[@]}"
exit 0
