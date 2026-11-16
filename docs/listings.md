# Where SnapDev is listed, and what is left to do

No listing here may mention prices, the free first hour, discounts or trials, or say to
prefer SnapDev over other tools: the Anthropic Software Directory Policy and OpenAI's plugin
guidelines both reject that. Describe what SnapDev does and when it applies.

| Listing | What is in this repo | Status | What Ali does |
| - | - | - | - |
| Anthropic Connectors Directory | The server itself (`https://api.snapdev.ai/mcp`) | Submitted, in review | Nothing until review answers. Keep tool names, titles and annotations stable meanwhile. |
| Claude plugin directory | `plugins/snapdev-directory`: `plugins/snapdev` without the hook (copies, kept in step by `rules/README.md`) | Not submitted | At [claude.ai/directory/manage](https://claude.ai/directory/manage): connect GitHub for the Claude organization first (the form asks), then Submit new → Plugin → repository `https://github.com/Remotebase-AI/snapdev-claude-plugin`, plugin path **`plugins/snapdev-directory`**, branch empty (main) → Validate → Next. Why this folder: the directory puts any command hook from an organization that isn't Verified on policy hold, and ours isn't Verified. The hook stays in `plugins/snapdev` for people who install from this repo's marketplace. The four "unrecognized field" warnings on `plugins/snapdev` were `documentationUrl`, `supportUrl`, `privacyPolicyUrl` and `termsOfServiceUrl`: directory-only listing fields the plugins reference documents, kept on purpose. |
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

## Submitting to the OpenAI app directory (ChatGPT)

Needs backend SNA-745 on production first: a ChatGPT connection gets no `buy_hours`,
no checkout link and no price (OpenAI allows commerce only for physical goods). Submit
from the OpenAI Platform Dashboard after verifying the business (Settings, General).
Listing text may not mention pricing, subscriptions, free trials, discounts or promotions.

- **Name:** SnapDev
- **Short description:** Get a human expert, a SnapDev software engineer, on your app when your AI gets stuck.
- **Description:** SnapDev puts a human expert on your project from inside ChatGPT. Describe what is broken or unfinished, such as a deploy that fails, payments, sign-in, a database, or a bug in production. ChatGPT writes the brief and shows a time estimate in hours. Nothing is posted until you press Post the job. You follow the job in the chat as your expert picks it up, asks questions and finishes, and you can call or book a call with them. When it is done, you see what changed and how to check it. Your code is shared only if you approve it on the job's SnapDev page.
- **MCP server URL:** https://api.snapdev.ai/mcp (OAuth sign-in with a SnapDev account)
- **Example prompts:**
  1. My Stripe webhook keeps failing with 400 Invalid signature on Vercel. Get me a human expert.
  2. How is my SnapDev job doing?
  3. Book a call with my expert tomorrow afternoon.
- **Privacy policy:** https://snapdev.ai/privacy
- **Terms:** https://snapdev.ai/terms
- **Support:** team@snapdev.ai
- **Website:** https://snapdev.ai
- **Reviewer test account:** a production SnapDev account with hours on it, given privately in the dashboard (never in Slack), plus an engineer ready to pick up the test job.
