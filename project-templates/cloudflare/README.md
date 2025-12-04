# Cloudflare Workers Development Template

Devbox environment for developing Cloudflare Workers with TypeScript.

## What's Included

- **Node.js 22** - Latest LTS runtime
- **pnpm** - Fast, efficient package manager
- **Wrangler** - Cloudflare Workers CLI
- **TypeScript** - Type-safe development
- **TSServer** - TypeScript language server for IDE support

## Quick Start

### Initialize a New Project

```bash
# Copy this template to your project
cp -r ~/dotfiles/project-templates/cloudflare my-worker
cd my-worker

# Start devbox shell
devbox shell

# Initialize worker (interactive)
devbox run init

# Or initialize with specific options
wrangler init my-worker --type=webpack
```

### Development Workflow

```bash
# Start local development server
devbox run dev

# Deploy to Cloudflare
devbox run deploy

# Watch logs in real-time
devbox run tail

# Run tests
devbox run test
```

### Available Scripts

- `devbox run init` - Initialize new worker project
- `devbox run dev` - Start local development server
- `devbox run deploy` - Deploy to Cloudflare
- `devbox run tail` - Tail worker logs
- `devbox run install` - Install dependencies
- `devbox run test` - Run tests
- `devbox run lint` - Lint code
- `devbox run format` - Format code

## Configuration

### Wrangler Configuration

Edit `wrangler.toml` to configure your worker:

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[env.production]
name = "my-worker-production"
vars = { ENVIRONMENT = "production" }

[env.staging]
name = "my-worker-staging"
vars = { ENVIRONMENT = "staging" }
```

### TypeScript Configuration

Edit `tsconfig.json` for TypeScript settings:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "types": ["@cloudflare/workers-types"]
  }
}
```

## Common Tasks

### Deploy to Different Environments

```bash
# Deploy to staging
wrangler deploy --env staging

# Deploy to production
wrangler deploy --env production
```

### View Logs

```bash
# Tail all logs
wrangler tail

# Filter logs by status code
wrangler tail --status error

# Filter by specific event
wrangler tail --header X-Custom-Header=value
```

### Test Locally

```bash
# Start dev server
wrangler dev

# Test with curl
curl http://localhost:8787

# Test with xh (better curl)
xh GET http://localhost:8787
xh POST http://localhost:8787/api data=value
```

## Example Worker

### Basic TypeScript Worker

```typescript
export interface Env {
  // Define your environment variables here
  ENVIRONMENT: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Handle different routes
    if (url.pathname === '/') {
      return new Response('Hello from Cloudflare Workers!', {
        headers: { 'Content-Type': 'text/plain' }
      });
    }

    if (url.pathname === '/api/health') {
      return Response.json({
        status: 'healthy',
        environment: env.ENVIRONMENT,
        timestamp: new Date().toISOString()
      });
    }

    return new Response('Not Found', { status: 404 });
  },
};
```

### API Worker with JSON

```typescript
export default {
  async fetch(request: Request): Promise<Response> {
    // Parse JSON body
    const data = await request.json();

    // Process data
    const result = {
      received: data,
      processed: true,
      timestamp: Date.now()
    };

    // Return JSON response
    return Response.json(result);
  },
};
```

## Resources

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Reference](https://developers.cloudflare.com/workers/wrangler/)
- [Workers Examples](https://developers.cloudflare.com/workers/examples/)
- [Workers Types](https://github.com/cloudflare/workers-types)

## Tips

- Use `navi --query cloudflare` for quick command reference
- Use `xh` instead of `curl` for easier API testing
- Use `jless` to view API responses interactively
- Check logs with `wrangler tail | jless` for better formatting
