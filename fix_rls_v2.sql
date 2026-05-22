-- ============================================================
-- MUSKFUND — RLS Fix v2
-- Fixes the 403 on profiles by:
-- 1. Granting EXECUTE on get_my_role() to all roles
-- 2. Splitting policies so id=auth.uid() NEVER depends on the function
-- Run this in Supabase SQL Editor
-- ============================================================

-- ─────────────────────────────────────────────
-- STEP 1: Grant execute on the helper function
-- ─────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.get_my_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_role() TO anon;
GRANT EXECUTE ON FUNCTION public.get_my_role() TO service_role;


-- ─────────────────────────────────────────────
-- STEP 2: Drop and recreate policies cleanly
-- Split into TWO separate policies per table so
-- "own row" never depends on the function call
-- ─────────────────────────────────────────────

-- PROFILES
DROP POLICY IF EXISTS "profiles_select"       ON pub-- ============================================================
-- MUSKFUND — RLS Fix v2
-- Fixes the 403 on profiles by:
-- 1. Granting EXECUTE on get_my_role() to all roles
-- 2. Splitting policies so id=auth.uid() NEVER depends on the function
-- Run this in Supabase SQL Editor
-- ============================================================

-- ─────────────────────────────────────────────
-- STEP 1: Grant execute on the helper function
-- ─────────────────────────────────────────────
GRANT EXECUTE ON FUNCTION public.get_my_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_role() TO anon;
GRANT EXECUTE ON FUNCTION public.get_my_role() TO service_role;


-- ─────────────────────────────────────────────
-- STEP 2: Drop and recreate policies cleanly
-- Split into TWO separate policies per table so
-- "own row" never depends on the function call
-- ─────────────────────────────────────────────

-- PROFILES
DROP POLICY IF EXISTS "profiles_select"       ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert"       ON public.profiles;
DROP POLICY IF EXISTS "profiles_update"       ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete"       ON public.profiles;

-- Any user can read their OWN profile (no function call needed)
CREATE POLICY "profiles_select_own"
    ON public.profiles FOR SELECT
    USING (id = auth.uid());

-- Admin can read ALL profiles
CREATE POLICY "profiles_select_admin"
    ON public.profiles FOR SELECT
    USING (public.get_my_role() = 'admin');

-- Any user can insert their own profile (for signup flow)
CREATE POLICY "profiles_insert_own"
    ON public.profiles FOR INSERT
    WITH CHECK (id = auth.uid());

-- Admin can insert any profile (for creating investors)
CREATE POLICY "profiles_insert_admin"
    ON public.profiles FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

-- Admin can update any profile
CREATE POLICY "profiles_update_admin"
    ON public.profiles FOR UPDATE
    USING (public.get_my_role() = 'admin');

-- Admin can delete any profile
CREATE POLICY "profiles_delete_admin"
    ON public.profiles FOR DELETE
    USING (public.get_my_role() = 'admin');


-- PORTFOLIOS
DROP POLICY IF EXISTS "portfolios_select" ON public.portfolios;
DROP POLICY IF EXISTS "portfolios_insert" ON public.portfolios;
DROP POLICY IF EXISTS "portfolios_update" ON public.portfolios;
DROP POLICY IF EXISTS "portfolios_delete" ON public.portfolios;

CREATE POLICY "portfolios_select_own"
    ON public.portfolios FOR SELECT
    USING (client_id = auth.uid());

CREATE POLICY "portfolios_select_admin"
    ON public.portfolios FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_insert_admin"
    ON public.portfolios FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_update_admin"
    ON public.portfolios FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_delete_admin"
    ON public.portfolios FOR DELETE
    USING (public.get_my_role() = 'admin');


-- TRANSACTIONS
DROP POLICY IF EXISTS "transactions_select" ON public.transactions;
DROP POLICY IF EXISTS "transactions_insert" ON public.transactions;
DROP POLICY IF EXISTS "transactions_update" ON public.transactions;
DROP POLICY IF EXISTS "transactions_delete" ON public.transactions;

CREATE POLICY "transactions_select_own"
    ON public.transactions FOR SELECT
    USING (client_id = auth.uid());

CREATE POLICY "transactions_select_admin"
    ON public.transactions FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "transactions_insert_admin"
    ON public.transactions FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "transactions_update_admin"
    ON public.transactions FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "transactions_delete_admin"
    ON public.transactions FOR DELETE
    USING (public.get_my_role() = 'admin');


-- ANNOUNCEMENTS
DROP POLICY IF EXISTS "announcements_select" ON public.announcements;
DROP POLICY IF EXISTS "announcements_insert" ON public.announcements;
DROP POLICY IF EXISTS "announcements_update" ON public.announcements;
DROP POLICY IF EXISTS "announcements_delete" ON public.announcements;

