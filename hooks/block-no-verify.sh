#!/bin/bash
# ============================================================================
# claude-code-hardened: block-no-verify
# Prevents Claude from bypassing git pre-commit hooks with --no-verify
# ============================================================================
# Why: AI agents love --no-verify to "save time". This defeats the purpose
#      of pre-commit hooks (linting, secrets scanning, formatting).
#      If your hooks exist, they should ALWAYS run.
# ============================================================================

# Read JSON input from stdin (Claude Code hook system)
INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

if echo "$COMMAND" | grep -qE '\-\-no-verify|--no-gpg-sign'; then
  echo "BLOCKED: --no-verify or --no-gpg-sign flag detected." >&2
  echo "Pre-commit hooks exist for a reason. Fix the issue instead of skipping it." >&2
  exit 2
fi

exit 0
