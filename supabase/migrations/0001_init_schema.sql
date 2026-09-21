-- Allez Moris / Fjelvik demo — shared schema for the website + dashboard.
-- Run this once against a fresh Supabase project (SQL Editor, or `supabase db push`).
-- Safe to re-run: every statement is guarded with IF NOT EXISTS / OR REPLACE.

create schema if not exists booking;

grant usage on schema booking to anon, authenticated;

-- ---------------------------------------------------------------------------
-- tours: the public catalog. Read by both the website (catalog + detail
-- pages) and the dashboard (to show which tour a request is for). Edited by
-- re-running supabase/seed.sql, never by hand in the client apps.
-- ---------------------------------------------------------------------------
create table if not exists booking.tours (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  -- Marketing category shown on the website's filter chips.
  category text not null check (category in ('water', 'land', 'nature', 'accommodation', 'transport')),
  -- Maps 1:1 onto booking.requests.form_type when a booking is created for this tour.
  form_type text not null check (form_type in ('activity', 'accommodation', 'rental', 'transfer')),
  location text,
  short_description text not null,
  description text not null,
  price numeric not null check (price >= 0),
  currency text not null default 'MUR',
  duration_label text not null,
  image_url text not null,
  gallery jsonb not null default '[]'::jsonb,
  highlights jsonb not null default '[]'::jsonb,
  max_party_size int not null default 10,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

comment on column booking.tours.category is 'Website-facing filter category — cosmetic only.';
comment on column booking.tours.form_type is 'Backend request type this tour becomes when booked (booking.requests.form_type).';

-- ---------------------------------------------------------------------------
-- requests: one row per booking request/enquiry, created by the website and
-- reviewed by the dashboard.
-- ---------------------------------------------------------------------------
create table if not exists booking.requests (
  id uuid primary key default gen_random_uuid(),
  reference text unique,
  tour_id uuid references booking.tours(id),
  activity_ref text,
  activity_name text not null,
  full_name text not null,
  email text not null,
  phone text,
  adults int not null default 1 check (adults >= 0),
  children int not null default 0 check (children >= 0),
  start_date date not null,
  end_date date,
  party_size int not null default 1 check (party_size >= 1),
  notes text,
  message text not null default '',
  form_type text not null check (form_type in ('activity', 'accommodation', 'rental', 'transfer')),
  status text not null default 'pending_review' check (status in (
    'pending_review', 'declined', 'approved', 'awaiting_payment',
    'confirmed', 'reminded', 'completed', 'cancelled'
  )),
  total_amount numeric,
  paid boolean not null default false,
  approved_by text,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists requests_status_idx on booking.requests (status);
create index if not exists requests_tour_id_idx on booking.requests (tour_id);

-- Auto-generate a human-friendly reference code (e.g. REQ-2026-0007) when the
-- website inserts a request without one.
create sequence if not exists booking.request_reference_seq;

create or replace function booking.set_request_reference()
returns trigger
language plpgsql
as $$
begin
  if new.reference is null then
    new.reference := 'REQ-' || to_char(now(), 'YYYY') || '-' ||
      lpad(nextval('booking.request_reference_seq')::text, 4, '0');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_set_request_reference on booking.requests;
create trigger trg_set_request_reference
before insert on booking.requests
for each row execute function booking.set_request_reference();

-- ---------------------------------------------------------------------------
-- payments: one row per payment attempt against a request (read-only in the
-- dashboard for this demo; nothing writes to it since there's no real
-- payment provider wired up).
-- ---------------------------------------------------------------------------
create table if not exists booking.payments (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references booking.requests(id),
  provider text,
  provider_txn_id text,
  amount numeric,
  currency text default 'MUR',
  pay_url text,
  status text default 'pending' check (status in ('pending', 'paid', 'failed', 'expired')),
  result_code text,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  quickbooks_invoice_id text,
  quickbooks_customer_id text,
  quickbooks_payment_id text
);

create index if not exists payments_request_id_idx on booking.payments (request_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table booking.tours enable row level security;
alter table booking.requests enable row level security;
alter table booking.payments enable row level security;

-- Tours: public catalog, readable by anyone (website visitors + dashboard).
drop policy if exists "tours are publicly readable" on booking.tours;
create policy "tours are publicly readable"
  on booking.tours for select
  to anon, authenticated
  using (is_active = true);

drop policy if exists "authenticated can read all tours" on booking.tours;
create policy "authenticated can read all tours"
  on booking.tours for select
  to authenticated
  using (true);

-- Requests: the public website can only INSERT a fresh pending request — it
-- can never read other customers' bookings directly (they go through the
-- lookup_booking() function below) or write a status/price/paid themselves.
drop policy if exists "anyone can submit a booking request" on booking.requests;
create policy "anyone can submit a booking request"
  on booking.requests for insert
  to anon
  with check (
    status = 'pending_review'
    and total_amount is null
    and paid = false
    and approved_by is null
    and approved_at is null
  );

-- The dashboard (signed-in owner) can read and write everything.
drop policy if exists "authenticated can read all requests" on booking.requests;
create policy "authenticated can read all requests"
  on booking.requests for select
  to authenticated
  using (true);

drop policy if exists "authenticated can update requests" on booking.requests;
create policy "authenticated can update requests"
  on booking.requests for update
  to authenticated
  using (true)
  with check (true);

-- Payments: dashboard-only (read), nothing writes to it in this demo.
drop policy if exists "authenticated can read payments" on booking.payments;
create policy "authenticated can read payments"
  on booking.payments for select
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- lookup_booking: the only way the public website can read back a request's
-- status. Requires knowing both the reference code and the email it was
-- booked under, so one customer can't browse another's booking by guessing
-- reference codes.
-- ---------------------------------------------------------------------------
create or replace function booking.lookup_booking(p_reference text, p_email text)
returns table (
  reference text,
  activity_name text,
  status text,
  start_date date,
  end_date date,
  party_size int,
  total_amount numeric,
  currency text,
  paid boolean,
  notes text,
  created_at timestamptz
)
language sql
security definer
set search_path = booking, pg_temp
as $$
  select r.reference, r.activity_name, r.status, r.start_date, r.end_date,
         r.party_size, r.total_amount, coalesce(t.currency, 'MUR'), r.paid,
         r.notes, r.created_at
  from booking.requests r
  left join booking.tours t on t.id = r.tour_id
  where r.reference = p_reference
    and lower(r.email) = lower(p_email);
$$;

grant execute on function booking.lookup_booking(text, text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- create_booking_request: the only way the public website creates a booking.
-- A SECURITY DEFINER RPC (rather than a raw table insert) so we can validate
-- the tour exists/is active and derive form_type/activity_name/price
-- server-side instead of trusting whatever the client sends.
-- ---------------------------------------------------------------------------
create or replace function booking.create_booking_request(
  p_tour_slug text,
  p_full_name text,
  p_email text,
  p_phone text,
  p_adults int,
  p_children int,
  p_start_date date,
  p_end_date date,
  p_message text
)
returns table (reference text)
language plpgsql
security definer
set search_path = booking, pg_temp
as $$
declare
  v_tour booking.tours%rowtype;
  v_reference text;
begin
  select * into v_tour from booking.tours where slug = p_tour_slug and is_active = true;
  if not found then
    raise exception 'Unknown or inactive tour: %', p_tour_slug;
  end if;

  insert into booking.requests (
    tour_id, activity_ref, activity_name, full_name, email, phone,
    adults, children, start_date, end_date, party_size, message, form_type
  ) values (
    v_tour.id, v_tour.slug, v_tour.title, p_full_name, p_email, p_phone,
    coalesce(p_adults, 1), coalesce(p_children, 0), p_start_date, p_end_date,
    coalesce(p_adults, 1) + coalesce(p_children, 0), coalesce(p_message, ''),
    v_tour.form_type
  )
  returning booking.requests.reference into v_reference;

  return query select v_reference;
end;
$$;

grant execute on function booking.create_booking_request(
  text, text, text, text, int, int, date, date, text
) to anon;
