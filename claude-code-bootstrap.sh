#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# claude-code-bootstrap.sh
# Scaffolds Claude Code best practices into any project
# Supports: fullstack (Next.js + FastAPI), frontend, backend, generic
# ============================================================================

VERSION="1.0.0"
SCRIPT_NAME="claude-code-bootstrap"

# ── Colors & formatting ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✔${NC}  $1"; }
log_warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error()   { echo -e "${RED}✖${NC}  $1"; }
log_step()    { echo -e "\n${BOLD}${CYAN}━━━ $1 ━━━${NC}\n"; }

# ── Argument parsing ─────────────────────────────────────────────────────────
PROJECT_DIR="."
SKIP_INSTALL=false
DRY_RUN=false
UNINSTALL=false
DB_NAME="myapp"
DB_PORT="5432"
STACK="auto"

usage() {
    cat <<EOF
${BOLD}$SCRIPT_NAME v$VERSION${NC}
Scaffold Claude Code best practices into your project.

${BOLD}Usage:${NC}
  $0 [options] [project-directory]

${BOLD}Options:${NC}
  --stack STACK          Project type: fullstack, frontend, backend, generic, auto (default: auto)
  -d, --db-name NAME     PostgreSQL database name (default: myapp)
  -p, --db-port PORT     PostgreSQL port (default: 5432)
  -s, --skip-install     Skip installing npm/pip dependencies
  -n, --dry-run          Show what would be created without writing files
  --uninstall            Remove all files and configs created by this script
  -h, --help             Show this help message

${BOLD}Stack types:${NC}
  fullstack    Next.js + FastAPI + PostgreSQL (all rules, hooks, MCP servers)
  frontend     Next.js + TailwindCSS + shadcn/ui (frontend rules/hooks only)
  backend      Python + FastAPI + PostgreSQL (backend rules/hooks only)
  generic      Stack-agnostic (agents, secrets protection, git hooks)
  auto         Detect from project files (default)

${BOLD}Examples:${NC}
  $0                              # Auto-detect stack, bootstrap current dir
  $0 --stack generic              # Minimal, stack-agnostic config
  $0 --stack frontend ./my-app    # Frontend-only project
  $0 -d production_db -p 5433     # Custom DB settings (fullstack/backend)
  $0 --skip-install               # Config only, no package installs
  $0 --uninstall ./my-project     # Remove all bootstrap files
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stack) STACK="$2"; shift 2 ;;
        -d|--db-name) DB_NAME="$2"; shift 2 ;;
        -p|--db-port) DB_PORT="$2"; shift 2 ;;
        -s|--skip-install) SKIP_INSTALL=true; shift ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        --uninstall) UNINSTALL=true; shift ;;
        -h|--help) usage ;;
        -*) log_error "Unknown option: $1"; usage ;;
        *) PROJECT_DIR="$1"; shift ;;
    esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# ── Stack detection ──────────────────────────────────────────────────────────
if [[ "$STACK" == "auto" ]]; then
    HAS_FRONTEND=false
    HAS_BACKEND=false

    # Check for frontend indicators
    if [[ -f "$PROJECT_DIR/frontend/package.json" ]] || \
       [[ -f "$PROJECT_DIR/package.json" && -d "$PROJECT_DIR/src/app" ]] || \
       [[ -f "$PROJECT_DIR/next.config.js" ]] || [[ -f "$PROJECT_DIR/next.config.mjs" ]] || [[ -f "$PROJECT_DIR/next.config.ts" ]]; then
        HAS_FRONTEND=true
    fi

    # Check for backend indicators
    if [[ -f "$PROJECT_DIR/backend/pyproject.toml" ]] || \
       [[ -f "$PROJECT_DIR/backend/requirements.txt" ]] || \
       [[ -f "$PROJECT_DIR/pyproject.toml" && -d "$PROJECT_DIR/app" ]]; then
        HAS_BACKEND=true
    fi

    if $HAS_FRONTEND && $HAS_BACKEND; then
        STACK="fullstack"
    elif $HAS_FRONTEND; then
        STACK="frontend"
    elif $HAS_BACKEND; then
        STACK="backend"
    else
        STACK="generic"
    fi
    log_info "Auto-detected stack: ${BOLD}$STACK${NC}"
fi

# Validate stack value
case "$STACK" in
    fullstack|frontend|backend|generic) ;;
    *) log_error "Invalid stack: $STACK (must be fullstack, frontend, backend, or generic)"; exit 1 ;;
esac

# Convenience flags
HAS_FE=false
HAS_BE=false
case "$STACK" in
    fullstack) HAS_FE=true; HAS_BE=true ;;
    frontend)  HAS_FE=true ;;
    backend)   HAS_BE=true ;;
esac

# ── Helpers ──────────────────────────────────────────────────────────────────

write_file() {
    local filepath="$1"
    local content="$2"
    local full_path="$PROJECT_DIR/$filepath"

    if $DRY_RUN; then
        echo -e "  ${DIM}(dry-run)${NC} would create ${CYAN}$filepath${NC}"
        return
    fi

    mkdir -p "$(dirname "$full_path")"
    echo "$content" > "$full_path"
    log_success "Created ${CYAN}$filepath${NC}"
}

write_file_heredoc() {
    local filepath="$1"
    local full_path="$PROJECT_DIR/$filepath"

    if $DRY_RUN; then
        echo -e "  ${DIM}(dry-run)${NC} would create ${CYAN}$filepath${NC}"
        cat > /dev/null  # consume stdin
        return
    fi

    mkdir -p "$(dirname "$full_path")"
    cat > "$full_path"
    log_success "Created ${CYAN}$filepath${NC}"
}

make_executable() {
    if ! $DRY_RUN; then
        chmod +x "$PROJECT_DIR/$1"
    fi
}

# ── Pre-flight checks ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║       Claude Code Bootstrap v${VERSION}                        ║${NC}"
echo -e "${BOLD}${CYAN}║       Claude Code Best Practices Scaffold                 ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_info "Project directory: ${BOLD}$PROJECT_DIR${NC}"
log_info "Project name:      ${BOLD}$PROJECT_NAME${NC}"
log_info "Stack:             ${BOLD}$STACK${NC}"
if $HAS_BE; then
    log_info "Database:          ${BOLD}$DB_NAME${NC} (port $DB_PORT)"
fi
log_info "Skip install:      ${BOLD}$SKIP_INSTALL${NC}"
log_info "Dry run:           ${BOLD}$DRY_RUN${NC}"
echo ""

