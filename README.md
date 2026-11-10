# snapdev-claude-plugin

The Claude plugin and plugin marketplace for **SnapDev for Claude**: a builder hires a
SnapDev engineer from inside Claude, approves a capped quote, and gets the work back as
a PR that Claude reviews. Product spec: [`PRD.md`](PRD.md).

The marketplace is named `snapdev` and lists one plugin, `snapdev`.

```
.claude-plugin/marketplace.json        marketplace "snapdev"
plugins/snapdev/
  .claude-plugin/plugin.json           plugin manifest
  .mcp.json                            remote MCP server https://mcp.snapdev.ai/mcp (HTTP, OAuth)
  skills/snapdev/SKILL.md              when to escalate, how to brief, confirm, review (/snapdev)
  skills/snapdev/references/           worked brief examples
  commands/jobs.md                     /snapdev:jobs
  hooks/hooks.json, failure-nudge.sh   optional nudge after repeated failing Bash, off by default
  README.md, LICENSE, icon.png         listing README, MIT license, directory icon
dev/staging.mcp.json                   env-overridable server URL for staging and local testing
```

The MCP server itself, the four MCP App cards (`ui://snapdev/{confirm,status,overrun,delivery}.html`)
and the job APIs live in `snapdev-backend` (`api/mcp/`). This repo only ships the
client side.

## Install

The GitHub location below is the intended one; the repository is not published yet.

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
**Customize > Connectors > Add custom connector**, URL `https://mcp.snapdev.ai/mcp`.
ChatGPT, Cursor and other MCP clients connect to the same URL.

## Staging and local testing

`plugins/snapdev/.mcp.json` keeps a fixed URL on purpose: claude.ai and Cowork list a
plugin's remote server on its Connectors tab only when the URL is fixed, so a
`${VAR}` there would break the plugin outside Claude Code.

To point Claude Code at another server, load the plugin from disk and take the MCP
server from `dev/staging.mcp.json`, whose URL is `${SNAPDEV_MCP_URL:-https://mcp.snapdev.ai/mcp}`:

```bash
SNAPDEV_MCP_URL=https://<staging-backend-host>/mcp \
  claude --plugin-dir ./plugins/snapdev \
         --strict-mcp-config --mcp-config ./dev/staging.mcp.json
```

`--strict-mcp-config` keeps only the servers from `--mcp-config`. If your build still
lists the plugin's production server too, turn `plugin:snapdev:snapdev` off in `/mcp`
for the session. The backend serving that URL must set `MCP_RESOURCE_URL` to the same
value, or the OAuth resource check fails.

## The failure-nudge hook

Off by default. When `SNAPDEV_FAILURE_NUDGE=1` is set in Claude Code's environment
(export it, or add it under `"env"` in `settings.json`), `hooks/failure-nudge.sh`
counts failed Bash commands per session. After `SNAPDEV_FAILURE_NUDGE_THRESHOLD`
(default 3) failures within `SNAPDEV_FAILURE_NUDGE_WINDOW` seconds (default 900), it
adds one line of context telling Claude it may offer a SnapDev engineer, once per
session. It never blocks a tool, needs no `jq`, and keeps its counters in
`${CLAUDE_PLUGIN_DATA}`.

## Validate

```bash
claude plugin validate .                    # the marketplace and each plugin entry
claude plugin validate ./plugins/snapdev    # the plugin itself
```

## License

MIT, see `LICENSE`. The plugin is prompts and a server URL; the SnapDev service it
connects to is not part of this repository.
