# Claude Code Configuration

This directory (`~/.config/claude/` when stowed) contains helper scripts and templates for managing Claude Code MCP servers.

## Important: Configuration Locations

Claude Code uses these configuration locations:

| Path | Purpose | Stowable? |
|------|---------|-----------|
| `~/.claude.json` | Global config (including `mcpServers`) | **No** - contains runtime data |
| `~/.claude/` | Data directory (history, cache, settings) | **No** - runtime data |
| `~/.config/claude/` | Helper scripts and templates (this directory) | **Yes** |
| `.mcp.json` | Project-scoped MCP servers | N/A - per project |

**Note:** `~/.claude.json` cannot be stowed because Claude Code stores runtime data (project stats, tips history, caches) in the same file as configuration. Use `sync-mcp-servers.js` to merge server definitions into your existing `~/.claude.json`.

## Files

- `mcp-servers.json` - Centralized MCP server definitions (source of truth)
- `generate-project-mcp.js` - Generate `.mcp.json` for projects
- `sync-mcp-servers.js` - Sync/merge servers to `~/.claude.json`
- `.env.example` - Example environment variables for MCP servers

## MCP Server Management

The `mcp-servers.json` file defines MCP servers that can be deployed. You have two deployment options:

### Option 1: Project-Scoped (Recommended)
Generate a `.mcp.json` file in your project directory. This file can be committed to version control, making servers available to your whole team.

### Option 2: Global Config
Sync servers to `~/.claude.json` for personal use across all projects.

### Global Servers (in mcp-servers.json)

| Server | Type | Description | Requirements |
|--------|------|-------------|--------------|
| **sequentialthinking** | docker | Advanced reasoning capabilities | Docker installed |
| **playwright** | stdio | Browser automation and testing | None (npx) |

### Project-Specific Servers (in .mcp.json files)

Use `generate-project-mcp.js` to add these to projects as needed:

| Server | Type | Description | Requirements |
|--------|------|-------------|--------------|
| **cloudflare** | remote | Cloudflare documentation access | None (via mcp-remote) |
| **mui** | stdio | Material-UI documentation | None (npx) |
| **looker** | stdio | Looker BI platform integration | Google MCP Toolbox |
| **ref** | stdio | Reference tools | REF_API_KEY env var |

**Server Types:**
- **stdio**: Local process servers (run on your machine)
- **remote**: HTTP-based servers (accessed via `mcp-remote` proxy)
- **docker**: Containerized servers

### Quick Start

```bash
# 1. Generate .mcp.json in your project
cd ~/path/to/project
node ~/.config/claude/generate-project-mcp.js

# 2. Restart Claude Code and approve MCP servers
```

## Usage

### Option 1: Project-Scoped MCP Servers (Recommended)

This creates a `.mcp.json` file in your project that Claude Code will automatically detect:

1. Navigate to your project directory:
   ```bash
   cd ~/path/to/your/project
   ```

2. Generate the `.mcp.json` file:
   ```bash
   node ~/.config/claude/generate-project-mcp.js
   ```

3. Restart Claude Code and approve the MCP servers when prompted

4. (Optional) Commit `.mcp.json` to share with your team:
   ```bash
   git add .mcp.json
   git commit -m "Add MCP server configuration"
   ```

### Option 2: Global MCP Servers

This syncs servers to `~/.claude.json` for personal use across all projects:

1. Ensure the `claude` CLI is in your PATH (run `which claude` to verify)

2. Run the sync script:
   ```bash
   node ~/.config/claude/sync-mcp-servers.js
   ```

   The script automatically creates a timestamped backup of your `~/.claude.json` before making changes.

3. Restart Claude Code to load the servers

### Adding New MCP Servers

Edit `mcp-servers.json` and add your server configuration based on the server type:

**For stdio servers (local NPM packages):**
```json
{
  "mcpServers": {
    "your-server": {
      "command": "npx",
      "args": ["-y", "@your/mcp-server"],
      "env": {
        "API_KEY": "${YOUR_API_KEY}"
      }
    }
  }
}
```

