#!/bin/bash
# ============================================================================
# claude-code-hardened: validate
# Check your Claude Code setup for security issues
# ============================================================================
# Run this anytime: bash scripts/validate.sh
# Also works as a standalone audit tool on any machine.
# ============================================================================

CLAUDE_DIR="$HOME/.claude"
PASS=0
FAIL=0
WARN=0

check_pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
check_fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check_warn() { echo "  ⚠️  $1"; WARN=$((WARN + 1)); }

echo ""
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║    claude-code-hardened validation                 ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo ""

# ── 1. Hooks ───────────────────────────────────────────────────────────────
echo "  Hooks:"

if [ -f "$CLAUDE_DIR/hooks/block-no-verify.sh" ]; then
  check_pass "block-no-verify hook installed"
else
  check_fail "block-no-verify hook MISSING — AI can bypass pre-commit hooks"
fi

if [ -f "$CLAUDE_DIR/hooks/pre-push-secrets-scan.sh" ]; then
  check_pass "pre-push-secrets-scan hook installed"
else
  check_fail "pre-push-secrets-scan hook MISSING — secrets can leak on push"
fi

if [ -f "$CLAUDE_DIR/hooks/protect-critical-files.sh" ]; then
  check_pass "protect-critical-files hook installed"
else
  check_warn "protect-critical-files hook not installed (optional)"
fi

if [ -f "$CLAUDE_DIR/hooks/enforce-branch-policy.sh" ]; then
  check_pass "enforce-branch-policy hook installed"
else
  check_warn "enforce-branch-policy hook not installed (optional)"
fi

# ── 2. Settings ────────────────────────────────────────────────────────────
echo ""
echo "  Settings:"

if [ -f "$CLAUDE_DIR/settings.json" ]; then
  check_pass "settings.json exists"

  if grep -q '"hooks"' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
    check_pass "hooks configured in settings.json"
  else
    check_fail "NO hooks in settings.json — hooks are installed but not activated!"
  fi

  if grep -q 'block-no-verify' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
    check_pass "block-no-verify registered in settings"
  else
    check_warn "block-no-verify not registered (hook file exists but won't run)"
  fi

  if grep -q 'secrets-scan\|security' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
    check_pass "secrets scan registered in settings"
  else
    check_warn "secrets scan not registered (hook file exists but won't run)"
  fi
else
  check_fail "settings.json does not exist"
fi

# ── 3. Rules ───────────────────────────────────────────────────────────────
echo ""
echo "  Rules:"

if [ -d "$CLAUDE_DIR/rules/common" ]; then
  RULE_COUNT=$(ls "$CLAUDE_DIR/rules/common/"*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$RULE_COUNT" -ge 4 ]; then
    check_pass "$RULE_COUNT rules installed in common/"
  else
    check_warn "Only $RULE_COUNT rules in common/ (recommend 4+)"
  fi
else
  check_warn "No common rules directory"
fi

if [ -f "$CLAUDE_DIR/rules/common/security.md" ]; then
  check_pass "security rules installed"
else
  check_fail "security rules MISSING"
fi

# ── 4. Dangerous Patterns ─────────────────────────────────────────────────
echo ""
echo "  Dangerous patterns:"

if grep -q 'dangerously-skip-permissions\|bypassPermissions' "$CLAUDE_DIR/settings.json" 2>/dev/null; then
  check_fail "Dangerous permission bypass detected in settings!"
else
  check_pass "No permission bypass flags"
fi

if [ -f "$HOME/.env" ]; then
  check_warn ".env file in home directory — ensure it's not committed anywhere"
else
  check_pass "No .env in home directory"
fi

# ── 5. .gitignore ─────────────────────────────────────────────────────────
echo ""
echo "  Project .gitignore:"

if [ -f ".gitignore" ]; then
  for pattern in ".env" "*.local" "wrangler.toml"; do
    if grep -q "$pattern" .gitignore 2>/dev/null; then
      check_pass ".gitignore includes $pattern"
    else
      check_warn ".gitignore missing $pattern"
    fi
  done
else
  check_warn "No .gitignore in current directory"
fi

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────────"
TOTAL=$((PASS + FAIL + WARN))
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings ($TOTAL checks)"

if [ $FAIL -eq 0 ]; then
  echo "  Status:  HARDENED ✅"
else
  echo "  Status:  VULNERABLE ❌ — fix the failures above"
fi
echo ""
