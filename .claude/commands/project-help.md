Display this reference guide. Format the output exactly as shown below using markdown.

---

# Project Reference

## Planning Agents (BMAD Workflow)

Run these agents **in order** to go from idea to implementation-ready stories. Each agent interviews you, drafts a document, and writes the output file after your confirmation.

| # | Agent | Model | Output | Prereqs |
|---|-------|-------|--------|---------|
| 1 | **analyst** | Haiku | `docs/briefs/product-brief.md` | None |
| 2 | **pm** | Haiku | `docs/prd.md` | product-brief |
| 3 | **architect** | Sonnet | `docs/architecture.md` | product-brief + prd |
| 4 | **scrum-master** | Haiku | `docs/stories/*.md` | prd + architecture |

**Example — CLI (separate terminal):**
```bash
claude --agent analyst
# ... complete the interview, review the brief ...
claude --agent pm
# ... review the PRD ...
claude --agent architect
# ... review the architecture ...
claude --agent scrum-master
# ... stories are ready, start coding
```

**Example — In-session (within your coding session):**
```
> Use the analyst agent to gather requirements for user authentication
> Have the pm agent create the PRD
> Use the architect to design the system
> Have the scrum-master break it into stories
```

---

## Quality Gate Agents

Run these agents **on demand** to review, test, and ship your code.

| Agent | Model | What it does |
|-------|-------|-------------|
| **code-reviewer** | Sonnet | Code quality, OWASP Top 10, N+1 queries, naming conventions |
| **security-reviewer** | Haiku | SAST scanning, dependency audit, secret detection, data flow analysis |
| **qa** | Sonnet | Run tests, check coverage, generate missing tests, E2E validation |
| **ship** | Sonnet | Stage changes, conventional commit, push, open PR via `gh` |
| **ui-review** | Sonnet | Accessibility, responsive design, component patterns (frontend stacks) |

**Example — Typical development cycle:**
```bash
# Terminal 1: code with Opus
claude
> Implement the login page

# Terminal 2: review and ship with Sonnet
claude --agent code-reviewer      # review quality
claude --agent security-reviewer  # scan for vulnerabilities
claude --agent qa                 # run tests, check coverage
claude --agent ship               # commit, push, open PR
```

**Example — In-session delegation:**
```
> Use the qa agent to run tests and check coverage
> Have the code-reviewer look at my recent changes
> Use the ship agent to commit and open a PR
```

---

## Hooks (automatic — no action needed)

| Hook | Trigger | What it does |
|------|---------|-------------|
| **PreToolUse** | Before any file write | Blocks writes to `.env`/secrets/`.git`, detects hardcoded API keys, blocks push to main/master |
| **PostToolUse** | After each file edit | Auto-formats with Prettier (JS/TS) or Ruff (Python), then auto-lints — errors block and self-correct |
| **Notification** | Permission prompt | Plays a system sound so you know Claude needs input (macOS) |

---

## Manual Lint Check

The full-project lint/type-check script is available on demand:
```bash
bash .claude/hooks/end-of-turn-check.sh
```
Or ask within a session: *"Run the end-of-turn lint check on the project"*

---

## Quick Links

- [User Guide](USER_GUIDE.md) — Full walkthrough of agents, workflows, and best practices
- [README](README.md) — Project overview, setup, and configuration
- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code) — Official documentation
