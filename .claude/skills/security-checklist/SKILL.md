---
name: security-checklist
description: >
  Security audit checklist: OWASP Top 10, dependency vulnerabilities,
  secrets scanning, secure coding patterns. Use when auditing code,
  scanning for vulnerabilities, or reviewing auth logic.
---

# Security Audit Checklist

## Automated Scans (Run First)

### Dependencies
```bash
# JavaScript/TypeScript
npm audit --production

# Python
pip audit 2>/dev/null || safety check 2>/dev/null || true

# Go
govulncheck ./... 2>/dev/null || true

# Rust
cargo audit 2>/dev/null || true
```

### Secrets Detection
```bash
grep -rn "API_KEY\|SECRET\|PASSWORD\|TOKEN\|PRIVATE_KEY" src/ lib/ app/ --include="*.ts" --include="*.tsx" --include="*.py" --include="*.go" --include="*.rs"
grep -rn "sk-\|pk_\|ghp_\|xox[bps]-\|AIza\|AKIA" src/ lib/ app/
```

## OWASP Top 10 Quick Check
| # | Risk | Check |
|---|------|-------|
| A01 | Broken Access Control | Auth on every endpoint, IDOR checks |
| A02 | Crypto Failures | HTTPS, strong hashing, no custom crypto |
| A03 | Injection | Parameterized queries, input validation |
| A05 | Security Misconfig | Default creds, error exposure |
| A07 | Auth Failures | Brute force protection, session mgmt |

## Manual Checklist
- [ ] No hardcoded secrets — all via env vars or secret manager
- [ ] `.env` in `.gitignore`
- [ ] All user input validated server-side
- [ ] SQL uses parameterized queries ONLY
- [ ] HTML output encoded
- [ ] Passwords hashed with bcrypt/argon2
- [ ] JWT tokens short-lived, properly validated
- [ ] Rate limiting on auth endpoints
- [ ] CORS configured properly

## Severity Levels
- **CRITICAL**: Blocks deployment (RCE, SQLi, exposed secrets)
- **HIGH**: Blocks merge (auth bypass, XSS, IDOR)
- **MEDIUM**: Fix within sprint (missing rate limits)
- **LOW**: Track in backlog (missing headers)
