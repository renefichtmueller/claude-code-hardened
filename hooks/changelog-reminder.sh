#!/bin/bash
# ============================================================================
# claude-code-hardened: changelog-reminder
# Reminds to update CHANGELOG_PENDING.md after feature commits
# ============================================================================
# Why: Keeping a changelog is easy to forget when you're deep in code.
#      This hook fires after git commits and checks if a changelog entry
#      was included in the session's recent changes.
#
# Expected format in CHANGELOG_PENDING.md:
#   {"d":"YYYY-MM-DD","t":"FEAT|UI|AI|INT|DATA|FIX","m":"Description"}
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

# Only trigger on git commit (not push, not status)
if ! echo "$COMMAND" | grep -qE 'git commit'; then
  exit 0
fi

# Skip if it's a merge commit or fixup
if echo "$COMMAND" | grep -qE '(--amend|--fixup|merge|revert)'; then
  exit 0
fi

# Check if CHANGELOG_PENDING.md exists and was recently modified (last 60s)
CHANGELOG="CHANGELOG_PENDING.md"
if [ -f "$CHANGELOG" ]; then
  # Check if the file was modified in the last 5 minutes
  LAST_MODIFIED=$(python3 -c "
import os, time
try:
    mtime = os.path.getmtime('$CHANGELOG')
    age = time.time() - mtime
    print(int(age))
except:
    print(9999)
" 2>/dev/null)

  if [ "$LAST_MODIFIED" -lt 300 ] 2>/dev/null; then
    # Recently updated — all good
    exit 0
  fi
fi

echo "REMINDER: Did you update CHANGELOG_PENDING.md?" >&2
echo "  Format: {\"d\":\"$(date +%Y-%m-%d)\",\"t\":\"FEAT|UI|AI|INT|DATA|FIX\",\"m\":\"Description\"}" >&2
echo "  File:   CHANGELOG_PENDING.md (in project root)" >&2

exit 0
