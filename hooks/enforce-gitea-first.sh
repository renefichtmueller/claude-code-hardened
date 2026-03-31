#!/bin/bash
# ============================================================================
# claude-code-hardened: enforce-gitea-first
# Warns when pushing directly to GitHub instead of Gitea (self-hosted)
# ============================================================================
# Pattern: ALL development goes to Gitea first. GitHub is for intentional
#          public releases only — never for dev work or testing.
#
# This hook warns (exit 0) when it detects a GitHub push without explicit
# confirmation context. Change to exit 2 to hard-block.
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

# Only trigger on git push
if ! echo "$COMMAND" | grep -q 'git push'; then
  exit 0
fi

# Detect GitHub push
if echo "$COMMAND" | grep -qE 'github\.com|git@github'; then
  echo "WARNING: Pushing to GitHub detected." >&2
  echo "  → GitHub is for INTENTIONAL PUBLIC RELEASES only." >&2
  echo "  → All development and testing must go to Gitea first." >&2
  echo "  → If this is a planned public release, run the triple security scan first:" >&2
  echo "      Scan 1: grep -nE '(api[_-]?key|secret|token|password|credential|auth)'" >&2
  echo "      Scan 2: grep -nE '(192\.168\.|@gmail|/Users/)'" >&2
  echo "      Scan 3: grep -nE '(database_id|VAPID|DATABASE_URL|SENDGRID)'" >&2
  # Change to exit 2 to hard-block GitHub pushes entirely
  exit 0
fi

exit 0
