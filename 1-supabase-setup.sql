-- ═══════════════════════════════════════════════════════════
--  MATCALC — Supabase setup (roles + invite system)
--  Run this in Supabase → SQL Editor
-- ═══════════════════════════════════════════════════════════

-- ── 1. PROFILES TABLE (stores role per user) ──
create table if not exists profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  role text not null default 'user',  -- 'admin' or 'user'
  created_at timestamptz default now()
);

alter table profiles enable row level security;

-- Everyone authenticated can read profiles (to check their own role)
create policy "Authenticated can read profiles"
  on profiles for select to authenticated using (true);

-- Users can update only their own profile (but NOT their role — handled below)
create policy "Users update own profile"
  on profiles for update to authenticated
  using (auth.uid() = id);

-- ── 2. AUTO-CREATE PROFILE ON SIGNUP ──
-- When a new user confirms their account, create a profile row automatically.
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'user')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ── 3. MATERIALS TABLE (already exists, policies confirm both roles can edit) ──
-- If you already created materials, you can skip the create.
create table if not exists materials (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  category text,
  unit text default 'each',
  price numeric(10,4) default 0,
  updated_at timestamptz default now()
);

alter table materials enable row level security;

-- Drop old policies if re-running
drop policy if exists "Auth users can read" on materials;
drop policy if exists "Auth users can insert" on materials;
drop policy if exists "Auth users can update" on materials;
drop policy if exists "Auth users can delete" on materials;

-- Both admin AND user can do everything on materials
create policy "Auth read materials"   on materials for select to authenticated using (true);
create policy "Auth insert materials" on materials for insert to authenticated with check (true);
create policy "Auth update materials" on materials for update to authenticated using (true);
create policy "Auth delete materials" on materials for delete to authenticated using (true);

-- ═══════════════════════════════════════════════════════════
--  4. MAKE YOURSELF ADMIN
--  Replace the email below with YOUR email, then run.
--  (You must have already signed up / been created as a user.)
-- ═══════════════════════════════════════════════════════════
-- First make sure your profile exists:
insert into public.profiles (id, email, role)
select id, email, 'admin' from auth.users
where email = 'YOUR_EMAIL@example.com'
on conflict (id) do update set role = 'admin';
