# MatCalc — Email Invite System Setup

This enables admins to send registration invites by email from inside the app.

---

## Step 1 — Run the database setup

In Supabase → SQL Editor, run the file `1-supabase-setup.sql`.

**Before running**, edit the last line to use YOUR email:
```sql
where email = 'YOUR_EMAIL@example.com'
```
This makes you the admin. Everyone else invited will be a regular user.

---

## Step 2 — Enable email in Supabase

By default Supabase's built-in email is limited (3 emails/hour) and good only for testing. For real use, set up your own SMTP:

1. Supabase → Project Settings → Authentication → SMTP Settings
2. Enable Custom SMTP and enter details from a free provider:
   - **Resend** (resend.com) — 100 emails/day free, easiest
   - **Brevo** (brevo.com) — 300/day free
   - **Gmail SMTP** — works but limited

For testing without SMTP, the built-in email works fine for a few invites.

---

## Step 3 — Configure the invite email template

Supabase → Authentication → Email Templates → "Invite user"

Make sure the confirmation URL points to your app. The default `{{ .ConfirmationURL }}` works — it carries the invite token in the URL hash, which the app reads to show the "Set password" screen.

Also in Authentication → URL Configuration:
- **Site URL:** `https://dearmrkoval-cpu.github.io/Price-calculate/`
- **Redirect URLs:** add `https://dearmrkoval-cpu.github.io/Price-calculate/`

---

## Step 4 — Deploy the Edge Function

The invite is sent through a secure server function (so the admin key never touches the browser).

### Install Supabase CLI
```bash
npm install -g supabase
supabase login
```

### Link your project
```bash
supabase link --project-ref plgnvfzfqmwcrghsteey
```

### Create and deploy the function
```bash
supabase functions new invite-user
# Replace the generated index.ts with the file from supabase-function/index.ts
supabase functions deploy invite-user --no-verify-jwt
```

### Set the secrets (service role key)
Get your service_role key from Supabase → Project Settings → API → service_role (secret).
```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```
(SUPABASE_URL and SUPABASE_ANON_KEY are set automatically.)

---

## Step 5 — Test

1. Log in as admin → you'll see the "✉ Invite user" button (top-right on desktop, in Settings on mobile)
2. Click it, enter an email
3. That person receives an email → clicks the link → opens the app's "Set password" screen → creates a password → gets access as a regular user

---

## How roles work

- **Admin:** can do everything + send invites. Role stored in `profiles` table as `admin`.
- **User:** can do everything except send invites. Default role for all new signups.

To promote someone to admin later, run in SQL Editor:
```sql
update profiles set role = 'admin' where email = 'their@email.com';
```
