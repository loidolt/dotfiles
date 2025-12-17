# OpenCode Configuration

This directory contains the OpenCode configuration.

## Files

- `opencode.json` - Main OpenCode configuration file
- `.env.example` - Example environment variables for API keys
- `package.json` - OpenCode plugin dependencies
- `agent/` - Custom specialized agents for specific tasks

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
   export AIRTABLE_API_KEY="your-airtable-api-key-here"
   export MAPBOX_ACCESS_TOKEN="your-mapbox-access-token-here"
   ```

2. **Reload your shell** to apply the changes:

   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

3. **Verify the environment variables are set**:

   ```bash
   echo $CONTEXT7_API_KEY
   echo $REF_API_KEY
   echo $AIRTABLE_API_KEY
   echo $MAPBOX_ACCESS_TOKEN
   ```

### Getting API Keys

- **Context7**: Sign up at [context7.com](https://context7.com) to get your API key
- **Ref Tools**: Sign up at [ref.tools](https://ref.tools) to get your API key
- **Airtable**: Create an API key at [airtable.com/create/tokens](https://airtable.com/create/tokens)
- **Mapbox**: Get an access token at [account.mapbox.com/access-tokens](https://account.mapbox.com/access-tokens/)

## Customization

Edit `opencode.json` to customize:
- Theme settings (`theme`)
- MCP server configurations (`mcp`)
- Enable/disable specific MCP servers
- Model preferences

The configuration uses OpenCode's built-in variable substitution with `{env:VARIABLE_NAME}` syntax to securely reference API keys from environment variables.

## Custom Agents

This configuration includes specialized agents for common development tasks:

- **bug-fixer** - Investigates and fixes bugs with minimal scope changes
- **docs-writer** - Creates and maintains project documentation
- **refactor** - Improves code structure and maintainability
- **review** - Reviews code for quality and best practices (read-only)
- **test-writer** - Writes comprehensive tests for existing code

See [`agent/README.md`](agent/README.md) for detailed documentation on each agent and how to create your own.

### Using Agents

- Use **Tab** to cycle through primary agents (Build, Plan)
- Use **@agent-name** to invoke a specific subagent (e.g., `@bug-fixer`, `@review`)
- Create new agents with `opencode agent create`

## MCP Servers

This configuration includes the following MCP servers:

- **context7** - AI-powered code context and search (disabled by default)
- **ref** - Reference documentation lookup (enabled)
- **sequentialthinking** - Advanced reasoning capabilities (enabled, requires Docker)
- **memory** - Persistent memory across conversations (disabled by default, requires Docker)
- **playwright** - Browser automation (enabled, requires npx)
- **github** - GitHub Copilot integration (disabled by default)
- **cloudflare** - Cloudflare documentation and tools (enabled)
- **mui** - Material-UI component documentation (enabled, requires npx)
- **airtable** - Airtable database integration (enabled, requires npx)
- **mapbox** - Mapbox mapping and location services (enabled, requires npx)
