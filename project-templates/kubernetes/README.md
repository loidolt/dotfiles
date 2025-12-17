# Kubernetes Project Template

This template provides a complete Kubernetes development environment using devbox.

## Tools Included

- **kubectl** - Kubernetes command-line tool
- **helm** - Kubernetes package manager
- **k9s** - Terminal UI for Kubernetes
- **argocd** - GitOps continuous delivery tool
- **grpcurl** - cURL for gRPC services

## Quick Start

1. Copy `devbox.json` to your Kubernetes project root
2. Run `devbox shell` to enter the environment
3. All tools will be available in your PATH

## Usage

### Enter the development shell
```bash
devbox shell
```

### Run scripts
```bash
# Check cluster connection
devbox run check-cluster

# Launch K9s dashboard
devbox run dashboard
```

### Install packages
```bash
# Install dependencies
devbox install

# Update packages
devbox update
```

## Customization

Edit `devbox.json` to add or remove packages. Search for packages at:
https://www.nixhub.io (Devbox package search)
