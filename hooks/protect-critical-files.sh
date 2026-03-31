#!/bin/bash
# ============================================================================
# claude-code-hardened: protect-critical-files
# Warns (or blocks) when Claude modifies files that shouldn't change casually
# ============================================================================
# Use case: Prevent AI from overwriting your production config, landing page,
#           or database migrations without you explicitly asking for it.
#
# Configure PROTECTED_PATTERNS below with your own file patterns.
# Exit code 0 = warn only. Change to exit 2 to hard-block.
# ============================================================================

# Read JSON input from stdin (Claude Code hook system)
INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    # FileWrite uses 'file_path', FileEdit uses 'file_path' too
    print(ti.get('file_path', ti.get('path', '')))
except:
    print('')
" 2>/dev/null)

# ── Configure your protected patterns ──────────────────────────────────────
PROTECTED_PATTERNS=(
  "index.html"
  "package.json"
  "docker-compose.yml"
  "Dockerfile"
  ".env"
  "wrangler.toml"
  "migration"
  "schema.prisma"
  ".github/workflows"
  "CLAUDE.md"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qi "$pattern"; then
    echo "WARNING: Modifying protected file matching '$pattern': $FILE_PATH" >&2
    echo "Make sure this change is intentional." >&2
    # To hard-block instead of warn, uncomment:
    # exit 2
  fi
done

exit 0
