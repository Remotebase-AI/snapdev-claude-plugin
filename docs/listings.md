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
| Cursor Marketplace | Not yet: needs a `.cursor-plugin/plugin.json` bundling `rules/cursor/snapdev.mdc`, the MCP server and the optional hook | Not started | Cursor requires plugins to be open source (this repo is public) and reviews each one by hand; submit at cursor.com/marketplace/publish ([Cursor plugins](https://cursor.com/docs/plugins)). Ask me to add the manifest first. |
| cursor.directory | Nothing needed | Not listed | Optional free listing; submit the server URL on the site. |
| ChatGPT / Codex directory | Nothing | Blocked | OpenAI's plugin guidelines allow commerce only for physical goods and no direct checkout links, so `buy_hours`, the checkout links and the free-hour claim would fail review. Needs a ChatGPT variant without them first. Connecting ChatGPT by URL still works. |
