# 🛡️ claude-code-hardened

**Stop your AI from pushing secrets to GitHub.**

Claude Code is powerful. It's also an unsupervised intern with root access. This repo adds the guardrails that should have been there from day one.

---

<p align="center">
<strong>5 security hooks · 6 battle-tested rules · 1 install script · 0 dependencies</strong>
</p>

<p align="center">
<a href="#-quick-start">Quick Start</a> · <a href="#-what-it-catches">What It Catches</a> · <a href="#%EF%B8%8F-hooks">Hooks</a> · <a href="#-rules">Rules</a> · <a href="#-validate-your-setup">Validate</a>
</p>

---

## The Problem

Claude Code can:
- Push API keys to public repos (**it will, if you don't stop it**)
- Skip pre-commit hooks with `--no-verify` to "save time"
- Force-push to main and destroy your commit history
- Overwrite your landing page while "improving" a CSS class
- Commit database URLs, private IPs, and AWS credentials

These aren't hypothetical. They happened. This repo exists because of them.

## 🚀 Quick Start

```bash
git clone https://github.com/renefichtmueller/claude-code-hardened.git
cd claude-code-hardened
bash install.sh
```

That's it. Restart Claude Code. You're hardened.

### Manual Install (if you prefer)

```bash
# Copy hooks
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Copy rules
cp -r rules/common ~/.claude/rules/common

# Add hooks to settings.json (see examples/settings-hooks.json)
```

## 🔍 What It Catches

Run the validator on any machine to see your security posture:

```bash
bash scripts/validate.sh
```

Output:
```
  ╔═══════════════════════════════════════════════════╗
  ║    claude-code-hardened validation                 ║
  ╚═══════════════════════════════════════════════════╝

  Hooks:
  ✅ block-no-verify hook installed
  ✅ pre-push-secrets-scan hook installed
  ✅ protect-critical-files hook installed
  ✅ enforce-branch-policy hook installed

  Settings:
  ✅ settings.json exists
  ✅ hooks configured in settings.json
  ✅ block-no-verify registered in settings
  ✅ secrets scan registered in settings

  Rules:
  ✅ 6 rules installed in common/
  ✅ security rules installed

  Dangerous patterns:
  ✅ No permission bypass flags
  ✅ No .env in home directory

  ─────────────────────────────────────────────────
  Results: 12 passed, 0 failed, 0 warnings (12 checks)
  Status:  HARDENED ✅
```

## 🛡️ Hooks

### `block-no-verify.sh` — PreToolUse
Blocks `--no-verify` and `--no-gpg-sign` flags. AI agents love skipping hooks to avoid lint errors. This forces them to fix the actual issue.

### `pre-push-secrets-scan.sh` — PreToolUse
Triple-layer scan before any `git push`:

| Scan | What | Examples |
|------|------|---------|
| **Secrets** | API keys, tokens, passwords | `api_key = "sk-..."`, `auth_token: "ghp_..."` |
| **Private Network** | RFC 1918 addresses | `192.168.1.1`, `10.0.0.1`, `172.16.x.x` |
| **Database URLs** | Connection strings | `postgres://user:pass@host`, `DATABASE_URL=...` |

Exits with code 2 (blocks the push) if any scan fails.

### `enforce-branch-policy.sh` — PreToolUse
- **Blocks** force-push to main/master
- **Blocks** `git reset --hard` on main
- **Warns** on direct push to main (suggests PR workflow)

### `protect-critical-files.sh` — PostToolUse
Warns when Claude edits files that shouldn't change casually:
- `index.html`, `package.json`, `docker-compose.yml`
- `Dockerfile`, `.env`, `wrangler.toml`
- Database migrations, Prisma schema, CI/CD workflows

Customize the `PROTECTED_PATTERNS` array for your project.

### `post-edit-lint-reminder.sh` — PostToolUse
After file edits, reminds about language-specific formatting:
- TypeScript/JS → prettier/biome + eslint
- Python → ruff format + ruff check
- Go → gofmt + go vet
- Rust → cargo fmt + cargo clippy

## 📏 Rules

Battle-tested from 200+ Claude Code sessions across production projects:

| Rule | What It Enforces |
|------|-----------------|
| [coding-style.md](rules/common/coding-style.md) | Immutability, file size limits, error handling, input validation |
| [security.md](rules/common/security.md) | Pre-commit checklist, secret management, `.gitignore` requirements |
| [testing.md](rules/common/testing.md) | TDD workflow, 80% coverage target, test quality rules |
| [git-workflow.md](rules/common/git-workflow.md) | Conventional commits, branch strategy, PR templates |
| [development-workflow.md](rules/common/development-workflow.md) | Research → Plan → Test → Code → Review → Push pipeline |
| [performance.md](rules/common/performance.md) | Model routing, context window discipline, parallel execution |

Rules are loaded automatically when placed in `~/.claude/rules/`. Claude Code reads them at the start of every session.

## 📁 Structure

```
claude-code-hardened/
├── hooks/                          # Security hooks (bash scripts)
│   ├── block-no-verify.sh          # Block --no-verify flag
│   ├── pre-push-secrets-scan.sh    # Triple secrets scan before push
│   ├── enforce-branch-policy.sh    # Protect main branch
│   ├── protect-critical-files.sh   # Warn on critical file edits
│   └── post-edit-lint-reminder.sh  # Remind about formatting
├── rules/
│   └── common/                     # Language-agnostic rules
│       ├── coding-style.md
│       ├── security.md
│       ├── testing.md
│       ├── git-workflow.md
│       ├── development-workflow.md
│       └── performance.md
├── scripts/
│   └── validate.sh                 # Audit your setup
├── examples/
│   └── settings-hooks.json         # Hook config for settings.json
├── install.sh                      # One-command installer
└── README.md
```

## How Hooks Work

Claude Code hooks run shell commands before or after tool executions:

```
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│  Claude says  │───▶│  PreToolUse   │───▶│  Tool runs   │
│  "git push"   │    │  hooks fire   │    │  (if allowed) │
└──────────────┘    └───────────────┘    └──────────────┘
                           │
                    exit 0 = allow
                    exit 2 = BLOCK
```

Hooks are configured in `~/.claude/settings.json` under the `hooks` key. See [examples/settings-hooks.json](examples/settings-hooks.json) for the full configuration.

## Customization

### Add Your Own Protected Files

Edit `hooks/protect-critical-files.sh`:
```bash
PROTECTED_PATTERNS=(
  "index.html"
  "package.json"
  "your-landing-page.html"    # add your files
  "terraform/"                 # add entire directories
)
```

### Add Custom Secrets Patterns

Edit `hooks/pre-push-secrets-scan.sh` — add patterns to the grep:
```bash
SECRETS=$(grep -rnE \
  "(api[_-]?key|your_custom_pattern|STRIPE_SECRET)" \
  ...
```

### Block vs. Warn

Every hook can either warn (exit 0) or block (exit 2):
```bash
# Warn only (default for protect-critical-files)
echo "WARNING: ..." >&2
exit 0

# Hard block (default for secrets-scan)
echo "BLOCKED: ..." >&2
exit 2
```

## FAQ

**Q: Does this slow down Claude Code?**
A: No. Hooks run in milliseconds. The secrets scan greps the codebase but skips `node_modules` and `.git`.

**Q: Can I use this with other AI coding tools?**
A: The rules work with any tool that reads markdown. The hooks are specific to Claude Code's hook system.

**Q: What about false positives in the secrets scan?**
A: The scan ignores `.example`, `.sample`, `.template` files and references to `process.env` / `os.environ`. If you get false positives, add exclusion patterns to the grep.

**Q: I already use pre-commit hooks. Do I need this?**
A: Yes. Claude Code can bypass your pre-commit hooks with `--no-verify`. This repo blocks that. Defense in depth.

## Contributing

PRs welcome. Especially:
- New hook ideas (must be zero-dependency bash)
- Language-specific rules (TypeScript, Python, Go, Rust)
- False positive fixes in secrets scan
- Translations of rules

## License

MIT — use it, fork it, harden everything.

---

<p align="center">
<em>Built from real incidents, not hypotheticals.<br/>
Every rule exists because something went wrong without it.</em>
</p>
