-- ==========================================
-- MUSKFUND: COMPLETE DATABASE SETUP SCRIPT
-- Run this script in the Supabase SQL Editor
-- ==========================================

-- 1. DROP EXISTING TABLES (Optional: Only if resetting completely)
-- DROP TABLE IF EXISTS public.audit_logs CASCADE;
-- DROP TABLE IF EXISTS public.announcements CASCADE;
-- DROP TABLE IF EXISTS public.transactions CASCADE;
-- DROP TABLE IF EXISTS public.portfolios CASCADE;
-- DROP TABLE IF EXISTS public.profiles CASCADE;

-- ==========================================
-- 2. CREATE TABLES
-- ==========================================

-- PROFILES (Users and Admins)
CREATE TABLE public.profiles (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    investor_id     TEXT UNIQUE,
    full_name       TEXT,
    email           TEXT,
    phone           TEXT,
    aadhaar_last_6  TEXT,
    role            TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('admin', 'client')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    notes           TEXT,
    avatar_url      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- PORTFOLIOS (One per client)
CREATE TABLE public.portfolios (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id            UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
    invested_amount      NUMERIC NOT NULL DEFAULT 0,
    current_value        NUMERIC NOT NULL DEFAULT 0,
    monthly_return       NUMERIC,
    lockin_period_months INTEGER,
    withdrawal_date      DATE,
    last_updated         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TRANSACTIONS (History of deposits, withdrawals, returns, etc.)
CREATE TABLE public.transactions (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id              UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    date                   DATE NOT NULL,
    type                   TEXT NOT NULL,
    amount                 NUMERIC NOT NULL DEFAULT 0,
    current_value_snapshot NUMERIC,
    remark                 TEXT,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ANNOUNCEMENTS (Global notices shown to clients)
CREATE TABLE public.announcements (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       TEXT NOT NULL,
    body        TEXT NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- AUDIT LOGS (Admin action tracking)
CREATE TABLE public.audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    client_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action      TEXT NOT NULL,
    details_old JSONB,
    details_new JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==========================================
-- 3. CREATE FUNCTIONS (RPCs)
-- ==========================================

-- Function to check if the current user is an admin
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

-- Function to log an audit event safely
CREATE OR REPLACE FUNCTION public.log_audit(
    p_admin_id UUID,
    p_client_id UUID,
    p_action TEXT,
    p_details_old JSONB,
    p_details_new JSONB
) RETURNS void AS $$
BEGIN
    INSERT INTO audit_logs (admin_id, client_id, action, details_old, details_new)
    VALUES (p_admin_id, p_client_id, p_action, p_details_old, p_details_new);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Custom login function: Find user's email purely by Name or Investor ID
-- (Allows users to change their password and still log in using Name + Custom Password)
CREATE OR REPLACE FUNCTION public.get_investor_email(p_name TEXT, p_secret TEXT)
RETURNS TEXT AS $$
DECLARE
    v_email TEXT;
BEGIN
    SELECT email INTO v_email
    FROM profiles
    WHERE (full_name ILIKE p_name OR investor_id ILIKE p_name)
      AND role = 'client'
    LIMIT 1;
    
    RETURN v_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==========================================
-- 4. STORAGE BUCKET CONFIGURATION (Avatars)
-- ==========================================

-- Create the bucket for profile pictures
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies if they exist (to prevent errors if re-running)
DO $$
BEGIN
  DROP POLICY IF EXISTS "Public Access" ON storage.objects;
  DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
  DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
EXCEPTION
  WHEN undefined_object THEN
    NULL;
END $$;

-- Policy: Anyone can view avatars
CREATE POLICY "Public Access" 
ON storage.objects FOR SELECT 
USING ( bucket_id = 'avatars' );

-- Policy: Only logged-in users can upload a new avatar
CREATE POLICY "Authenticated users can upload avatars" 
ON storage.objects FOR INSERT 
WITH CHECK (
    bucket_id = 'avatars' AND auth.role() = 'authenticated'
);

-- Policy: Users can update their own existing avatar
CREATE POLICY "Users can update their own avatar" 
ON storage.objects FOR UPDATE 
USING (
    bucket_id = 'avatars' AND auth.role() = 'authenticated'
);

-- ==========================================
-- 5. ROW LEVEL SECURITY (RLS) - OPTIONAL BUT RECOMMENDED
-- ==========================================
-- To enable maximum security, you would run these:
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE portfolios ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
-- (Note: Custom policies would be required if RLS is enabled)
