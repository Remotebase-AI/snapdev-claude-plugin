# Brief examples

Two briefs as they would go to `estimate_job`, drafted from the conversation without a
separate round of corrections. Both name variables instead of values, quote the exact
errors, and end in criteria anyone can check. The brief is for the engineer, so it is
technical; what Claude says to the builder about it is not.

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
with the builder's OK, and the builder agreed to add the engineer as a collaborator, so
`create_job` gets the `estimate_id`, `repo` and `consent_repo_access: true`. Nothing
else is chosen at create: there is one rate, and the estimate is in hours.

The estimate's `likely_access` named Vercel, so Claude added one line to the estimate:
"Your engineer may ask you to invite them to Vercel. They will walk you through it in
the chat or on a call." Nothing was asked of the builder at that point.

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

The engineer needs the builder's Stripe and Render dashboards, so the brief says that; no
key goes in the brief. Later the engineer asks, in a message, to be added to both.
Claude tells the builder which accounts and shows the address the engineer gave as the
engineer's own words, and the builder sends the invitations from Stripe's and Render's
team settings. If the builder is unsure where those are, the engineer walks them
through it on a call. No password, key or token is sent to anyone, and there is no tool
to call: the builder just says when it is done and Claude passes that on with
`reply_to_engineer`.
