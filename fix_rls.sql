-- ============================================================
-- MUSKFUND — RLS FIX
-- Run this in Supabase SQL Editor to fix the login issue.
-- Tables are kept. Only policies are replaced.
-- ============================================================

-- ─────────────────────────────────────────────
-- STEP 1: Drop all broken policies
-- ─────────────────────────────────────────────
DROP POLICY IF EXISTS "Admin reads all profiles"              ON public.profiles;
DROP POLICY IF EXISTS "Client reads own profile"              ON public.profiles;
DROP POLICY IF EXISTS "Admin inserts profiles"                ON public.profiles;
DROP POLICY IF EXISTS "New user inserts own profile"          ON public.profiles;
DROP POLICY IF EXISTS "Admin updates profiles"                ON public.profiles;
DROP POLICY IF EXISTS "Admin deletes profiles"                ON public.profiles;

DROP POLICY IF EXISTS "Admin full access portfolios"          ON public.portfolios;
DROP POLICY IF EXISTS "Client reads own portfolio"            ON public.portfolios;

DROP POLICY IF EXISTS "Admin full access transactions"        ON public.transactions;
DROP POLICY IF EXISTS "Client reads own transactions"         ON public.transactions;

DROP POLICY IF EXISTS "Admin full access announcements"       ON public.announcements;
DROP POLICY IF EXISTS "Authenticated reads active announcements" ON public.announcements;

DROP POLICY IF EXISTS "Admin full access audit_log"           ON public.audit_log;


-- ─────────────────────────────────────────────
-- STEP 2: Create a SECURITY DEFINER helper function
-- This checks the role WITHOUT triggering RLS
-- (so there's no infinite loop)
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$;


-- ─────────────────────────────────────────────
-- STEP 3: New clean RLS policies
-- ─────────────────────────────────────────────

-- ── PROFILES ───────────────────────────────────

-- Every authenticated user can read their own profile
-- Admins can read ALL profiles
CREATE POLICY "profiles_select"
    ON public.profiles FOR SELECT
    USING (
        id = auth.uid()
        OR public.get_my_role() = 'admin'
    );

-- Any authenticated user can insert their own profile (needed for signup)
-- Admins can also insert profiles for investors
CREATE POLICY "profiles_insert"
    ON public.profiles FOR INSERT
    WITH CHECK (
        id = auth.uid()
        OR public.get_my_role() = 'admin'
    );

-- Admins can update any profile
CREATE POLICY "profiles_update"
    ON public.profiles FOR UPDATE
    USING (public.get_my_role() = 'admin');

-- Admins can delete any profile
CREATE POLICY "profiles_delete"
    ON public.profiles FOR DELETE
    USING (public.get_my_role() = 'admin');


-- ── PORTFOLIOS ──────────────────────────────────

-- Client sees own portfolio; admin sees all
CREATE POLICY "portfolios_select"
    ON public.portfolios FOR SELECT
    USING (
        client_id = auth.uid()
        OR public.get_my_role() = 'admin'
    );

-- Admin can insert/update/delete portfolios
CREATE POLICY "portfolios_insert"
    ON public.portfolios FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_update"
    ON public.portfolios FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_delete"
    ON public.portfolios FOR DELETE
    USING (public.get_my_role() = 'admin');


-- ── TRANSACTIONS ────────────────────────────────

-- Client sees own transactions; admin sees all
CREATE POLICY "transactions_select"
    ON public.transactions FOR SELECT
    USING (
        client_id = auth.uid()
        OR public.get_my_role() = 'admin'
    );

-- Admin can insert/update/delete transactions
CREATE POLICY "transactions_insert"
    ON public.transactions FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "transactions_update"
    ON public.transactions FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "transactions_delete"
    ON public.transactions FOR DELETE
    USING (public.get_my_role() = 'admin');


-- ── ANNOUNCEMENTS ───────────────────────────────

-- Any logged-in user can read announcements
CREATE POLICY "announcements_select"
    ON public.announcements FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Only admin can create/edit/delete
CREATE POLICY "announcements_insert"
    ON public.announcements FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "announcements_update"
    ON public.announcements FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "announcements_delete"
    ON public.announcements FOR DELETE
    USING (public.get_my_role() = 'admin');


-- ── AUDIT LOG ───────────────────────────────────

-- Only admin can read/write audit logs
CREATE POLICY "audit_log_select"
    ON public.audit_log FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "audit_log_insert"
    ON public.audit_log FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');


-- ─────────────────────────────────────────────
-- DONE. Login should now work correctly.
-- ─────────────────────────────────────────────