if [[ ! -d "$PROJECT_DIR" ]]; then
    if $UNINSTALL; then
        log_error "Directory $PROJECT_DIR does not exist. Nothing to uninstall."
        exit 1
    fi
    log_warn "Directory $PROJECT_DIR does not exist. Creating it."
    $DRY_RUN || mkdir -p "$PROJECT_DIR"
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 0. Uninstall — remove all bootstrap files                                ║
# ╚════════════════════════════════════════════════════════════════════════════╝
if $UNINSTALL; then
    echo ""
    log_step "Uninstalling Claude Code Bootstrap"

    # All files/dirs this script creates
    BOOTSTRAP_FILES=(
        "CLAUDE.md"
        "frontend/CLAUDE.md"
        "backend/CLAUDE.md"
        ".mcp.json"
        ".claude/rules/security.md"
        ".claude/rules/frontend/components.md"
        ".claude/rules/frontend/animations.md"
        ".claude/rules/backend/api.md"
        ".claude/rules/backend/database.md"
        ".claude/agents/code-reviewer.md"
        ".claude/agents/security-reviewer.md"
        ".claude/agents/ship.md"
        ".claude/agents/ui-review.md"
        ".claude/agents/qa.md"
        ".claude/hooks/end-of-turn-check.sh"
        ".claude/hooks/detect-secrets.sh"
        ".claude/hooks/build-notify.sh"
        ".claude/settings.json"
        
        # Legacy/renamed files from earlier versions
        ".claude/skills/qa/SKILL.md"
        ".claude/skills/ship/SKILL.md"
        ".claude/skills/ui-review/SKILL.md"
    )

    # Show what will be removed
    FOUND_FILES=()
    for f in "${BOOTSTRAP_FILES[@]}"; do
        if [[ -f "$PROJECT_DIR/$f" ]]; then
            FOUND_FILES+=("$f")
        fi
    done

    if [[ ${#FOUND_FILES[@]} -eq 0 ]]; then
        log_info "No bootstrap files found in $PROJECT_DIR. Nothing to remove."
        exit 0
    fi

    echo -e "  The following files will be ${RED}permanently deleted${NC}:\n"
    for f in "${FOUND_FILES[@]}"; do
        echo -e "    ${RED}x${NC}  $f"
    done
    echo ""

    if $DRY_RUN; then
        log_info "(dry-run) Would remove ${#FOUND_FILES[@]} files. No changes made."
        exit 0
    fi

    echo -en "  ${BOLD}Are you sure? This cannot be undone.${NC} ${DIM}[y/N]${NC} "
    if [[ -t 0 ]]; then
        read -r confirm </dev/tty
    else
        read -r confirm
    fi
    case "$confirm" in
        [Yy]*)
            for f in "${FOUND_FILES[@]}"; do
                rm -f "$PROJECT_DIR/$f"
                log_success "Removed ${CYAN}$f${NC}"
            done

            # Clean up empty directories left behind
            for dir in \
                ".claude/rules/frontend" \
                ".claude/rules/backend" \
                ".claude/rules" \
                ".claude/agents" \
                ".claude/skills/qa" \
                ".claude/skills/ship" \
                ".claude/skills/ui-review" \
                ".claude/skills" \
                ".claude/hooks" \
                ".claude"; do
                if [[ -d "$PROJECT_DIR/$dir" ]]; then
                    # Try to remove empty dir
                    rmdir "$PROJECT_DIR/$dir" 2>/dev/null && \
                    log_success "Removed empty directory ${CYAN}$dir/${NC}" || true
                fi
            done
            
            # Check if .claude still exists
            if [[ -d "$PROJECT_DIR/.claude" ]]; then
                echo ""
                log_warn "Directory ${BOLD}.claude${NC} was not removed because it contains user files:"
                # List files relative to project dir
                (cd "$PROJECT_DIR" && find .claude -maxdepth 2 -not -path '*/.*')
                echo ""
                echo -e "  To remove everything, run: ${BOLD}rm -rf $PROJECT_DIR/.claude${NC}"
            fi

            # Clean gitignore entries we added
            if [[ -f "$PROJECT_DIR/.gitignore" ]]; then
                # Remove our added lines
                sed -i.bak '/# Claude Code local overrides/d;/settings\.local\.json/d;/CLAUDE\.local\.md/d' "$PROJECT_DIR/.gitignore"
                rm -f "$PROJECT_DIR/.gitignore.bak"
                log_success "Cleaned Claude Code entries from ${CYAN}.gitignore${NC}"
            fi

            echo ""
            log_success "${BOLD}Uninstall complete.${NC} Removed ${#FOUND_FILES[@]} files."
            echo ""
            log_info "Note: Installed packages (eslint, ruff, bandit, etc.) were NOT removed."
            log_info "Remove them manually if no longer needed."
            ;;
        *)
            log_info "Uninstall cancelled."
            ;;
    esac
    exit 0
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 1. CLAUDE.md — Root project context                                      ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "1/10 · Root CLAUDE.md"

# Build CLAUDE.md content based on stack
CLAUDE_CONTENT="# Project Context

## Tech Stack"

case "$STACK" in
    fullstack)
        CLAUDE_CONTENT+="
- **Frontend**: Next.js 15 (App Router), TypeScript, TailwindCSS v4, shadcn/ui, motion.dev (Framer Motion), Lucide icons
- **Backend**: Python 3.12+, FastAPI, SQLAlchemy 2.0, Pydantic v2, Alembic migrations
- **Database**: PostgreSQL 16
- **Testing**: Vitest + React Testing Library (frontend), pytest + httpx (backend), Playwright (E2E)
- **Tooling**: ESLint, Prettier, Ruff, pre-commit