**For remote HTTP servers:**
```json
{
  "mcpServers": {
    "remote-server": {
      "command": "npx",
      "args": ["mcp-remote", "https://api.example.com/mcp"]
    }
  }
}
```

**For Docker-based servers:**
```json
{
  "mcpServers": {
    "docker-server": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "vendor/image-name"]
    }
  }
}
```

**After adding a server:**
1. Regenerate `.mcp.json` in your project(s):
   ```bash
   node ~/.config/claude/generate-project-mcp.js
   ```
2. Restart Claude Code and approve the new server

### Environment Variables

MCP servers often require API keys or other environment variables. Claude Code supports environment variable expansion in `.mcp.json` files using the syntax: `${VAR_NAME}` or `${VAR_NAME:-default_value}`

**Recommended approach:**

1. **Use environment variable expansion in `mcp-servers.json`** when needed:
   ```json
   {
     "mcpServers": {
       "your-server": {
         "command": "npx",
         "args": ["-y", "@your/mcp-server"],
         "env": {
           "YOUR_API_KEY": "${YOUR_API_KEY}"
         }
       }
     }
   }
   ```

2. **Set actual values in your shell profile** (`~/.zshrc`, `~/.bashrc`, etc.):
   ```bash
   export YOUR_API_KEY="your_actual_key_here"
   ```

3. **Restart your terminal** and launch Claude Code from the terminal to inherit env vars

**Why this approach?**
- ✅ Safe to commit `.mcp.json` to version control
- ✅ Each team member uses their own API keys
- ✅ No secrets stored in repository
- ✅ Follows Claude Code's documented best practices

## Security Considerations

⚠️ **Important**: MCP servers can execute arbitrary commands on your system. When approving MCP servers:

1. **Review server configurations** before approving
2. **Only enable servers you trust** from reputable sources
3. **Check command arguments** - avoid servers with excessive permissions
4. **Use environment variables** for API keys (never hardcode secrets)
5. **Regularly audit** enabled servers in Claude Code settings

### Server Types and Risks

- **stdio servers**: Run locally with full system access
- **remote servers**: Access external APIs (verify URLs are legitimate)
- **docker servers**: Run in containers (more isolated, but still need review)

### Best Practices

- Use project-scoped `.mcp.json` files (team visibility)
- Review changes to MCP configurations in pull requests
- Prefer official or well-maintained MCP servers
- Keep MCP server packages updated

**Alternative (not recommended for committed configs):**
- Put the actual API key directly in the config: `"YOUR_API_KEY": "actual_key_123"`
- Only use this for local-only configurations

## Per-Project MCP Servers

While this setup manages global MCP servers, you can still add project-specific servers:

1. In your project directory, add servers to `.claude.json`:
   ```json
   {
     "mcpServers": {
       "project-specific-server": {
         "command": "npx",
         "args": ["-y", "@specific/server"]
       }
     }
   }
   ```

2. Or use Claude Code's built-in commands:
   - Type `#mcp` in chat to manage servers
   - Use `@mcp-server-name` to interact with specific servers

## Syncing Across Machines

Since this configuration is in your dotfiles repo:

1. Commit and push changes to `mcp-servers.json`
2. On other machines, pull the latest dotfiles
3. Run `./sync-mcp-servers.js` to update the local Claude Code config

## MCP Configuration Locations

This dotfiles repository has MCP configurations in multiple places. Here's how they relate:

| Location | Purpose | Format | Used By |
|----------|---------|--------|---------|
| `stow/claude/.config/claude/mcp-servers.json` | Global MCP server definitions | Claude format | `generate-project-mcp.js`, `sync-mcp-servers.js` |
| `.mcp.json` (project root) | Project-specific MCP config | Claude format | Claude Code (when working on that project) |
| `stow/opencode/.config/opencode/opencode.json` | OpenCode-specific MCP configuration | OpenCode format | OpenCode editor |

**Key Differences:**

- **Claude format**: Uses `command`, `args`, `env` structure
- **OpenCode format**: Uses `type`, `enabled`, `command`/`url` structure

**Workflow:**
1. Define global servers in `~/.config/claude/mcp-servers.json` (via stow)
2. Run `node ~/.config/claude/generate-project-mcp.js` to create `.mcp.json` files for projects
3. OpenCode config at `~/.config/opencode/opencode.json` is maintained separately

