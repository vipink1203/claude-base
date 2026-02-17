# Codex Help

Use the `$project-help` skill to display Codex-specific project guidance.

Core files:
- `AGENTS.md` — Codex instructions
- `.agents/skills/project-help/SKILL.md` — project help skill
- `README.md` and `USER_GUIDE.md` — shared workflow docs

## How To Run

- Codex help: `$project-help`
- Codex planning prompts:
  - `Create docs/briefs/product-brief.md from this feature idea: ...`
  - `Draft docs/prd.md from docs/briefs/product-brief.md`
  - `Draft docs/architecture.md from docs/prd.md`
  - `Break docs/prd.md + docs/architecture.md into docs/stories/*.md`
- Codex verification prompt:
  - `Run lint/tests relevant to changed files and summarize blockers`

Use Claude/Gemini help only inside those tools (`/project-help` there), not inside Codex.
