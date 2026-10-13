#!/usr/bin/env bash
# Réinstalle les skills externes à leur version relue (voir ../THIRD_PARTY.md).
# Usage : bash ~/.claude/scripts/install-third-party-skills.sh
set -euo pipefail

SKILLS="$HOME/.claude/skills"
TRANSITIONS_COMMIT=9398105c07dafe877e43197b71c15a10a3b0e3f6
ANATOMY_COMMIT=e6600ffc4e8e6620eeb45bf49bcdbd5e4b84163f

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp:?}"' EXIT

fetch() { # $1 dépôt, $2 commit, $3 dossier
  git init -q "$3"
  git -C "$3" fetch -q --depth 1 "https://github.com/$1.git" "$2"
  git -C "$3" checkout -q FETCH_HEAD
}

manual_only() { # ajoute disable-model-invocation à l'en-tête du SKILL.md
  python3 - "$1/SKILL.md" <<'EOF'
import sys
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
end = s.index("\n---", 4)
fm = s[4:end]
if "disable-model-invocation" not in fm:
    fm += "\ndisable-model-invocation: true"
open(p, "w", encoding="utf-8").write("---\n" + fm + s[end:])
EOF
}

install() { # $1 source, $2 nom de la skill
  if [ -e "$SKILLS/$2" ]; then
    echo "déjà présente, ignorée : $2 (supprimer le dossier pour la réinstaller)"
    return
  fi
  rsync -a --exclude .git --exclude .github "$1/" "$SKILLS/$2/"
  manual_only "$SKILLS/$2"
  echo "installée : $2"
}

fetch Jakubantalik/transitions.dev "$TRANSITIONS_COMMIT" "$tmp/transitions"
fetch wheresryan22/anatomy "$ANATOMY_COMMIT" "$tmp/anatomy"

for s in transitions-dev transitions-polish transitions-ui-generation; do
  install "$tmp/transitions/skills/$s" "$s"
done
install "$tmp/anatomy" anatomy
