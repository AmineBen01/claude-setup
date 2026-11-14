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
#  3. In an app made from the starter (a `.starter-version` file at its root: the starter commit it
#     has caught up with, then optional `key: value` lines such as Ironmile's `map: apps/web=apps/api`):
#     the files an app never edits are compared by content with what the starter makes for that app
#     today, and everything else is the list of starter commits since that version, whole. The
#     comparison itself is the starter's `scripts/drift.mjs` (it holds the list of files).
#  4. No project in the map is past its end of use (`fin d'usage : AAAA-MM-JJ` on its line).
#  5. The setup's auto-push didn't refuse a secret, and its last push didn't fail.
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

# 3. What the app of this session no longer has in common with the starter.
starter="$projects/starter"
dir="$cwd"
while [ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$projects" ] && [ ! -f "$dir/.starter-version" ]; do dir=$(dirname "$dir"); done
if [ -f "$dir/.starter-version" ] && [ "$dir" != "$starter" ] && [ -f "$starter/scripts/drift.mjs" ]; then
  app=$(basename "$dir")
  if ! command -v node >/dev/null; then
    problems+=("Impossible de comparer $app au starter : \`node\` n'est pas dans le PATH de ce hook.")
  else
    drift=$(node "$starter/scripts/drift.mjs" "$dir" 2>&1)
    files=$(sed -nE 's/^differs (.*)/  \1 (contenu différent)/p; s/^missing (.*)/  \1 (absent)/p' <<<"$drift")
    commits=$(sed -nE 's/^commit +(.*)/  \1/p' <<<"$drift" | cut -c1-150)
    other=$(grep -vE '^(differs|missing|commit) ' <<<"$drift" | sed -E 's/^problem //')
    [ -n "$files" ] && problems+=("$app s'écarte du starter sur des fichiers qu'une app ne modifie pas (comparés à ce que le starter produit aujourd'hui pour elle) :
$files
  Reprends chacun tel que le starter le donne (\`node scripts/drift.mjs ../$app --show <chemin>\` dans ~/Projects/starter) ; ce que l'app y avait ajouté va dans un fichier à elle. Si c'est le starter qui a tort, corrige d'abord le starter.")
    [ -n "$commits" ] && problems+=("Le starter a changé depuis la version que $app a rattrapée (.starter-version), en dehors de ces fichiers :
$commits
  Propose à Amine ceux qui valent pour cette app (en une ligne chacun), applique ce qu'il accepte, puis écris $(git -C "$starter" rev-parse --short HEAD) (le commit revu) sur la première ligne de .starter-version.")
    [ -n "$other" ] && problems+=("La comparaison de $app avec le starter n'a pas pu se faire : $other")
  fi
fi

# 4. Projects past their end of use; the project is the first backticked slug on that line.
while read -r line; do
  end=$(grep -oE "fin d'usage : [0-9]{4}-[0-9]{2}-[0-9]{2}" <<<"$line" | grep -oE '[0-9-]{10}')
  [[ "$end" < "$today" ]] || continue
  name=$(grep -oE '`[a-z0-9][a-z0-9.-]*`' <<<"$line" | head -1 | tr -d '`')
  problems+=("Le projet \`${name:-?}\` a passé sa fin d'usage ($end) : demande à Amine s'il continue (nouvelle date dans la carte) ou s'il passe « En sommeil » (déplace sa ligne, retire la date, mets ses mémoires à jour).")
done < <(grep -E "fin d'usage : [0-9]{4}-[0-9]{2}-[0-9]{2}" <<<"$map")

# 5. The setup's auto-push (push-setup.sh) refused a secret, or its last push failed: cloud
#    sessions no longer get the setup's changes.
setup_hooks="$HOME/.claude/hooks"
[ -f "$setup_hooks/push-setup.blocked" ] && problems+=("push-setup.sh a refusé un commit de ~/.claude : $(cat "$setup_hooks/push-setup.blocked") Retire le secret du fichier, puis le prochain appel d'outil pousse.")
last_push=$(grep -E ' (pushed|push FAILED)' "$setup_hooks/push-setup.log" 2>/dev/null | tail -1)
[[ "$last_push" == *"push FAILED"* ]] && problems+=("Le dernier push de ~/.claude a échoué ($last_push) : lis la fin de ~/.claude/hooks/push-setup.log et règle-le.")

[ ${#problems[@]} -eq 0 ] && exit 0
echo "Dérive détectée par ~/.claude/hooks/check-drift.sh, à traiter avant le reste de la session :"
printf -- '- %s\n' "${problems[@]}"
exit 0
