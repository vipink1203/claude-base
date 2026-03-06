# Code Quality Checks

Runs lint, format, type checking, and tests using the **code-quality** subagent.

## Usage
```
/sdlc-quality
/sdlc-quality src/    # Target specific directory
```

## Workflow

1. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "SDLC Phase 2: Running code quality checks"
```

2. Announce subagent launch:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Launching code quality subagent"
```

3. **You MUST use the Task tool** to spawn the **code-quality** subagent (subagent_type: "general-purpose"). Do NOT run quality checks directly — always delegate via Task tool. Include any target directory in the prompt.

4. The subagent will:
   - Detect tech stack from project config
   - Run formatter with auto-fix
   - Run linter with auto-fix
   - Run type checker
   - Run test suite with coverage
   - Fix issues and re-run (max 3 iterations)

5. On completion, announce based on result:

   If PASS:
   ```bash
   uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 2 complete. All quality checks passed. Run slash sdlc-security next."
   ```

   If FAIL:
   ```bash
   uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 2 failed. Quality issues remain. Review the report and re-run slash sdlc-quality."
   ```

6. Print the quality report and suggest next step.
