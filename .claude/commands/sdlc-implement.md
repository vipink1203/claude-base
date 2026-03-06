# Implement from PRD

Implements code from a PRD or feature description using the **implementer** subagent.

## Input
Provide a PRD file path or describe the feature inline:
```
/sdlc-implement docs/prd.md
/sdlc-implement Add a health check endpoint at GET /api/health
```

## Workflow

1. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "SDLC Phase 1: Starting implementation from PRD"
```

2. If a file path is provided, read the file contents first.

3. Announce subagent launch:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Launching implementer subagent"
```

4. **You MUST use the Task tool** to spawn the **implementer** subagent (subagent_type: "general-purpose"). Do NOT implement code directly — always delegate via Task tool. Pass the full PRD context and any file contents in the prompt.

5. When subagent returns, verify:
   - Files were actually created/modified
   - No placeholder or TODO code left behind
   - Basic syntax check passes

6. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "Phase 1 complete. Implementation done. Run slash sdlc-quality next."
```

7. Print summary of files created/modified and suggest: "Run `/sdlc-quality` to proceed."
