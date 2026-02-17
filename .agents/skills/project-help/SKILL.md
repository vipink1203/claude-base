---
name: project-help
description: Show project-specific workflow and file guidance for this repository.
---

# Project Help (Codex)

When invoked, provide a concise project guide that includes:

1. A **How to run** section with exact commands:
   - Codex help: `$project-help`
   - Codex planning prompts:
     - `Create docs/briefs/product-brief.md from this feature idea: ...`
     - `Draft docs/prd.md from docs/briefs/product-brief.md`
     - `Draft docs/architecture.md from docs/prd.md`
     - `Break docs/prd.md + docs/architecture.md into docs/stories/*.md`
   - Codex verification prompt:
     - `Run lint/tests relevant to changed files and summarize blockers`
2. Current workflow expectations (plan -> implement -> verify).
3. Where planning docs live (`docs/briefs`, `docs/prd.md`, `docs/architecture.md`, `docs/stories`).
4. Validation expectations (run lint/tests relevant to changed code).
5. Safety constraints (no force push, no direct push to main/master).
6. A short note that Claude/Gemini have separate help entrypoints and should not be run inside Codex.

Reference files:
- `AGENTS.md`
- `README.md`
- `USER_GUIDE.md`
- `docs/help/codex.md`
