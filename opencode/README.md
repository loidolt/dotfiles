# OpenCode Configuration

This directory contains the OpenCode configuration.

## Files

- `opencode.json` - Main OpenCode configuration file
- `.env.example` - Example environment variables for API keys
- `package.json` - OpenCode plugin dependencies

## Installation

The configuration will be symlinked to `~/.config/opencode/` by the install script.

## Setting Up API Keys

This configuration uses environment variables to keep API keys secure and out of version control.

### Setup Steps

1. **Add your API keys to your shell profile** (`~/.zshrc` or `~/.bashrc`):

   ```bash
   # OpenCode MCP Server API Keys
   export CONTEXT7_API_KEY="your-context7-api-key-here"
   export REF_API_KEY="your-ref-api-key-here"
   ```

2. **Reload your shell** to apply the changes:

   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

3. **Verify the environment variables are set**:

   ```bash
   echo $CONTEXT7_API_KEY
   echo $REF_API_KEY
   ```

### Getting API Keys

- **Context7**: Sign up at [context7.com](https://context7.com) to get your API key
- **Ref Tools**: Sign up at [ref.tools](https://ref.tools) to get your API key

## Customization

Edit `opencode.json` to customize:
- Theme settings (`theme`)
- MCP server configurations (`mcp`)
- Enable/disable specific MCP servers
- Model preferences

The configuration uses OpenCode's built-in variable substitution with `{env:VARIABLE_NAME}` syntax to securely reference API keys from environment variables.

## MCP Servers

This configuration includes the following MCP servers:

- **context7** - AI-powered code context and search (disabled by default)
- **ref** - Reference documentation lookup (enabled)
- **sequentialthinking** - Advanced reasoning capabilities (enabled, requires Docker)
- **memory** - Persistent memory across conversations (enabled, requires Docker)
- **playwright** - Browser automation (enabled, requires npx)
- **github** - GitHub Copilot integration (disabled by default)
