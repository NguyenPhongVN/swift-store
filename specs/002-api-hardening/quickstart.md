# Quickstart: Validation Guide — API Hardening

**Feature**: specs/002-api-hardening | **Date**: 2026-09-25

Prerequisites: Xcode 26+ (Swift 6.2 toolchain), macOS host. No device or simulator needed for the automated suite.

## A. Compile + API gates (every change)

```sh
# 1. Public-surface diff — only additions + deprecation annotations allowed
grep -hn "public " Sources/SwiftStore/*.swift | sort > /tmp/api-after.txt
diff specs/002-api-hardening/public-api-baseline.txt /tmp/api-after.txt

# 2. Desktop build (new gate, enabled by macOS platform declaration)
swift build

# 3. Pure-logic tests from the command line (no network, no store)
swift test

# 4. Example app still builds with zero new warnings
xcodebuild -project Examples/Examples.xcodeproj -scheme Examples \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build

# 5. Package still builds for iOS
xcodebuild -scheme SwiftStore -destination 'generic/platform=iOS Simulator' build
```

## B. Events observable (US1 → SC-001/SC-002)

1. In a scratch app: subscribe to the store's event slot, then run the simulator purchase flow (scheme uses the bundled StoreKit configuration).
2. Expected: entitlement-changed event on purchase; expiry/revoke produces entitlement-changed with inactive state; tampering simulation (unverified) produces the verification-failed event with state unchanged.
3. With no subscriber registered: behavior identical to before (regression gate from spec 001 quickstart §E).

## C. Writable pathway deprecated (US2 → SC-004)

1. In a scratch app: assign through the property-wrapper pathway (`ssState.activeLifeTime = true`).
2. Expected: deprecation warning with guidance; code compiles and runs (state change visible — functional until next major).
3. Read-only usage (`ssState.isPremium`) compiles with no warning.

## D. Standalone instances (US3 → SC-005)

1. `swift test` — instance isolation tests: two factory instances with different configs report independent product lists; neither affects `shared`.
2. Query `isInitialized` before and after initialization on an instance — false then true.

## E. Type safety + validated links (US4)

1. Configure a product with a `ProductID` literal and with a raw string — classification and matching identical (covered by tests too).
2. Set a malformed legal-link string; validated accessor returns absent (no crash); valid string returns the URL.

## F. Restore + management (US5)

1. On simulator: invoke restore (signed-in account) → restore-finished event observed; invoke twice rapidly → no duplicate system prompt.
2. Invoke management presentation with the window scene → system subscription management screen appears.

## G. Deprecation + naming (US6)

1. Classify configured product → lifetime/subscription; unconfigured → unrecognized.
2. Use the old classification value → compiles with deprecation warning, behaves as before.
3. Use `StoreConfiguration` alias and `SSConfiguration` interchangeably.

## H. Change log (US8)

1. Open CHANGELOG.md → latest entry lists all additions/deprecations of this feature and states no removals.