## Project Structure
\`\`\`
├── frontend/          # Next.js app
│   ├── src/
│   │   ├── app/       # App Router pages & layouts
│   │   ├── components/# React components (shadcn/ui based)
│   │   ├── lib/       # Utilities, API client, hooks
│   │   └── types/     # TypeScript type definitions
│   └── public/
├── backend/           # FastAPI app
│   ├── app/
│   │   ├── api/       # Route handlers
│   │   ├── models/    # SQLAlchemy models
│   │   ├── schemas/   # Pydantic schemas
│   │   ├── services/  # Business logic
│   │   └── core/      # Config, security, dependencies
│   ├── migrations/    # Alembic migrations
│   └── tests/
└── shared/            # Shared types/contracts
\`\`\`

## Common Commands
- \`cd frontend && pnpm dev\` — Start frontend dev server
- \`cd backend && uvicorn app.main:app --reload\` — Start backend
- \`cd frontend && pnpm test\` — Run frontend tests
- \`cd backend && pytest\` — Run backend tests
- \`cd frontend && pnpm lint\` — Lint frontend
- \`cd backend && ruff check .\` — Lint backend
- \`alembic upgrade head\` — Run DB migrations

## Rules
- ALWAYS plan before coding. Use Plan Mode for non-trivial features.
- NEVER commit directly to main/master. Create feature branches.
- NEVER use f-strings or string formatting in SQL queries.
- NEVER use \`dangerouslySetInnerHTML\` without DOMPurify sanitization.
- NEVER expose secrets via \`NEXT_PUBLIC_\` env vars.
- All API endpoints must use \`async def\` and return Pydantic models.
- All React components must be typed with explicit prop interfaces.
- Use \`/clear\` between unrelated tasks to preserve context quality.
- Stop at ~75% context usage — quality degrades past this point."
        ;;
    frontend)
        CLAUDE_CONTENT+="
- **Frontend**: Next.js 15 (App Router), TypeScript, TailwindCSS v4, shadcn/ui, motion.dev (Framer Motion), Lucide icons
- **Testing**: Vitest + React Testing Library, Playwright (E2E)
- **Tooling**: ESLint, Prettier

## Common Commands
- \`pnpm dev\` — Start dev server
- \`pnpm test\` — Run tests
- \`pnpm lint\` — Lint
- \`pnpm build\` — Production build

## Rules
- ALWAYS plan before coding. Use Plan Mode for non-trivial features.
- NEVER commit directly to main/master. Create feature branches.
- NEVER use \`dangerouslySetInnerHTML\` without DOMPurify sanitization.
- NEVER expose secrets via \`NEXT_PUBLIC_\` env vars.
- All React components must be typed with explicit prop interfaces.
- Use \`/clear\` between unrelated tasks to preserve context quality.
- Stop at ~75% context usage — quality degrades past this point."
        ;;
    backend)
        CLAUDE_CONTENT+="
- **Backend**: Python 3.12+, FastAPI, SQLAlchemy 2.0, Pydantic v2, Alembic migrations
- **Database**: PostgreSQL 16
- **Testing**: pytest + httpx
- **Tooling**: Ruff, pre-commit

## Common Commands
- \`uvicorn app.main:app --reload\` — Start backend
- \`pytest\` — Run tests
- \`ruff check .\` — Lint
- \`alembic upgrade head\` — Run DB migrations

## Rules
- ALWAYS plan before coding. Use Plan Mode for non-trivial features.
- NEVER commit directly to main/master. Create feature branches.
- NEVER use f-strings or string formatting in SQL queries.
- All API endpoints must use \`async def\` and return Pydantic models.
- Use \`/clear\` between unrelated tasks to preserve context quality.
- Stop at ~75% context usage — quality degrades past this point."
        ;;
    generic)
        CLAUDE_CONTENT+="
- TODO: Add your tech stack here

## Common Commands
- TODO: Add your common commands here

## Rules
- ALWAYS plan before coding. Use Plan Mode for non-trivial features.
- NEVER commit directly to main/master. Create feature branches.
- NEVER hardcode secrets — use environment variables.
- Use \`/clear\` between unrelated tasks to preserve context quality.
- Stop at ~75% context usage — quality degrades past this point."
        ;;
esac

# Workflow section is stack-agnostic
CLAUDE_CONTENT+="

## Development Workflow
\`\`\`
Develop → [Auto: Code Review + Security Scan] → qa agent → ship agent
\`\`\`

### Automatic (every turn)
- **Code Reviewer** — checks quality, OWASP Top 10, performance (blocks on critical)
- **Security Reviewer** — SAST, dependency audit, secret scanning (blocks on critical)

### User-invoked Agents
**From a separate terminal (new session):**"

if $HAS_FE; then
    CLAUDE_CONTENT+="
- \`claude --agent ui-review\` — UX/accessibility/responsive review with Playwright screenshots"
fi

CLAUDE_CONTENT+="
- \`claude --agent qa\` — Run tests, generate missing coverage, E2E validation
- \`claude --agent ship\` — Stage, commit (conventional), push, create PR

**From within an active session (subagent delegation):**
- \`Use the qa agent to check test coverage\`
- \`Use the ship agent to commit and open a PR\`
- \`Have the code-reviewer look at my recent changes\`"

write_file "CLAUDE.md" "$CLAUDE_CONTENT"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 2. Subdirectory CLAUDE.md files                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "2/10 · Subdirectory CLAUDE.md files"

if $HAS_FE; then
write_file_heredoc "frontend/CLAUDE.md" <<'CLAUDE_FE'
# Frontend Conventions

## Component Patterns
- Use shadcn/ui primitives as the base — don't reinvent buttons, dialogs, forms.
- Compose with `cn()` utility from `@/lib/utils` for conditional classes.
- Use motion.dev (`<motion.div>`) for animations — keep durations 150–300ms.
- Icons: import from `lucide-react`, never inline SVGs.
- File naming: `kebab-case.tsx` for components, `use-kebab-case.ts` for hooks.

## State & Data
- Server Components by default. Only add `"use client"` when needed.
- Use `@tanstack/react-query` for server state. No manual fetch + useEffect.
- Form handling via `react-hook-form` + `zod` validation.
- Keep API calls in `src/lib/api/` — never fetch directly in components.

## Styling
- TailwindCSS v4 — use CSS variables for theming via shadcn/ui.
- Never use inline `style={}` — always Tailwind classes.
- Responsive: mobile-first (`sm:`, `md:`, `lg:` breakpoints).

## Testing
- Vitest + React Testing Library for unit/component tests.
- Test user behavior, not implementation details.
- E2E: Playwright tests in `e2e/` directory.
CLAUDE_FE
fi

if $HAS_BE; then
write_file_heredoc "backend/CLAUDE.md" <<'CLAUDE_BE'
# Backend Conventions

## API Patterns
- All endpoints use `async def` and FastAPI's `Depends()` for DI.
- Return Pydantic v2 response models — never return raw dicts.
- Use `HTTPException` for errors with appropriate status codes.
- Validate all input via Pydantic schemas with regex/length constraints.
- Prefix internal routes with `/api/v1/`.

## Database
- SQLAlchemy 2.0 async style with `AsyncSession`.
- ALWAYS use ORM methods or `text()` with named params — NEVER f-string SQL.
- Alembic for all schema changes — never modify DB manually.
- Use `select()` statements, not legacy `Query` API.

## Security
- Parameterized queries only. No exceptions.
- Hash passwords with `passlib[bcrypt]`.
- JWT tokens via `python-jose` with short expiry.
- CORS: explicit origin allowlist, never `allow_origins=["*"]` in production.

## Testing
- pytest with `httpx.AsyncClient` for API tests.
- Use factory fixtures, not raw SQL test data.
- Target: 80%+ coverage on `services/` and `api/` directories.
CLAUDE_BE
fi

if [[ "$STACK" == "generic" ]]; then
    log_info "Generic stack — no subdirectory CLAUDE.md files needed."
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 3. Rules directory (path-scoped)                                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "3/10 · Path-scoped rules"

write_file_heredoc ".claude/rules/security.md" <<'RULE_SEC'
# Security Rules

## SQL Injection Prevention
- DO: Use SQLAlchemy ORM methods: `db.query(User).filter(User.id == uid)`
- DO: Use parameterized raw SQL: `text("SELECT * FROM users WHERE id = :id")`
- DON'T: Use f-strings in SQL: `f"SELECT * FROM users WHERE id = {uid}"`
- WHY: SQL injection is the #1 most exploited vulnerability.

## XSS Prevention
- DO: Let React's JSX auto-escape handle user input: `{userInput}`
- DO: Sanitize with DOMPurify before `dangerouslySetInnerHTML`
- DON'T: Pass user input to `href` without protocol validation
- DON'T: Prefix secrets with `NEXT_PUBLIC_` — these are bundled client-side

## Authentication
- DO: Use short-lived JWTs (15 min access, 7 day refresh)
- DO: Hash passwords with bcrypt (min 12 rounds)
- DON'T: Store tokens in localStorage — use httpOnly cookies
- DON'T: Log tokens, passwords, or PII

## Dependency Security
- Run `npm audit` and `pip-audit` before every release
- Pin exact dependency versions in production
- Review changelogs for major version bumps
RULE_SEC

if $HAS_FE; then
write_file_heredoc ".claude/rules/frontend/components.md" <<'RULE_COMP'
---
paths:
  - "frontend/src/components/**/*.tsx"
  - "frontend/src/components/**/*.ts"
---
# Component Rules

- Every component file exports a single named component matching the filename.
- Props interface is defined above the component: `interface ButtonProps { ... }`
- Use `cn()` from `@/lib/utils` for merging Tailwind classes.
- shadcn/ui components go in `components/ui/` — custom components alongside.
- Use `React.forwardRef` when wrapping native elements.
- Keep components under 150 lines — extract sub-components if larger.
- Animations: use motion.dev `<motion.div>` with layout animations where applicable.
- Icons: `import { IconName } from "lucide-react"` — size via `size` prop, not CSS.
RULE_COMP

write_file_heredoc ".claude/rules/frontend/animations.md" <<'RULE_ANIM'
---
paths:
  - "frontend/src/**/*.tsx"
---
# Animation Conventions (motion.dev)

- Import from `"motion/react"` (motion.dev v11+), not `"framer-motion"`.
- Standard durations: micro (150ms), normal (250ms), emphasis (400ms).
- Use `layout` prop for layout animations on lists and grids.
- Prefer `AnimatePresence` with `mode="wait"` for page transitions.
- Entry animations: `initial={{ opacity: 0, y: 8 }}` → `animate={{ opacity: 1, y: 0 }}`
- Use spring physics for interactive elements: `transition={{ type: "spring", stiffness: 300, damping: 24 }}`
- Reduce motion: always wrap in `useReducedMotion()` check for accessibility.
RULE_ANIM
fi

if $HAS_BE; then
write_file_heredoc ".claude/rules/backend/api.md" <<'RULE_API'
---
paths:
  - "backend/app/api/**/*.py"
---
# API Endpoint Rules

- All endpoints must use `async def`.
- Use `Depends()` for authentication, database sessions, and shared logic.
- Return Pydantic response models — annotate return type: `-> UserResponse`.
- Use `status_code=201` for creation endpoints.
- Pagination: accept `skip: int = 0, limit: int = Query(default=20, le=100)`.
- Error responses: `HTTPException(status_code=404, detail="User not found")`.
- Group routes with `APIRouter(prefix="/api/v1/users", tags=["users"])`.
RULE_API

write_file_heredoc ".claude/rules/backend/database.md" <<'RULE_DB'
---
paths:
  - "backend/app/models/**/*.py"
  - "backend/app/services/**/*.py"
  - "backend/migrations/**/*.py"
---
# Database Rules

- Use SQLAlchemy 2.0 `Mapped[]` type annotations for all model columns.
- Every model has `id`, `created_at`, `updated_at` columns via a `BaseMixin`.
- Relationships use `Mapped[list["Child"]]` with `back_populates`.
- Service layer handles business logic — routes should only call service methods.
- Alembic migrations: always generate with `--autogenerate`, then review before applying.
- NEVER modify the database schema manually — always through Alembic.
- Use `select()` statements, not legacy `session.query()`.
RULE_DB
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 4. Task agents (user-invoked)                                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "4/10 · Task agents"

write_file_heredoc ".claude/agents/ship.md" <<'AGENT_SHIP'
---
name: ship
description: Git shipping agent. Use when the user wants to commit, push, open a PR, or ship their changes. Stage, commit with conventional messages, push, and create pull requests.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Ship — Git Manager

**FIRST:** Always begin your output with this identification banner:
```
═══════════════════════════════════════════
🚀 SHIP AGENT (model: sonnet)
═══════════════════════════════════════════
```

You are a Git Manager agent. Execute the following workflow:

## Pre-flight
1. Run `git status` and `git diff --stat` to understand what changed.
2. If on `main` or `master`, create a feature branch:
   - Derive name from changes: `feat/<topic>`, `fix/<topic>`, or `chore/<topic>`
   - Run `git checkout -b <branch-name>`

## Stage & Commit
3. Stage relevant files with `git add <files>` (never `git add .` blindly — review first).
4. Generate a **conventional commit** message from the diff:
   - Format: `type(scope): description` (e.g., `feat(auth): add JWT refresh token rotation`)
   - Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`
   - Keep subject under 72 chars. Add body if changes are non-trivial.
