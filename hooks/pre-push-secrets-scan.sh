#!/bin/bash
# ============================================================================
# claude-code-hardened: pre-push-secrets-scan
# Triple-layer security scan before any git push
# ============================================================================
# Catches: API keys, tokens, passwords, private IPs, emails, database URLs,
#          and config values that should never leave your machine.
#
# This hook runs as a PreToolUse hook on Bash commands containing "git push".
# Exit code 2 = BLOCK the push. Exit code 0 = allow.
# ============================================================================

INPUT="$1"

# Only trigger on git push
if ! echo "$INPUT" | grep -q 'git push'; then
  exit 0
fi

echo "=== Pre-Push Security Scan ===" >&2
FAIL=0

# ── Scan 1: Secrets & Credentials ──────────────────────────────────────────
SECRETS=$(grep -rnE \
  "(api[_-]?key|secret[_-]?key|auth[_-]?token|access[_-]?token|password|credential|private[_-]?key)\s*[:=]" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" \
  --include="*.py" --include="*.go" --include="*.rs" --include="*.env" \
  . 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v package-lock \
  | grep -v "\.example" | grep -v "\.sample" | grep -v "\.template" \
  | grep -v "process\.env\." | grep -v "os\.environ" | grep -v "os\.Getenv" \
  | head -10)

if [ -n "$SECRETS" ]; then
  echo "FAIL [secrets]: Potential hardcoded secrets found:" >&2
  echo "$SECRETS" >&2
  FAIL=1
else
  echo "PASS [secrets]: No hardcoded secrets detected" >&2
fi

# ── Scan 2: Private Network Data ───────────────────────────────────────────
PRIVATE=$(grep -rnE \
  "(192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+)" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" \
  --include="*.py" --include="*.go" --include="*.rs" \
  . 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v package-lock \
  | grep -v "\.example" | grep -v "\.md" | grep -v "README" \
  | head -10)

if [ -n "$PRIVATE" ]; then
  echo "FAIL [private-net]: Private IP addresses found in source:" >&2
  echo "$PRIVATE" >&2
  FAIL=1
else
  echo "PASS [private-net]: No private IPs in source files" >&2
fi

# ── Scan 3: Database & Service URLs ────────────────────────────────────────
DBurls=$(grep -rnE \
  "(postgres://|mysql://|mongodb://|redis://|amqp://|DATABASE_URL|REDIS_URL)\s*[:=]" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" \
  --include="*.py" --include="*.go" --include="*.rs" \
  . 2>/dev/null \
  | grep -v node_modules | grep -v .git | grep -v package-lock \
  | grep -v "\.example" | grep -v "\.sample" | grep -v "\.template" \
  | grep -v "process\.env\." | grep -v "os\.environ" | grep -v "os\.Getenv" \
  | head -10)

if [ -n "$DBURL" ]; then
  echo "FAIL [db-urls]: Database/service connection strings found:" >&2
  echo "$DBURLS" >&2
  FAIL=1
else
  echo "PASS [db-urls]: No hardcoded connection strings" >&2
fi

# ── Verdict ─────────────────────────────────────────────────────────────────
if [ $FAIL -eq 1 ]; then
  echo "" >&2
  echo "PUSH BLOCKED — Fix the issues above before pushing." >&2
  echo "If these are false positives, use environment variables instead of hardcoded values." >&2
  exit 2
fi

echo "All scans passed." >&2
exit 0
