# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| v1.x    | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

As this is an AI agent framework capable of executing code and filesystem operations, we take security extremely seriously.

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report vulnerabilities by:

1. Emailing [INSERT SECURITY EMAIL]
2. Including details about the potential exploit, specially crafted CLAUDE.md files, or malicious agent configurations

We will acknowledge your report within 48 hours and aim for a fix within 5 business days.

## Specific Threat Models

We are particularly interested in reports concerning:

- **Prompt Injection**: Malicious instructions in files that override agent safety rules
- **Tool Abuse**: Circumvention of tool restrictions (e.g., writing to protected files)
- **Context Leaks**: Unauthorized access to secrets or files outside the project scope
- **Remote Code Execution**: Unintended execution of shell commands via agent actions

## Security Best Practices for Users

- **Review generated code**: Agents are powerful but fallible. Always review code, especially security-critical components.
- **Protect your .env**: Ensure secrets are never committed to git.
- **Limit agent permissions**: Only grant tools necessary for the specific agent's role.
- **Audit your hooks**: Regularly review `.claude/settings.json` and `.claude/hooks/` for unauthorized changes.
