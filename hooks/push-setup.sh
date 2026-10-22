#!/bin/bash
# Claude Code hook: commits and pushes this setup (~/.claude, GitHub AmineBen01/claude-setup)
# as soon as a versioned file changes, so cloud sessions get it within minutes (their
# SessionStart hook re-syncs from GitHub). Runs after every Edit/Write/Bash and at SessionEnd;
# does nothing when no versioned file changed (git status is a few ms). What .gitignore leaves
# out (sessions, project memory, synced and third-party skills) is never committed.
# The push runs in the background so the session never waits on the network.
# Logs to ~/.claude/hooks/push-setup.log.

cd "$HOME/.claude" || exit 0
cat >/dev/null # the hook's input isn't needed
log="$HOME/.claude/hooks/push-setup.log"
lock="$HOME/.claude/hooks/.push-setup.lock"

changed=$(git status --porcelain 2>/dev/null)
ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
[ -z "$changed" ] && [ "$ahead" = "0" ] && exit 0

# One commit/push at a time; a later run picks up whatever this one missed.
mkdir "$lock" 2>/dev/null || exit 0
(
  trap 'rmdir "$lock"' EXIT
  if [ -n "$(git status --porcelain)" ]; then
    files=$(git status --porcelain | awk '{print $NF}' | head -5 | paste -sd ' ' -)
    git add -A && git commit -q -m "Auto: $files" >>"$log" 2>&1
  fi
  { git pull -q --rebase origin main && git push -q origin main; } >>"$log" 2>&1 \
    && echo "$(date '+%F %T') pushed $(git rev-parse --short HEAD)" >>"$log" \
    || echo "$(date '+%F %T') push FAILED (see above)" >>"$log"
) </dev/null >/dev/null 2>&1 &
exit 0
