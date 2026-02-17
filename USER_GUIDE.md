# Claude Code Bootstrap — User Guide

A practical guide to getting the most out of your bootstrapped Claude Code project. This covers everything from your first session to advanced multi-agent workflows.

---

## Table of Contents

- [Installation & Setup](#installation--setup)
  - [Running the bootstrap script](#running-the-bootstrap-script)
  - [Script options](#script-options)
  - [Stack types](#stack-types)
  - [What gets created](#what-gets-created)
  - [Dry run & uninstall](#dry-run--uninstall)
- [Quick Start](#quick-start)
- [BMAD Agile Planning Workflow](#bmad-agile-planning-workflow)
- [Understanding the Agent System](#understanding-the-agent-system)
  - [User-invoked Agents](#user-invoked-agents)
- [Invoking Agents](#invoking-agents)
  - [Method 1: CLI (new terminal)](#method-1-cli-new-terminal)
  - [Method 2: In-Session Delegation](#method-2-in-session-delegation)
  - [Which method should I use?](#which-method-should-i-use)
- [Identifying Agents](#identifying-agents)
- [The Quality Pipeline](#the-quality-pipeline)
  - [What happens on every edit](#what-happens-on-every-edit)
  - [What happens at end of turn](#what-happens-at-end-of-turn)
  - [The self-correcting loop](#the-self-correcting-loop)
- [Model Allocation](#model-allocation)
- [Workflows](#workflows)
  - [Solo developer workflow](#solo-developer-workflow)
  - [Team workflow](#team-workflow)
  - [CI/CD integration](#cicd-integration)
- [Context Management](#context-management)
- [Customization](#customization)
  - [Changing agent models](#changing-agent-models)
  - [Adding new agents](#adding-new-agents)
  - [Modifying hooks](#modifying-hooks)
  - [Adding MCP servers](#adding-mcp-servers)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Installation & Setup

### Running the bootstrap script

The simplest way to get started — auto-detects your stack and bootstraps the current directory:

```bash
./claude-code-bootstrap.sh
```

Or target a specific project directory:

```bash
./claude-code-bootstrap.sh ./my-project
```

### Script options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--stack STACK` | | Project type (see [Stack types](#stack-types) below) | `auto` |
| `--db-name NAME` | `-d` | PostgreSQL database name (fullstack/backend only) | `myapp` |
| `--db-port PORT` | `-p` | PostgreSQL port (fullstack/backend only) | `5432` |
| `--skip-install` | `-s` | Generate config files only — skip npm/pip dependency installs | `false` |
| `--dry-run` | `-n` | Preview what would be created without writing any files | `false` |
| `--uninstall` | | Remove all files and configs created by this script | — |
| `--help` | `-h` | Show help message | — |

### Stack types

The script tailors its output based on your project's stack. It auto-detects by default, but you can override:

| Stack | What it sets up | Auto-detected when |
|-------|----------------|-------------------|
| `fullstack` | All rules, hooks, MCP servers for frontend + backend + DB | Both `frontend/` and `backend/` dirs exist |
| `frontend` | Frontend-only rules/hooks (shadcn/ui, Tailwind, motion.dev, ESLint, Prettier) | `package.json` with `src/app/` or `next.config.*` found |
| `backend` | Backend-only rules/hooks (FastAPI, SQLAlchemy, Ruff, pytest) | `pyproject.toml` or `requirements.txt` with `app/` dir found |
| `generic` | Stack-agnostic: agents + secrets protection + git hooks only | No frontend or backend indicators detected |
| `auto` | Detect from project files (default) | — |

**Examples:**

```bash
# Explicit stack type
./claude-code-bootstrap.sh --stack fullstack ./my-project
./claude-code-bootstrap.sh --stack frontend ./my-nextjs-app
./claude-code-bootstrap.sh --stack backend ./my-api
./claude-code-bootstrap.sh --stack generic ./my-cli-tool

# Custom database settings (fullstack/backend stacks)
./claude-code-bootstrap.sh -d production_db -p 5433

# Config files only — don't install linters/formatters
./claude-code-bootstrap.sh --skip-install
```

### What gets created

After running the script, your project will have:

```
your-project/
├── CLAUDE.md                           # Root project context (tech stack, commands, rules)
├── frontend/CLAUDE.md                  # Frontend conventions (if fullstack/frontend)
├── backend/CLAUDE.md                   # Backend conventions (if fullstack/backend)
├── .mcp.json                           # MCP server configs (Playwright, Postgres, Context7)
└── .claude/
    ├── settings.json                   # Hooks pipeline + permission deny lists
    ├── agents/
    │   ├── code-reviewer.md            # Quality gate — invoke manually (Sonnet)
    │   ├── security-reviewer.md        # Security scan — invoke manually (Haiku)
    │   ├── ship.md                     # Task: git commit, push, PR
    │   ├── qa.md                       # Task: tests, coverage, E2E
    │   └── ui-review.md               # Task: a11y, responsive, UX (frontend stacks)
    ├── hooks/
    │   ├── end-of-turn-check.sh        # Lint/type check orchestrator
    │   ├── detect-secrets.sh           # PreToolUse secret scanner
    │   └── build-notify.sh             # Audio notification on build/test
    └── rules/
        ├── security.md                 # SQL injection, XSS, auth rules
        ├── frontend/components.md      # shadcn/ui, Lucide, cn() patterns
        ├── frontend/animations.md      # motion.dev conventions
        ├── backend/api.md              # FastAPI async, Depends, Pydantic
        └── backend/database.md         # SQLAlchemy 2.0, Alembic rules
```

The script also installs tooling dependencies (unless `--skip-install`):
- **Frontend**: ESLint, Prettier
- **Backend**: Ruff, Bandit, pip-audit
- **Both**: The corresponding MCP servers

### Dry run & uninstall

**Preview before committing** — see exactly what would be created:

```bash
./claude-code-bootstrap.sh --dry-run
./claude-code-bootstrap.sh --dry-run --stack frontend ./my-app
```

**Remove everything** — cleanly undoes the bootstrap:

```bash
# Preview what would be removed
./claude-code-bootstrap.sh --uninstall --dry-run ./my-project

# Remove all bootstrap files (with confirmation prompt)
./claude-code-bootstrap.sh --uninstall ./my-project
```

Uninstall removes all generated files (`CLAUDE.md`, `.claude/`, `.mcp.json`) and cleans up empty directories. It does **not** uninstall packages (eslint, ruff, bandit, etc.) — remove those manually if needed.

---

## Quick Start

After bootstrapping, start a Claude Code session in your project:

```bash
cd your-project
claude
```

That's it. PostToolUse hooks auto-format and lint every file edit. Use `/project-help` for a quick reference of all agents and commands.

You now have access to several agents you can invoke on demand. Try one:

```
> Use the qa agent to check test coverage
```

You'll see something like:

```
═══════════════════════════════════════════
🧪 QA AGENT (model: sonnet)
═══════════════════════════════════════════
```

This confirms which agent is running and on what model.

---

## BMAD Agile Planning Workflow

Before writing code, use the BMAD planning agents to go from idea to implementation-ready stories. Run them in order:

```
1. analyst       → Interview → docs/briefs/product-brief.md
2. pm            → Brief → docs/prd.md
3. architect     → PRD → docs/architecture.md
4. scrum-master  → PRD + arch → docs/stories/*.md
5. Start coding with implementation-ready stories
```

| Step | Agent | Model | Command | What it produces |
|------|-------|-------|---------|-----------------|
| 1 | **analyst** | Haiku | `claude --agent analyst` | Product brief with personas, scope, metrics |
| 2 | **pm** | Haiku | `claude --agent pm` | PRD with features, user stories, acceptance criteria |
| 3 | **architect** | Sonnet | `claude --agent architect` | Architecture doc with tech stack, data model, API design |
| 4 | **scrum-master** | Haiku | `claude --agent scrum-master` | Individual stories sized for 2-4 hours of work |

Each agent is **dialogue-based** — it interviews you, drafts a document, asks for confirmation, then writes the file. Each checks for prerequisite files and stops with a clear message if they're missing.

**In-session usage:**
```
> Use the analyst agent to start a new product brief
> Have the pm agent create the PRD
> Use the architect to design the system
> Have the scrum-master break it into stories
```

**Tips:**
- You can re-run any agent to update its output (e.g., run `pm` again after scope changes)
- All output goes to `docs/` — commit these artifacts to track project evolution
- Use `/project-help` for a quick reference of all agents and commands

---

## Understanding the Agent System

Your project comes with **9 agents** — 4 BMAD planning agents and 5 quality gate agents:

### User-invoked Agents

These agents run **only when you ask for them**. They each specialize in a specific workflow.

| Agent | Model | When to use | What it does |
|-------|-------|-------------|-------------|
| 🔍 **code-reviewer** | Sonnet | After code changes, before shipping | Reviews quality, OWASP Top 10, N+1 queries, naming conventions |
| 🛡️ **security-reviewer** | Haiku | After code changes, before shipping | Runs Bandit SAST, dependency audit, secret scanning, data flow analysis |
| 🚀 **ship** | Sonnet | Ready to commit and push | Creates feature branch, stages files, generates conventional commit message, pushes, opens PR via `gh` |
| 🧪 **qa** | Sonnet | Before shipping | Runs tests (pytest/vitest), analyzes coverage, generates missing tests, runs E2E if Playwright is available |
| 🎨 **ui-review** | Sonnet | After frontend changes | Reviews accessibility, responsive design, shadcn/ui patterns, motion.dev animations, takes Playwright screenshots |

---

## Invoking Agents

There are **two ways** to invoke task agents. Understanding the difference is key.

### Method 1: CLI (new terminal)

Open a **separate terminal** and run:

```bash
claude --agent ship
claude --agent qa
claude --agent ui-review
claude --agent code-reviewer
claude --agent security-reviewer
```

**What happens:** This starts an entirely new Claude session dedicated to that agent. The agent gets:
- Its own context window (clean, focused)
- The model specified in its config (e.g., Sonnet)
- Only the tools listed in its frontmatter
- Full access to the project filesystem

**Best for:**
- Running agents without interrupting your main coding session
- Long-running tasks (full test suite, comprehensive PR review)
- When you want a clean context devoted entirely to one job

### Method 2: In-Session Delegation

From within your **existing Claude session**, ask naturally:

```
> Use the ship agent to commit and open a PR
> Have the qa agent run the test suite
> Use the code-reviewer to look at my recent changes
> Run the ui-review agent on the dashboard component
```

**What happens:** Claude spawns a **subagent** via the Task tool. The subagent:
- Gets its own isolated context window
- Uses the model from its config (e.g., Sonnet for `ship`, Haiku for `security-reviewer`)
- Runs with its restricted tool set
- Returns a summary to your main session when done

Your main session **keeps its context intact** — the subagent's work doesn't pollute your conversation history.

**Best for:**
- Quick checks mid-session ("run qa before I continue")
- Chaining agents ("review, then ship")
- When you don't want to switch terminals

### Which method should I use?

| Scenario | Recommended Method |
|----------|--------------------|
| Deep focus coding session, ready to ship | **CLI** — open Terminal 2, run `claude --agent ship` |
| Quick test check before continuing work | **In-session** — "use the qa agent to run tests" |
| Comprehensive UI accessibility audit | **CLI** — `claude --agent ui-review` (lots of output) |
| Chain review → test → ship in one flow | **In-session** — ask for each agent sequentially |
| CI/CD pipeline automation | **CLI headless** — `claude -p --agent qa "run tests"` |

---

## Identifying Agents

Every agent prints an **identification banner** when it starts, so you always know:
- **Which** agent is running
- **What model** it's using

```
═══════════════════════════════════════════
🚀 SHIP AGENT (model: sonnet)
═══════════════════════════════════════════
```

Here's the full roster:

| Banner | Agent | Model | Trigger |
|--------|-------|-------|---------|
| 🔍 CODE REVIEWER | `code-reviewer` | Sonnet | User-invoked |
| 🛡️ SECURITY REVIEWER | `security-reviewer` | Haiku | User-invoked |
| 🚀 SHIP AGENT | `ship` | Sonnet | User-invoked |
| 🧪 QA AGENT | `qa` | Sonnet | User-invoked |
| 🎨 UI REVIEW AGENT | `ui-review` | Sonnet | User-invoked |

If you see no banner, the **main agent** (Opus) is working — not a subagent.

---

## The Quality Pipeline

Bootstrap sets up a multi-layered quality pipeline using Claude Code's **hooks system**. Every code change passes through deterministic checks that Claude cannot bypass.

### What happens on every edit

When Claude writes or edits a file, **PostToolUse hooks** fire immediately:

```
Edit file → Prettier auto-format → ESLint auto-fix → ✅ or ❌ back to Claude
                                 → Ruff check + format → ✅ or ❌ back to Claude
```

- **JavaScript/TypeScript** files: Prettier formats, ESLint fixes what it can
- **Python** files: Ruff checks and formats
- If errors remain after auto-fix, they're sent back to Claude (exit code 2) and Claude fixes them

> **Tip:** Run `claude --agent code-reviewer` and `claude --agent security-reviewer` for thorough reviews before shipping.
>
> **Manual lint check:** Run `bash .claude/hooks/end-of-turn-check.sh` for a full project lint/type-check on demand.

### The self-correcting loop

The key mechanism is **exit code 2**. When any hook returns exit code 2:

1. Claude's action is **blocked**
2. The error output is **fed back** to Claude as feedback
3. Claude reads the errors, **fixes the issues**, and retries
4. The hook runs again on the new code
5. This repeats until all checks pass

This means Claude literally **cannot** complete an edit with:
- Lint errors (caught by PostToolUse auto-lint)
- Hardcoded secrets (caught by PreToolUse secret detection)

### What hooks block before Claude even writes

**PreToolUse hooks** prevent dangerous operations:

| Protection | What it blocks |
|-----------|---------------|
| Protected files | Writes to `.env`, `.secret`, `package-lock.json`, `.git/`, `node_modules/` |
| Hardcoded secrets | AWS keys (`AKIA`), API keys (`sk-`, `ghp_`), Slack tokens (`xox`) |
| Branch protection | Direct `git push` to `main` or `master` |

---

## Model Allocation

Bootstrap uses a deliberate model allocation strategy to balance quality and cost:

| Role | Model | Why |
|------|-------|-----|
| **Main coding agent** | Opus (your default) | Complex reasoning, architecture, code generation |
| **Code reviewer** (on demand) | Sonnet | Good for pattern matching and best-practice checks |
| **Security reviewer** (on demand) | Haiku | Fast scanning, regex matching |
| **ship, qa, ui-review** (on demand) | Sonnet | Workflow execution with tool access |

**Only your main coding agent uses Opus.** All other agents run on cheaper models, enforced by the `model:` field in each agent's frontmatter. This keeps costs manageable while maintaining quality where it matters.

**Estimated cost:** ~$6/developer/day or $100–200/month with typical usage.

---

## Workflows

### Solo developer workflow

**Option A: Multi-terminal (recommended for larger features)**

```bash
# Terminal 1: main coding session (Opus)
claude
> Implement user profile page with avatar upload
  ... Claude codes, auto-review runs at end of turn ...
  ... if critical issues found, Claude auto-fixes ...

# Terminal 2: review & ship (Sonnet)
claude --agent ui-review    # reviews a11y, responsive, component patterns
claude --agent qa            # runs tests, generates missing coverage
claude --agent ship          # creates branch, commits, pushes, opens PR
  # → PR: https://github.com/you/repo/pull/42
```

**Option B: Single-session (great for quick iterations)**

```
> Implement user profile page with avatar upload
  ... Claude codes, auto-review runs at end of turn ...

> Use the qa agent to run tests and check coverage
  ═══════════════════════════════════════════
  🧪 QA AGENT (model: sonnet)
  ═══════════════════════════════════════════
  Tests Run: 47 passed, 0 failed
  Coverage: 83% (profile.tsx: 91%, avatar-upload.tsx: 76%)
  Generated: tests/profile.test.tsx

> Use the ship agent to commit and open a PR
  ═══════════════════════════════════════════
  🚀 SHIP AGENT (model: sonnet)
  ═══════════════════════════════════════════
  Branch: feat/user-profile-avatar
  Commit: feat(profile): add user profile page with avatar upload
  PR: https://github.com/you/repo/pull/42
```

### Team workflow

For teams, the bootstrapped configuration is committed to git so everyone gets the same quality pipeline:

```
.claude/
├── agents/              # Shared agent definitions
├── hooks/               # Shared quality hooks
├── rules/               # Shared coding rules
├── settings.json        # Shared hooks + permissions
└── settings.local.json  # Personal overrides (gitignored)
```

Each developer can add personal overrides in `.claude/settings.local.json` without affecting the team config.

### CI/CD integration

Use Claude Code's headless mode (`-p` flag) in CI pipelines:

```bash
# In GitHub Actions or similar
claude -p --agent qa "Run the full test suite and report results"
claude -p --agent security-reviewer "Scan all changed files for security issues"
```

The official [`anthropics/claude-code-action@v1`](https://github.com/anthropics/claude-code-action) GitHub Action supports responding to `@claude` mentions in PRs and issues.

---

## Context Management

Context is Claude Code's most critical resource. Performance degrades non-linearly as the 200K token window fills.

### Best practices

| Practice | Why |
|----------|-----|
| Use `/clear` between unrelated tasks | Stale context wastes tokens on every subsequent message |
| Stop at ~75% context usage | The final 20% of context produces 80% of errors |
| Use `/rename` before clearing | So you can `/resume` the session later if needed |
| Keep CLAUDE.md under 150 lines | Every line is reprocessed with each message |
| Delegate to subagents | They get their own clean context windows |

### The "Document & Clear" pattern

For complex features spanning multiple sessions:

```
> Write your implementation plan to docs/plan-avatar-upload.md
  ... Claude dumps its plan and progress ...

> /rename avatar-upload
> /clear

> Read docs/plan-avatar-upload.md and continue implementing
  ... fresh session with clean context, full plan preserved ...
```

---

## Customization

### Changing agent models

Edit the `model:` field in any agent's frontmatter:

```yaml
# .claude/agents/code-reviewer.md
---
model: sonnet    # change to "haiku", "opus", or "inherit"
---
```

Available values:
- `sonnet` — balanced quality/cost
- `opus` — highest quality, highest cost
- `haiku` — fastest, cheapest
- `inherit` — uses whatever model your main session uses

### Adding new agents

Create a new `.md` file in `.claude/agents/`:

```yaml
# .claude/agents/docs-writer.md
---
name: docs-writer
description: Documentation agent. Use when the user wants to generate or update documentation, READMEs, or API docs.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
---

**FIRST:** Always begin your output with this identification banner:
\```
═══════════════════════════════════════════
📝 DOCS WRITER (model: sonnet)
═══════════════════════════════════════════
\```

You are a documentation specialist. When invoked, analyze the codebase and generate
or update documentation...
```

**Tips for good agent definitions:**
- Write **action-oriented descriptions** — "Use when the user wants to..." helps Claude's auto-delegation match correctly
- Include the **identification banner** so users can see which agent is running
- Restrict **tools** to only what the agent needs (principle of least privilege)
- Set the **model** explicitly — don't rely on `inherit` for specialized agents

### Modifying hooks

Edit `.claude/settings.json` to change what runs on each event:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [{
          "type": "command",
          "command": "your-custom-command-here"
        }]
      }
    ]
  }
}
```

Hook types:
- **PreToolUse** — runs *before* Claude writes (block dangerous actions)
- **PostToolUse** — runs *after* each edit (auto-format, lint)
- **Notification** — runs on permission prompts (audio alerts)

### Adding MCP servers

Edit `.mcp.json` to add new MCP servers:

```json
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost:5432/myapp"]
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {"Authorization": "Bearer ${GITHUB_PAT}"}
    }
  }
}
```

---

## Troubleshooting

### Agent doesn't respond to in-session invocation

**Symptom:** You say "use the ship agent" but Claude handles it directly instead of delegating.

**Fix:** Be more explicit:
```
> Use the ship subagent to commit my changes
> Delegate to the qa agent to run tests
> Invoke the code-reviewer agent on the files I changed
```

If that doesn't work, check that the agent file exists in `.claude/agents/` and has a valid `description:` field in its frontmatter.

### Hooks are running but not blocking issues

**Symptom:** Lint errors get through even though hooks are configured.

**Check:**
1. Ensure the tools are installed (`npx eslint --version`, `ruff --version`)
2. Run the hook command manually to see if it produces output
3. Check that the hook exits with code 2 on errors (not code 1)

### Context fills up too fast

**Symptoms:** Quality degrades, Claude forgets earlier instructions, responses become generic.

**Fix:**
1. Run `/clear` between unrelated tasks
2. Delegate heavy work to subagents (they don't consume your main context)
3. Use `/cost` to monitor token usage
4. Break large features into smaller sessions with the "Document & Clear" pattern

---

## FAQ

**Q: Do the review agents cost money?**
A: Yes. The code-reviewer (Sonnet) and security-reviewer (Haiku) each make API calls when invoked. Since they're now user-invoked (not automatic), you control when they run and the associated costs.

**Q: Can I use agents from other projects?**
A: Yes. You can place agents in `~/.claude/agents/` for user-level agents available in all projects, or use `claude --agents '{...}'` to define agents inline for a single session.

**Q: Do subagents have access to my conversation history?**
A: No. Subagents get their own isolated context window. They inherit `CLAUDE.md` project context, MCP servers, and skills, but **not** your conversation history.

**Q: Can a subagent spawn other subagents?**
A: No. Claude Code enforces a single-level delegation hierarchy — subagents cannot spawn sub-subagents.

**Q: How do I know if the main agent or a subagent is responding?**
A: All agents print an identification banner (e.g., `🚀 SHIP AGENT (model: sonnet)`). If you see no banner, it's your main agent responding.

**Q: What's the difference between agents and skills?**
A: **Agents** are subagents with their own context windows and tool sets — they run independently and return results. **Skills** are instruction files that Claude reads and follows within the current context — they don't spawn a separate agent.

**Q: Can I run agents in the background?**
A: Yes. Ask Claude to "run this in the background" or press `Ctrl+B` to background a running task. Background agents auto-deny permissions not pre-approved.

**Q: How do I see all available agents?**
A: Use the `/agents` command within a Claude session to view, create, edit, and delete agents.
