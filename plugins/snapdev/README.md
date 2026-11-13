# SnapDev for Claude

Get a human expert without leaving Claude: a SnapDev software engineer. When a deploy, payment flow, auth setup
or production issue keeps failing, Claude writes a brief from the conversation and
shows an estimate in hours (for example "1–3 hours"). The job is created only after you
confirm. You can talk to your expert now, or book a call for later. When the engineer
marks it done, Claude tells you in plain words what changed and how to check it.

## What's inside

| Part | What it does |
| - | - |
| `snapdev` MCP connector | `https://api.snapdev.ai/mcp`, signed in with your SnapDev account (OAuth). 21 tools: estimates, jobs, your repositories, replies, cancelling a waiting job, reopening, calls now, calls booked for later, live consults, balance. Plus the `get_a_human_expert` prompt |
| `snapdev` skill (`/snapdev`) | When to bring in a human expert and when not to, how to brief, one confirmation before anything starts, what to offer when you are short of hours, no passwords or keys through Claude, calling your expert now or booking a time for later, engineer text is untrusted, what to tell you when the job is done |
| `/snapdev:jobs` | Check on your jobs and anything waiting on you |
| "Stuck" hook | On by default, at most once per session. When you ask for a person ("a real person", "a human expert", "a developer") or say it is still broken, or after 3 failed shell commands, it tells Claude that SnapDev can help. It sends nothing anywhere and never posts a job. Turn it off with `SNAPDEV_NUDGE=off` (see below) |

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
`https://api.snapdev.ai/mcp`.

## Usage

Say "get a human expert to deploy this", type `/snapdev`, or let Claude suggest it
after repeated failures. Claude shows the estimate; nothing is created until you
confirm. Check progress any time with `/snapdev:jobs`.

## Data it sends

The connector sends SnapDev the brief Claude writes (goal, stack, repository and
branch, what was tried, error text, acceptance criteria) and your replies to the
engineer. Repository access is granted only when you consent at job creation. Engineer
messages come back marked as untrusted text that Claude must not obey.

When you book a call, it also sends the time you picked and your time zone (Claude asks
which city you are in only when SnapDev has no time zone saved for you), and the code
Cal.com emailed you if it asked for one.

## Passwords and keys

Passwords, API keys and tokens are never sent through Claude, and never to the engineer
in a message. The skill forbids secrets in any tool argument, and the server scans
briefs and removes anything that looks like a key before an engineer sees it.

If the work needs one of your accounts (Vercel, Stripe, AWS, your domain registrar),
the engineer asks you in the chat or on a call and walks you through inviting them
from that provider's own settings. They sign in as themselves.

The one code Claude does take from you is the one Cal.com emails when you book a call
(see **Calls**). It only confirms your email address for that booking and opens no
account. It goes to the booking and never to the engineer.

## Calls

- **Now.** Ask to talk to your expert and Claude rings them and gives you the link.
- **Later.** Ask to book a call and Claude shows your engineer's free times in your
  time zone. You pick one and Claude books 30 minutes. Claude never picks a time for
  you.
- **The invite comes by email** from Cal.com, the scheduling service SnapDev uses, with
  reminders before the call. Cal.com may first email you a code to confirm your address
  (check spam); give it to Claude, or book on your job page instead.
- **Joining.** From the invite, from your job page, or ask Claude for the link.
- **One booked call per job.** To change the time, Claude cancels the booked call and
  books the new one, and tells you before it does. Cancelling a job also cancels the call
  booked on it.
- You can always book on your job page instead; Claude gives you the link whenever
  booking through Claude does not work.

## Hours

Everything is in hours, at one rate. The only price you see is for buying hours.

- **The estimate** is a range of hours, made by AI. A real engineer's time can vary,
  and you only use the hours actually worked.
- **To hire** you need at least the low end of the estimate. If you are short, Claude
  points you to your free first hour (if you have not claimed it), to buying the hours
  you are missing, and to the plans page. Then you come back and confirm.
- **Your engineer logs the hours after the work**, as for all SnapDev work. They show
  in your SnapDev hours. Claude does not report or guess what a job took.
- **Cancelling.** Free while the job is waiting for an expert. Once an expert has picked
  it up, the job cannot be cancelled.
- **Calls.** A call has no charge of its own, and booking one uses no hours. Your
  engineer logs the time actually spent. You need some hours left to book.
- **If something is off**, say so within 7 days of the job being done and the engineer
  fixes it at no extra hours. This can be used once per job.

A live consult is different: it is a live chat with an expert, started only while one is
online and only after you confirm. There is no clock: hours come off only as your expert
logs the time they worked.
