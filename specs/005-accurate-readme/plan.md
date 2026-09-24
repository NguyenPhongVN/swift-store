# Implementation Plan: Accurate README (Documentation Correction)

**Branch**: `005-accurate-readme` (label only — commits go directly to `main`) | **Date**: 2026-09-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-accurate-readme/spec.md`

## Summary

Rewrite README.md so every claim, requirement, and snippet matches the shipped library: real repository URL and version, true toolchain requirements, accurate capability scope (subscriptions + lifetime; no consumables; no pre-approval query), complete API reference (events, standalone instances, type-safe identifiers, validated links, restore outcomes, classification, initialization state, deprecations), copy-safe Quick Start using the closure initialization, and behavior guarantees (single pipeline, grace retention, instance isolation). Documentation-only — no source changes.

## Technical Context

**Language/Version**: Documentation for Swift 6.2 package (iOS 17+ / macOS 14+)

**Primary Dependencies**: None added — markdown only

**Storage**: N/A

**Testing**: Documentation gates: member cross-check (every named member exists), snippet compilation check in a scratch context, build gates stay green

**Target Platform**: N/A (readers on macOS with Xcode 26+)

**Project Type**: Docs-only change to `README.md`

**Performance Goals**: N/A

**Constraints**: Zero source-code changes; README in English; link CHANGELOG.md for history instead of duplicating

**Scale/Scope**: 1 file rewritten (`README.md`); artifacts in this directory

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Public API Stability | No code touched | ✅ PASS |
| II–V | No runtime behavior in scope | ✅ PASS |
| VI. Documentation Accuracy | This feature IS the gate — README must match the real public interface and behavior guarantees | ✅ PASS |

**Post-Phase 1 re-check**: contracts/accuracy-contract.md enumerates the members/behaviors the README must cover; the completion gate cross-checks README mentions against it.

## Project Structure

### Documentation (this feature)

```text
specs/005-accurate-readme/
├── plan.md                        # This file
├── research.md                    # Phase 0 output: wrong-claims inventory
├── quickstart.md                  # Phase 1 output
├── contracts/
│   └── accuracy-contract.md       # Phase 1 output: real surface to document
└── tasks.md                       # Phase 2 output (/speckit-tasks)
```

*(No data-model.md — no data entities; documentation change only.)*

### Source Code (repository root)

```text
README.md    # The only modified file
```

**Structure Decision**: Single-file rewrite; no new files.

## Complexity Tracking

> No constitution violations.
