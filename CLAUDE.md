# Project Context

## Tech Stack
- Bash (bootstrap script)
- Claude Code agents (markdown with YAML frontmatter)
- Shell hooks (bash scripts for PreToolUse/PostToolUse)

## Common Commands
- `bash claude-code-bootstrap.sh --dry-run` — Preview what would be created
- `bash claude-code-bootstrap.sh --stack generic .` — Bootstrap current dir
- `bash claude-code-bootstrap.sh --agent-platform claude,codex .` — Scaffold multiple agent platforms
- `bash claude-code-bootstrap.sh --uninstall .` — Remove bootstrap files
- `bash -n claude-code-bootstrap.sh` — Syntax-check the script

## Rules
- ALWAYS plan before coding. Use Plan Mode for non-trivial features.
- NEVER commit directly to main/master. Create feature branches.
- NEVER hardcode secrets — use environment variables.
- Use `/clear` between unrelated tasks to preserve context quality.
- Stop at ~75% context usage — quality degrades past this point.

## Development Workflow
```
Plan (BMAD agents) → Develop → code-reviewer / security-reviewer → qa agent → ship agent
```

### BMAD Planning Agents (run in order for new projects/features)
- `claude --agent analyst` — Interview → product brief (`docs/briefs/product-brief.md`)
- `claude --agent pm` — Brief → PRD (`docs/prd.md`)
- `claude --agent architect` — PRD → architecture (`docs/architecture.md`)
- `claude --agent scrum-master` — PRD + arch → stories (`docs/stories/*.md`)

### Quality Gate Agents
**From a separate terminal (new session):**
- `claude --agent code-reviewer` — Quality gate: code quality, OWASP Top 10, performance
- `claude --agent security-reviewer` — SAST, dependency audit, secret scanning
- `claude --agent qa` — Run tests, generate missing coverage, E2E validation
- `claude --agent ship` — Stage, commit (conventional), push, create PR

**From within an active session (subagent delegation):**
- `Use the qa agent to check test coverage`
- `Use the ship agent to commit and open a PR`
- `Have the code-reviewer look at my recent changes`

### Commands
- `/project-help` — List all agents, hooks, and workflows
- See `docs/help/` for provider-specific help references (Claude/Gemini/Codex)

## SDLC Pipeline Commands
Run phases individually or all at once:
- `/sdlc-implement <prd>` — Phase 1: Implement from PRD (spawns implementer subagent)
- `/sdlc-quality` — Phase 2: Lint, format, type check, test (spawns code-quality subagent)
- `/sdlc-security` — Phase 3: Security audit (spawns security-auditor subagent)
- `/sdlc-docs` — Phase 4: Update CHANGELOG, docs, docstrings (spawns doc-updater subagent)
- `/sdlc-ship` — Phase 5: Commit and push (runs inline)
- `/sdlc-all <prd>` — Run all 5 phases in sequence
