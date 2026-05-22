-- ============================================================
-- CREATE INVESTOR DIRECTLY VIA SQL (FIXED)
-- ============================================================
-- Bypasses email limits entirely. 
-- IMPORTANT: Change the email, password, and name below!
-- ============================================================

DO $$
DECLARE
    new_user_id UUID := gen_random_uuid();
    investor_email TEXT := 'new_inveor@example.com';   -- ⬅️ CHANGE THIS
    investor_pass TEXT := 'Investo123!';                -- ⬅️ CHANGE THIS
    investor_name TEXT := 'Rajesh Kumar';                -- ⬅️ CHANGE THIS
    investor_phone TEXT := '+91 9876543210';             -- ⬅️ CHANGE THIS
    invest_amount NUMERIC := 50000;                      -- ⬅️ CHANGE THIS
    new_investor_id TEXT := 'MFH-' || floor(random() * 900 + 100)::text;
BEGIN

    -- 1. Insert into auth.users (Must use extensions.crypt to avoid schema errors)
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, 
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
        created_at, updated_at, confirmation_token, email_change, 
        email_change_token_new, recovery_token
    ) VALUES (
        new_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
        investor_email, extensions.crypt(investor_pass, extensions.gen_salt('bf')), 
        now(), '{"provider":"email","providers":["email"]}', 
        json_build_object('full_name', investor_name)::jsonb, 
        now(), now(), '', '', '', ''
    );
    
    -- 1.5 Insert into auth.identities (Required for Supabase Auth to work perfectly)
    INSERT INTO auth.identities (
        id, user_id, provider_id, identity_data, provider, created_at, updated_at
    ) VALUES (
        gen_random_uuid(), new_user_id, new_user_id::text, 
        json_build_object('sub', new_user_id, 'email', investor_email)::jsonb, 
        'email', now(), now()
    );

    -- 2. Insert into public.profiles
    INSERT INTO public.profiles (
        id, investor_id, full_name, email, phone, role, is_active
    ) VALUES (
        new_user_id, new_investor_id, investor_name, investor_email, investor_phone, 'client', true
    );

    -- 3. Insert into public.portfolios
    INSERT INTO public.portfolios (
        client_id, invested_amount, current_value, monthly_return, investment_date
    ) VALUES (
        new_user_id, invest_amount, invest_amount, 0, current_date
    );

    -- 4. Insert into public.transactions
    INSERT INTO public.transactions (
        client_id, date, type, amount, current_value_snapshot, remark
    ) VALUES (
        new_user_id, current_date, 'Deposit', invest_amount, invest_amount, 'Initial investment via SQL'
    );

END $$;
