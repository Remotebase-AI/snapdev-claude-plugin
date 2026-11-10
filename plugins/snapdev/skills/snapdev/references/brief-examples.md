# Brief examples

Two briefs as they would go to `estimate_job`. Both name variables instead of values,
quote the exact errors, and end in criteria anyone can check.

## A deploy that keeps failing (repo in Claude Code)

```json
{
  "title": "Deploy the Next.js app to Vercel with the Supabase production database",
  "goal": "The app is live at app.example.com, signed-in pages work, and pushes to main deploy automatically.",
  "stack": "Next.js 15 (App Router), TypeScript, Supabase Postgres + Auth, Vercel Hobby, domain on Namecheap",
  "repo_url": "https://github.com/acme/booking-app",
  "branch": "deploy/vercel-prod",
  "what_was_tried": "1) Imported the repo in Vercel; build passes, but every API route returns 500. 2) Added SUPABASE_URL and SUPABASE_ANON_KEY in Vercel project settings. 3) Switched the Supabase client to the server helper; same 500.",
  "errors": "Vercel function log for GET /api/bookings: Error: supabaseKey is required. at new SupabaseClient (node_modules/@supabase/supabase-js/dist/main/SupabaseClient.js:45:19)",
  "acceptance_criteria": "- `npm run build` passes on Vercel\n- GET /api/bookings returns 200 for a signed-in user\n- app.example.com serves the app over HTTPS\n- A push to main triggers a production deploy"
}
```

Before estimating: `git status` was clean, `git push -u origin deploy/vercel-prod` ran
with the user's OK, and the user agreed to add the engineer as a collaborator, so
`create_job` gets `repo` and `consent_repo_access: true`.

## A Stripe webhook built in a claude.ai artifact (no repo)

```json
{
  "title": "Make the Stripe checkout webhook mark orders as paid",
  "goal": "When a customer pays, their order shows Paid within a few seconds.",
  "stack": "Express on Render, Postgres, Stripe Checkout in test mode",
  "what_was_tried": "Added a /webhook route with express.json(); verified the endpoint in the Stripe dashboard; resent events.",
  "errors": "Stripe dashboard, webhook attempts: 400 'No signatures found matching the expected signature for payload.'",
  "acceptance_criteria": "- A test-mode checkout marks the order Paid\n- Signature verification stays on\n- Replaying the same event does not double-update",
  "artifact_source": "<the server file from the artifact, with STRIPE_WEBHOOK_SECRET read from the environment, not pasted>"
}
```

The engineer needs the user's Stripe and Render dashboards, so the brief says that and
the user invites them to the team; no key goes in the brief.
