-- Run this in your Supabase SQL Editor to add the avatar_url column
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