CREATE POLICY "announcements_select_all"
    ON public.announcements FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "announcements_insert_admin"
    ON public.announcements FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "announcements_update_admin"
    ON public.announcements FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "announcements_delete_admin"
    ON public.announcements FOR DELETE
    USING (public.get_my_role() = 'admin');


-- AUDIT LOG
DROP POLICY IF EXISTS "audit_log_select" ON public.audit_log;
DROP POLICY IF EXISTS "audit_log_insert" ON public.audit_log;

CREATE POLICY "audit_log_select_admin"
    ON public.audit_log FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "audit_log_insert_admin"
    ON public.audit_log FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');


-- ─────────────────────────────────────────────
-- DONE. Login should now work.
-- ─────────────────────────────────────────────
lic.profiles;
DROP POLICY IF EXISTS "profiles_insert"       ON public.profiles;
DROP POLICY IF EXISTS "profiles_update"       ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete"       ON public.profiles;

-- Any user can read their OWN profile (no function call needed)
CREATE POLICY "profiles_select_own"
    ON public.profiles FOR SELECT
    USING (id = auth.uid());

-- Admin can read ALL profiles
CREATE POLICY "profiles_select_admin"
    ON public.profiles FOR SELECT
    USING (public.get_my_role() = 'admin');

-- Any user can insert their own profile (for signup flow)
CREATE POLICY "profiles_insert_own"
    ON public.profiles FOR INSERT
    WITH CHECK (id = auth.uid());

-- Admin can insert any profile (for creating investors)
CREATE POLICY "profiles_insert_admin"
    ON public.profiles FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

-- Admin can update any profile
CREATE POLICY "profiles_update_admin"
    ON public.profiles FOR UPDATE
    USING (public.get_my_role() = 'admin');

-- Admin can delete any profile
CREATE POLICY "profiles_delete_admin"
    ON public.profiles FOR DELETE
    USING (public.get_my_role() = 'admin');


-- PORTFOLIOS
DROP POLICY IF EXISTS "portfolios_select" ON public.portfolios;
DROP POLICY IF EXISTS "portfolios_insert" ON public.portfolios;
DROP POLICY IF EXISTS "portfolios_update" ON public.portfolios;
DROP POLICY IF EXISTS "portfolios_delete" ON public.portfolios;

CREATE POLICY "portfolios_select_own"
    ON public.portfolios FOR SELECT
    USING (client_id = auth.uid());

CREATE POLICY "portfolios_select_admin"
    ON public.portfolios FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_insert_admin"
    ON public.portfolios FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_update_admin"
    ON public.portfolios FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "portfolios_delete_admin"
    ON public.portfolios FOR DELETE
    USING (public.get_my_role() = 'admin');


-- TRANSACTIONS
DROP POLICY IF EXISTS "transactions_select" ON public.transactions;
DROP POLICY IF EXISTS "transactions_insert" ON public.transactions;
DROP POLICY IF EXISTS "transactions_update" ON public.transactions;
DROP POLICY IF EXISTS "transactions_delete" ON public.transactions;

CREATE POLICY "transactions_select_own"
    ON public.transactions FOR SELECT
    USING (client_id = auth.uid());

CREATE POLICY "transactions_select_admin"
    ON public.transactions FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "transactions_insert_admin"
    ON public.transactions FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "transactions_update_admin"
    ON public.transactions FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "transactions_delete_admin"
    ON public.transactions FOR DELETE
    USING (public.get_my_role() = 'admin');


-- ANNOUNCEMENTS
DROP POLICY IF EXISTS "announcements_select" ON public.announcements;
DROP POLICY IF EXISTS "announcements_insert" ON public.announcements;
DROP POLICY IF EXISTS "announcements_update" ON public.announcements;
DROP POLICY IF EXISTS "announcements_delete" ON public.announcements;

CREATE POLICY "announcements_select_all"
    ON public.announcements FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "announcements_insert_admin"
    ON public.announcements FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');

CREATE POLICY "announcements_update_admin"
    ON public.announcements FOR UPDATE
    USING (public.get_my_role() = 'admin');

CREATE POLICY "announcements_delete_admin"
    ON public.announcements FOR DELETE
    USING (public.get_my_role() = 'admin');


-- AUDIT LOG
DROP POLICY IF EXISTS "audit_log_select" ON public.audit_log;
DROP POLICY IF EXISTS "audit_log_insert" ON public.audit_log;

CREATE POLICY "audit_log_select_admin"
    ON public.audit_log FOR SELECT
    USING (public.get_my_role() = 'admin');

CREATE POLICY "audit_log_insert_admin"
    ON public.audit_log FOR INSERT
    WITH CHECK (public.get_my_role() = 'admin');


-- ─────────────────────────────────────────────
-- DONE. Login should now work.
-- ─────────────────────────────────────────────
