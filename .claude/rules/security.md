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
