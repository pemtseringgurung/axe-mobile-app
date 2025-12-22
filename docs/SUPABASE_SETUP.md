# Supabase Authentication Setup Guide (Google Only)

## Step 1: Create Supabase Project ✅
Already done! Your project URL: `https://aslwlmdtkinrnefsdolk.supabase.co`

---

## Step 2: Get Your API Keys

1. Go to **Project Settings** → **API**
2. Copy these values:

```
SUPABASE_URL = "https://aslwlmdtkinrnefsdolk.supabase.co"
SUPABASE_ANON_KEY = "eyJ..." (copy the long anon/public key)
```

---

## Step 3: Enable Google Auth Provider

1. In Supabase: **Authentication** → **Sign In / Providers**
2. Find **Google** and toggle it **ON**
3. Paste your **Client ID** and **Client Secret** from Google Cloud

### Google Cloud Setup:
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. **APIs & Services** → **OAuth consent screen** → Create (External)
3. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**
4. Type: **Web application**
5. Authorized redirect URI:
   ```
   https://aslwlmdtkinrnefsdolk.supabase.co/auth/v1/callback
   ```
6. Copy **Client ID** and **Client Secret** → paste into Supabase

---

## Step 4: Configure Redirect URL in Supabase

1. Go to **Authentication** → **URL Configuration**
2. Add to **Redirect URLs**:
   ```
   axe://auth-callback
   ```

---

## Step 5: Create Database Tables

Go to **SQL Editor** and run:

```sql
-- Profiles table
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    spending_personality JSONB,
    financial_goals JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## ✅ Checklist

- [x] Supabase project created
- [ ] Copied `SUPABASE_ANON_KEY`
- [ ] Google OAuth configured (Client ID + Secret in Supabase)
- [ ] Redirect URL added: `axe://auth-callback`
- [ ] Profiles table created (SQL above)