# Contributing to Claude Code Bootstrap

Thank you for your interest in contributing! This guide will help you get started.

## How to Contribute

### Reporting Bugs

Found a bug? [Open an issue](../../issues/new?template=bug_report.md) with:

- A clear title and description
- Steps to reproduce the behavior
- Expected vs. actual behavior
- Your environment (OS, Claude Code version, stack type used)

### Suggesting Features

Have an idea? [Open a feature request](../../issues/new?template=feature_request.md) with:

- The problem you're solving
- Your proposed solution
- Any alternatives you've considered

### Submitting Changes

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feat/your-feature
   ```
3. **Make your changes** — follow the conventions below
4. **Test your changes**:
   ```bash
   # Run the script with dry-run to verify output
   ./claude-code-bootstrap.sh --dry-run --stack fullstack ./test-project
   ./claude-code-bootstrap.sh --dry-run --stack frontend ./test-project
   ./claude-code-bootstrap.sh --dry-run --stack backend ./test-project
   ./claude-code-bootstrap.sh --dry-run --stack generic ./test-project
   ```
5. **Commit** using [conventional commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat(agents): add documentation writer agent"
   git commit -m "fix(hooks): handle missing eslint gracefully"
   git commit -m "docs: update user guide with new workflow"
   ```
6. **Push** and **open a Pull Request**

### What We're Looking For

- **New agents** — well-scoped agents for common workflows (e.g., migration agent, docs writer)
- **Stack support** — extending the script to support new stacks (e.g., Django, Rails, Go)
- **Hook improvements** — better auto-formatting, linting, or validation hooks
- **Bug fixes** — especially around edge cases in stack detection or hook execution
- **Documentation** — improving the user guide, README, or adding examples

## Development Setup

```bash
# Clone the repo
git clone https://github.com/vipink1203/claude-base.git
cd claude-base

# The project is a single bash script + markdown files — no build step needed
# Test changes with dry-run against a sample project
mkdir /tmp/test-project
./claude-code-bootstrap.sh --dry-run --stack generic /tmp/test-project
```

## Conventions

### Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

| Type | When to use |
|------|------------|
| `feat` | New feature or agent |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code restructuring without behavior change |
| `test` | Adding or updating tests |
| `chore` | Maintenance, CI, tooling |

### Agent Definitions

When adding or modifying agents in `.claude/agents/`:

1. Use **action-oriented descriptions** — "Use when the user wants to..."
2. Include the **identification banner** pattern:
   ```
   **FIRST:** Always begin your output with this identification banner:
   ═══════════════════════════════════════════
   🎯 AGENT NAME (model: sonnet)
   ═══════════════════════════════════════════
   ```
3. Restrict **tools** to only what the agent needs
4. Set the **model** explicitly in frontmatter
5. Include **safety rules** to prevent destructive actions

### Bootstrap Script

When modifying `claude-code-bootstrap.sh`:

- Use the existing `write_file` / `write_file_heredoc` helpers for file creation
- Guard stack-specific content with `$HAS_FE` / `$HAS_BE` flags
- Add new files to the `BOOTSTRAP_FILES` array in the uninstall section
- Test all four stack types with `--dry-run`
- Use color variables (`$CYAN`, `$GREEN`, `$RED`, etc.) for terminal output

### Documentation

- Keep `README.md` as a reference/overview — detailed guidance belongs in `USER_GUIDE.md`
- Use tables for structured comparisons
- Include code examples for every concept
- Keep language concise and direct

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior by opening an issue.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

## Questions?

Open a [discussion](../../discussions) or reach out via issues. We're happy to help!
