---
name: documentation-standards
description: >
  Documentation and changelog standards. Use when updating README, CHANGELOG,
  API docs, or adding docstrings. Also use when generating docs from code changes.
---

# Documentation Standards

## CHANGELOG (Keep a Changelog)
```markdown
## [Unreleased]

### Added
- New feature description

### Changed
- Modified behavior

### Fixed
- Bug fix description

### Security
- Vulnerability fix
```
- Present tense: "Add" not "Added"
- Most recent at top
- Never delete previous entries
- File: `CHANGELOG.md` in project root

## Code Docs

### Python — Google style docstrings
```python
def create_user(email: str, password: str) -> User:
    """Create a new user account.

    Args:
        email: User's email (must be unique).
        password: Plain text (will be hashed).

    Returns:
        Created User with generated ID.

    Raises:
        ValueError: If email already registered.
    """
```

### TypeScript — JSDoc
```typescript
/**
 * Create a new user account.
 * @param email - Must be unique
 * @param password - Will be hashed
 * @returns Created User with generated ID
 * @throws {ConflictError} If email exists
 */
```

### Go — Godoc
```go
// CreateUser creates a new user account.
// Returns an error if the email is already registered.
func CreateUser(email, password string) (*User, error) {
```

### Rust — Rustdoc
```rust
/// Creates a new user account.
///
/// # Arguments
/// * `email` - Must be unique
/// * `password` - Will be hashed
///
/// # Errors
/// Returns `ConflictError` if email exists.
pub fn create_user(email: &str, password: &str) -> Result<User, Error> {
```
