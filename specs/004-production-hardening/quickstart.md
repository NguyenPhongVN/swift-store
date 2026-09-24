# Quickstart: Validation Guide — Production Hardening

**Feature**: specs/004-production-hardening | **Date**: 2026-09-25

Prerequisites: Xcode 26+, iOS simulator. Automated suites run on desktop.

## A. Compile + API gates (every change)

```sh
swift build && swift test                       # desktop build + full suite
xcodebuild -scheme SwiftStore -destination 'generic/platform=iOS Simulator' build
xcodebuild -project Examples/Examples.xcodeproj -scheme Examples \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build

# Public-surface diff: additions only
grep -hn "public " Sources/SwiftStore/*.swift | sort > /tmp/after.txt
diff <(sed 's/^[0-9]*://; s/^ *//' specs/004-production-hardening/public-api-baseline.txt | sort) \
     <(sed 's/^[0-9]*://; s/^ *//' /tmp/after.txt | sort)
```

## B. Single pipeline, correct fan-out (US1 → SC-001) — automated

1. `swift test` — `PipelineFanOutTests`: three instances registered; one synthetic verified outcome broadcast; each instance's state updates exactly once; per-instance event fires exactly once; completion decision recorded once.
2. Manual cross-check on simulator: subscribe `onEvent` on `shared`, create a `make()` instance, purchase once → the purchasing instance reports the event once (not duplicated per instance).

## C. Grace protection (US5 → SC-004)

1. `swift test` — `GraceDecisionTests`: expired + billing-retry → retained; expired + grace window in the future → retained; plain expired → cleared; unexpired → granted; revoked → cleared regardless of grace.
2. Manual (optional): in the StoreKit config editor enable an accelerated renewal + grace period, purchase, force renewal failure — premium remains during the grace window, clears after lapse.

## D. Restore outcome (US2 → SC-002)

1. `swift test` — `RestoreOutcomeTests`: entitlement count 0 → `.nothingToRestore`; count ≥ 1 → `.restored(count:)`.
2. Manual: on simulator, airplane-mode restore → throwing API surfaces failure (no success event); successful restore with purchases → `.restored` and `.restoreFinished` observed.

## E. Concurrency-friendly initialization (US3 → SC-003)

1. Strict-concurrency scratch app (or the demo app in Swift 6 mode):

```swift
let store = SwiftStore.make()
store.initialize { config in
    config.setSubscriptionProductIDs(["sub.month"])
    config.setLifetimeProductIDs(["lifetime"])
}
```

2. Expected: compiles with zero concurrency diagnostics; entitlement behavior identical to `initialize(configuration:)`.

## F. Pending purchases (US4)

1. Docs review: README/doc comments describe Ask-to-Buy flow (`.pending` via platform purchase callbacks; approval resolution arrives as pipeline events).
2. Manual (optional, needs a Family Sharing sandbox tester): initiate Ask to Buy purchase, approve on parent account → purchase event observed after approval.

## G. License (US6)

1. `LICENSE` exists at root (MIT); README references it.
