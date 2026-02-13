# Project Context

## Tech Stack
- TODO: Add your tech stack here

## Common Commands
- TODO: Add your common commands here

## Rules
- ALWAYS plan before coding. Use Plan Mode for non-trivial features.
- NEVER commit directly to main/master. Create feature branches.
- NEVER hardcode secrets — use environment variables.
- Use `/clear` between unrelated tasks to preserve context quality.
- Stop at ~75% context usage — quality degrades past this point.

## Development Workflow
```
Develop → [Auto: Code Review + Security Scan] → qa agent → ship agent
```

### Automatic (every turn)
- **Code Reviewer** — checks quality, OWASP Top 10, performance (blocks on critical)
- **Security Reviewer** — SAST, dependency audit, secret scanning (blocks on critical)

### User-invoked Agents
**From a separate terminal (new session):**
- `claude --agent qa` — Run tests, generate missing coverage, E2E validation
- `claude --agent ship` — Stage, commit (conventional), push, create PR

**From within an active session (subagent delegation):**
- `Use the qa agent to check test coverage`
- `Use the ship agent to commit and open a PR`
- `Have the code-reviewer look at my recent changes`
