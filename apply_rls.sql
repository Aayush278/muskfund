-- ==========================================
-- MUSKFUND: ROW LEVEL SECURITY (RLS) POLICIES
-- Run this in the Supabase SQL Editor
-- ==========================================

-- 0. Ensure audit_logs exists (fixes the missing relation error)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    client_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action      TEXT NOT NULL,
    details_old JSONB,
    details_new JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1. Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies (to prevent errors if re-run)
DO $$
BEGIN
    DROP POLICY IF EXISTS "Admins can do everything on profiles" ON public.profiles;
    DROP POLICY IF EXISTS "Clients can read their own profile" ON public.profiles;
    DROP POLICY IF EXISTS "Clients can update their own profile" ON public.profiles;
    
    DROP POLICY IF EXISTS "Admins can do everything on portfolios" ON public.portfolios;
    DROP POLICY IF EXISTS "Clients can read their own portfolio" ON public.portfolios;
    
    DROP POLICY IF EXISTS "Admins can do everything on transactions" ON public.transactions;
    DROP POLICY IF EXISTS "Clients can read their own transactions" ON public.transactions;
    
    DROP POLICY IF EXISTS "Admins can do everything on announcements" ON public.announcements;
    DROP POLICY IF EXISTS "Clients can view active announcements" ON public.announcements;
    
    DROP POLICY IF EXISTS "Admins can do everything on audit_logs" ON public.audit_logs;
EXCEPTION
    WHEN undefined_object THEN NULL;
END $$;


-- ==========================================
-- 3. CREATE ADMIN FUNCTION (Required for policies)
-- ==========================================
CREATE OR REPLACE FUNCTION public.check_is_admin()
RETURNS BOOLEAN AS $$
DECLARE
    is_admin BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() AND role = 'admin'
    ) INTO is_admin;
    RETURN is_admin;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==========================================
-- 4. ADMIN POLICIES (Admins have FULL access to everything)
-- ==========================================
CREATE POLICY "Admins can do everything on profiles" ON public.profiles FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on portfolios" ON public.portfolios FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on transactions" ON public.transactions FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on announcements" ON public.announcements FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on audit_logs" ON public.audit_logs FOR ALL USING ( public.check_is_admin() );


-- ==========================================
-- 4. CLIENT POLICIES (Strict isolation: Clients only see their own data)
-- ==========================================

-- Profiles: A client can ONLY view and update their own row.
CREATE POLICY "Clients can read their own profile" ON public.profiles 
FOR SELECT USING ( id = auth.uid() );

CREATE POLICY "Clients can update their own profile" ON public.profiles 
FOR UPDATE USING ( id = auth.uid() );

-- Portfolios: A client can ONLY view their own portfolio.
CREATE POLICY "Clients can read their own portfolio" ON public.portfolios 
FOR SELECT USING ( client_id = auth.uid() );

-- Transactions: A client can ONLY view their own transactions.
CREATE POLICY "Clients can read their own transactions" ON public.transactions 
FOR SELECT USING ( client_id = auth.uid() );

-- Announcements: Clients can read announcements (if they are active).
CREATE POLICY "Clients can view active announcements" ON public.announcements 
FOR SELECT USING ( is_active = TRUE );

-- Note: No client policy for audit_logs. Clients cannot view or touch audit logs at all.
