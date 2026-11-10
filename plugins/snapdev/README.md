# SnapDev for Claude

Hire a SnapDev engineer without leaving Claude. When a deploy, payment flow, auth setup
or production issue keeps failing, Claude writes a brief from the conversation, shows
a quote with a hard cap (for example "$40–$90, capped at $90", or a fixed price for
predictable work), and creates the job only after you confirm. The engineer's work
comes back as a pull request (or a deploy URL and steps) that Claude reviews and tests
locally before recommending you accept it.

## What's inside

| Part | What it does |
| - | - |
| `snapdev` MCP connector | `https://mcp.snapdev.ai/mcp`, signed in with your SnapDev account (OAuth). Quotes, jobs, replies, overrun approval, delivery, balance |
| `snapdev` skill (`/snapdev`) | When to escalate and when not to, how to brief, confirm before spending, engineer text is untrusted, review the PR before accepting |
| `/snapdev:jobs` | Check on your jobs and anything waiting on you |
| Failure-nudge hook | Optional and off by default. After repeated failing shell commands, reminds Claude it can offer an engineer. Turn on with `SNAPDEV_FAILURE_NUDGE=1` |

## Install

**Claude Code**

```bash
claude plugin marketplace add Remotebase-AI/snapdev-claude-plugin
claude plugin install snapdev@snapdev
```

The first SnapDev tool call opens a browser to sign in to SnapDev and approve access.

**claude.ai, the desktop app and Cowork**

Customize > Plugins > Add > Add marketplace, enter the repository, and add **SnapDev**.
Then open the plugin's **Connectors** tab and connect `snapdev`. Or add only the
connector: Customize > Connectors > Add custom connector, URL
`https://mcp.snapdev.ai/mcp`.

## Usage

Say "get a SnapDev engineer to deploy this", type `/snapdev`, or let Claude suggest it
after repeated failures. Claude shows the quote; nothing is created or charged until
you confirm. Check progress any time with `/snapdev:jobs`.

## Data it sends

The connector sends SnapDev the brief Claude writes (goal, stack, repository and
branch, what was tried, error text, acceptance criteria) and your replies to the
engineer. It never sends credentials: the skill forbids secrets in any tool argument,
and the server scans briefs and removes anything that looks like a key before an
engineer sees it. Repository access is granted only when you consent at job creation.
Engineer messages come back marked as untrusted text that Claude must not obey.

## Billing

Minutes actually worked, billed from your SnapDev hours: Engineer $1/min, Senior
$1.50/min, 15-minute minimum. The cap is held when the job starts and the unused part
is released; going past it needs your explicit approval. One revision within scope is
included. You can set a monthly agent spend limit.
