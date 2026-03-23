#!/bin/bash
# ============================================================================
# claude-code-hardened: post-edit-lint-reminder
# After file edits, reminds about formatting and linting
# ============================================================================
# PostToolUse hook on Write|Edit — lightweight, async-safe.
# Customize the commands for your stack.
# ============================================================================

INPUT="$1"

# Detect file type from the edit
if echo "$INPUT" | grep -qE '\.(ts|tsx|js|jsx)'; then
  echo "Reminder: Run formatter (prettier/biome) and linter (eslint) on changed files." >&2
elif echo "$INPUT" | grep -qE '\.(py)'; then
  echo "Reminder: Run formatter (ruff format) and linter (ruff check) on changed files." >&2
elif echo "$INPUT" | grep -qE '\.(go)'; then
  echo "Reminder: Run gofmt and go vet on changed files." >&2
elif echo "$INPUT" | grep -qE '\.(rs)'; then
  echo "Reminder: Run cargo fmt and cargo clippy on changed files." >&2
fi

exit 0
