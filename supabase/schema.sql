-- Run this in the SQL Editor for project:
-- https://syshvcymwktnkrkrvwtk.supabase.co
--
-- Secure configuration for the current application architecture:
-- React -> Edge Functions -> Postgres / signed private-Storage upload.

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

-- The public React client must not insert/read/update/delete order rows directly.
-- submit-order performs the insert through the Edge Function's administrative client.
drop policy if exists "anon can submit order requests" on public.order_requests;
revoke insert, select, update, delete on table public.order_requests from anon;

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

-- The browser must not have a general anonymous INSERT policy for Storage.
-- create-upload-url creates a path-specific signed upload authorization instead.
drop policy if exists "anon can upload order documents" on storage.objects;
