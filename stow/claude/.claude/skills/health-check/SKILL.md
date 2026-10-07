# Project Health Check

Diagnose project setup and environment.

---

/health-check [area]

---

Run diagnostic checks on project setup and development environment.

## Areas

- `all` - Full check (default)
- `deps` - Dependency status (package.json, requirements.txt, etc.)
- `tools` - Required development tools
- `git` - Git repository status
- `env` - Environment variables and config files

## Checks Performed

### Dependencies
- Detect package manager (npm, yarn, pip, cargo, go mod)
- Check if dependencies are installed
- Look for outdated or vulnerable packages
- Verify lock file exists and is current

### Development Tools
- Language runtime (node, python, go, rust)
- Build tools (make, cmake, webpack)
- Linters and formatters
- Test frameworks

### Git Status
- Clean working tree
- Branch status (ahead/behind remote)
- Uncommitted changes
- Untracked files

### Environment
- Required environment variables set
- Config files present (.env, config files)
- Correct file permissions

## Output Format

```
=== Project Health Check ===

[✓] Dependencies: node_modules up to date
[✓] Tools: node 20.11.0, npm 10.2.0
[!] Git: 2 uncommitted changes
[✓] Environment: .env present

Issues found: 1
  - Uncommitted changes in src/config.ts
```

## Usage

```
/health-check         # Full check
/health-check deps    # Just dependencies
/health-check git     # Just git status
```
