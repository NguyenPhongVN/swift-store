# Quickstart: Validation Guide — Clean Up Examples App

**Feature**: specs/003-clean-examples | **Date**: 2026-09-25

Prerequisites: Xcode 26+, iOS simulator. Library is untouched; `swift test` must stay green.

## A. Build gates (every change)

```sh
# Example app: zero errors, no new warnings
xcodebuild -project Examples/Examples.xcodeproj -scheme Examples \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build

# Library untouched but must stay green
swift build && swift test
```

## B. Preservation gate (SC-002)

```sh
# Every struct/extension/preview must survive (compare against
# contracts/preservation-inventory.md)
grep -rEhn "^(struct|final class|class|extension) |#Preview" Examples/Examples --include="*.swift"
# No file deleted:
git status --short   # expect modifications only; no deletions
```

## C. Visual identity (SC-001)

1. On `main` before refactoring: run the app; screenshot ContentView (settled state), PreviewView (View Examples), PaywallView (Upgrade to Premium). Save the captures.
2. Apply the refactor; rebuild; recapture the same three screens at the same sizes.
3. Expected: layouts, colors, and settled animation states match; entrance animations play with the same curves/delays (carry-over verified numerically as well).

## D. Extraction sanity (SC-003)

1. Search for the fade-in pattern implementation — expect one private modifier/helper per file where used; call sites pass delay/state parameters.
2. Search failure/unavailable/unknown status blocks in each ProductViewStyle file — expect one shared private view per file rendering all three.
3. Duplicate preview names: `grep -rn '#Preview(' Examples/Examples` — expect unique names within each file.
