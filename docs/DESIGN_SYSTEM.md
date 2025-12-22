# Design System

## Colors

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#0E0E12` | Main background |
| Surface | `#1A1A1E` | Cards, containers |
| Accent | `#B9FF64` | Buttons, highlights |
| Text Primary | `#FFFFFF` | Main text |
| Text Secondary | `#808080` | Labels, hints |

### SwiftUI
```swift
let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
let surface = Color(red: 26/255, green: 26/255, blue: 30/255)
let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
```

---

## Typography

| Style | Weight | Size | Design |
|-------|--------|------|--------|
| Display | Black | 42pt | Rounded |
| Title | Bold | 26pt | Rounded |
| Body | Medium | 15pt | Rounded |
| Caption | Regular | 12pt | Default |
| Numbers | Semibold | Varies | Monospaced |

---

## Components

### Icons
- Style: **Outline** (SF Symbols without `.fill`)
- Weight: Light
- Container: Circle with 1.5px stroke

### Inputs
- Style: **Underline** (single line below)
- No boxes or borders
- Accent color on focus

### Buttons
- Primary: Accent fill, black text
- Secondary: Outline, white text
- Corner radius: 14px

### Cards
- Background: Surface color
- Corner radius: 18-26px
- No shadows

---

## SF Symbols Used

| Category | Icon |
|----------|------|
| Food | `cup.and.saucer` |
| Transport | `tram` |
| Shopping | `handbag` |
| Fun | `gamecontroller` |
| Bills | `creditcard` |
| Other | `square.grid.2x2` |
