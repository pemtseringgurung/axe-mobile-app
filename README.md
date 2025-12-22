# axe 🪓

> AI-powered behavioral finance app - understand *why* you spend.

## Quick Start

```bash
# Open in Xcode
open axe-mobile-app.xcodeproj

# Run on simulator
⌘ + R
```

## Features

| Feature | Status |
|---------|--------|
| Email Auth | ✅ |
| Google OAuth | ✅ |
| Dark Theme UI | ✅ |
| Budget Tracking | ✅ |
| Transaction Logging | ✅ |
| Profile & Logout | ✅ |
| Supabase Sync | 🔜 |
| AI Insights | 🔜 |

## Tech Stack

- **Frontend**: SwiftUI, iOS 17+
- **Auth**: Supabase Auth
- **Database**: Supabase (planned)
- **AI**: OpenAI GPT-4 (planned)
- **Storage**: UserDefaults (local)

## Project Structure

```
axe-mobile-app/
├── Views/
│   ├── Splash/          # Launch screen
│   ├── Onboarding/      # Welcome flow
│   ├── Auth/            # Login/signup
│   └── Home/            # Main dashboard
├── ViewModels/          # Business logic
├── Models/              # Data models
├── Services/            # API & auth
└── docs/                # Documentation
```

## Docs

- [Product Roadmap](docs/PRODUCT_ROADMAP.md)
- [Design System](docs/DESIGN_SYSTEM.md)
- [Changelog](docs/CHANGELOG.md)
- [Database Setup](docs/DATABASE_SETUP.md)

## License

Private - All rights reserved
