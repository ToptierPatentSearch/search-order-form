# Top-tier Patent Search — Section 4 Order Details

A React/Vite implementation of Section 4, **Provide Your Order Details**, for the Place an Order workflow.

## Included

- Client Information
- Assignment Information
- Optional supporting-document upload
- Scope-review acknowledgment
- Requested completion date displayed as `Month/Day/Year`
- Supabase Database submission
- Private Supabase Storage bucket for attachments
- Responsive, conservative B2B styling
- A generated order reference after successful submission

## 1. Install

```bash
npm install
```

## 2. Configure Supabase

The project URL is already placed in `.env.example`:

```text
https://syshvcymwktnkrkrvwtk.supabase.co
```

Copy the example file:

```bash
cp .env.example .env.local
```

Then obtain the project's **Publishable key** from the Supabase Dashboard **Connect** panel and set:

```text
VITE_SUPABASE_PUBLISHABLE_KEY=...
```

Do not put the `service_role` key or any secret server key in a Vite/browser environment variable.

## 3. Create the database table and Storage bucket

Open the Supabase SQL Editor for the project and run:

```text
supabase/schema.sql
```

The SQL creates:

- `public.order_requests`
- RLS permitting anonymous **INSERT only**
- private bucket `order-supporting-documents`
- an anonymous upload-only Storage policy

## 4. Run locally

```bash
npm run dev
```

Open the Vite URL shown in the terminal (normally `http://localhost:5173`).

## 5. Build

```bash
npm run build
```

The deployable output will be in `dist/`.

## Important production hardening

This browser-only version is suitable as a functional baseline, but a public form can be spammed because the publishable key is intentionally browser-visible. Before a production launch, route submission and document uploads through a Supabase Edge Function and add bot protection such as Cloudflare Turnstile. The Edge Function can validate payloads, apply rate limits, and perform the database/storage writes using server-side credentials.

Because submitted technical information may be confidential, keep the Storage bucket private and provide staff access only through authenticated/admin workflows or signed URLs generated server-side.
