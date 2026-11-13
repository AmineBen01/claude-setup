#!/bin/bash
# Claude Code hook: commits and pushes this setup (~/.claude, GitHub AmineBen01/claude-setup)
# as soon as a versioned file changes, so cloud sessions get it within minutes (their
# SessionStart hook re-syncs from GitHub). Runs after every Edit/Write/Bash and at SessionEnd;
# does nothing when no versioned file changed (git status is a few ms). What .gitignore leaves
# out (sessions, project memory, synced and third-party skills) is never committed.
# The work runs in the background so the session never waits on the network.
# Logs to ~/.claude/hooks/push-setup.log. A refused commit (a secret in the diff) leaves
# hooks/push-setup.blocked, which check-drift.sh reports at the next session start.

cd "$HOME/.claude" || exit 0
cat >/dev/null # the hook's input isn't needed
log="$HOME/.claude/hooks/push-setup.log"
lock="$HOME/.claude/hooks/.push-setup.lock"
blocked="$HOME/.claude/hooks/push-setup.blocked"

# Fast exit when nothing is versioned-changed and nothing waits to be pushed (the common case).
[ -z "$(git status --porcelain 2>/dev/null)" ] && [ "$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)" = "0" ] \
  && [ ! -d "$lock" ] && exit 0

# One run at a time, from the manifest rebuild to the push (two runs collided on 13 Nov 2026 when
# the second rebuilt the manifest during the first one's rebase). A lock older than 10 minutes is
# left over from a killed run.
find "$lock" -maxdepth 0 -mmin +10 -exec rmdir {} \; 2>/dev/null
mkdir "$lock" 2>/dev/null || exit 0
(
  trap 'rmdir "$lock"' EXIT

  # What cloud sessions download (cloud/sync.sh): rebuilt here, a versioned hook, so a fresh clone
  # of this setup keeps it right (a .git/hooks/pre-commit would not come along).
  git ls-files -- CLAUDE.md docs skills cloud/sync.sh 2>/dev/null | sort > cloud/manifest.txt.new
  cmp -s cloud/manifest.txt.new cloud/manifest.txt && rm cloud/manifest.txt.new || mv cloud/manifest.txt.new cloud/manifest.txt

  if [ -n "$(git status --porcelain)" ]; then
    git add -A
    # Never commit a secret: the repo is read by every cloud session. This file holds the patterns
    # themselves, so it is left out of the scan.
    hits=$(git diff --cached -U0 -- . ':!hooks/push-setup.sh' | grep -E '^\+' | grep -nE \
      'sk-ant-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|re_[A-Za-z0-9]{8,}_[A-Za-z0-9]{16,}|postgres(ql)?://[^:/@[:space:]]+:[^@[:space:]]+@|BEGIN [A-Z ]*PRIVATE KEY|AGE-SECRET-KEY-|(TOKEN|SECRET|PASSWORD|_KEY)=["'\'']?[A-Za-z0-9+/_=-]{24,}' \
      | cut -d: -f1 | head -3)
    if [ -n "$hits" ]; then
      files=$(git diff --cached --name-only | paste -sd ' ' -)
      git reset -q
      echo "$(date '+%F %T') REFUSED: a staged line looks like a secret (files: $files). Nothing committed." | tee -a "$log" >"$blocked"
      exit 0
    fi
    rm -f "$blocked"
    files=$(git diff --cached --name-only | head -5 | paste -sd ' ' -)
    git commit -q -m "Auto: $files" >>"$log" 2>&1
  fi
  # --autostash: another session may edit a file while this one rebases.
  { git pull -q --rebase --autostash origin main && git push -q origin main; } >>"$log" 2>&1 \
    && echo "$(date '+%F %T') pushed $(git rev-parse --short HEAD)" >>"$log" \
    || echo "$(date '+%F %T') push FAILED (see above)" >>"$log"
) </dev/null >/dev/null 2>&1 &
exit 0
