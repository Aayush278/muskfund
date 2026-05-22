-- Run this script in your Supabase SQL Editor to add the new features

-- 1. Add Aadhaar Last 6 to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS aadhaar_last_6 VARCHAR(6);

-- 2. Add Lock-in Period and Withdrawal Date to portfolios
ALTER TABLE public.portfolios 
ADD COLUMN IF NOT EXISTS lockin_period_months INT DEFAULT 12,
ADD COLUMN IF NOT EXISTS withdrawal_date DATE;

-- 3. Update transactions type to support Profit and Loss explicitly if needed
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_type_check;
ALTER TABLE public.transactions 
ADD CONSTRAINT transactions_type_check 
CHECK (type IN ('Deposit', 'Withdrawal', 'Bonus', 'Return Update', 'Profit', 'Loss'));

-- 4. Create RPC to fetch investor email for custom login
CREATE OR REPLACE FUNCTION public.get_investor_email(p_name text, p_secret text)
RETURNS text
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email text;
BEGIN
  -- p_secret could be investor_id OR aadhaar_last_6
  SELECT email INTO v_email
  FROM public.profiles
  WHERE lower(trim(full_name)) = lower(trim(p_name))
    AND (investor_id = p_secret OR aadhaar_last_6 = p_secret)
  LIMIT 1;
  
  RETURN v_email;
END;
$$ LANGUAGE plpgsql;
