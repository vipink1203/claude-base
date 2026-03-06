# Update Documentation

Updates README, CHANGELOG, API docs, and docstrings using the **doc-updater** subagent.

## Usage
```
/sdlc-docs
/sdlc-docs --changelog-only    # Only update CHANGELOG.md
```

## Workflow

1. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "SDLC Phase 4: Updating documentation and changelog"
```

2. Announce subagent launch:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Launching doc updater subagent"
```

3. **You MUST use the Task tool** to spawn the **doc-updater** subagent (subagent_type: "general-purpose"). Do NOT update docs directly — always delegate via Task tool.

4. The subagent will:
   - Run `git diff HEAD` to understand all changes since last commit
   - Update CHANGELOG.md with new entries under [Unreleased]
   - Update docs/ if features, config, or setup changed
   - Add/update JSDoc or docstrings on all new public functions
   - Update API docs if endpoints changed

5. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 4 complete. Documentation updated. Run slash sdlc-ship to commit and push."
```

6. Print summary of documentation changes and suggest: "Run `/sdlc-ship` to proceed."
