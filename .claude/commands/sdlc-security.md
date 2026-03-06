# Security Audit

Runs security scans and code review using the **security-auditor** subagent.

## Usage
```
/sdlc-security
/sdlc-security --fix    # Auto-fix all fixable issues
```

## Workflow

1. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "SDLC Phase 3: Running security audit"
```

2. Announce subagent launch:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Launching security auditor subagent"
```

3. **You MUST use the Task tool** to spawn the **security-auditor** subagent (subagent_type: "general-purpose"). Do NOT run security checks directly — always delegate via Task tool.

4. The subagent will:
   - Run dependency scanners (npm audit / pip audit / relevant tool)
   - Scan for hardcoded secrets
   - Run static analysis (semgrep/bandit if available)
   - Manual review against OWASP Top 10
   - Fix CRITICAL and HIGH issues directly
   - Document MEDIUM/LOW as code comments

5. On completion, announce based on result:

   If PASS:
   ```bash
   uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 3 complete. Security audit passed. Run slash sdlc-docs next."
   ```

   If PASS_WITH_NOTES:
   ```bash
   uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 3 complete. Security audit passed with notes. Medium and low issues documented. Run slash sdlc-docs next."
   ```

   If FAIL:
   ```bash
   uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 3 failed. Critical security issues remain. Review the report and re-run slash sdlc-security."
   ```

6. Print the security report and suggest next step.
