# Claude Code Configuration

This directory contains centralized configuration for Claude Code, similar to the OpenCode setup in `../opencode/`.

## Files

- `mcp-servers.json` - Centralized MCP server definitions
- `generate-project-mcp.js` - Generate `.mcp.json` for projects
- `sync-mcp-servers.js` - (Alternative) Sync to global config
- `.env.example` - Example environment variables for MCP servers

## MCP Server Management

The `mcp-servers.json` file defines MCP servers that can be deployed to your projects. You have two deployment options:

### Option 1: Project-Scoped (Recommended)
Generate a `.mcp.json` file in your project directory. This file can be committed to version control, making servers available to your whole team.

### Option 2: Global Config
Sync servers to `~/.claude.json` for personal use across all projects (requires Claude CLI in PATH).

### Current Servers

| Server | Type | Description | Requirements |
|--------|------|-------------|--------------|
| **ref** | stdio | Documentation and reference search | `REF_API_KEY` env var |
| **sequentialthinking** | stdio/docker | Advanced reasoning capabilities | Docker installed |
| **playwright** | stdio | Browser automation and testing | None (npx) |
| **cloudflare** | remote | Cloudflare documentation access | None (via mcp-remote) |
| **mui** | stdio | Material-UI documentation | None (npx) |

**Server Types:**
- **stdio**: Local process servers (run on your machine)
- **remote**: HTTP-based servers (accessed via `mcp-remote` proxy)
- **docker**: Containerized servers

### Quick Start

```bash
# 1. Set up environment variables in ~/.zshrc
echo 'export REF_API_KEY="your_key_here"' >> ~/.zshrc
source ~/.zshrc

# 2. Generate .mcp.json in your project
cd ~/path/to/project
node ~/Documents/GitHub/dotfiles/claude/generate-project-mcp.js

# 3. Launch Claude Code from terminal (to inherit env vars)
open -a Claude

# 4. Restart Claude Code and approve MCP servers
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
   node ~/Documents/GitHub/dotfiles/claude/generate-project-mcp.js
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
   node ~/Documents/GitHub/dotfiles/claude/sync-mcp-servers.js
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
   node ~/Documents/GitHub/dotfiles/claude/generate-project-mcp.js
   ```
2. Restart Claude Code and approve the new server

### Environment Variables

MCP servers often require API keys or other environment variables. Claude Code supports environment variable expansion in `.mcp.json` files using the syntax: `${VAR_NAME}` or `${VAR_NAME:-default_value}`

**Recommended approach:**

1. **Use environment variable expansion in `mcp-servers.json`**:
   ```json
   {
     "mcpServers": {
       "ref": {
         "command": "npx",
         "args": ["-y", "@ref-tools/mcp-server"],
         "env": {
           "REF_API_KEY": "${REF_API_KEY}"
         }
       }
     }
   }
   ```

2. **Set actual values in your shell profile** (`~/.zshrc`, `~/.bashrc`, etc.):
   ```bash
   export REF_API_KEY="your_actual_key_here"
   ```

3. **Restart your terminal** and launch Claude Code from the terminal to inherit env vars

**Why this approach?**
- ✅ Safe to commit `.mcp.json` to version control
- ✅ Each team member uses their own API keys
- ✅ No secrets stored in the repository
- ✅ Follows Claude Code's documented best practices

**Alternative (not recommended for committed configs):**
- Put the actual API key directly in the config: `"REF_API_KEY": "actual_key_123"`
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

The global `globalMcpServers` approach in `~/.claude.json` has limitations:
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
1. Check that `~/.claude.json` has a `globalMcpServers` section
2. Restart Claude Code completely
3. Note: This method may not work reliably without the CLI
4. Consider using project-scoped configuration instead

### Environment variables not working

1. **Check if env vars are set**:
   ```bash
   echo $REF_API_KEY
   # Should show your key, not empty
   ```

2. **Ensure variables are exported in your shell profile** (`~/.zshrc` for zsh):
   ```bash
   export REF_API_KEY="your_key_here"
   export CONTEXT7_API_KEY="your_key_here"
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
     "REF_API_KEY": "${REF_API_KEY}"  // ✅ Correct
     // NOT: "REF_API_KEY": ""         // ❌ Won't expand
     // NOT: "REF_API_KEY": "{env:...}" // ❌ Wrong syntax
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
