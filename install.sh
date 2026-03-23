#!/bin/bash
# ============================================================================
# claude-code-hardened installer
# One command to harden your Claude Code setup
# ============================================================================
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║        claude-code-hardened installer              ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Install hooks ──────────────────────────────────────────────────
echo "Installing hooks..."
mkdir -p "$CLAUDE_DIR/hooks"
cp "$REPO_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/"*.sh
echo "  ✅ $(ls "$REPO_DIR/hooks/"*.sh | wc -l | tr -d ' ') hooks installed to $CLAUDE_DIR/hooks/"

# ── Step 2: Install rules ─────────────────────────────────────────────────
echo "Installing rules..."
mkdir -p "$CLAUDE_DIR/rules/common"
cp "$REPO_DIR/rules/common/"*.md "$CLAUDE_DIR/rules/common/"
echo "  ✅ $(ls "$REPO_DIR/rules/common/"*.md | wc -l | tr -d ' ') rules installed to $CLAUDE_DIR/rules/common/"

# ── Step 3: Update settings.json ───────────────────────────────────────────
SETTINGS="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS" ]; then
  # Check if hooks already configured
  if grep -q '"hooks"' "$SETTINGS" 2>/dev/null; then
    echo "  ⚠️  settings.json already has hooks configured."
    echo "     To add hardened hooks, merge manually from examples/settings-hooks.json"
  else
    echo "  ⚠️  settings.json exists but has no hooks."
    echo "     Copy the hooks config from examples/settings-hooks.json"
  fi
else
  echo "  Creating settings.json with hooks..."
  cp "$REPO_DIR/examples/settings-hooks.json" "$SETTINGS"
  echo "  ✅ settings.json created with security hooks"
fi

# ── Step 4: Verify ─────────────────────────────────────────────────────────
echo ""
echo "Verifying installation..."
bash "$REPO_DIR/scripts/validate.sh"

echo ""
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║  Installation complete!                            ║"
echo "  ║                                                    ║"
echo "  ║  Restart Claude Code to activate hooks.            ║"
echo "  ║  Run: bash scripts/validate.sh to check status.    ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo ""
