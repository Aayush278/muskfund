-- ========================================================================================
-- MUSKFUND: MASTER DATABASE BACKUP & SETUP SCRIPT
-- This script contains the COMPLETE state of your Supabase database, including:
-- Tables, RLS Security Policies, RPC Functions, and Storage Buckets.
-- Keep this file safe! You can run it on any blank Supabase project to recreate MUSKFUND.
-- ========================================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. TABLE CREATION
-- ==========================================

-- A. PROFILES (Stores both Admins and Investors)
CREATE TABLE IF NOT EXISTS public.profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    email       TEXT UNIQUE NOT NULL,
    full_name   TEXT,
    role        TEXT DEFAULT 'client', -- 'admin' or 'client'
    investor_id TEXT UNIQUE,           -- e.g., MFH-001
    avatar_url  TEXT,                  -- Profile picture storage URL
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- B. PORTFOLIOS (Stores Current Capital)
CREATE TABLE IF NOT EXISTS public.portfolios (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id       UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    invested_amount NUMERIC NOT NULL DEFAULT 0,
    current_value   NUMERIC NOT NULL DEFAULT 0,
    last_updated    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- C. TRANSACTIONS (Stores History: Deposits, Withdrawals, Returns)
CREATE TABLE IF NOT EXISTS public.transactions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id               UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    type                    TEXT NOT NULL, -- 'deposit', 'withdrawal', 'bonus', 'return_update'
    amount                  NUMERIC NOT NULL DEFAULT 0,
    date                    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    remark                  TEXT,
    current_value_snapshot  NUMERIC
);

-- D. ANNOUNCEMENTS (Global notices for all investors)
CREATE TABLE IF NOT EXISTS public.announcements (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       TEXT NOT NULL,
    body        TEXT,
    date        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active   BOOLEAN DEFAULT TRUE
);

-- E. AUDIT LOGS (Tracks Admin actions behind the scenes)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    client_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action      TEXT NOT NULL,
    details_old JSONB,
    details_new JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ==========================================
-- 2. RPC FUNCTIONS (Backend Logic)
-- ==========================================

-- Check if the current logged-in user is an Admin
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

-- Get Investor Email by Full Name or Investor ID (Used for custom login flow)
CREATE OR REPLACE FUNCTION public.get_investor_email(p_name TEXT, p_secret TEXT)
RETURNS TEXT AS $$
DECLARE
    v_email TEXT;
BEGIN
    -- ILIKE makes the search case-insensitive!
    SELECT email INTO v_email
    FROM profiles
    WHERE (full_name ILIKE p_name OR investor_id ILIKE p_name)
      AND role = 'client'
    LIMIT 1;
    
    RETURN v_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==========================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ADMIN POLICIES (Admins bypass RLS and can do everything)
CREATE POLICY "Admins can do everything on profiles" ON public.profiles FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on portfolios" ON public.portfolios FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on transactions" ON public.transactions FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on announcements" ON public.announcements FOR ALL USING ( public.check_is_admin() );
CREATE POLICY "Admins can do everything on audit_logs" ON public.audit_logs FOR ALL USING ( public.check_is_admin() );

-- CLIENT POLICIES (Strict isolation: Clients only read their own data)
CREATE POLICY "Clients can read their own profile" ON public.profiles FOR SELECT USING ( id = auth.uid() );
CREATE POLICY "Clients can update their own profile" ON public.profiles FOR UPDATE USING ( id = auth.uid() );
CREATE POLICY "Clients can read their own portfolio" ON public.portfolios FOR SELECT USING ( client_id = auth.uid() );
CREATE POLICY "Clients can read their own transactions" ON public.transactions FOR SELECT USING ( client_id = auth.uid() );
CREATE POLICY "Clients can view active announcements" ON public.announcements FOR SELECT USING ( is_active = TRUE );


-- ==========================================
-- 4. STORAGE SETUP (Profile Pictures)
-- ==========================================

-- Create the "avatars" bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS for the storage.objects table
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Anyone can view the profile pictures
CREATE POLICY "Avatar images are publicly accessible" 
ON storage.objects FOR SELECT 
USING ( bucket_id = 'avatars' );

-- Logged in users can upload a picture, but ONLY with their own user ID as the filename
CREATE POLICY "Users can upload their own avatar" 
ON storage.objects FOR INSERT 
WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.uid() IS NOT NULL 
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can update their own picture
CREATE POLICY "Users can update their own avatar" 
ON storage.objects FOR UPDATE 
USING (
    bucket_id = 'avatars' 
    AND auth.uid() IS NOT NULL 
    AND (storage.foldername(name))[1] = auth.uid()::text
);
