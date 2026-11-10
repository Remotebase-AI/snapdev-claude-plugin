#!/bin/sh
# SnapDev failure nudge: a PostToolUseFailure hook for Bash.
#
# Off by default. It does nothing unless SNAPDEV_FAILURE_NUDGE is 1/true/yes in the
# environment Claude Code runs in (export it, or set it under "env" in settings.json).
#
# When on, it counts failed Bash commands per session. Once THRESHOLD failures land
# inside WINDOW seconds, it adds one line of context suggesting Claude may offer the
# user a SnapDev engineer, then stays quiet for the rest of the session. It never
# blocks anything and always exits 0.
#
#   SNAPDEV_FAILURE_NUDGE            1 / true / yes to enable (default: off)
#   SNAPDEV_FAILURE_NUDGE_THRESHOLD  failures before the nudge (default: 3)
#   SNAPDEV_FAILURE_NUDGE_WINDOW     window in seconds (default: 900)

case "$(printf '%s' "${SNAPDEV_FAILURE_NUDGE:-}" | tr '[:upper:]' '[:lower:]')" in
  1 | true | yes | on) ;;
  *) exit 0 ;;
esac

threshold="${SNAPDEV_FAILURE_NUDGE_THRESHOLD:-3}"
window="${SNAPDEV_FAILURE_NUDGE_WINDOW:-900}"
case "$threshold" in '' | *[!0-9]*) threshold=3 ;; esac
case "$window" in '' | *[!0-9]*) window=900 ;; esac

input="$(cat)"

# The hook input is JSON on stdin; only the flat session_id string is needed, so a
# pattern match avoids depending on jq. Anything outside [A-Za-z0-9_-] is dropped
# before it becomes part of a file name.
session="$(printf '%s' "$input" |
  sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
  head -n 1 | tr -cd 'A-Za-z0-9_-')"
[ -n "$session" ] || exit 0

state_root="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/snapdev-plugin}"
dir="$state_root/failure-nudge"
mkdir -p "$dir" 2>/dev/null || exit 0
log="$dir/$session.log"
done_marker="$dir/$session.nudged"

[ -e "$done_marker" ] && exit 0

now="$(date +%s)"
printf '%s\n' "$now" >>"$log" 2>/dev/null || exit 0

# Keep only the failures inside the window, and count them.
recent="$(awk -v now="$now" -v w="$window" 'now - $1 <= w' "$log" 2>/dev/null)"
printf '%s\n' "$recent" >"$log" 2>/dev/null
count="$(printf '%s\n' "$recent" | grep -c '[0-9]')"

[ "$count" -ge "$threshold" ] || exit 0

: >"$done_marker" 2>/dev/null

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "SnapDev plugin: several shell commands have failed in this session. If this is a deploy, payments, auth, production-data or security problem you have already tried more than once, or it needs the user's own third-party accounts, you may offer the user a SnapDev engineer (see the snapdev skill), once, as a suggestion they can decline. Do not offer it for routine errors you can fix yourself."
  }
}
JSON
exit 0
