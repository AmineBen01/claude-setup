#!/bin/bash
# Brings a cloud session's ~/.claude up to date with github.com/AmineBen01/claude-setup (public).
# Run once by the cloud environment's setup script, then at every session start by the SessionStart
# hook it installs, so a push here reaches new sessions within minutes (raw.githubusercontent.com
# caches about 5 minutes). Never fails a session: on any error it leaves what was there.
# With --hook, prints the global instructions when they changed after the session had loaded them.

base="https://raw.githubusercontent.com/AmineBen01/claude-setup/main"
dest="$HOME/.claude"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsS --max-time 10 "$base/cloud/manifest.txt" -o "$tmp/manifest.txt" || exit 0
# Download everything first (8 at a time); copy only if every file arrived.
grep -v '^$' "$tmp/manifest.txt" | xargs -P 8 -I{} sh -c 'mkdir -p "$(dirname "$2/$1")" && curl -fsS --max-time 15 "$3/$1" -o "$2/$1"' _ {} "$tmp/files" "$base" || exit 0

before=$(cat "$dest/CLAUDE.md" 2>/dev/null)
mkdir -p "$dest"
cp -R "$tmp/files/." "$dest/"

# The SessionStart hook that runs this script again in every new session.
python3 - "$dest/settings.json" <<'PY'
import json, os, sys
path = sys.argv[1]
try:
    settings = json.load(open(path))
except Exception:
    settings = {}
command = "bash ~/.claude/cloud/sync.sh --hook"
starts = settings.setdefault("hooks", {}).setdefault("SessionStart", [])
if not any(h.get("command") == command for group in starts for h in group.get("hooks", [])):
    starts.append({"hooks": [{"type": "command", "command": command, "timeout": 30}]})
    json.dump(settings, open(path, "w"), indent=2)
PY

if [ "$1" = "--hook" ] && [ -n "$before" ] && [ "$before" != "$(cat "$dest/CLAUDE.md")" ]; then
  echo "Amine's global instructions (~/.claude/CLAUDE.md) changed after this session loaded them. This is the current version; it replaces the earlier one:"
  echo
  cat "$dest/CLAUDE.md"
fi
exit 0
