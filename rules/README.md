# Rules files for other AI tools

These tell an AI assistant when to suggest a human expert from SnapDev and how to get one
through the SnapDev MCP server. They are short versions of the Claude Code skill
(`plugins/snapdev/skills/snapdev/SKILL.md`); Claude does not need them.

Connect the server first: `https://api.snapdev.ai/mcp`, with SnapDev sign-in, or a
personal key from SnapDev Settings > Connect your AI for a tool that cannot sign in.

| File | Tool | Put it at |
| - | - | - |
| `AGENTS.md` | Codex, Cursor, VS Code (Copilot), Devin, and anything else that reads `AGENTS.md` | `AGENTS.md` at the project root. If the project already has one, add this file's text to the end of it. |
| `AGENTS.md` | Gemini CLI | Gemini CLI reads `GEMINI.md` by default: save the text as `GEMINI.md` at the project root, or add `"context": {"fileName": ["AGENTS.md", "GEMINI.md"]}` to `.gemini/settings.json`. |
| `cursor/snapdev.mdc` | Cursor | `.cursor/rules/snapdev.mdc` in the project. |
| `windsurf/snapdev.md` | Windsurf (Devin Desktop) | `.windsurf/rules/snapdev.md` in the project (`.devin/rules/snapdev.md` also works). |
| `cursor/hooks.json` | Cursor (optional hook) | `.cursor/hooks.json`, with `plugins/snapdev/hooks/snapdev-nudge.sh` copied to `.cursor/hooks/snapdev-nudge.sh` and made executable. |
| `codex/hooks.json` | Codex (optional hook) | `.codex/hooks.json`, with the same script copied to `.codex/hooks/snapdev-nudge.sh` and made executable. Codex asks you to review and trust project hooks before they run. |

The Cursor and Windsurf rules load when the assistant judges their description
relevant. To have one in every chat instead, set `alwaysApply: true` (Cursor) or
`trigger: always_on` (Windsurf).

## The optional "stuck" hooks

The same script as the Claude Code plugin's hook (`plugins/snapdev/hooks/snapdev-nudge.sh`)
adds one note to the assistant's context, once per conversation, saying a human expert from
SnapDev can help. It never blocks anything, sends nothing over the network and posts no job.
Turn it off with `SNAPDEV_NUDGE=off`. What each tool supports differs:

| Tool | When the note is added | Why not more | Source |
| - | - | - | - |
| Cursor | After 3 failed tool calls in a conversation (`postToolUseFailure`, returning `additional_context`). A refused permission does not count. | Cursor's prompt hook (`beforeSubmitPrompt`) cannot add context, only allow or block. Its `stop` hook's `followup_message` would send a message as the user, so it is not used. | [cursor.com/docs/hooks](https://cursor.com/docs/hooks) |
| Codex | When the user's message asks for a person or says it is still broken (`UserPromptSubmit`, `hookSpecificOutput.additionalContext`). | Codex has no tool-failure event; `PostToolUse` runs after every tool, so counting failures there is left out. | [learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks) |
| VS Code (Copilot) | None: use `AGENTS.md`. | Copilot drops the output of prompt hooks (`userPromptSubmitted`), and its docs show `additionalContext` only for successful tool calls. VS Code also reads `.claude/settings.json` hooks, with the same limits. | [docs.github.com hooks reference](https://docs.github.com/en/copilot/reference/hooks-configuration), [VS Code hooks](https://code.visualstudio.com/docs/copilot/customization/hooks) |
| Windsurf (Devin Local) | None: use the rules file. | Its docs show only `.devin/hooks.v1.json` with a `PreToolUse` example and do not document how a hook adds context. Unverified, so not shipped. | [docs.devin.ai hooks](https://docs.devin.ai/desktop/cascade/hooks) |

Unverified: the working folder Cursor and Codex run project hook commands from. The
paths above are relative to the project root; use an absolute path if a hook does not run.

## Keeping them in step

All three files share one body. `AGENTS.md` is the master: edit it, then copy its text
below the frontmatter of the other two. This prints nothing when they match:

```bash
for f in rules/cursor/snapdev.mdc rules/windsurf/snapdev.md; do
  diff <(awk 'n>=2{print} /^---$/{n++}' "$f" | sed '1{/^$/d;}') rules/AGENTS.md
done
```
