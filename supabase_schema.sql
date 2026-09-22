-- CareLedger Pharmacy Khata
-- Run this entire script in Supabase Dashboard -> SQL Editor -> New query.
-- This schema is intentionally open for the current no-login demo app.
-- For production, add Supabase Auth and restrict policies by authenticated user/organization.

create extension if not exists pgcrypto;

create table if not exists public.patients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null default '',
  area text not null default '',
  category text not null default 'Regular customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  type text not null check (type in ('Credit sale', 'Payment received', 'Return')),
  detail text not null default '',
  total numeric(12, 2) not null default 0 check (total >= 0),
  paid numeric(12, 2) not null default 0 check (paid >= 0),
  due numeric(12, 2) not null default 0,
  method text,
  transaction_date timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists patients_name_idx on public.patients (lower(name));
create index if not exists patients_phone_idx on public.patients (phone);
create index if not exists transactions_patient_id_idx on public.transactions (patient_id);
create index if not exists transactions_date_idx on public.transactions (transaction_date desc);
create index if not exists transactions_type_idx on public.transactions (type);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists patients_set_updated_at on public.patients;
create trigger patients_set_updated_at
before update on public.patients
for each row execute function public.set_updated_at();

drop trigger if exists transactions_set_updated_at on public.transactions;
create trigger transactions_set_updated_at
before update on public.transactions
for each row execute function public.set_updated_at();

alter table public.patients enable row level security;
alter table public.transactions enable row level security;

drop policy if exists "Public can read patients" on public.patients;
create policy "Public can read patients"
on public.patients for select to anon, authenticated using (true);

drop policy if exists "Public can insert patients" on public.patients;
create policy "Public can insert patients"
on public.patients for insert to anon, authenticated with check (true);

drop policy if exists "Public can update patients" on public.patients;
create policy "Public can update patients"
on public.patients for update to anon, authenticated using (true) with check (true);

drop policy if exists "Public can delete patients" on public.patients;
create policy "Public can delete patients"
on public.patients for delete to anon, authenticated using (true);

drop policy if exists "Public can read transactions" on public.transactions;
create policy "Public can read transactions"
on public.transactions for select to anon, authenticated using (true);

drop policy if exists "Public can insert transactions" on public.transactions;
create policy "Public can insert transactions"
on public.transactions for insert to anon, authenticated with check (true);

drop policy if exists "Public can update transactions" on public.transactions;
create policy "Public can update transactions"
on public.transactions for update to anon, authenticated using (true) with check (true);

drop policy if exists "Public can delete transactions" on public.transactions;
create policy "Public can delete transactions"
on public.transactions for delete to anon, authenticated using (true);

-- Enable realtime updates for both tables. The guard makes this safe to run more than once.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'patients'
  ) then
    alter publication supabase_realtime add table public.patients;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'transactions'
  ) then
    alter publication supabase_realtime add table public.transactions;
  end if;
end;
$$;

-- Optional verification queries:
-- select * from public.patients order by created_at desc;
-- select * from public.transactions order by transaction_date desc;

-- Optional sample patient:
-- insert into public.patients (name, phone, area, category)
-- values ('Test Patient', '03470636118', 'Johar Town', 'Regular customer');
