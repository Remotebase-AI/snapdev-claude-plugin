# SnapDev for Cursor

Get a human expert, a SnapDev software engineer, without leaving Cursor. Ask your AI for a
human expert (or let it suggest one after repeated failed attempts): it writes the brief,
shows an estimate in hours, and posts the job only after you confirm. You follow the job,
answer your expert's questions and see what changed, all from the chat.

What this plugin adds:

- **MCP server** (`mcp.json`): `https://api.snapdev.ai/mcp`. Cursor opens a SnapDev
  sign-in the first time; press Allow.
- **Rule** (`rules/snapdev.mdc`): when a human expert helps, and how to brief one.
- **Skill** (`skills/snapdev`): the full guide for the assistant, with brief examples.
- **Command** (`commands/jobs.md`): check on your SnapDev jobs.
- **Hook** (`hooks/hooks.json`): after 3 failed tool calls in a conversation, one note,
  once, that a human expert from SnapDev can help. It never blocks anything and sends
  nothing. Turn it off with `SNAPDEV_NUDGE=off`.

Guide: https://snapdev.ai/mcp/guide. Support: team@snapdev.ai.

These files are copies of the repo's masters (`rules/cursor/snapdev.mdc`,
`plugins/snapdev/skills`, `plugins/snapdev/commands/jobs.md`,
`plugins/snapdev/hooks/snapdev-nudge.sh`); `rules/README.md` has the check that keeps
them in step.
