# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **User Guide**: Comprehensive usage documentation tailored for different workflows.
- **Agent Identification Banners**: Clear visual indicators for task agents (ship, qa, ui-review) and auto agents.
- **Improved Invocation Docs**: Clearer instructions for CLI vs in-session agent usage.
- **Open Source Basics**: LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, and GitHub templates.

### Changed
- **Bootstrap Script**: Updated agent templates to include identification banners and improved descriptions.
- **README**: Restructured for clarity, linking to the new User Guide.

## [0.1.0] - 2025-10-25

### Added
- Initial public release of `claude-code-bootstrap.sh`.
- Support for **Fullstack** (Next.js + FastAPI), **Frontend**, **Backend**, and **Generic** stacks.
- **Auto Agents**: Code Reviewer (Sonnet), Security Reviewer (Haiku).
- **Task Agents**: Ship (Sonnet), QA (Sonnet), UI Review (Sonnet).
- **Hooks Pipeline**: PreToolUse, PostToolUse, Stop hooks for quality enforcement.
- **MCP Integration**: Playwright, PostgreSQL, Context7 support.