## Comparison with OpenCode

| Feature | OpenCode | Claude Code |
|---------|----------|-------------|
| Config location | `opencode.json` in project | `~/.claude.json` globally + per-project `.claude.json` |
| MCP format | Custom format with `type`, `enabled`, `url`/`command` | Standard MCP format with `command`, `args`, `env` |
| Global servers | Per-project only | Global + per-project |
| Sync mechanism | Manual file copy | Script-based merge |

## Backup and Recovery

The sync script automatically creates a timestamped backup before modifying `~/.claude.json`:
- Backups are stored as `~/.claude.json.backup-YYYY-MM-DDTHH-MM-SS`
- To restore from a backup: `cp ~/.claude.json.backup-YYYY-MM-DDTHH-MM-SS ~/.claude.json`

### Manual Backup

Before syncing, you can also create a manual backup:
```bash
cp ~/.claude.json ~/.claude.json.manual-backup
```

## Why Project-Scoped is Recommended

The global `mcpServers` approach in `~/.claude.json` has limitations:
- Requires the `claude` CLI to be in your PATH
- Not officially documented as the primary method
- Harder to share configurations with teams

The project-scoped `.mcp.json` approach is better because:
- Works immediately without CLI setup
- Can be committed to version control
- Official Claude Code standard for team sharing
- Clear approval workflow for security

## Troubleshooting

### MCP servers not appearing in Claude Code

**For project-scoped servers (.mcp.json):**
1. Verify `.mcp.json` exists in your project root
2. Restart Claude Code completely
3. When prompted, approve the MCP servers
4. Run `/mcp` in Claude Code to verify servers are loaded
5. If not prompted, run `claude mcp reset-project-choices` (requires CLI)

**For global servers (~/.claude.json):**
1. Check that `~/.claude.json` has a `mcpServers` section
2. Restart Claude Code completely
3. Note: This method may not work reliably without the CLI
4. Consider using project-scoped configuration instead

### Environment variables not working

1. **Check if env vars are set**:
   ```bash
   echo $YOUR_API_KEY
   # Should show your key, not empty
   ```

2. **Ensure variables are exported in your shell profile** (`~/.zshrc` for zsh):
   ```bash
   export YOUR_API_KEY="your_key_here"
   ```

3. **Restart your terminal** to reload the profile:
   ```bash
   source ~/.zshrc  # or just close and reopen terminal
   ```

4. **Launch Claude Code from the terminal** (not from Dock/Finder):
   ```bash
   open -a Claude
   # or just type 'claude' if CLI is in PATH
   ```

5. **Verify the config syntax** in `.mcp.json`:
   ```json
   "env": {
     "YOUR_API_KEY": "${YOUR_API_KEY}"  // ✅ Correct
     // NOT: "YOUR_API_KEY": ""         // ❌ Won't expand
     // NOT: "YOUR_API_KEY": "{env:...}" // ❌ Wrong syntax
   }
   ```

### Servers disabled after sync

- The sync script only updates server definitions, not enabled/disabled state
- Enable servers in Claude Code using the `#mcp` command

## Common MCP Server Configurations

Here are some popular MCP servers and their correct configurations:

```json
{
  "mcpServers": {
    // Remote servers (via mcp-remote)
    "github": {
      "command": "npx",
      "args": ["mcp-remote", "https://api.githubcopilot.com/mcp/"]
    },
    "notion": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.notion.com/mcp"]
    },
    "stripe": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.stripe.com"]
    },
    
    // Local stdio servers
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    
    // Docker-based servers
    "memory": {
      "command": "docker",
      "args": ["run", "-i", "-v", "claude-memory:/app/dist", "--rm", "mcp/memory"]
    }
  }
}
```

**Note:** Always check the official documentation for each MCP server as configurations may change.

## Additional Resources

- [Claude Code MCP Documentation](https://docs.claude.com/en/docs/claude-code/mcp)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Available MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Cloudflare MCP Docs](https://developers.cloudflare.com/agents/model-context-protocol/)
