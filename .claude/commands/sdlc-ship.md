# Commit and Push to GitHub

Stages all changes, generates a conventional commit message, commits, and pushes.
This phase runs inline (no subagent needed).

## Usage
```
/sdlc-ship
/sdlc-ship fix: resolve null pointer in auth handler    # Custom commit message
```

## Workflow

1. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "SDLC Phase 5: Committing and pushing to GitHub"
```

2. Check prerequisites:
   - Verify we're NOT on `main` or `master` branch
   - If on main/master, create a feature branch:
     ```bash
     git checkout -b feat/$(date +%Y%m%d)-sdlc-implementation
     ```

3. Stage all changes:
```bash
git add -A
```

4. Generate commit message:
   - If user provided a custom message, use it
   - Otherwise, analyze `git diff --cached --stat` and generate a
     conventional commit message following the `git-conventions` skill
   - Format: `<type>(<scope>): <description>`

5. Commit and push:
```bash
git commit -m "<generated or custom message>"
git push origin HEAD
```

6. Announce:
```bash
uv run "$CLAUDE_PROJECT_DIR/.claude/hooks/voice-notify.py" --say "SDLC pipeline complete. Code has been committed and pushed to GitHub successfully."
```

7. Print:
   - Branch name
   - Commit hash
   - Commit message
   - Files changed count
   - Remote URL for creating a PR
