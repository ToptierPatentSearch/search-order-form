# Top-tier Patent Search — Order Details App

React/Vite implementation of **Section 4 — Provide Your Order Details** for the Top-tier Patent Search “Place an Order” workflow.

## Stack

- React 19
- Vite 7
- Supabase JavaScript client
- Supabase Edge Functions
- Supabase Postgres + private Storage

## Supabase project

Project URL:

```text
https://syshvcymwktnkrkrvwtk.supabase.co
```

The repository intentionally does **not** contain a real Supabase publishable key or any secret key.

## Local setup

1. Install dependencies:

```bash
npm install
```

2. Copy `.env.example` to `.env.local`.

3. Set your browser-safe Supabase publishable key in `.env.local`:

```env
VITE_SUPABASE_URL=https://syshvcymwktnkrkrvwtk.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_your_key_here
```

4. Start Vite:

```bash
npm run dev
```

5. Open the local URL printed by Vite, normally `http://localhost:5173/`.

## Production build

```bash
npm run build
```

The build output is written to `dist/`.

## Supabase setup

Run `supabase/schema.sql` in the Supabase SQL Editor to create the order table, private Storage bucket, and initial policies.

The application uses two Edge Functions:

- `submit-order` — validates and records an order.
- `create-upload-url` — creates temporary signed upload authorization for supporting documents.

The corresponding source is version-controlled under `supabase/functions/`.

For both functions, the deployed Supabase configuration should use publishable-key authentication and have the legacy **Verify JWT with legacy secret** setting disabled when using the `@supabase/server` wrapper shown here.

## Security notes

- `.env.local` is ignored by Git and must never be committed.
- Never place a Supabase secret/service-role key in Vite browser code.
- Supporting documents are stored in a private bucket.
- The current frontend requests a signed upload token from `create-upload-url` and then uploads with `uploadToSignedUrl()`.
- Before broad public launch, add anti-bot protection and rate limiting.
