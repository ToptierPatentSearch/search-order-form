-- Run this in the SQL Editor for project:
-- https://syshvcymwktnkrkrvwtk.supabase.co

create extension if not exists pgcrypto;

create table if not exists public.order_requests (
  id uuid primary key,
  order_reference text not null unique,
  created_at timestamptz not null default now(),
  client_name text not null,
  organization text,
  email text not null,
  country text not null,
  billing_organization text,
  search_service text not null,
  technical_subject text not null,
  search_objective text not null,
  relevant_jurisdictions text not null,
  relevant_dates text,
  known_patent_documents text,
  known_competitors_or_assignees text,
  requested_completion_date date,
  preferred_deliverable text not null,
  additional_instructions text,
  supporting_documents jsonb not null default '[]'::jsonb,
  scope_review_acknowledged boolean not null default false,
  source text not null default 'place-an-order-section-4',
  status text not null default 'submitted'
);

alter table public.order_requests enable row level security;

-- Public form users may submit an order request, but cannot read, update, or delete records.
drop policy if exists "anon can submit order requests" on public.order_requests;
create policy "anon can submit order requests"
on public.order_requests
for insert
to anon
with check (
  scope_review_acknowledged = true
  and char_length(client_name) between 1 and 160
  and char_length(email) between 3 and 254
  and char_length(country) between 1 and 120
  and char_length(technical_subject) between 1 and 3000
  and char_length(search_objective) between 1 and 5000
  and char_length(relevant_jurisdictions) between 1 and 1000
);

grant insert on table public.order_requests to anon;
revoke select, update, delete on table public.order_requests from anon;

-- Private bucket for sensitive supporting materials.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'order-supporting-documents',
  'order-supporting-documents',
  false,
  10485760,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    'image/png',
    'image/jpeg'
  ]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

-- Anonymous browser users can only upload into the private bucket.
-- They receive no SELECT/UPDATE/DELETE policy for storage.objects.
drop policy if exists "anon can upload order documents" on storage.objects;
create policy "anon can upload order documents"
on storage.objects
for insert
to anon
with check (bucket_id = 'order-supporting-documents');
