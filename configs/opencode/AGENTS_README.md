# OpenCode Custom Agents

This directory contains specialized agents for OpenCode that can be invoked for specific tasks.

## Available Agents

### bug-fixer
**Type:** Subagent  
**Model:** Claude Sonnet 4  
**Description:** Investigates and fixes bugs with minimal scope changes

Focuses on:
- Understanding error messages and stack traces
- Locating root causes
- Implementing minimal, surgical fixes
- Testing fixes to ensure no new issues

**Usage:** `@bug-fixer fix the null pointer exception in user.service.ts`

---

### docs-writer
**Type:** Subagent  
**Model:** Claude Sonnet 4  
**Description:** Writes and maintains clear, comprehensive project documentation

Focuses on:
- README files
- API documentation
- Tutorials and guides
- Architecture documentation
- Markdown best practices

**Usage:** `@docs-writer create API documentation for the user service`

---

### refactor
**Type:** Subagent  
**Model:** Claude Sonnet 4  
**Description:** Refactors code to improve structure, readability, and maintainability

Focuses on:
- Extracting duplicated code
- Simplifying complex conditionals
- Improving naming and organization
- Preserving behavior (tests must pass)
- Applying SOLID principles

**Usage:** `@refactor improve the authentication module`

---

### review
**Type:** Subagent  
**Model:** Claude Sonnet 4  
**Description:** Reviews code for quality and best practices

Focuses on:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations
- Maintainability

**Note:** This is a read-only agent that provides feedback without making changes.

**Usage:** `@review check this PR for potential issues`

---

### test-writer
**Type:** Subagent  
**Model:** Claude Sonnet 4  
**Description:** Writes comprehensive tests for existing code

Focuses on:
- Unit, integration, and e2e tests
- Happy paths and edge cases
- Error handling scenarios
- Arrange-Act-Assert pattern
- Framework-specific best practices

**Usage:** `@test-writer create unit tests for the payment processor`

---

## Creating New Agents

You can create new agents using the interactive command:

```bash
opencode agent create
```

Or manually by creating a new `.md` file in this directory with the following structure:

```markdown
---
description: Brief description of what the agent does
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: true
  edit: true
  bash: true
---

Your agent's system prompt goes here.
Explain what the agent should focus on and how it should behave.
```

## Agent Configuration Options

### Required Fields
- `description`: Brief description for when the agent should be invoked
- `mode`: Either `primary`, `subagent`, or `all`

### Optional Fields
- `model`: Override the default model
- `temperature`: Control creativity (0.0-1.0, default varies by model)
- `tools`: Enable/disable specific tools
- `permission`: Fine-grained permission control for tools

### Tool Configuration
```yaml
tools:
  write: true    # Allow creating new files
  edit: true     # Allow editing existing files
  bash: true     # Allow running shell commands
  read: true     # Allow reading files (default: true)
  glob: true     # Allow file pattern matching (default: true)
  grep: true     # Allow content search (default: true)
```

### Permission Configuration
```yaml
permission:
  edit: ask      # Options: allow, ask, deny
  bash:
    "git *": allow
    "*": ask
  webfetch: allow
```

## Documentation

For more information about agents, see:
- [OpenCode Agent Documentation](https://opencode.ai/docs/agents/)
- Main README: `../README.md`

## Tips

- Use **Tab** to cycle through primary agents
- Use **@agent-name** to invoke specific subagents
- Agents work best when given clear, specific tasks
- Review agent prompts to understand their strengths
- Create specialized agents for your specific workflows
