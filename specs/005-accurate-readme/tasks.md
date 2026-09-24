---
description: "Task list for Accurate README (005)"
---

# Tasks: Accurate README (Documentation Correction)

**Input**: Design documents from `/specs/005-accurate-readme/`

**Prerequisites**: plan.md, spec.md, research.md, contracts/accuracy-contract.md, quickstart.md

**Tests**: Gates are mechanical doc checks (quickstart.md): member cross-check, claim scan, snippet compile, builds.

**Organization**: Documentation-only; `README.md` is the only modified file.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup

- [ ] T001 Establish the accuracy contract from the real public interface (contracts/accuracy-contract.md — captured during planning)

---

## Phase 2: User Story 1 & 2 — Accurate, complete, copy-safe README (Priority: P1)

**Goal**: README matches the shipped library 100% (FR-001..FR-009).

**Independent Test**: quickstart §A–§C gates.

- [x] T002 Rewrite README.md per contracts/accuracy-contract.md and research.md inventory: real repo URL + version 1.0.0 in Installation; true requirements (iOS 17+/macOS 14+, Xcode 26+/Swift 6.2); accurate scope (subscriptions + lifetime, no consumables); Quick Start via closure `initialize { ... }`; observability section (`onEvent` + StoreEvent + Ask to Buy boundary); restore section (`restore()` + legacy call); standalone instances & strict concurrency note; behavior guarantees (single pipeline, product-scoped clearing, grace retention, instance isolation); API reference grouped and complete with deprecations noted; license + changelog links; all snippets copy-safe (validated link accessors, no empty-handler purchase buttons)

---

## Phase 3: Polish & Gates

- [x] T003 Run quickstart §A member cross-check and §B claim scan — all identifiers exist; placeholder URL gone; no unsupported-capability claims
- [x] T004 Run quickstart §C snippet compile and §D build gates — snippets compile; `swift build`, `swift test`, example app build all green
- [x] T005 Record results in Notes

---

## Dependencies

T002 → T003–T005.

## Notes

- Documentation-only: `Sources/`, `Tests/`, and the example app are untouched
- T003 results (2026-09-25): §A member cross-check — all 20 identifiers exist in Sources/SwiftStore; §B claim scan — "consumable" appears only in explicit not-supported statements, placeholder URL gone
- T004 results: §C Quick Start + observability/restore snippets compiled in a scratch SPM app (Build complete); §D `swift test` 21/21, example app BUILD SUCCEEDED
- T005 results: all documentation gates green; README now documents the real public surface per contracts/accuracy-contract.md
