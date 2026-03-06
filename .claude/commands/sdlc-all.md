# Full SDLC Pipeline

Runs ALL phases in sequence. Each phase (except ship) MUST delegate to its subagent via the Task tool.

## Usage
```
/sdlc-all docs/prd.md
/sdlc-all Implement user registration with email verification
```

## Workflow

Execute these phases IN ORDER. After each phase, check the result.
Stop immediately if any phase returns FAIL.

### Phase 1: Implementation
Voice: "Phase 1: Starting implementation"
Voice: "Launching implementer subagent"
**MUST use Task tool** to spawn implementer subagent.

### Phase 2: Code Quality
Voice: "Phase 2: Running quality checks"
Voice: "Launching code quality subagent"
**MUST use Task tool** to spawn code-quality subagent.
**STOP if FAIL** — announce failure and tell user to fix issues.

### Phase 3: Security
Voice: "Phase 3: Running security audit"
Voice: "Launching security auditor subagent"
**MUST use Task tool** to spawn security-auditor subagent.
**STOP if FAIL** — announce failure and tell user to review findings.

### Phase 4: Documentation
Voice: "Phase 4: Updating documentation"
Voice: "Launching doc updater subagent"
**MUST use Task tool** to spawn doc-updater subagent.

### Phase 5: Ship
Voice: "Phase 5: Committing and pushing"
Runs inline (no subagent needed). Commits and pushes to remote.

Final voice: "Full SDLC pipeline complete. All 5 phases passed. Code shipped."