5. Commit: `git commit -m "<message>"`

## Push & PR
6. Push: `git push -u origin HEAD`
7. Create PR via `gh pr create`:
   - Title: same as commit subject (or summarized if multiple commits)
   - Body: structured summary with `## Summary`, `## Changes`, `## Test plan`
   - Add relevant labels if `gh label list` shows matching ones
8. Report the PR URL to the user.

## Safety Rules
- NEVER force push.
- NEVER push to main/master directly.
- If tests are failing, warn the user and ask whether to proceed.
- If there are unstaged changes the user might want, ask before committing partial work.
AGENT_SHIP

if $HAS_FE; then
write_file_heredoc ".claude/agents/ui-review.md" <<'AGENT_UI'
---
name: ui-review
description: UI/UX review agent. Use when the user wants a frontend review, accessibility audit, responsive design check, or component architecture review.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# UI Review — UX/UI Expert

**FIRST:** Always begin your output with this identification banner:
```
═══════════════════════════════════════════
🎨 UI REVIEW AGENT (model: sonnet)
═══════════════════════════════════════════
```

You are a UX/UI Expert agent. Review frontend code for design quality, accessibility, and adherence to project conventions.

## Component Architecture
- Verify shadcn/ui primitives are used as base components (not custom reimplementations).
- Check composition patterns: `cn()` usage, proper prop forwarding, `React.forwardRef` where needed.
- Ensure components are under 150 lines; suggest extraction if larger.
- Verify single named export per file matching filename.

