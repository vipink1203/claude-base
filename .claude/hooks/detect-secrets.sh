#!/usr/bin/env bash
# PreToolUse hook — blocks file writes that contain potential secrets.
# Reads JSON from stdin (tool_input), checks the content for secret patterns.
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [[ -z "$CONTENT" ]]; then
    exit 0
fi

# Patterns that indicate hardcoded secrets
PATTERNS=(
    'AKIA[0-9A-Z]{16}'                    # AWS Access Key
    'sk-[a-zA-Z0-9]{20,}'                 # OpenAI / Stripe secret key
    'ghp_[a-zA-Z0-9]{36}'                 # GitHub personal access token
    'gho_[a-zA-Z0-9]{36}'                 # GitHub OAuth token
    'xox[bpors]-[a-zA-Z0-9-]+'            # Slack tokens
    'pk_live_[a-zA-Z0-9]+'                # Stripe publishable key
    'sk_live_[a-zA-Z0-9]+'                # Stripe secret key
    'SG\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+' # SendGrid API key
    'password\s*=\s*["\x27][^"\x27]{8,}'  # Hardcoded passwords
)

for pattern in "${PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -qE "$pattern"; then
        echo "BLOCKED: Potential secret/credential detected in $FILE_PATH matching pattern: $pattern" >&2
        echo "Use environment variables instead of hardcoding secrets." >&2
        exit 2
    fi
done

exit 0
