---
name: code-quality-standards
description: >
  Code quality enforcement: linting, formatting, type checking, test coverage.
  Use when running quality checks, fixing lint errors, formatting code,
  or ensuring test coverage meets thresholds.
---

# Code Quality Standards

## Stack Detection
| Config File | Linter | Formatter | Type Checker |
|-------------|--------|-----------|-------------|
| package.json | ESLint | Prettier | tsc --noEmit |
| pyproject.toml | Ruff / flake8 | Ruff format / black | pyright / mypy |
| Cargo.toml | clippy | rustfmt | (built-in) |
| go.mod | golangci-lint | gofmt | (built-in) |

## Execution Order
1. Format first → 2. Lint second → 3. Type check → 4. Tests

## Quality Gates
- Lint: Zero errors
- Format: All files clean
- Types: Zero errors
- Tests: All pass
- Coverage: >= 80%

## Fix Strategy
1. Auto-fix with --fix flags
2. Manually fix remaining
3. Re-run ALL checks
4. Max 3 iterations before escalating

## Code Smells to Flag
- Functions > 50 lines, Files > 300 lines
- Cyclomatic complexity > 10
- Nested callbacks > 3 levels
- Duplicate code > 10 lines
- Magic numbers, leftover console.log/print
