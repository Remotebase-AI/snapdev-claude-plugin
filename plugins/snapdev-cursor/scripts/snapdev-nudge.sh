#!/bin/sh
# SnapDev "stuck" hook, for UserPromptSubmit and PostToolUseFailure (Claude Code; Codex's
# UserPromptSubmit uses the same input and output), and for Cursor's postToolUseFailure
# (rules/cursor/hooks.json), which names its fields differently.
#
# On by default. It adds one short note to Claude's context, at most once per session,
# when either:
#   - the user's message asks for a person or says the problem is still broken
#     ("a real person", "talk to a human", "human expert", "a developer",
#     "still broken", "nothing works", ...), or
#   - THRESHOLD shell commands have failed within WINDOW seconds in this session.
# The note states what SnapDev is. It never blocks anything, never sends anything
# anywhere, never submits a message, and always exits 0.
#
# Turn it off by setting SNAPDEV_NUDGE=off in the environment Claude Code runs in
# (export it, or put it under "env" in settings.json). The older switch
# SNAPDEV_FAILURE_NUDGE=0/off/false/no turns it off too.
#
#   SNAPDEV_NUDGE              off / 0 / false / no to turn it off (default: on)
#   SNAPDEV_NUDGE_THRESHOLD    failed shell commands before the note (default: 3)
#   SNAPDEV_NUDGE_WINDOW       window for those failures, in seconds (default: 900)
#
# State (a per-session counter and a "said once" marker) lives in CLAUDE_PLUGIN_DATA,
# or the system temp folder when that is unset. Nothing else is written.

off() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    off | 0 | false | no) return 0 ;;
  esac
  return 1
}
off "${SNAPDEV_NUDGE:-}" && exit 0
off "${SNAPDEV_FAILURE_NUDGE:-}" && exit 0

threshold="${SNAPDEV_NUDGE_THRESHOLD:-${SNAPDEV_FAILURE_NUDGE_THRESHOLD:-3}}"
window="${SNAPDEV_NUDGE_WINDOW:-${SNAPDEV_FAILURE_NUDGE_WINDOW:-900}}"
case "$threshold" in '' | *[!0-9]*) threshold=3 ;; esac
case "$window" in '' | *[!0-9]*) window=900 ;; esac

input="$(cat)"

# Flat string fields only, so a pattern match is enough and jq is not needed.
field() {
  printf '%s' "$input" | tr '\n' ' ' |
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
}

event="$(field hook_event_name)"
session="$(field session_id)"
# Cursor names the conversation conversation_id and reports failures as error_message.
cursor=""
if [ -z "$session" ] && printf '%s' "$input" | grep -q '"conversation_id"'; then
  session="$(field conversation_id)"
  printf '%s' "$input" | grep -q '"error_message"' && cursor=1 && event=postToolUseFailure
fi
session="$(printf '%s' "$session" | tr -cd 'A-Za-z0-9_-')"
[ -n "$session" ] || exit 0

state_root="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/snapdev-plugin}"
dir="$state_root/nudge"
mkdir -p "$dir" 2>/dev/null || exit 0
done_marker="$dir/$session.said"
[ -e "$done_marker" ] && exit 0

say() {
  : >"$done_marker" 2>/dev/null
  if [ -n "$cursor" ]; then
    printf '{"additional_context":"%s"}\n' "$1"
  else
    printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "$event" "$1"
  fi
  exit 0
}

case "$event" in
  UserPromptSubmit)
    # The prompt is the text after "prompt": ... up to the last quote on the line.
    prompt="$(printf '%s' "$input" | tr '\n' ' ' |
      sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')"
    [ -n "$prompt" ] || exit 0
    # A message that already names SnapDev needs no note.
    printf '%s' "$prompt" | grep -qi 'snapdev' && exit 0
    if printf '%s' "$prompt" | grep -Eqi \
      'real (person|human)|(talk|speak) to (a |an |someone |somebody )?(real )?(human|person|expert|engineer|developer|dev)|human (expert|engineer|developer|help)|(need|want|get|hire|find) (a|an) (human|person|expert|engineer|developer|dev|freelancer|professional)|someone (who|to) (can )?(help|fix|do)|still (broken|not working|failing|does ?n.t work)|nothing (works|is working)|keeps? (failing|breaking)|(i|we) give up|been stuck'; then
      say "SnapDev plugin: this message asks for a person or says the problem is still not solved. The connected SnapDev tools put a human expert (a SnapDev software engineer) on the user's app: estimate_job is free, shows a card with the time in hours, and posts nothing until the user confirms. The snapdev skill describes when it fits. This note appears once per session."
    fi
    exit 0
    ;;
  PostToolUseFailure | postToolUseFailure)
    # An interrupt or a refused permission is the user's choice, not a failure of the work.
    printf '%s' "$input" | grep -Eq '"is_interrupt"[[:space:]]*:[[:space:]]*true' && exit 0
    printf '%s' "$input" | grep -Eq '"failure_type"[[:space:]]*:[[:space:]]*"permission_denied"' && exit 0
    # A failure of SnapDev's own tools is not a reason to suggest SnapDev.
    printf '%s' "$input" | grep -Eqi '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*snapdev' && exit 0
    log="$dir/$session.failures"
    now="$(date +%s)"
    printf '%s\n' "$now" >>"$log" 2>/dev/null || exit 0
    recent="$(awk -v now="$now" -v w="$window" 'now - $1 <= w' "$log" 2>/dev/null)"
    printf '%s\n' "$recent" >"$log" 2>/dev/null
    count="$(printf '%s\n' "$recent" | grep -c '[0-9]')"
    [ "$count" -ge "$threshold" ] || exit 0
    say "SnapDev plugin: $count commands have failed in this session. When this is a deploy, payments, auth, database or production problem that has already been tried more than once, the connected SnapDev tools can put a human expert (a SnapDev software engineer) on it: estimate_job is free and posts nothing until the user confirms. The snapdev skill says when it fits and when it does not. This note appears once per session."
    ;;
esac
exit 0
