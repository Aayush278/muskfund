-- Bypasses Supabase Auth Email Rate Limits by creating the user directly in the database
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.create_investor_direct(
    p_email TEXT,
    p_password TEXT,
    p_full_name TEXT
) RETURNS UUID AS $$
DECLARE
    new_user_id UUID;
    encrypted_pw TEXT;
BEGIN
    -- Hash the password using bcrypt
    encrypted_pw := crypt(p_password, gen_salt('bf'));
    
    -- Generate a new UUID for the user
    new_user_id := gen_random_uuid();
    
    -- Insert directly into auth.users (Bypasses the email system entirely)
    INSERT INTO auth.users (
        id,
        instance_id,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        role,
        aud,
        confirmation_token
    ) VALUES (
        new_user_id,
        '00000000-0000-0000-0000-000000000000',
        p_email,
        encrypted_pw,
        now(),
        '{"provider":"email","providers":["email"]}',
        json_build_object('full_name', p_full_name),
        now(),
        now(),
        'authenticated',
        'authenticated',
        ''
    );
    
    -- Insert identity so login works smoothly
    INSERT INTO auth.identities (
        id,
        user_id,
        provider_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    ) VALUES (
        new_user_id,
        new_user_id,
        new_user_id::text,
        format('{"sub":"%s","email":"%s"}', new_user_id::text, p_email)::jsonb,
        'email',
        now(),
        now(),
        now()
    );

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