## Accessibility (a11y)
- Check all interactive elements have ARIA labels or accessible text.
- Verify keyboard navigation: focusable elements, tab order, Escape to close modals.
- Check color contrast meets WCAG 2.1 AA (4.5:1 for text, 3:1 for large text).
- Ensure form inputs have associated `<label>` elements.
- Check `alt` text on images, `role` attributes on custom widgets.

## Responsive Design
- Verify mobile-first approach: base styles for mobile, `sm:`, `md:`, `lg:` for larger screens.
- Check no fixed pixel widths that break on small screens.
- Verify touch targets are at least 44x44px on mobile.
- Test layout doesn't overflow horizontally on 320px viewport.

## Animation & Motion (motion.dev)
- Verify imports from `"motion/react"` (not `"framer-motion"`).
- Check durations: micro (150ms), normal (250ms), emphasis (400ms).
- Verify `useReducedMotion()` wraps all animations for accessibility.
- Check `AnimatePresence` with `mode="wait"` for page/route transitions.
- Verify spring physics for interactive elements: `type: "spring"`, `stiffness: 300`, `damping: 24`.

## Tailwind & Styling
- No inline `style={}` — always Tailwind classes.
- CSS variables via shadcn/ui theming (not hardcoded colors).
- Verify dark mode support if theme toggle exists.
- Check consistent spacing scale usage.

## Visual Verification (if Playwright MCP available)
- Navigate to `http://localhost:3000` (or the relevant route).
- Take screenshots at mobile (375px), tablet (768px), and desktop (1280px) widths.
- Verify visual output matches component intent.

## Output Format
Report findings as:
- **Critical**: Accessibility violations, broken layouts, missing keyboard support
- **Warning**: Inconsistent patterns, missing responsive breakpoints, hardcoded colors
- **Suggestion**: Animation improvements, component extraction opportunities, design polish
AGENT_UI
fi

write_file_heredoc ".claude/agents/qa.md" <<'AGENT_QA'
---
name: qa
description: QA and testing agent. Use when the user wants to run tests, check coverage, generate missing tests, or validate quality before shipping.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
---

# QA — Testing Expert

**FIRST:** Always begin your output with this identification banner:
```
═══════════════════════════════════════════
🧪 QA AGENT (model: sonnet)
═══════════════════════════════════════════
```

You are a QA Expert agent. Run comprehensive testing and generate missing test coverage.

## 1. Analyze Scope
- Run `git diff --name-only HEAD~1` (or vs. main) to identify changed files.
- Categorize changes: frontend components, API endpoints, services, models, utilities.
- Map each changed file to its expected test file location.

## 2. Run Existing Tests
- **Backend**: `cd backend && pytest -x -q --tb=short`
- **Frontend**: `cd frontend && pnpm test --run`
- Capture and report results. If tests fail, diagnose the root cause.

## 3. Coverage Analysis
- **Backend**: `cd backend && pytest --cov=app --cov-report=term-missing -q`
- **Frontend**: `cd frontend && pnpm test --run --coverage`
- Identify uncovered code paths in changed files.

## 4. Generate Missing Tests
For each uncovered path in changed files, write tests following project conventions:

### Backend Tests (pytest + httpx)
- Place in `backend/tests/` mirroring source structure.
- Use `AsyncClient` for API tests, factory fixtures for test data.
- Test: happy path, validation errors, auth failures, edge cases.
- Use `@pytest.mark.asyncio` for async tests.

### Frontend Tests (Vitest + React Testing Library)
- Place in `__tests__/` alongside components or in `frontend/src/__tests__/`.
- Test user behavior: render, interact, assert visible output.
- Mock API calls with `vi.mock()`, not implementation details.
- Test: renders correctly, handles user input, shows error states, loading states.

## 5. E2E Tests (if Playwright MCP available)
- For user-facing flows affected by changes, run or create Playwright tests.
- Place in `frontend/e2e/` or `e2e/` directory.
- Cover critical user journeys: login, form submission, navigation.

## 6. Final Report
Output a structured report:
- **Tests Run**: total passed / failed / skipped
- **Coverage**: percentage for changed files (highlight < 80%)
- **Generated Tests**: list of new test files created
- **Blockers**: any critical failures that should block shipping
- **Warnings**: flaky tests, slow tests (> 5s), low coverage areas

## Safety Rules
- NEVER delete existing tests.
- NEVER modify source code — only create/modify test files.
- If a test fails due to a bug in source code, report the bug rather than making the test pass around it.
AGENT_QA

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 5. Agents                                                                ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "5/10 · Custom agents"

write_file_heredoc ".claude/agents/code-reviewer.md" <<'AGENT_REVIEW'
---
name: code-reviewer
description: Automatic code review agent. Proactively reviews code for quality, security, and performance. Use after writing or modifying code, or when the user asks for a code review.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
---

**FIRST:** Always begin your output with this identification banner:
```
═══════════════════════════════════════════
🔍 CODE REVIEWER (model: sonnet)
═══════════════════════════════════════════
```

You are a senior code reviewer that runs automatically at the end of every Claude turn. Your job is to catch issues before they accumulate.

## What to Review
Analyze all files modified in the current session. Use `git diff` or `git diff --cached` to identify changes.

## Code Quality Checks
- Functions over 50 lines or components over 150 lines
- Hardcoded values that should be constants or env vars
- Bare `except:` or swallowed errors (empty catch blocks)
- Naming inconsistencies with project conventions (kebab-case files, PascalCase components)
- Missing type annotations on function signatures (TypeScript `any`, Python without type hints)

## Security Checks (OWASP Top 10)
- SQL injection: f-strings or string concatenation in queries
- XSS: unsanitized `dangerouslySetInnerHTML`, unvalidated `href` attributes
- CSRF: missing token validation on state-changing endpoints
- Broken auth: hardcoded tokens, missing auth middleware, JWT without expiry
- Sensitive data exposure: secrets in code, PII in logs

## Performance Checks
- N+1 query patterns (loop with DB calls, missing `selectinload`/`joinedload`)
- Missing error handling in async operations
- Blocking calls in async handlers (`time.sleep`, sync file I/O)
- React: missing `key` props in lists, unnecessary re-renders

## Output Format
Produce a structured report. ONLY report issues you are confident about:

```
## Code Review Report

### Critical (blocks turn if exit code 2)
- [file:line] Description of critical issue

### Warning
- [file:line] Description of warning

### Suggestion
- [file:line] Description of improvement
```

