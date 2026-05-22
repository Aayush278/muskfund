-- ============================================================
-- MUSKFUND — Complete Database Setup
-- Run this entire script in Supabase SQL Editor in one shot
-- ============================================================

-- ─────────────────────────────────────────────
-- 0. DROP existing tables (clean slate)
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS public.audit_log        CASCADE;
DROP TABLE IF EXISTS public.transactions     CASCADE;
DROP TABLE IF EXISTS public.portfolios       CASCADE;
DROP TABLE IF EXISTS public.announcements    CASCADE;
DROP TABLE IF EXISTS public.profiles         CASCADE;


-- ─────────────────────────────────────────────
-- 1. PROFILES
--    One row per user (admin or client)
--    id references auth.users
-- ─────────────────────────────────────────────
CREATE TABLE public.profiles (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    investor_id     TEXT UNIQUE,                        -- e.g. MFH-001
    full_name       TEXT NOT NULL,
    email           TEXT NOT NULL,
    phone           TEXT,
    role            TEXT NOT NULL DEFAULT 'client'      -- 'admin' | 'client'
                        CHECK (role IN ('admin', 'client')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast role-based queries
CREATE INDEX idx_profiles_role       ON public.profiles(role);
CREATE INDEX idx_profiles_investor_id ON public.profiles(investor_id);


-- ─────────────────────────────────────────────
-- 2. PORTFOLIOS
--    One row per client
-- ─────────────────────────────────────────────
CREATE TABLE public.portfolios (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    invested_amount   NUMERIC(15,2) NOT NULL DEFAULT 0,
    current_value     NUMERIC(15,2) NOT NULL DEFAULT 0,
    monthly_return    NUMERIC(6,2)  NOT NULL DEFAULT 0, -- percentage e.g. 2.5
    investment_date   DATE,
    last_updated      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (client_id)  -- one portfolio per client
);

CREATE INDEX idx_portfolios_client_id ON public.portfolios(client_id);


-- ─────────────────────────────────────────────
-- 3. TRANSACTIONS
--    Many rows per client
--    type: 'Deposit' | 'Withdrawal' | 'Bonus' | 'Return Update'
-- ─────────────────────────────────────────────
CREATE TABLE public.transactions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id               UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    date                    DATE NOT NULL,
    type                    TEXT NOT NULL
                                CHECK (type IN ('Deposit','Withdrawal','Bonus','Return Update')),
    amount                  NUMERIC(15,2) NOT NULL DEFAULT 0,
    current_value_snapshot  NUMERIC(15,2) NOT NULL DEFAULT 0,
    remark                  TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_client_id ON public.transactions(client_id);
CREATE INDEX idx_transactions_date       ON public.transactions(date);


-- ─────────────────────────────────────────────
-- 4. ANNOUNCEMENTS
--    Admin posts announcements visible to clients
-- ─────────────────────────────────────────────
CREATE TABLE public.announcements (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       TEXT NOT NULL,
    body        TEXT NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    posted_by   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_announcements_created_at ON public.announcements(created_at DESC);


-- ─────────────────────────────────────────────
-- 5. AUDIT LOG
--    Records every admin action
-- ─────────────────────────────────────────────
CREATE TABLE public.audit_log (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    client_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action      TEXT NOT NULL,   -- e.g. 'CREATE_CLIENT', 'ADD_TRANSACTION', etc.
    old_value   TEXT,            -- JSON string
    new_value   TEXT,            -- JSON string
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_created_at ON public.audit_log(created_at DESC);
CREATE INDEX idx_audit_log_admin_id   ON public.audit_log(admin_id);


-- ─────────────────────────────────────────────
-- 6. ROW LEVEL SECURITY (RLS)
-- ─────────────────────────────────────────────
ALTER TABLE public.profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log     ENABLE ROW LEVEL SECURITY;


-- ── PROFILES policies ──────────────────────────────────────

-- Admin can read all profiles
CREATE POLICY "Admin reads all profiles"
    ON public.profiles FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- Client can read own profile
CREATE POLICY "Client reads own profile"
    ON public.profiles FOR SELECT
    USING (id = auth.uid());

-- Admin can insert profiles (creates investor accounts)
CREATE POLICY "Admin inserts profiles"
    ON public.profiles FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- Admin can update any profile
CREATE POLICY "Admin updates profiles"
    ON public.profiles FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- Admin can delete profiles
CREATE POLICY "Admin deletes profiles"
    ON public.profiles FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- NEW USER can insert their own profile (needed during signup)
CREATE POLICY "New user inserts own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (id = auth.uid());


-- ── PORTFOLIOS policies ────────────────────────────────────

-- Admin can do everything
CREATE POLICY "Admin full access portfolios"
    ON public.portfolios FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- Client reads own portfolio
CREATE POLICY "Client reads own portfolio"
    ON public.portfolios FOR SELECT
    USING (client_id = auth.uid());


-- ── TRANSACTIONS policies ──────────────────────────────────

-- Admin can do everything
CREATE POLICY "Admin full access transactions"
    ON public.transactions FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- Client reads own transactions
CREATE POLICY "Client reads own transactions"
    ON public.transactions FOR SELECT
    USING (client_id = auth.uid());


-- ── ANNOUNCEMENTS policies ─────────────────────────────────

-- Admin can do everything
CREATE POLICY "Admin full access announcements"
    ON public.announcements FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

-- Any authenticated user can read active announcements
CREATE POLICY "Authenticated reads active announcements"
    ON public.announcements FOR SELECT
    USING (auth.uid() IS NOT NULL);


-- ── AUDIT LOG policies ─────────────────────────────────────

-- Admin can read and insert audit logs
CREATE POLICY "Admin full access audit_log"
    ON public.audit_log FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );


-- ─────────────────────────────────────────────
-- 7. CREATE THE ADMIN USER PROFILE
--    ⚠️  IMPORTANT: Run this AFTER you manually
--    create the admin account via Supabase Auth
--    (Authentication > Users > Add User)
--    Then replace the UUID below with the real one.
-- ─────────────────────────────────────────────

-- INSERT INTO public.profiles (id, investor_id, full_name, email, role, is_active)
-- VALUES (
--     'PASTE-ADMIN-UUID-HERE',   -- ← get this from Supabase Auth > Users
--     'MFH-ADMIN',
--     'Admin',
--     'admin@yourdomain.com',    -- ← your admin email
--     'admin',
--     true
-- );


-- ─────────────────────────────────────────────
-- DONE. Tables created:
--   ✅ profiles
--   ✅ portfolios
--   ✅ transactions
--   ✅ announcements
--   ✅ audit_log
-- ─────────────────────────────────────────────
