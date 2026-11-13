# snapdev-claude-plugin

The Claude plugin and plugin marketplace for **SnapDev for Claude**: a builder hires a
human expert (a SnapDev software engineer) from inside Claude, sees an estimate in hours
and confirms it, can call their expert now or book a call for later, and is told in plain
words what changed and how to check it. Product spec: [`PRD.md`](PRD.md).

The marketplace is named `snapdev` and lists one plugin, `snapdev`.

```
.claude-plugin/marketplace.json        marketplace "snapdev"
plugins/snapdev/
  .claude-plugin/plugin.json           plugin manifest
  .mcp.json                            remote MCP server https://api.snapdev.ai/mcp (HTTP, OAuth)
  skills/snapdev/SKILL.md              when to bring in a human expert, the brief, the estimate, calls, done (/snapdev)
  skills/snapdev/references/           worked brief examples
  commands/jobs.md                     /snapdev:jobs
  hooks/hooks.json, snapdev-nudge.sh   once-per-session note when stuck or asking for a person; SNAPDEV_NUDGE=off
  README.md, LICENSE, icon.png         listing README, MIT license, directory icon
dev/staging.mcp.json                   env-overridable server URL for staging and local testing
rules/                                 the same guidance and hooks for other AI tools (AGENTS.md, Cursor, VS Code, Codex, Windsurf)
gemini-extension.json, GEMINI.md      the Gemini CLI extension
server.json                           the official MCP Registry entry
tests/                                tests for the hook script
```

The MCP server itself (21 tools and one prompt), its MCP App cards (`ui://snapdev/*.html`) and the
job APIs live in `snapdev-backend` (`api/mcp/`). This repo only ships the client side.

The tools: `list_services`, `estimate_job`, `create_job`, `get_job`, `list_jobs`,
`list_github_repos`, `reply_to_engineer`, `cancel_job`, `request_revision`, `rate_job`,
`get_balance`, `buy_hours`, `start_call`, `decline_call`, `get_call_times`,
`book_call`, `cancel_booked_call`, `start_consult`, `send_consult_message`,
`get_consult_messages`, `end_consult`. The prompt: `get_a_human_expert` (shows as
`/snapdev:get_a_human_expert (MCP)` in Claude Code and as `/get_a_human_expert` in Gemini
CLI), which takes the problem and what was already tried and starts an estimate.

## Install

### Claude Code

```bash
claude plugin marketplace add Remotebase-AI/snapdev-claude-plugin
claude plugin install snapdev@snapdev
```

Or inside a session: `/plugin marketplace add Remotebase-AI/snapdev-claude-plugin`, then
`/plugin install snapdev@snapdev`. The first SnapDev tool call returns `401`; Claude
Code opens the SnapDev sign-in and consent page and stores the token.

The skill runs as `/snapdev` (also `/snapdev:snapdev`) and loads by itself when the
conversation matches. `/snapdev:jobs` checks on open jobs.

### claude.ai, the desktop app and Cowork

1. **Customize > Plugins > Add > Add marketplace**, enter
   `Remotebase-AI/snapdev-claude-plugin`, and add **SnapDev**. (Or **Add > Upload
   plugin** with a zip of `plugins/snapdev/`.)
2. Open the plugin's **Connectors** tab and connect `snapdev`; sign in to SnapDev.

Chat loads the skill and the `jobs` command (as a skill) and ignores the hook; Cowork
loads all of it. To use only the tools, add the connector on its own:
**Customize > Connectors > Add custom connector**, URL `https://api.snapdev.ai/mcp`.
ChatGPT, Cursor and other MCP clients connect to the same URL.

### Other AI tools

Codex, Cursor, VS Code, Gemini CLI, Windsurf and other MCP clients connect to the same
URL, with SnapDev sign-in, or with a personal key from SnapDev Settings for a tool that
cannot sign in. They do not load the skill, so [`rules/`](rules/) carries a short
version of it for each:

- [`rules/AGENTS.md`](rules/AGENTS.md): for any tool that reads `AGENTS.md` (Codex,
  Cursor, VS Code, Gemini CLI with one setting).
- [`rules/cursor/snapdev.mdc`](rules/cursor/snapdev.mdc): a Cursor project rule, for
  `.cursor/rules/`.
- [`rules/windsurf/snapdev.md`](rules/windsurf/snapdev.md): a Windsurf rule, for
  `.windsurf/rules/`.

[`rules/README.md`](rules/README.md) says where each goes. `rules/AGENTS.md` is the
master copy: change it with the skill, and copy its text into the other two.

## Staging and local testing

`plugins/snapdev/.mcp.json` keeps a fixed URL on purpose: claude.ai and Cowork list a
plugin's remote server on its Connectors tab only when the URL is fixed, so a
`${VAR}` there would break the plugin outside Claude Code.

To point Claude Code at another server, load the plugin from disk and take the MCP
server from `dev/staging.mcp.json`, whose URL is `${SNAPDEV_MCP_URL:-https://api.snapdev.ai/mcp}`:

```bash
SNAPDEV_MCP_URL=https://<staging-backend-host>/mcp \
  claude --plugin-dir ./plugins/snapdev \
         --strict-mcp-config --mcp-config ./dev/staging.mcp.json
```

`--strict-mcp-config` keeps only the servers from `--mcp-config`. If your build still
lists the plugin's production server too, turn `plugin:snapdev:snapdev` off in `/mcp`
for the session. The backend serving that URL must set `MCP_RESOURCE_URL` to the same
value, or the OAuth resource check fails.

## The "stuck" hook

On by default, at most once per session. `hooks/snapdev-nudge.sh` runs on two events:

- **UserPromptSubmit:** when the message asks for a person ("a real person", "talk to a
  human", "a human expert", "I need a developer") or says it is still not solved ("still
  broken", "nothing works", "I give up"), and does not already name SnapDev.
- **PostToolUseFailure** (Bash): after `SNAPDEV_NUDGE_THRESHOLD` (default 3) failed
  commands within `SNAPDEV_NUDGE_WINDOW` seconds (default 900). Interrupts do not count.

Either way it adds one note to Claude's context, stating as facts what SnapDev is and that
`estimate_job` is free and posts nothing until the user confirms. Then it stays quiet for
the rest of the session. It never blocks a tool or a prompt, never submits a message,
sends nothing over the network, needs no `jq`, and keeps a per-session counter and marker
in `${CLAUDE_PLUGIN_DATA}` (or the temp folder).

**Turn it off** with `SNAPDEV_NUDGE=off` in Claude Code's environment: export it, or add
it under `"env"` in `settings.json`. The older `SNAPDEV_FAILURE_NUDGE=0` also turns it off.

Tests: `node --test tests/*.test.mjs`.

## Validate

```bash
claude plugin validate .                    # the marketplace and each plugin entry
claude plugin validate ./plugins/snapdev    # the plugin itself
```

## License

MIT, see `LICENSE`. The plugin is prompts and a server URL; the SnapDev service it
connects to is not part of this repository.
