# Development Workflow

> The full pipeline from idea to production. Every step exists because skipping it caused a bug.

## The Pipeline

```
Research → Plan → Test → Code → Review → Push
```

Not `Code → Maybe Test → Push → Fix in Prod`.

## Step 0: Research & Reuse

Before writing ANY code:
1. **Search for existing solutions** — GitHub, npm, PyPI, crates.io
2. **Read the docs** — don't guess at API behavior
3. **Check for prior art** — someone probably solved this already
4. Prefer battle-tested libraries over hand-rolled solutions
5. If you find an 80% match, fork/wrap it — don't rewrite from scratch

## Step 1: Plan

For any task that takes more than 30 minutes:
- Write down what you're building (1-3 sentences)
- List the files you'll change
- Identify dependencies and risks
- Break into phases if complex

## Step 2: TDD

See [testing.md](./testing.md) for the full TDD workflow.

## Step 3: Code

- Follow [coding-style.md](./coding-style.md)
- Follow [security.md](./security.md)
- Small commits, each one compiles and passes tests

## Step 4: Review

After writing code, review it yourself:
- Read every line of the diff
- Check for security issues
- Check for performance issues
- Check for edge cases
- Would a new team member understand this code?

## Step 5: Push

See [git-workflow.md](./git-workflow.md) for commit/PR conventions.
The security hooks in this repo automate the pre-push checks.
