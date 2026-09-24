# Quickstart: Validation Guide — Fix Store Bugs

**Feature**: specs/001-fix-store-bugs | **Date**: 2026-09-24

Prerequisites: Xcode 26+, iOS simulator (iOS 26), repo at `/Users/computer/Desktop/swift-store`.

## A. Compile + public API surface gates (every change)

```sh
# 1. Library builds (zero errors). NOTE: `swift build` is not a valid gate for this
#    iOS-only package — a macOS host build fails because @Observable requires macOS 14
#    while the host default is 12 (pre-existing, by design). Build for iOS instead:
xcodebuild -scheme SwiftStore -destination 'generic/platform=iOS Simulator' build

# 2. Example app builds (zero errors)
xcodebuild -project Examples/Examples.xcodeproj -scheme Examples \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build

# 3. Public-surface diff (Constitution I): must show zero removals / signature changes
grep -hn "public " Sources/SwiftStore/*.swift | sort > /tmp/api-after.txt
# compare against the same listing captured before the change (contracts/public-api.md is the reference)
```

## B. Scenario: legal links open the correct document (US2 → SC-004)

1. In `Examples/Examples/Constants.swift`, temporarily set `termsString` and `privacyString` to two visibly different URLs.
2. Run the Examples scheme on a simulator → open the paywall → tap Terms and Privacy buttons.
3. Expected: Terms opens U1, Privacy opens U2 (previously both opened U1). Revert temp values after check.

## C. Scenario: stable product colors (US3 → SC-003)

1. Run the Examples app → "View Examples" screen lists products with colored crown icons.
2. Stop and relaunch the app 3 times.
3. Expected: each product keeps the same color on every launch (previously re-randomized per process).

## D. Scenario: safe + repeatable initialization (US4 → SC-002)

1. Read-before-init check: in a scratch build, access `SwiftStore.shared.isPremium`, `termsURL`, `productIDs` before calling `initialize`.
   Expected: `false` / `nil` / `[]` — no crash (previously: crash).
2. Repeat-init check: call `initialize` twice at startup, then purchase/restore.
   Expected: each transaction processed exactly once; premium state correct; no duplicated UI updates.

## E. Scenario: entitlement correctness (US1 → SC-001) — StoreKit Transaction Manager

1. Run the Examples scheme (scheme already uses `Examples/SmokeTrack: Daily.storekit`).
2. Purchase the weekly subscription → main screen shows "Premium Active" + Active Plan chip.
3. In Xcode: **Debug → StoreKit → Manage Transactions**. With the config's time rate accelerated (or via the editor), let the subscription expire; alternatively refund (revoke) it.
4. Expected after expiry/refund: status returns to "Free Version" and the Active Plan chip disappears.
5. Cross-product check: purchase lifetime, then expire/refund the subscription transaction in Manage Transactions.
   Expected: premium stays active via lifetime (previously: any expired delivery could clear state).

## F. Scenario: transaction hygiene (US5 → SC-005)

1. Temporarily remove a product id from `Constants.subscriptionIDs`, purchase it, restore the constant, relaunch.
   Expected: the (now unknown) verified transaction does not re-appear for processing on subsequent launches (finished on first delivery); premium state unaffected.

## G. Scenario: documentation accuracy (US6 → SC-007)

1. Open Quick Help (⌥-click) on `SwiftStoreState` members in Xcode.
   Expected: examples reference only existing members; no mention of `consumableCount`/`boughtNonConsumable`; `projectedValue` described as a binding to the store instance.
