# Coding Style

> Battle-tested rules from 200+ Claude Code sessions across production projects.

## Immutability First

ALWAYS create new objects, NEVER mutate existing ones:

```
WRONG:  user.name = "new"          // mutates in place
RIGHT:  const updated = { ...user, name: "new" }  // new object
```

Why: Prevents hidden side effects, makes debugging trivial, enables safe concurrency.

## File Organization

**Many small files > few large files.**

| Metric | Target | Maximum |
|--------|--------|---------|
| Lines per file | 200-400 | 800 |
| Lines per function | 15-30 | 50 |
| Nesting depth | 2-3 | 4 |
| Parameters per function | 2-3 | 5 |

Extract when a file exceeds 400 lines. Organize by feature/domain, not by type.

## Error Handling

```
WRONG:  try { ... } catch (e) { /* silence */ }
WRONG:  catch (e) { console.log(e) }
RIGHT:  catch (e) { logger.error('Context:', { error: e, input }); throw new AppError(...) }
```

Rules:
- Handle errors explicitly at every level
- User-facing code: friendly messages
- Server-side: detailed context in logs
- Never swallow errors silently
- Always include the operation context

## Input Validation

Validate at every system boundary:
- All user input before processing
- All API responses before using
- All file content before parsing
- All environment variables at startup

Fail fast with clear error messages. Never trust external data.

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling everywhere
- [ ] No hardcoded values (use constants/config)
- [ ] No mutation (immutable patterns used)
- [ ] No `any` types (TypeScript) or equivalent
