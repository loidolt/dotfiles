# Claude Code Configuration

This directory is managed by GNU Stow as part of the dotfiles repository.

## Files

- `mcp-servers.json` - Centralized MCP server definitions
- `generate-project-mcp.js` - Generate `.mcp.json` for projects
- `sync-mcp-servers.js` - Sync servers to global `~/.claude.json`

## MCP Server Management

The `mcp-servers.json` file defines MCP servers that can be deployed to your projects.

### Current Servers

| Server | Type | Description |
|--------|------|-------------|
| **sequentialthinking** | docker | Advanced reasoning capabilities |
| **playwright** | stdio | Browser automation and testing |
| **cloudflare** | remote | Cloudflare documentation access |
| **mui** | stdio | Material-UI documentation |

### Usage

#### Option 1: Project-Scoped MCP Servers (Recommended)

Generate a `.mcp.json` file in your project:

```bash
cd ~/path/to/your/project
node ~/.config/claude/generate-project-mcp.js
```

Restart Claude Code and approve the MCP servers when prompted.

#### Option 2: Global MCP Servers

Sync servers to `~/.claude.json` for personal use across all projects:

```bash
node ~/.config/claude/sync-mcp-servers.js
```

Restart Claude Code to load the servers.

### Adding New MCP Servers

Edit `mcp-servers.json` and add your server configuration. See the main dotfiles documentation for examples.

## Installation

This configuration is automatically managed via GNU Stow when you run:

```bash
cd ~/Documents/GitHub/dotfiles
stow -t ~ stow/claude
```

Or install all dotfiles:

```bash
./install.sh
```
