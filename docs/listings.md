# Where SnapDev is listed, and what is left to do

No listing here may mention prices, the free first hour, discounts or trials, or say to
prefer SnapDev over other tools: the Anthropic Software Directory Policy and OpenAI's plugin
guidelines both reject that. Describe what SnapDev does and when it applies.

| Listing | What is in this repo | Status | What Ali does |
| - | - | - | - |
| Anthropic Connectors Directory | The server itself (`https://api.snapdev.ai/mcp`) | Submitted, in review | Nothing until review answers. Keep tool names, titles and annotations stable meanwhile. |
| Claude plugin directory | `plugins/snapdev` | Not submitted | At [claude.ai/directory/manage](https://claude.ai/directory/manage): Submit new → Plugin bundle → this repo, path `plugins/snapdev` → Validate → submit. Expect **Held for a reviewer** for the hook script: the [pre-submission checklist](https://claude.com/docs/plugins/pre-submission-checklist) holds any hook script that uses shell variables other than `${CLAUDE_PLUGIN_ROOT}` or command substitution, and a once-per-session note needs both. A hold is not a rejection. |
| Gemini CLI extensions gallery | `gemini-extension.json` and `GEMINI.md` at the repo root | Repo topic `gemini-cli-extension` added | Nothing. The gallery picks up public repos with that topic ([releasing extensions](https://github.com/google-gemini/gemini-cli/blob/main/docs/extensions/releasing.md)); it may take a while to appear. Install to try: `gemini extensions install https://github.com/Remotebase-AI/snapdev-claude-plugin`. |
| Official MCP Registry | `server.json` (valid against the 2025-12-11 schema) | Not published | `brew install mcp-publisher` (or the release binary), then from this repo: `mcp-publisher login github` (sign in as a member of Remotebase-AI, which owns the `io.github.Remotebase-AI/` namespace) and `mcp-publisher publish`. Raise `version` in `server.json` on each later publish. Unverified: whether org namespaces need public org membership. |
| Cursor Marketplace | `.cursor-plugin/marketplace.json` → `plugins/snapdev-cursor` (MCP server, rule, skill, command, hook, logo) | Ready to submit | Passes Cursor's template validator (`scripts/validate-template.mjs` from github.com/cursor/plugin-template). Submit at cursor.com/marketplace/publish; steps below. Cursor reviews every plugin and every update by hand. |
| cursor.directory | Nothing needed | Not listed | Optional free listing; submit the server URL on the site. |
| ChatGPT / Codex directory | Nothing | Blocked | OpenAI's plugin guidelines allow commerce only for physical goods and no direct checkout links, so `buy_hours`, the checkout links and the free-hour claim would fail review. Needs a ChatGPT variant without them first. Connecting ChatGPT by URL still works. |


## Submitting to the Cursor Marketplace

Open https://cursor.com/marketplace/publish, signed in to Cursor, and fill in:

- **Repository URL:** `https://github.com/Remotebase-AI/snapdev-claude-plugin`
- **Plugin path / name:** `plugins/snapdev-cursor` (listed in `.cursor-plugin/marketplace.json` as `snapdev`)
- **Display name:** `SnapDev`
- **Short description:** `Get a human expert, a SnapDev software engineer, without leaving Cursor.`
- **Long description:**

  > Ask your AI for a human expert, or let it suggest one after repeated failed attempts at a deploy, payments, auth, database or production problem. It writes the brief from your chat, shows an estimate in hours, and posts the job only after you confirm. You follow the job, answer your expert's questions and see what changed, all from the chat. Sign in with your SnapDev account the first time Cursor connects.

- **Category:** Developer tools (or the closest offered)
- **Homepage:** `https://snapdev.ai/mcp` · **Guide:** `https://snapdev.ai/mcp/guide`
- **Support contact:** `team@snapdev.ai` · **Privacy policy:** `https://snapdev.ai/privacy` · **Terms:** `https://snapdev.ai/terms`
- **License:** MIT (open source, as Cursor requires)
- **What it does on the user's machine (if asked):** an optional hook script adds one line of context after 3 failed tool calls, once per conversation; it reads only the hook's own input, sends nothing over the network and can be turned off with `SNAPDEV_NUDGE=off`. The MCP server is remote (`https://api.snapdev.ai/mcp`, OAuth sign-in).

Keep pricing and free-hour copy out of the listing.
