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

- **sequentialthinking** - Advanced reasoning capabilities (enabled, requires Docker)
- **memory** - Persistent memory across conversations (disabled by default, requires Docker)
- **playwright** - Browser automation (enabled, requires npx)
- **github** - GitHub Copilot integration (disabled by default)
- **looker** - Looker BI platform integration (enabled, requires toolbox binary)

### Playwright MCP Setup

The Playwright MCP server enables browser automation capabilities. It requires:

1. **Node.js/npx** - For running the MCP server
2. **Chromium browser** - Pre-installed for faster startup

**Automatic Installation:**

The dotfiles package installer automatically sets up Playwright:

```bash
cd ~/dotfiles && ./packages/install.sh
```

**Manual Installation:**

If you need to install Playwright browsers manually:

```bash
# Install Chromium for Playwright
npx -y playwright install chromium
```

**Verify Installation:**

Run the health check to verify MCP dependencies:

```bash
./scripts/health-check.sh
```

**Troubleshooting:**

If Playwright fails to start:

1. Check browsers are installed:
   - **macOS**: `ls ~/Library/Caches/ms-playwright`
   - **Linux**: `ls ~/.cache/ms-playwright`
2. Reinstall browsers: `npx -y playwright install chromium`
3. On Linux, install system dependencies: `npx playwright install-deps chromium`
4. On macOS, ensure Xcode Command Line Tools are installed: `xcode-select --install`

### Docker-based MCP Servers

Some MCP servers run in Docker containers:

```bash
# Pull sequentialthinking image
docker pull mcp/sequentialthinking

# Pull memory image (if needed)
docker pull mcp/memory
```

### Looker MCP Setup

The Looker MCP server enables integration with Looker BI platform for querying models, explores, dimensions, measures, and saved content.

**Prerequisites:**

1. **Google MCP Toolbox** - Download the toolbox binary from [GitHub releases](https://github.com/googleapis/genai-toolbox/releases)
2. **Looker API Credentials** - Get Client ID and Secret from your Looker instance

**Installation:**

```bash
# macOS (Apple Silicon)
curl -O https://storage.googleapis.com/genai-toolbox/v0.24.0/darwin/arm64/toolbox
chmod +x toolbox
mv toolbox /usr/local/bin/

# macOS (Intel)
curl -O https://storage.googleapis.com/genai-toolbox/v0.24.0/darwin/amd64/toolbox
chmod +x toolbox
mv toolbox /usr/local/bin/

# Linux (amd64)
curl -O https://storage.googleapis.com/genai-toolbox/v0.24.0/linux/amd64/toolbox
chmod +x toolbox
sudo mv toolbox /usr/local/bin/
```

**Configuration:**

Add these environment variables to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export LOOKER_BASE_URL="https://looker.example.com"
export LOOKER_CLIENT_ID="your_client_id"
export LOOKER_CLIENT_SECRET="your_client_secret"
```

**Getting Looker API Credentials:**

Follow the [Looker API authentication guide](https://cloud.google.com/looker/docs/api-auth#authentication_with_an_sdk) to generate API credentials.

**Available Tools:**

- Query models, explores, dimensions, and measures
- Run queries and retrieve SQL
- Manage Looks and Dashboards
- LookML authoring and project file management
- Instance health monitoring
