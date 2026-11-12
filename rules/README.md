# Rules files for other AI tools

These tell an AI assistant when to suggest a SnapDev engineer and how to hire one
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

The Cursor and Windsurf rules load when the assistant judges their description
relevant. To have one in every chat instead, set `alwaysApply: true` (Cursor) or
`trigger: always_on` (Windsurf).

## Keeping them in step

All three files share one body. `AGENTS.md` is the master: edit it, then copy its text
below the frontmatter of the other two. This prints nothing when they match:

```bash
for f in rules/cursor/snapdev.mdc rules/windsurf/snapdev.md; do
  diff <(awk 'n>=2{print} /^---$/{n++}' "$f" | sed '1{/^$/d;}') rules/AGENTS.md
done
```
