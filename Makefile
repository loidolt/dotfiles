.PHONY: switch update validate health clean check help

# Default target
help:
	@echo "Available targets:"
	@echo "  switch    - Rebuild home-manager configuration"
	@echo "  update    - Update flake inputs and rebuild"
	@echo "  validate  - Validate Nix configuration"
	@echo "  health    - Run health check"
	@echo "  clean     - Clean old Nix generations"
	@echo "  check     - Check flake syntax"
	@echo "  help      - Show this help"

# Rebuild home-manager configuration
switch:
	home-manager switch --flake . --impure

# Update flake inputs and rebuild
update:
	nix flake update
	$(MAKE) switch

# Validate Nix configuration
validate:
	./scripts/validate-nix.sh

# Run health check
health:
	./scripts/health-check.sh

# Clean old Nix generations
clean:
	nix-collect-garbage --delete-older-than 30d

# Check flake syntax
check:
	nix flake check