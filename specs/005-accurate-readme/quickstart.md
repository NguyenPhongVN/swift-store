# Quickstart: Validation Guide — Accurate README

**Feature**: specs/005-accurate-readme | **Date**: 2026-09-25

## A. Member cross-check (SC-002)

```sh
# Every identifier the README mentions must exist in the library sources:
for id in onEvent StoreEvent make isInitialized hasEntitlement ProductID \
          RestoreOutcome termsLink privacyLink ProductClassification classify \
          StoreConfiguration restore restorePurchases showManageSubscriptions \
          initialize SwiftStoreState SSConfiguration ProductType; do
  grep -rq "$id" Sources/SwiftStore/ && echo "OK  $id" || echo "MISSING  $id"
done
```

## B. Claim scan (SC-004)

```sh
grep -i "consumable" README.md   # must only appear inside an explicit
                                 # "not supported" statement, if at all
grep -i "your-username" README.md && echo "PLACEHOLDER LEFT" || echo "OK"
```

## C. Snippet compile (SC-003)

1. Copy the Quick Start snippet and the observability/restore snippets into a scratch Swift file compiled against the package (`swift build` in a temp SPM project or Xcode playground-style target).
2. Expected: zero compile errors; no force-unwraps in link examples.

## D. Build gates

```sh
swift build && swift test && \
xcodebuild -project Examples/Examples.xcodeproj -scheme Examples \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build
```
