#!/bin/bash
# Claude Code SessionEnd hook: stops what a session left running in its project folder.
#
# Targets only processes that Claude Code's Bash tool started (CLAUDECODE=1 in their environment
# or in a parent's: `next dev` renames its server process, which hides its environment from
# `ps -E` on macOS) whose working directory is inside the session's folder, and that either
# listen on a TCP port (dev servers, local databases) or are a headless browser / watcher.
# Your own terminal's `pnpm dev` doesn't carry CLAUDECODE, so it is never touched. Claude Code's
# own children that aren't shells (MCP servers such as Playwright) are left to Claude Code.
# Skipped on /clear and /resume: the same Claude Code keeps working.
# macOS and Linux. Logs to ~/.claude/hooks/stop-session-processes.log.

input=$(cat)
field() { printf '%s' "$input" | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'; }
dir=$(field cwd)
case "$(field reason)" in clear|resume) exit 0 ;; esac
[ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$HOME" ] || exit 0
log="$HOME/.claude/hooks/stop-session-processes.log"
mkdir -p "$(dirname "$log")"

has_marker() {
  if [ -r "/proc/$1/environ" ]; then
    tr '\0' '\n' < "/proc/$1/environ" 2>/dev/null | grep -qx 'CLAUDECODE=1'
  else
    ps -E -p "$1" -o command= 2>/dev/null | tr ' ' '\n' | grep -qx 'CLAUDECODE=1'
  fi
}
parent_of() { ps -o ppid= -p "$1" 2>/dev/null | tr -d ' '; }
name_of() { basename "$(ps -o comm= -p "$1" 2>/dev/null)" 2>/dev/null; }

# Started by Claude Code's Bash tool: the marker on the process or a parent, and either orphaned
# (parent chain ends at pid 1) or under a shell that Claude Code runs. Not an MCP server.
started_by_claude() {
  local pid=$1 marked=1 parent
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    has_marker "$pid" && marked=0
    parent=$(parent_of "$pid")
    [ -z "$parent" ] && return 1
    if [ "$(name_of "$parent")" = "claude" ]; then
      case "$(name_of "$pid")" in zsh|bash|sh|-zsh|-bash) return $marked ;; *) return 1 ;; esac
    fi
    pid=$parent
  done
  return $marked
}

cwd_of() {
  if [ -e "/proc/$1/cwd" ]; then
    readlink "/proc/$1/cwd"
  else
    lsof -a -p "$1" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p'
  fi
}

# Servers (anything listening on TCP) and headless browsers or watchers.
candidates=$( {
  lsof -nP -iTCP -sTCP:LISTEN -Fp 2>/dev/null | sed -n 's/^p//p'
  pgrep -f -- '--headless|playwright|puppeteer|chromedriver|--watch' 2>/dev/null
} | sort -un)

targets=()
for pid in $candidates; do
  [ "$pid" = "$$" ] || [ "$pid" = "$PPID" ] && continue
  case "$(cwd_of "$pid")/" in "$dir"/*) ;; *) continue ;; esac
  started_by_claude "$pid" && targets+=("$pid")
done
[ ${#targets[@]} -eq 0 ] && exit 0

for pid in "${targets[@]}"; do
  echo "$(date '+%F %T') $dir: stopping $pid $(ps -p "$pid" -o command= 2>/dev/null | cut -c1-120)" >> "$log"
  kill -TERM "$pid" 2>/dev/null
done
sleep 1
for pid in "${targets[@]}"; do kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null; done
exit 0