If there are Critical findings, exit with code 2 to block the turn.
If there are only Warnings or Suggestions, exit with code 0 and print the report.
If everything looks clean, print "No issues found." and exit 0.
AGENT_REVIEW

write_file_heredoc ".claude/agents/security-reviewer.md" <<'AGENT_SEC'
---
name: security-reviewer
description: Automatic security scanning agent. Scans code for vulnerabilities, hardcoded secrets, SQL injection, and auth weaknesses. Use after code changes or when the user asks for a security review.
model: haiku
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

**FIRST:** Always begin your output with this identification banner:
```
═══════════════════════════════════════════
🛡️ SECURITY REVIEWER (model: haiku)
═══════════════════════════════════════════
```

You are an automated security reviewer that runs at the end of every Claude turn, parallel with the code reviewer. Focus on high-confidence, exploitable findings only.

## Automated Scans
Run these tools on changed files (skip if tool not installed):

1. **Python SAST**: `bandit -r backend/app/ -q -ll` (HIGH confidence only)
2. **Python Deps**: `pip-audit --desc 2>/dev/null` (if pip-audit available)
3. **JS Deps**: `cd frontend && pnpm audit --audit-level=high 2>/dev/null` (if frontend exists)

## Pattern Scanning (on changed files only)
4. **Hardcoded secrets**: Scan for AWS keys (`AKIA`), API keys (`sk-`, `ghp_`, `gho_`), Slack tokens (`xox`), passwords assigned to string literals.
5. **SQL injection vectors**: f-strings or `.format()` in SQL query strings.
6. **Auth weaknesses**: JWT without expiry check, bcrypt rounds < 12, `allow_origins=["*"]` in CORS config.
7. **Data flow**: Trace user input from request params through to database queries or HTML output. Flag only if there is no sanitization in the path.

## Reporting Rules
- Report ONLY verified, exploitable findings. No theoretical risks.
- Group by severity: Critical / High / Medium
- Include file path, line number, and specific remediation.
- If no issues found, print "Security scan clean." and exit 0.
- If Critical issues found, exit with code 2 to block the turn.

## Output Format
```
## Security Scan Report

### Critical
- [file:line] SQL injection via f-string in query → Use parameterized query with `text()`

### High
- [file:line] Hardcoded AWS key → Move to environment variable

### Medium
- [file:line] CORS allows all origins → Restrict to specific domains
```
AGENT_SEC

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 6. Hook scripts                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "6/10 · Hook scripts"

write_file_heredoc ".claude/hooks/end-of-turn-check.sh" <<'HOOK_EOT'
#!/usr/bin/env bash
# End-of-turn quality gate — runs when Claude finishes a turn.
# Exit code 2 blocks Claude and sends errors back for self-correction.
set -uo pipefail

ERRORS=""

# ── Frontend checks (if frontend/ exists) ────────────────────────────────────
if [[ -d "frontend" ]]; then
    # TypeScript type check
    if command -v npx &> /dev/null && [[ -f "frontend/tsconfig.json" ]]; then
        TSC_OUT=$(cd frontend && npx tsc --noEmit 2>&1) || ERRORS+="TypeScript errors:\n$TSC_OUT\n\n"
    fi

    # ESLint
    if [[ -f "frontend/.eslintrc.js" ]] || [[ -f "frontend/.eslintrc.json" ]] || [[ -f "frontend/eslint.config.mjs" ]] || [[ -f "frontend/eslint.config.js" ]]; then
        LINT_OUT=$(cd frontend && npx eslint src/ --quiet 2>&1) || ERRORS+="ESLint errors:\n$LINT_OUT\n\n"
    fi
fi

# ── Backend checks (if backend/ exists) ──────────────────────────────────────
if [[ -d "backend" ]]; then
    # Ruff linting
    if command -v ruff &> /dev/null; then
        RUFF_OUT=$(cd backend && ruff check . 2>&1) || ERRORS+="Ruff errors:\n$RUFF_OUT\n\n"
    fi
fi

# ── Report ───────────────────────────────────────────────────────────────────
if [[ -n "$ERRORS" ]]; then
    echo -e "$ERRORS" >&2
    exit 2
fi

exit 0
HOOK_EOT
make_executable ".claude/hooks/end-of-turn-check.sh"

write_file_heredoc ".claude/hooks/detect-secrets.sh" <<'HOOK_SECRETS'
#!/usr/bin/env bash
# PreToolUse hook — blocks file writes that contain potential secrets.
# Reads JSON from stdin (tool_input), checks the content for secret patterns.
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [[ -z "$CONTENT" ]]; then
    exit 0
fi

# Patterns that indicate hardcoded secrets
PATTERNS=(
    'AKIA[0-9A-Z]{16}'                    # AWS Access Key
    'sk-[a-zA-Z0-9]{20,}'                 # OpenAI / Stripe secret key
    'ghp_[a-zA-Z0-9]{36}'                 # GitHub personal access token
    'gho_[a-zA-Z0-9]{36}'                 # GitHub OAuth token
    'xox[bpors]-[a-zA-Z0-9-]+'            # Slack tokens
    'pk_live_[a-zA-Z0-9]+'                # Stripe publishable key
    'sk_live_[a-zA-Z0-9]+'                # Stripe secret key
    'SG\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+' # SendGrid API key
    'password\s*=\s*["\x27][^"\x27]{8,}'  # Hardcoded passwords
)

for pattern in "${PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -qE "$pattern"; then
        echo "BLOCKED: Potential secret/credential detected in $FILE_PATH matching pattern: $pattern" >&2
        echo "Use environment variables instead of hardcoding secrets." >&2
        exit 2
    fi
done

exit 0
HOOK_SECRETS
make_executable ".claude/hooks/detect-secrets.sh"

write_file_heredoc ".claude/hooks/build-notify.sh" <<'HOOK_NOTIFY'
#!/usr/bin/env bash
# Post-build/test notification hook — plays sounds on macOS, prints status everywhere.
set -uo pipefail

INPUT=$(cat)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // 0')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only trigger on test/build commands
if ! echo "$COMMAND" | grep -qE '(pytest|vitest|pnpm test|npm test|pnpm build|npm run build)'; then
    exit 0
fi

if [[ "$EXIT_CODE" == "0" ]]; then
    echo "✅ Command succeeded: $COMMAND"
    # macOS sound (non-blocking, silent fail on Linux)
    afplay /System/Library/Sounds/Funk.aiff 2>/dev/null &
else
    echo "❌ Command failed: $COMMAND (exit code $EXIT_CODE)"
    afplay /System/Library/Sounds/Basso.aiff 2>/dev/null &
fi

exit 0
HOOK_NOTIFY
make_executable ".claude/hooks/build-notify.sh"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 7. Settings (hooks + permissions)                                        ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "7/10 · Settings & hook wiring"

