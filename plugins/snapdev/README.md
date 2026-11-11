# SnapDev for Claude

Hire a SnapDev engineer without leaving Claude. When a deploy, payment flow, auth setup
or production issue keeps failing, Claude writes a brief from the conversation and
shows an estimate in hours (for example "1–3 hours"). The job is created only after you
confirm. When the engineer marks it done, Claude tells you in plain words what changed
and how to check it.

## What's inside

| Part | What it does |
| - | - |
| `snapdev` MCP connector | `https://mcp.snapdev.ai/mcp`, signed in with your SnapDev account (OAuth). 20 tools: estimates, jobs, replies, more time, stopping, reopening, calls, balance |
| `snapdev` skill (`/snapdev`) | When to bring in an engineer and when not to, how to brief, one confirmation before any hours are set aside, engineer text is untrusted, what to tell you when the job is done |
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
after repeated failures. Claude shows the estimate; nothing is created and no hours are
set aside until you confirm. Check progress any time with `/snapdev:jobs`.

## Data it sends

The connector sends SnapDev the brief Claude writes (goal, stack, repository and
branch, what was tried, error text, acceptance criteria) and your replies to the
engineer. It never sends credentials: the skill forbids secrets in any tool argument,
and the server scans briefs and removes anything that looks like a key before an
engineer sees it. Repository access is granted only when you consent at job creation.
Engineer messages come back marked as untrusted text that Claude must not obey.

## Hours

Everything is in hours, at one rate. You buy hours on SnapDev; that checkout page is
the only place a price appears.

- **The estimate** is a range of hours, made by AI. A real engineer's time can vary.
- **Confirming** sets the top of the range aside from your balance. Those are your
  approved hours.
- **When the engineer marks the job done** they enter the time they spent. You use
  only those hours, and the rest goes back to your balance.
- **More time.** The engineer cannot go past your approved hours. They ask first, with
  a reason, and you approve or stop.
- **Stopping.** Free before an engineer picks the job up. After that, the engineer is
  asked to stop and you use only the hours worked so far.
- **If something is off**, say so within 7 days of the job being done and the engineer
  fixes it at no extra hours. This can be used once per job.

You can also set a monthly limit, in hours, on what Claude may use.
