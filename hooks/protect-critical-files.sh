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

INPUT="$1"

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
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qi "$pattern"; then
    echo "WARNING: Modifying protected file matching '$pattern'" >&2
    echo "Make sure this change is intentional." >&2
    # To hard-block instead of warn, uncomment:
    # exit 2
  fi
done

exit 0