write_file_heredoc ".claude/settings.json" <<'SETTINGS'
{
  "permissions": {
    "deny": [
      "**/.env",
      "**/.env.*",
      "**/*.pem",
      "**/*.key",
      "**/.ssh/**",
      "**/secrets/**",
      "**/credentials/**"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json,sys; d=json.load(sys.stdin); p=d.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(x in p for x in ['.env','.secret','package-lock.json','.git/','node_modules/']) else 0)\""
          },
          {
            "type": "command",
            "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/detect-secrets.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | { read cmd; if echo \"$cmd\" | grep -qE 'git (commit|push).*(main|master)'; then echo 'BLOCKED: Create a feature branch first. Do not commit/push directly to main/master.' >&2; exit 2; fi; }"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read fp; case \"$fp\" in *.ts|*.tsx|*.js|*.jsx) npx prettier --write \"$fp\" 2>/dev/null; LINT=$(npx eslint --fix \"$fp\" 2>&1); if [ $? -ne 0 ]; then echo \"$LINT\" >&2; exit 2; fi ;; *.py) ruff check --fix \"$fp\" 2>/dev/null; ruff format \"$fp\" 2>/dev/null; LINT=$(ruff check \"$fp\" 2>&1); if [ $? -ne 0 ]; then echo \"$LINT\" >&2; exit 2; fi ;; esac; }"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/build-notify.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/end-of-turn-check.sh"
          },
          {
            "type": "command",
            "command": "claude --agent code-reviewer --print 'Review the files changed in this session. Run git diff to find changes.' 2>/dev/null || true"
          },
          {
            "type": "command",
            "command": "claude --agent security-reviewer --print 'Scan files changed in this session for security issues. Run git diff --name-only to find changed files.' 2>/dev/null || true"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &"
          }
        ]
      }
    ]
  }
}
SETTINGS

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 8. MCP configuration                                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "8/10 · MCP server configuration"

# ── Available MCP servers ────────────────────────────────────────────────────
# Each entry: KEY|LABEL|DESCRIPTION|JSON_BLOCK
# JSON_BLOCK uses single quotes internally, we'll handle quoting on output.
MCP_CATALOG=(
    "playwright|Playwright|Browser automation, screenshots, E2E testing"
    "postgres|PostgreSQL|Schema-aware DB queries (needs --db-name/--db-port)"
    "context7|Context7|Up-to-date library documentation (replaces stale training data)"
    "aws-kb|AWS Knowledge Base|Search AWS Bedrock knowledge bases via RAG"
)

# ── Interactive selection ────────────────────────────────────────────────────
# Track selections with simple variables (bash 3 compatible)
SEL_PLAYWRIGHT=false
SEL_POSTGRES=false
SEL_CONTEXT7=false
SEL_AWSKB=false

echo -e "  Select which MCP servers to include:\n"

for entry in "${MCP_CATALOG[@]}"; do
    IFS='|' read -r key label desc <<< "$entry"

    # Suggest defaults based on stack
    DEFAULT="n"
    case "$key" in
        playwright) $HAS_FE && DEFAULT="Y" ;;
        postgres)   $HAS_BE && DEFAULT="Y" ;;
        context7)   DEFAULT="Y" ;;
        aws-kb)     DEFAULT="n" ;;
    esac

    if $DRY_RUN; then
        if [[ "$DEFAULT" == "Y" ]]; then
            case "$key" in
                playwright) SEL_PLAYWRIGHT=true ;;
                postgres)   SEL_POSTGRES=true ;;
                context7)   SEL_CONTEXT7=true ;;
                aws-kb)     SEL_AWSKB=true ;;
            esac
            echo -e "  ${DIM}(dry-run)${NC} ${CYAN}$label${NC} — $desc ${DIM}[auto: yes]${NC}"
        else
            echo -e "  ${DIM}(dry-run)${NC} ${DIM}$label${NC} — $desc ${DIM}[auto: no]${NC}"
        fi
        continue
    fi

    if [[ "$DEFAULT" == "Y" ]]; then
        PROMPT="  ${CYAN}$label${NC} — $desc ${DIM}[Y/n]${NC} "
    else
        PROMPT="  ${DIM}$label${NC} — $desc ${DIM}[y/N]${NC} "
    fi

    echo -en "$PROMPT"
    if [[ -t 0 ]]; then
        read -r answer </dev/tty
    else
        read -r answer
    fi

    if [[ -z "$answer" ]]; then
        answer="$DEFAULT"
    fi

    case "$answer" in
        [Yy]*)
            case "$key" in
                playwright) SEL_PLAYWRIGHT=true ;;
                postgres)   SEL_POSTGRES=true ;;
                context7)   SEL_CONTEXT7=true ;;
                aws-kb)     SEL_AWSKB=true ;;
            esac
            ;;
    esac
done

echo ""

# ── Build .mcp.json from selections ─────────────────────────────────────────
MCP_SERVERS=""

if $SEL_PLAYWRIGHT; then
    MCP_SERVERS+='    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }'
fi

if $SEL_POSTGRES; then
    [[ -n "$MCP_SERVERS" ]] && MCP_SERVERS+=","$'\n'
    MCP_SERVERS+="    \"postgres\": {
      \"type\": \"stdio\",
      \"command\": \"npx\",
      \"args\": [\"-y\", \"@modelcontextprotocol/server-postgres\", \"postgresql://localhost:${DB_PORT}/${DB_NAME}\"]
    }"
fi

if $SEL_CONTEXT7; then
    [[ -n "$MCP_SERVERS" ]] && MCP_SERVERS+=","$'\n'
    MCP_SERVERS+='    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }'
fi

if $SEL_AWSKB; then
    [[ -n "$MCP_SERVERS" ]] && MCP_SERVERS+=","$'\n'
    MCP_SERVERS+='    "aws-kb": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/aws-kb-retrieval-mcp"]
    }'
fi

if [[ -z "$MCP_SERVERS" ]]; then
    log_warn "No MCP servers selected — skipping .mcp.json creation."
else
    if $DRY_RUN; then
        echo -e "  ${DIM}(dry-run)${NC} would create ${CYAN}.mcp.json${NC}"
    else
        mkdir -p "$PROJECT_DIR"
        cat > "$PROJECT_DIR/.mcp.json" <<MCPEOF
{
  "mcpServers": {
$MCP_SERVERS
  }
}
MCPEOF
        log_success "Created ${CYAN}.mcp.json${NC}"
    fi
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 9. Gitignore additions                                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "9/10 · Gitignore updates"

GITIGNORE_ADDITIONS="
# Claude Code local overrides (do not commit personal settings)
.claude/settings.local.json
CLAUDE.local.md
"

