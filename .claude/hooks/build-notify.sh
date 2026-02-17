#!/usr/bin/env bash
# Post-build/test notification hook — plays sounds on macOS, prints status everywhere.
set -uo pipefail

INPUT=$(cat)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // 0')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only trigger on test/build commands
if ! echo "$COMMAND" | grep -qE '(pytest|vitest|pnpm test|npm test|pnpm build|npm run build)'; then
    exit 0
fi

if [[ "$EXIT_CODE" == "0" ]]; then
    echo "✅ Command succeeded: $COMMAND"
    # macOS sound (non-blocking, silent fail on Linux)
    afplay /System/Library/Sounds/Funk.aiff 2>/dev/null &
else
    echo "❌ Command failed: $COMMAND (exit code $EXIT_CODE)"
    afplay /System/Library/Sounds/Basso.aiff 2>/dev/null &
fi

exit 0
