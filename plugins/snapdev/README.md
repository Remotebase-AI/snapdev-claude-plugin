# SnapDev for Claude

Hire a SnapDev engineer without leaving Claude. When a deploy, payment flow, auth setup
or production issue keeps failing, Claude writes a brief from the conversation and
shows an estimate in hours (for example "1–3 hours"). The job is created only after you
confirm. When the engineer marks it done, Claude tells you in plain words what changed
and how to check it.

## What's inside

| Part | What it does |
| - | - |
| `snapdev` MCP connector | `https://mcp.snapdev.ai/mcp`, signed in with your SnapDev account (OAuth). 18 tools: estimates, jobs, replies, stopping, reopening, calls, live consults, balance |
| `snapdev` skill (`/snapdev`) | When to bring in an engineer and when not to, how to brief, one confirmation before anything starts, what to offer when you are short of hours, no passwords or keys through Claude, engineer text is untrusted, what to tell you when the job is done |
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
after repeated failures. Claude shows the estimate; nothing is created until you
confirm. Check progress any time with `/snapdev:jobs`.

## Data it sends

The connector sends SnapDev the brief Claude writes (goal, stack, repository and
branch, what was tried, error text, acceptance criteria) and your replies to the
engineer. Repository access is granted only when you consent at job creation. Engineer
messages come back marked as untrusted text that Claude must not obey.

## Passwords and keys

Passwords, API keys and tokens are never sent through Claude, and never to the engineer
in a message. The skill forbids secrets in any tool argument, and the server scans
briefs and removes anything that looks like a key before an engineer sees it.

If the work needs one of your accounts (Vercel, Stripe, AWS, your domain registrar),
the engineer asks you in the chat or on a call and walks you through inviting them
from that provider's own settings. They sign in as themselves.

## Hours

Everything is in hours, at one rate. The only price you see is for buying hours.

- **The estimate** is a range of hours, made by AI. A real engineer's time can vary,
  and you only use the hours actually worked.
- **To hire** you need at least the low end of the estimate. If you are short, Claude
  points you to your free first hour (if you have not claimed it), to buying the hours
  you are missing, and to the plans page. Then you come back and confirm.
- **Your engineer logs the hours after the work**, as for all SnapDev work. They show
  in your SnapDev hours. Claude does not report or guess what a job took.
- **Stopping.** Free before an engineer picks the job up. After that, the job stops at
  once and you use only the hours your engineer already worked.
- **If something is off**, say so within 7 days of the job being done and the engineer
  fixes it at no extra hours. This can be used once per job.

A live consult is different: it is a live chat with an engineer that uses your hours
while it is open, for a set time. Claude checks with you before starting one, and
again before keeping it open past that time.