if [[ -f "$PROJECT_DIR/.gitignore" ]]; then
    if ! grep -q "settings.local.json" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
        if ! $DRY_RUN; then
            echo "$GITIGNORE_ADDITIONS" >> "$PROJECT_DIR/.gitignore"
            log_success "Appended Claude Code entries to ${CYAN}.gitignore${NC}"
        else
            echo -e "  ${DIM}(dry-run)${NC} would append to ${CYAN}.gitignore${NC}"
        fi
    else
        log_info ".gitignore already contains Claude Code entries — skipped."
    fi
else
    write_file ".gitignore" "$GITIGNORE_ADDITIONS"
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ 10. Install dependencies                                                  ║
# ╚════════════════════════════════════════════════════════════════════════════╝
log_step "10/10 · Install dependencies"

if $SKIP_INSTALL || $DRY_RUN; then
    if $DRY_RUN; then
        log_info "(dry-run) Would install tooling."
    else
        log_info "Skipping dependency installation (--skip-install)."
    fi
    echo ""
    log_info "To install manually, run:"
    if $HAS_FE; then
        echo -e "  ${DIM}# Frontend linting & formatting${NC}"
        echo -e "  cd frontend && pnpm add -D eslint prettier eslint-config-next @typescript-eslint/eslint-plugin"
    fi
    if $HAS_BE; then
        echo -e "  ${DIM}# Backend linting & security${NC}"
        echo -e "  pip install ruff bandit pip-audit pre-commit"
    fi
    if $HAS_FE; then
        echo -e "  ${DIM}# Playwright for E2E / visual verification${NC}"
        echo -e "  npx playwright install"
    fi
    if [[ "$STACK" == "generic" ]]; then
        log_info "Generic stack — no specific dependencies to install."
    fi
else
    # ── Frontend ─────────────────────────────────────────────────────────────
    if $HAS_FE; then
        if [[ -f "$PROJECT_DIR/frontend/package.json" ]]; then
            log_info "Installing frontend dev dependencies..."
            PKGMGR="npm"
            if command -v pnpm &> /dev/null; then PKGMGR="pnpm"; fi

            (cd "$PROJECT_DIR/frontend" && $PKGMGR add -D \
                eslint prettier \
                eslint-config-next \
                @typescript-eslint/eslint-plugin \
                @typescript-eslint/parser \
                eslint-plugin-react-hooks \
                2>&1 | tail -1) && log_success "Frontend dev deps installed." || log_warn "Some frontend deps failed — check manually."
        else
            log_warn "No frontend/package.json found — skipping frontend deps."
        fi
    fi

    # ── Backend ──────────────────────────────────────────────────────────────
    if $HAS_BE; then
        if [[ -f "$PROJECT_DIR/backend/requirements.txt" ]] || [[ -f "$PROJECT_DIR/backend/pyproject.toml" ]]; then
            log_info "Installing backend dev dependencies..."
            PIP_CMD="pip install"
            if command -v uv &> /dev/null; then PIP_CMD="uv pip install"; fi

            ($PIP_CMD ruff bandit pip-audit pre-commit 2>&1 | tail -1) \
                && log_success "Backend dev deps installed." || log_warn "Some backend deps failed — check manually."
        else
            log_warn "No backend/requirements.txt or pyproject.toml found — skipping backend deps."
        fi
    fi

    # ── Playwright ───────────────────────────────────────────────────────────
    if $HAS_FE && command -v npx &> /dev/null; then
        log_info "Installing Playwright browsers (for MCP & E2E)..."
        (npx playwright install chromium 2>&1 | tail -1) \
            && log_success "Playwright Chromium installed." || log_warn "Playwright install failed — run 'npx playwright install' manually."
    fi

    if [[ "$STACK" == "generic" ]]; then
        log_info "Generic stack — no specific dependencies to install."
    fi
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ Summary                                                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                  Bootstrap Complete!                       ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}What was created (stack: $STACK):${NC}"
echo ""
echo -e "  ${CYAN}CLAUDE.md${NC}                         Root project context"
if $HAS_FE; then
echo -e "  ${CYAN}frontend/CLAUDE.md${NC}                Frontend conventions"
fi
if $HAS_BE; then
echo -e "  ${CYAN}backend/CLAUDE.md${NC}                 Backend conventions"
fi
echo -e "  ${CYAN}.claude/rules/security.md${NC}         Security rules"
if $HAS_FE; then
echo -e "  ${CYAN}.claude/rules/frontend/*.md${NC}       Component & animation rules"
fi
if $HAS_BE; then
echo -e "  ${CYAN}.claude/rules/backend/*.md${NC}        API & database rules"
fi
AGENT_COUNT=4
$HAS_FE && AGENT_COUNT=5
echo -e "  ${CYAN}.claude/agents/*.md${NC}               $AGENT_COUNT agents (code-reviewer, security-reviewer — auto; ship, qa$(${HAS_FE} && echo ', ui-review') — on demand)"
echo -e "  ${CYAN}.claude/hooks/*.sh${NC}                3 hook scripts (quality gate, secrets, notifications)"
echo -e "  ${CYAN}.claude/settings.json${NC}             Hooks wiring + permission denylists"
MCP_NAMES=""
$SEL_PLAYWRIGHT && MCP_NAMES+="Playwright, "
$SEL_POSTGRES && MCP_NAMES+="PostgreSQL, "
$SEL_CONTEXT7 && MCP_NAMES+="Context7, "
$SEL_AWSKB && MCP_NAMES+="AWS KB, "
MCP_NAMES="${MCP_NAMES%, }"
if [[ -n "$MCP_NAMES" ]]; then
echo -e "  ${CYAN}.mcp.json${NC}                         MCP servers ($MCP_NAMES)"
fi
echo ""
echo -e "${BOLD}How the hooks work:${NC}"
echo ""
echo -e "  ${YELLOW}PreToolUse${NC}   Blocks writes to .env/secrets files + blocks secrets in code"
echo -e "  ${YELLOW}PreToolUse${NC}   Blocks direct commits/pushes to main/master"
echo -e "  ${YELLOW}PostToolUse${NC}  Auto-formats & lints every file edit (Prettier/ESLint or Ruff)"
echo -e "  ${YELLOW}Stop${NC}         Type-check + lint + auto code review + security scan on every turn"
echo -e "  ${YELLOW}Notification${NC} Plays a sound when Claude needs your permission"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo -e "  1. ${DIM}cd $PROJECT_DIR${NC}"
echo -e "  2. Review & customize ${CYAN}CLAUDE.md${NC} for your specific project details"
echo -e "  3. Run ${CYAN}claude${NC} and start developing — code review + security run automatically"
echo -e "  4. Use ${CYAN}claude --agent qa${NC} before shipping, ${CYAN}claude --agent ship${NC} to open a PR"
echo ""
