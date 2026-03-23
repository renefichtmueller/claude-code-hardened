# Security

> Mandatory security checklist before ANY commit or push.

## Pre-Commit Security Checklist

- [ ] No hardcoded secrets (API keys, passwords, tokens, connection strings)
- [ ] All user inputs validated and sanitized
- [ ] SQL injection prevention (parameterized queries only)
- [ ] XSS prevention (sanitized HTML output)
- [ ] CSRF protection enabled on all state-changing endpoints
- [ ] Authentication verified on all protected routes
- [ ] Authorization checked (not just authentication)
- [ ] Rate limiting on all public endpoints
- [ ] Error messages don't leak internal details
- [ ] No sensitive data in logs
- [ ] No sensitive data in URL parameters

## Secret Management

```
WRONG:  const API_KEY = "sk-abc123..."
WRONG:  // TODO: move to env
RIGHT:  const API_KEY = process.env.API_KEY ?? throw new Error("API_KEY required")
```

Rules:
- NEVER hardcode secrets in source code
- ALWAYS use environment variables or a secret manager
- Validate all required secrets at startup (fail fast)
- Rotate any secret that may have been exposed
- Add `.env*` and credential files to `.gitignore`

## Minimum `.gitignore` for Security

```gitignore
# Secrets
.env
.env.*
.dev.vars
*.local
wrangler.toml
credentials.json
service-account.json
*.pem
*.key

# Build artifacts that may contain inlined secrets
dist/
build/
.next/
```

## Response Protocol

If a security issue is found:
1. **STOP** — don't push, don't deploy
2. Assess the blast radius
3. Fix the issue
4. Rotate any exposed secrets
5. Search the entire codebase for similar patterns
6. Add a test to prevent regression
