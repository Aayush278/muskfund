-- MUSKFUND Update Script
-- Run this in your Supabase SQL Editor if you want to keep your existing data

-- 1. Add fields to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS aadhaar_last_6 TEXT;

-- 2. Add fields to portfolios
ALTER TABLE public.portfolios 
ADD COLUMN IF NOT EXISTS lockin_period_months INTEGER,
ADD COLUMN IF NOT EXISTS withdrawal_date DATE;

-- 3. Update transactions type constraint
-- Drop the existing constraint first
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_type_check;

-- Add the new constraint with Profit and Loss
ALTER TABLE public.transactions 
ADD CONSTRAINT transactions_type_check 
CHECK (type IN ('Deposit', 'Withdrawal', 'Bonus', 'Return Update', 'Profit', 'Loss'));

-- 4. Create the custom RPC function for Investor Login
CREATE OR REPLACE FUNCTION public.get_investor_email(p_name TEXT, p_secret TEXT)
RETURNS TEXT AS $$
DECLARE
    v_email TEXT;
BEGIN
    SELECT email INTO v_email
    FROM profiles
    WHERE full_name ILIKE p_name
      AND (aadhaar_last_6 = p_secret OR investor_id = p_secret)
      AND role = 'client'
    LIMIT 1;
    
    RETURN v_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
