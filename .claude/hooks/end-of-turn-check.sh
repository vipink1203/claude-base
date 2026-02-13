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
