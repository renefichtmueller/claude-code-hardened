# Testing

> TDD is not optional. Code without tests is a liability.

## Coverage Target: 80%+

| Type | What | When |
|------|------|------|
| Unit | Individual functions, utilities | Every function |
| Integration | API endpoints, DB operations | Every endpoint |
| E2E | Critical user flows | Every release |

## Test-Driven Development

Mandatory workflow for every feature and bug fix:

```
1. Write test        → should FAIL (RED)
2. Run test          → confirm it fails
3. Write minimal code → should PASS (GREEN)
4. Run test          → confirm it passes
5. Refactor          → improve code quality
6. Run all tests     → nothing broke
7. Check coverage    → 80%+
```

Why this order matters:
- Writing tests first forces you to think about the interface before the implementation
- A test that passes before you write code doesn't test anything
- Refactoring with tests is safe; without tests it's gambling

## Test Quality Rules

- Test behavior, not implementation
- One assertion per test (or one logical group)
- Tests must be independent (no shared state between tests)
- Tests must be deterministic (no flaky tests in CI)
- Mock external dependencies, not internal logic
- Name tests like sentences: `should return 404 when user not found`

## When Tests Fail

1. **Read the error message** — it usually tells you what's wrong
2. Check test isolation — is shared state leaking?
3. Verify mocks are correct — stale mocks cause phantom failures
4. Fix the implementation, not the test (unless the test is wrong)
5. If you need to change a test, explain why in the commit message
