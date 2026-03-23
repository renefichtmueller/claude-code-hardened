# Performance

> Practical rules for AI-assisted development that don't waste tokens or time.

## Model Routing

Not every task needs the most expensive model:

| Task | Model Tier | Examples |
|------|-----------|---------|
| Light | Haiku/Fast | Documentation, simple edits, formatting |
| Medium | Sonnet | Feature implementation, code review, testing |
| Heavy | Opus | Architecture decisions, complex debugging, security audit |

## Context Window Discipline

The last 20% of the context window degrades output quality. Plan accordingly:

**High context tasks** (start fresh if needed):
- Large-scale refactoring
- Multi-file feature implementation
- Complex debugging sessions

**Low context tasks** (safe at any point):
- Single-file edits
- Utility creation
- Documentation updates
- Simple bug fixes

## Parallel Execution

Always parallelize independent tasks:

```
SLOW: Agent 1 → wait → Agent 2 → wait → Agent 3
FAST: Agent 1 ─┐
      Agent 2 ─┤→ all done
      Agent 3 ─┘
```

Rule: If tasks don't share state, run them in parallel.
