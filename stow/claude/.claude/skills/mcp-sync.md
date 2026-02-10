# MCP Server Management

Manage Model Context Protocol server configurations.

---

/mcp-sync [action] [server]

---

Manage MCP server configurations for Claude Code.

## Actions

- `status` - Show enabled/disabled MCP servers
- `enable <server>` - Enable an MCP server
- `disable <server>` - Disable an MCP server
- `list` - List all configured MCP servers
- `add` - Add a new MCP server configuration

## Configuration Locations

- **Global**: `~/.config/claude/mcp-servers.json` - Server definitions
- **Project**: `.claude/settings.local.json` - Enable/disable per project

## How It Works

MCP servers are defined in `mcp-servers.json` and can be selectively disabled per-project using the `disabledMcpjsonServers` array in settings.

## Usage Examples

```
/mcp-sync status              # See current state
/mcp-sync list                # Show all available servers
/mcp-sync enable playwright   # Enable browser automation
/mcp-sync disable filesystem  # Disable in current project
```

## Common MCP Servers

- `playwright` - Browser automation and testing
- `filesystem` - Enhanced file operations
- `github` - GitHub API integration
- `sequentialthinking` - Structured reasoning

## Implementation

1. Read `~/.config/claude/mcp-servers.json` for available servers
2. Read `.claude/settings.local.json` for disabled list
3. For enable: Remove from `disabledMcpjsonServers` array
4. For disable: Add to `disabledMcpjsonServers` array
5. Write updated settings

## Output Format

```
=== MCP Server Status ===

Enabled:
  ✓ playwright - npx @playwright/mcp@latest
  ✓ github - gh-mcp

Disabled (this project):
  ✗ sequentialthinking
  ✗ filesystem
```
