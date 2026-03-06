---
name: git-conventions
description: >
  Git conventions: conventional commits, branch naming, PR standards.
  Use when committing, creating branches, or writing commit messages.
---

# Git Conventions

## Conventional Commits
Format: `<type>(<scope>): <description>`

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructure |
| `test` | Adding/fixing tests |
| `chore` | Build, deps, tooling |
| `security` | Security fix |

### Rules
- Subject <= 72 chars, imperative mood, no period
- Body explains WHY, not WHAT
- Reference issues: `Closes #123`

## Branch Naming
`<type>/<ticket>-<short-description>`
```
feat/AUTH-123-jwt-refresh
fix/API-456-null-payment
```

## Before Committing
1. `git diff --staged` — review changes
2. No secrets, debug code, console.logs
3. All tests pass
4. Never commit directly to main/master
