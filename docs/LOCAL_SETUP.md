# Local Setup

This file contains instructions for setting up secrets locally.

## Supabase Configuration

1. Open `axe-mobile-app/Services/SupabaseService.swift`
2. Replace the placeholder values:

```swift
static let url = URL(string: "YOUR_SUPABASE_URL")!
static let anonKey = "YOUR_SUPABASE_ANON_KEY"
```

With your actual Supabase credentials from [supabase.com](https://supabase.com).

## Finding Your Keys

1. Go to your Supabase project dashboard
2. Click **Settings** → **API**
3. Copy:
   - **Project URL** → `YOUR_SUPABASE_URL`
   - **anon public** key → `YOUR_SUPABASE_ANON_KEY`

## ⚠️ Important

Never commit your actual credentials to git. The `.gitignore` file protects:
- `Secrets.swift`
- `.env` files
- `*.xcconfig` files
