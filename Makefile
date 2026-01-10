# Dotfiles Makefile
# Provides a consistent interface for common operations

.PHONY: install update health-check stow-all uninstall packages help setup-git ssh

# Default target
help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  install      - Full installation (packages + stow)"
	@echo "  update       - Update packages and restow dotfiles"
	@echo "  health-check - Run system health check"
	@echo "  stow-all     - Restow all packages"
	@echo "  uninstall    - Remove all symlinks"
	@echo "  packages     - Install packages only"
	@echo "  setup-git    - Configure git user name and email"
	@echo "  ssh          - Setup GitHub SSH key"
	@echo ""
	@echo "Examples:"
	@echo "  make install      # First-time setup"
	@echo "  make update       # After pulling new changes"
	@echo "  make health-check # Diagnose issues"

install:
	@./install.sh

update:
	@./scripts/update.sh

health-check:
	@./scripts/health-check.sh

stow-all:
	@./stow-all.sh

uninstall:
	@./uninstall.sh

packages:
	@./packages/install.sh

# Interactive git configuration
setup-git:
	@echo "Setting up git user configuration..."
	@read -p "Enter your name: " name && \
		git config --file ~/.gitconfig.local user.name "$$name"
	@read -p "Enter your email: " email && \
		git config --file ~/.gitconfig.local user.email "$$email"
	@echo ""
	@echo "Git configuration saved to ~/.gitconfig.local"
	@echo "Your git identity:"
	@git config user.name
	@git config user.email

# Setup GitHub SSH key
ssh:
	@./scripts/setup-github-ssh.sh
