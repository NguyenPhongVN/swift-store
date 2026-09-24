# Contract: Preservation Inventory — Clean Up Examples App

**Feature**: specs/003-clean-examples | **Date**: 2026-09-25

Everything listed here MUST exist after the refactor (same or better organization; no removals). This inventory is the completion gate (SC-002).

## App entry & screens

| Item | File | Kind |
|---|---|---|
| `ExamplesApp` | ExamplesApp.swift | App entry (incl. commented-out product-ID exploration block) |
| `ContentView` | ContentView.swift | Screen |
| `FeatureRow` | ContentView.swift | Component |
| `InfoRow` | ContentView.swift | Component |
| `PreviewView` | PreviewView.swift | Screen |
| `PaywallView` | PaywallView.swift | Screen |

## Marketing & supporting components

| Item | File | Kind |
|---|---|---|
| `PassMarketingContent` | PaywallView.swift | Screen content |
| `FeatureCard` | PaywallView.swift | Component |
| `BenefitRow` | PaywallView.swift | Component |
| `SkyBackground` | PaywallView.swift | Component |
| `ParticleView` | PaywallView.swift | Component |
| `MarketingPaywallContent` | SubViews/MarketingPaywallContent.swift | Screen content |
| `PremiumFeatureRow` | SubViews/MarketingPaywallContent.swift | Component |
| `BenefitCard` | SubViews/MarketingPaywallContent.swift | Component |
| `PurchaseExample` | SubViews/PurchaseExample.swift | Component (unused, retained) |
| `ProductImage` + `Color.init(hex:)` | SubViews/ProductImage.swift | Component + extension |

## Styles

| Item | File | Kind |
|---|---|---|
| `CustomStoreStyle` | Styles/StoreStyle/CustomStoreStyle.swift | ViewModifier (empty, retained) |
| `ModernCardProductViewStyle` | Styles/ProductViewStyles/ModernCardProductViewStyle.swift | ProductViewStyle (loading/success/failure/unavailable/unknown states) |
| `SpinnerWhenLoadingStyle` | Styles/ProductViewStyles/SpinnerWhenLoadingStyle.swift | ProductViewStyle (loading/success/failure/unavailable/unknown states) |
| `CustomSubscriptionStoreControlStyle` | Styles/SubscriptionStoreControlStyles/CustomSubscriptionStoreControlStyle.swift | SubscriptionStoreControlStyle (incl. unused `selectedOption` state, retained) |
| `SelectionIndicator` | Styles/SubscriptionStoreControlStyles/CustomSubscriptionStoreControlStyle.swift | Component |
| `.priceComparisonButtons` style extension | same file | Static style accessor |

## Previews (15 — names may change, previews may not)

| File | Previews |
|---|---|
| SSStoreView.swift | 3 (compact / regular / large) |
| SSProductView.swift | 5 (two currently named "regular" → must become unique) |
| SSSubscriptionStoreView.swift | 3 |
| CustomSubscriptionStoreControlStyle.swift | 2 |
| ModernCardProductViewStyle.swift | 1 |
| SpinnerWhenLoadingStyle.swift | 1 |

## Patterns to extract (defined once after refactor)

1. Fade-in/offset/spring-delay appear animation (ContentView sections ×4, PaywallView marketing text ×8+, MarketingPaywallContent rows/sections)
2. Card background: gradient fill + gradient stroke + corner radius + shadow (ContentView status card, both ProductViewStyle files)
3. Status presentation: icon-in-tinted-circle + title + message (failure/unavailable/unknown across both ProductViewStyle files)
4. `ProductImage` stable-hex color helper (unchanged from spec 001; retained)

## Verification

`grep -E "^(struct|final class|class|extension) |#Preview" Examples/Examples -r` before vs after: every entry in this inventory present after refactor; preview names unique per file.
