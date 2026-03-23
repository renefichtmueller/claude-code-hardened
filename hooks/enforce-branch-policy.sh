#!/bin/bash
# ============================================================================
# claude-code-hardened: enforce-branch-policy
# Prevents force-push to main/master and warns about direct commits
# ============================================================================

INPUT="$1"

# Block force-push to main/master
if echo "$INPUT" | grep -qE 'git push.*--force.*(main|master)'; then
  echo "BLOCKED: Force-push to main/master is not allowed." >&2
  echo "Use a feature branch and create a PR instead." >&2
  exit 2
fi

if echo "$INPUT" | grep -qE 'git push.*-f.*(main|master)'; then
  echo "BLOCKED: Force-push (-f) to main/master is not allowed." >&2
  exit 2
fi

# Block destructive resets on main
if echo "$INPUT" | grep -qE 'git reset --hard.*(main|master|origin)'; then
  echo "BLOCKED: Hard reset on main/master. This destroys commit history." >&2
  echo "Use 'git revert' for safe undo, or work on a feature branch." >&2
  exit 2
fi

# Warn on direct push to main (not blocked, just warned)
if echo "$INPUT" | grep -qE 'git push.*(origin|upstream)\s+(main|master)$'; then
  echo "WARNING: Pushing directly to main/master." >&2
  echo "Consider using a feature branch + PR for code review." >&2
fi

exit 0
