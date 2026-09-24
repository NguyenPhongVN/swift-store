# AGENTS.md — Standing Rules for AI Agents Working on This Repo

## 1. Automatic Spec Kit flow (MANDATORY)

Every development task the user assigns — **new feature, bug fix, or behavioral change** — MUST be implemented through the full Spec Kit flow, **executed automatically end to end without pausing to ask between phases**:

```text
/speckit-specify → /speckit-plan → /speckit-tasks → /speckit-implement
                       (+ /speckit-analyze before implement when the change touches entitlement logic)
```

- The user states the task **once** and receives the finished, verified result: code changed, builds green, quality gates run, `tasks.md` items checked off.
- Do NOT wait for the user to invoke each phase command or confirm between phases.
- This applies **whether or not the user names a speckit command** — a plain task description triggers the flow.
- Non-development requests (questions, code review, commits, quick lookups) do NOT trigger the flow.
- The user may explicitly opt out per task (e.g., "fix directly", "hotfix") — note the opt-out in the feature's `tasks.md`.

## 2. Public API is frozen (NON-NEGOTIABLE)

SwiftStore is a library consumed by **other projects**. Public members are NEVER removed or have signatures changed — **even when unused inside this repo**. The example app not using an API is not evidence it is dead code. Removal requires deprecation first, then a major version. Full rules: `.specify/memory/constitution.md` (Principle I).

## 3. Quality gates before any "done"

- Package (`xcodebuild -scheme SwiftStore -destination 'generic/platform=iOS Simulator' build`) and example app (`xcodebuild -project Examples/Examples.xcodeproj -scheme Examples …`) build with **zero errors**. (`swift build` is not a valid gate — this is an iOS-only package; a macOS host build fails by design.)
- Public-surface diff against baseline: zero removals / signature changes.
- Bug fixes map to a spec requirement (FR-xxx) with a testable acceptance scenario.

## 4. Git workflow — main only (NO feature branches)

- Do NOT create git branches for tasks — no feature branches, no per-task branches. All development happens **directly on `main`**.
- `Feature Branch:` fields in existing `specs/*/plan.md` / `spec.md` documents are historical records of where past work happened, not instructions for future work.
- This is a deliberate standing order from the user (2026-09-24); it overrides any branch-first default.

## 5. Governance

`.specify/memory/constitution.md` is the authoritative rulebook and supersedes anything else. Read it at the start of every task.
