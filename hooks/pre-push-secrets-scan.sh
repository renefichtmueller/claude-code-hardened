#!/bin/bash
# ============================================================================
# claude-code-hardened: pre-push-secrets-scan
# Triple-layer security scan before any git push
# ============================================================================
# Catches: API keys, tokens, passwords, private IPs, emails, database URLs,
#          and config values that should never leave your machine.
#
# This hook runs as a PreToolUse hook on Bash commands containing "git push".
# Claude Code passes tool input as JSON via stdin.
# Exit code 2 = BLOCK the push. Exit code 0 = allow.
# ============================================================================

# Read JSON input from stdin (Claude Code hook system)
INPUT=$(cat)

# Extract the bash command from the JSON
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

echo "=== Pre-Push Security Scan ===" >&2
FAIL=0

# ── Scan 1: Secrets & Credentials ──────────────────────────────────────────
SECRETS=$(grep -rnE \
  "(api[_-]?key|secret[_-]?key|auth[_-]?token|access[_-]?token|password|credential|private[_-]?key)\s*[:=]" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" \
  --include="*.py" --include="*.go" --include="*.rs" --include="*.env" \
  . 2>/dev/null \
  | grep -v node_modules | grep -v "\.next/" | grep -v "/dist/" | grep -v "/build/" \
  | grep -v "\.cache/" | grep -v "/out/" | grep -v "\.min\." \
  | grep -v ".git" | grep -v package-lock \
  | grep -v "\.example" | grep -v "\.sample" | grep -v "\.template" \
  | grep -v "process\.env\." | grep -v "os\.environ" | grep -v "os\.Getenv" \
  | grep -v "cfg\." | grep -v "config\." | grep -v "env\." | grep -v "req\." \
  | grep -v ":-[a-zA-Z0-9_]*}" \
  | head -10)

if [ -n "$SECRETS" ]; then
  echo "FAIL [secrets]: Potential hardcoded secrets found:" >&2
  echo "$SECRETS" >&2
  FAIL=1
else
  echo "PASS [secrets]: No hardcoded secrets detected" >&2
fi

# ── Scan 2: Private Data (IPs, personal paths, internal domains) ───────────
PRIVATE=$(grep -rnE \
  "(192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+|@gmail\.com|@googlemail\.com|/Users/[a-zA-Z]+/|/home/[a-zA-Z]+/|gitea\.[a-z-]+\.[a-z]+)" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.yaml" --include="*.yml" --include="*.toml" \
  --include="*.py" --include="*.go" --include="*.rs" --include="*.sh" \
  . 2>/dev/null \
  | grep -v node_modules | grep -v "\.next/" | grep -v "/dist/" | grep -v "/build/" \
  | grep -v "\.cache/" | grep -v "/out/" | grep -v "\.min\." \
  | grep -v ".git" | grep -v package-lock \
  | grep -v "\.example" | grep -v "\.md" | grep -v "README" \
  | head -10)

if [ -n "$PRIVATE" ]; then
  echo "FAIL [private-data]: Private IPs, personal paths, or internal domains found:" >&2
  echo "$PRIVATE" >&2
  FAIL=1
else
  echo "PASS [private-data]: No private data in source files" >&2
fi

# ── Scan 3: Config Values & Service URLs ───────────────────────────────────
DB_URLS=$(grep -rnE \
  "(postgres://|mysql://|mongodb://|redis://|amqp://|DATABASE_URL|REDIS_URL|SENDGRID|VAPID|database_id\s*[:=])\s*[:=]" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" \
  --include="*.py" --include="*.go" --include="*.rs" \
  . 2>/dev/null \
  | grep -v node_modules | grep -v "\.next/" | grep -v "/dist/" | grep -v "/build/" \
  | grep -v "\.cache/" | grep -v "/out/" | grep -v "\.min\." \
  | grep -v ".git" | grep -v package-lock \
  | grep -v "\.example" | grep -v "\.sample" | grep -v "\.template" \
  | grep -v "process\.env\." | grep -v "os\.environ" | grep -v "os\.Getenv" \
  | grep -v ":-[a-zA-Z0-9_]*}" \
  | grep -v "\${[A-Z_]*}" \
  | head -10)

if [ -n "$DB_URLS" ]; then
  echo "FAIL [config-values]: Database URLs or service config values found:" >&2
  echo "$DB_URLS" >&2
  FAIL=1
else
  echo "PASS [config-values]: No hardcoded connection strings or config values" >&2
fi

# ── Verify .gitignore has required entries ──────────────────────────────────
GITIGNORE_MISSING=""
for pattern in "wrangler.toml" ".env" ".dev.vars" "*.local"; do
  if ! grep -q "$pattern" .gitignore 2>/dev/null; then
    GITIGNORE_MISSING="$GITIGNORE_MISSING $pattern"
  fi
done

if [ -n "$GITIGNORE_MISSING" ]; then
  echo "WARN [gitignore]: Missing required .gitignore entries:$GITIGNORE_MISSING" >&2
  echo "     Add these to .gitignore to prevent accidental secret exposure." >&2
else
  echo "PASS [gitignore]: Required entries present" >&2
fi

# ── Verdict ─────────────────────────────────────────────────────────────────
if [ $FAIL -eq 1 ]; then
  echo "" >&2
  echo "PUSH BLOCKED — Fix the issues above before pushing." >&2
  echo "Use environment variables instead of hardcoded values." >&2
  exit 2
fi

echo "All scans passed." >&2
exit 0
