-- Updates the get_investor_email function to ignore the password during lookup
-- This allows investors to change their password and still log in using their Name!

CREATE OR REPLACE FUNCTION public.get_investor_email(p_name TEXT, p_secret TEXT)
RETURNS TEXT AS $$
DECLARE
    v_email TEXT;
BEGIN
    -- Find the email using ONLY their Full Name or Investor ID
    SELECT email INTO v_email
    FROM profiles
    WHERE (full_name ILIKE p_name OR investor_id ILIKE p_name)
      AND role = 'client'
    LIMIT 1;
    
    RETURN v_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
