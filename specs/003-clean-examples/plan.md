# Implementation Plan: Clean Up Examples App (Behavior-Preserving Refactor)

**Branch**: `003-clean-examples` (label only — commits go directly to `main`) | **Date**: 2026-09-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-clean-examples/spec.md`

## Summary

Behavior-preserving refactor of the Examples demo app for readability: repeated presentation patterns (fade-in animations, gradient card styling, status blocks in product view styles) each defined once and reused with parameters; shared status views extracted inside the two ProductViewStyle files; unique preview display names; consistent MARK organization. Strict no-deletion contract: every view, style, preview, component, and commented-out block survives; rendered output is identical.

## Technical Context

**Language/Version**: Swift 5 language mode (example app target, Xcode 26 / iOS SDK 27); library untouched

**Primary Dependencies**: SwiftUI, StoreKit (demo surfaces only)

**Storage**: N/A

**Testing**: Compile gates (`xcodebuild` example app + package) with zero errors and no new warnings; preservation inventory check (every struct/preview present); screenshot comparison of main screens before/after; `swift test` library suite must stay green

**Target Platform**: iOS 26 simulator (example app); library unchanged (iOS 17+/macOS 14+)

**Project Type**: Demo app refactor — no library or API changes

**Performance Goals**: N/A — no runtime behavior change

**Constraints**: Zero deletions (views, styles, previews, components, comments); rendered output identical; animation curves/durations/delays carried over verbatim; shadowed duplicate modifiers may keep only the effective (second) application; duplicate preview display names renamed, not removed

**Scale/Scope**: ~13 Swift files in `Examples/Examples/` (+1 possible new helper file); library sources `Sources/SwiftStore/` explicitly out of scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Public API Stability | Library untouched; example-app code is not a public contract (Constitution I explicitly excludes it from driving API decisions) | ✅ PASS |
| II. Entitlement Correctness | No entitlement logic in scope | ✅ PASS |
| III. Deterministic Behavior | Rendering must remain deterministic and identical — core gate of this feature | ✅ PASS |
| IV. Safe Initialization | No initialization code in scope | ✅ PASS |
| V. Transaction Hygiene | No transaction code in scope | ✅ PASS |
| VI. Documentation Accuracy | MARK sections and doc comments must match the refactored structure | ✅ PASS |

**Post-Phase 1 re-check**: contracts/preservation-inventory.md lists every struct, preview, and extension that must survive; the completion gate diffs this inventory against the refactored codebase.

## Project Structure

### Documentation (this feature)

```text
specs/003-clean-examples/
├── plan.md                            # This file
├── research.md                        # Phase 0 output
├── quickstart.md                      # Phase 1 output
├── contracts/
│   └── preservation-inventory.md      # Phase 1 output: everything that must survive
└── tasks.md                           # Phase 2 output (/speckit-tasks)
```

*(No data-model.md: the feature introduces no data entities — it is a presentation refactor.)*

### Source Code (repository root)

```text
Examples/Examples/
├── ExamplesApp.swift                  # MARK organization; commented exploration preserved
├── Constants.swift                    # Grouped sections
├── ContentView.swift                  # Section organization; shared appear-animation helper
├── PaywallView.swift                  # Shared fade-in helper; grouped marketing sections
├── PreviewView.swift                  # Minor organization only
├── SubViews/…
├── SSPreview/…                        # Unique preview names; shadowed modifiers resolved
└── Styles/…                           # Shared status view per style file; organization
```

**Structure Decision**: No new files required unless a helper is shared across files; helpers used by a single file stay private in that file (locality).

## Complexity Tracking

> No constitution violations.
