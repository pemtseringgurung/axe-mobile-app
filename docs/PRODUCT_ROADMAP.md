# axe - Product Roadmap

> **Vision**: AI-powered behavioral finance app that helps users understand *why* they spend.

---

## ✅ Completed

### Authentication
- [x] Email/password signup & login
- [x] Google OAuth
- [x] Auth state persistence
- [x] Profile view with logout

### UI/UX - Modern Minimal Dark Theme
- [x] **SplashView** - Dark theme, accent logo
- [x] **WelcomeView** - Outline circle logo, accent button
- [x] **AuthView** - Dark theme, underline inputs, social buttons
- [x] **HomeView** - Premium dashboard with:
  - Budget card (neon green accent)
  - Category bubbles with progress rings
  - Recent transactions list
  - Floating pill tab bar
- [x] **AddTransactionView** - Outline icons, underline inputs
- [x] **SetupBudgetView** - Quick select amounts, minimal style
- [x] **ProfileView** - Menu items, logout button

### Design System
- Background: `#0E0E12` (dark)
- Accent: `#B9FF64` (neon green)
- Cards: `#1A1A1E`
- Icons: Outline style (SF Symbols)
- Typography: SF Pro Rounded, monospaced digits
- Inputs: Underline style (no boxes)

### Budget Management
- [x] Set monthly budget
- [x] Edit budget amount
- [x] Transaction logging (manual)
- [x] Local data persistence (UserDefaults)

---

## 🎯 Next Up

### Phase 1A: Core Polish
- [ ] Apple Sign-In
- [ ] Face ID / Touch ID
- [ ] Edit/delete transactions
- [ ] Budget categories CRUD
- [ ] Receipt photo OCR

### Phase 1B: Supabase Integration
- [ ] Sync transactions to cloud
- [ ] Multi-device sync
- [ ] RLS security policies

### Phase 2: AI Layer 🧠
- [ ] Weekly spending insights (OpenAI)
- [ ] AI chat assistant
- [ ] Spending pattern analysis
- [ ] Smart notifications

### Phase 3: Growth
- [ ] Savings goals
- [ ] Streaks & achievements
- [ ] Plaid bank connection
- [ ] Subscription tracking

---

## Views Architecture

```
axe-mobile-app/Views/
├── Splash/
│   └── SplashView.swift
├── Onboarding/
│   └── WelcomeView.swift
├── Auth/
│   └── AuthView.swift
└── Home/
    ├── HomeView.swift
    ├── AddTransactionView.swift
    ├── SetupBudgetView.swift
    └── ProfileView.swift
```

---

## Monetization

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | 1 category, basic logging |
| Pro | $4.99/mo | Unlimited, AI insights |
| Pro+ | $9.99/mo | Family, bank sync, API |

---

## Priority This Week

1. **Supabase sync** - Persist data to cloud
2. **Transaction CRUD** - Edit/delete transactions
3. **AI Insights** - OpenAI integration
