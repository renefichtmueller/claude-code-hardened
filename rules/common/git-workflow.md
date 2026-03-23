# Git Workflow

> Conventions that prevent "it worked on my machine" disasters.

## Commit Message Format

```
<type>: <description>

<optional body explaining why, not what>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

Examples:
```
feat: add rate limiting to auth endpoints
fix: prevent race condition in session refresh
refactor: extract validation logic from controller
test: add integration tests for payment webhook
```

## Branch Strategy

```
main (protected, no direct push)
  └── feat/add-user-auth
  └── fix/session-timeout
  └── refactor/extract-db-layer
```

Rules:
- Never push directly to main/master
- Feature branches from main
- Squash or rebase before merge (clean history)
- Delete branch after merge

## Pre-Push Checklist

Before every push:
- [ ] All tests pass locally
- [ ] No hardcoded secrets (run secrets scan)
- [ ] No private IPs or internal URLs
- [ ] No debug/console.log left in code
- [ ] Commit messages follow convention
- [ ] Branch is rebased on latest main

## PR Description Template

```markdown
## What
<1-3 bullet points>

## Why
<Context and motivation>

## How to Test
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Checklist
- [ ] Tests added/updated
- [ ] No secrets in diff
- [ ] Documentation updated (if needed)
```
