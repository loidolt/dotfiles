#!/usr/bin/env bash
# Bootstrap script - Main entry point for setting up a new development machine
#
# Usage:
#   ./bootstrap.sh              # Interactive mode
#   ./bootstrap.sh --full       # Full installation
#   ./bootstrap.sh --minimal    # Minimal installation
#   ./bootstrap.sh --dry-run    # Show what would be installed
#   DEBUG=1 ./bootstrap.sh      # Enable debug output
#
# This script will:
#   - Install package manager (Homebrew on macOS, apt on Linux)
#   - Install Ansible
#   - Run Ansible playbooks to install packages and tools
#   - Set up dotfiles (symlinks)
#   - Configure environment variables
#   - Optionally set up SSH keys

set -euo pipefail

# Get the directory where this script is located
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DOTFILES_DIR}"

# Load utilities
source "${DOTFILES_DIR}/scripts/lib/utils.sh"

# ============================================
# Configuration
# ============================================

INSTALL_PACKAGES=true
INSTALL_LANGUAGES=true
INSTALL_DOCKER=true
INSTALL_SHELL=true
INSTALL_GUI_APPS=true
SETUP_DOTFILES=true
SETUP_ENV=true
SETUP_SSH=false
RUN_VALIDATION=true

# ============================================
# Functions
# ============================================

show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                      
   Development Machine Bootstrap
EOF
    echo -e "${NC}"
}

show_menu() {
    section "Installation Options"
    echo "What would you like to install?"
    echo ""
    echo "  1) Full setup (everything)"
    echo "  2) Minimal (core packages + dotfiles)"
    echo "  3) Developer (packages + languages + docker + dotfiles)"
    echo "  4) Dotfiles only (symlinks)"
    echo "  5) Custom (choose components)"
    echo "  6) Dry run (show what would be installed)"
    echo ""
    
    local choice
    while true; do
        read -rp "Select option [1-6]: " choice
        echo ""
        
        case "${choice}" in
            1)
                info "Full setup selected"
                break
                ;;
            2)
                info "Minimal setup selected"
                INSTALL_LANGUAGES=false
                INSTALL_DOCKER=false
                INSTALL_GUI_APPS=false
                break
                ;;
            3)
                info "Developer setup selected"
                INSTALL_GUI_APPS=false
                break
                ;;
            4)
                info "Dotfiles only selected"
                INSTALL_PACKAGES=false
                INSTALL_LANGUAGES=false
                INSTALL_DOCKER=false
                INSTALL_SHELL=false
                INSTALL_GUI_APPS=false
                break
                ;;
            5)
                custom_menu
                break
                ;;
            6)
                info "Dry run mode - will show what would be installed"
                DRY_RUN=true
                break
                ;;
            *)
                error "Invalid option: ${choice}. Please select 1-6."
                ;;
        esac
    done
}

custom_menu() {
    info "Custom installation - choose components"
    echo ""
    
    ask "Install packages?" "y" && INSTALL_PACKAGES=true || INSTALL_PACKAGES=false
    ask "Install languages (Node, Bun, etc.)?" "y" && INSTALL_LANGUAGES=true || INSTALL_LANGUAGES=false
    ask "Install Docker?" "y" && INSTALL_DOCKER=true || INSTALL_DOCKER=false
    ask "Install shell tools?" "y" && INSTALL_SHELL=true || INSTALL_SHELL=false
    ask "Install GUI applications?" "n" && INSTALL_GUI_APPS=true || INSTALL_GUI_APPS=false
    ask "Setup dotfiles?" "y" && SETUP_DOTFILES=true || SETUP_DOTFILES=false
    ask "Setup environment variables?" "y" && SETUP_ENV=true || SETUP_ENV=false
    ask "Setup SSH keys?" "n" && SETUP_SSH=true || SETUP_SSH=false
    
    echo ""
}

check_prerequisites() {
    section "Checking Prerequisites"
    
    info "OS: $(detect_os)"
    info "Home: $(get_home)"
    
    if ! check_internet; then
        error "Internet connection required"
        echo ""
        echo "This script requires internet access to:"
        echo "  - Install Homebrew/apt packages"
        echo "  - Download language runtimes (Node.js, Python, etc.)"
        echo "  - Clone repositories"
        echo ""
        echo "Please check your network connection and try again."
        exit 1
    fi
    success "Internet connection available"
    
    echo ""
}

install_package_manager() {
    section "Package Manager"
    
    if is_macos; then
        if command_exists brew; then
            success "Homebrew already installed"
        else
            info "Installing Homebrew..."
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                # Add Homebrew to PATH for Apple Silicon
                if is_arm; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
                success "Homebrew installed"
            else
                error "Homebrew installation failed"
                exit 1
            fi
        fi
    elif is_linux; then
        info "Using apt package manager"
        if ! command_exists apt; then
            error "apt package manager not found"
            echo ""
            echo "This script currently supports:"
            echo "  - macOS (with Homebrew)"
            echo "  - Debian/Ubuntu Linux (with apt)"
            echo ""
            echo "Your system appears to be using a different package manager."
            echo "Please consider contributing support for your distribution!"
            exit 1
        fi
        sudo apt update
        success "Package manager ready"
    fi
    
    echo ""
}

install_ansible() {
    section "Ansible Installation"
    
    if command_exists ansible-playbook; then
        success "Ansible already installed"
        ansible --version | head -1
    else
        info "Installing Ansible..."
        
        if is_macos; then
            brew install ansible
        else
            sudo apt update
            sudo apt install -y software-properties-common
            sudo apt-add-repository -y ppa:ansible/ansible
            sudo apt update
            sudo apt install -y ansible
        fi
        
        success "Ansible installed"
    fi
    
    echo ""
}

run_ansible_playbook() {
    section "Running Ansible Playbook"
    
    local tags=""
    local skip_tags=""
    
    # Build tags based on selections
    [ "$INSTALL_PACKAGES" = true ] && tags="${tags}packages,"
    [ "$INSTALL_LANGUAGES" = true ] && tags="${tags}languages,"
    [ "$INSTALL_DOCKER" = true ] && tags="${tags}docker,"
    [ "$INSTALL_SHELL" = true ] && tags="${tags}shell,"
    [ "$INSTALL_GUI_APPS" = true ] && tags="${tags}applications,"
    
    # Remove trailing comma
    tags=${tags%,}
    
    if [ -z "$tags" ]; then
        info "No Ansible tasks selected, skipping..."
        return
    fi
    
    info "Running Ansible with tags: $tags"
    
    cd "$DOTFILES_DIR/ansible"
    
    if [ "${DRY_RUN:-false}" = true ]; then
        ansible-playbook setup.yml --tags "$tags" --check --diff
    else
        ansible-playbook setup.yml --tags "$tags"
    fi
    
    cd "$DOTFILES_DIR"
    echo ""
}

setup_dotfiles() {
    if [ "$SETUP_DOTFILES" = false ]; then
        return
    fi
    
    section "Setting Up Dotfiles"
    
    if [ "${DRY_RUN:-false}" = true ]; then
        info "Would run: $DOTFILES_DIR/install.sh"
    else
        info "Running dotfiles installation script..."
        "$DOTFILES_DIR/install.sh"
    fi
    
    echo ""
}

setup_environment() {
    if [ "$SETUP_ENV" = false ]; then
        return
    fi
    
    section "Environment Setup"
    
    if [ "${DRY_RUN:-false}" = true ]; then
        info "Would run: $DOTFILES_DIR/scripts/env-setup.sh"
    else
        "$DOTFILES_DIR/scripts/env-setup.sh"
    fi
    
    echo ""
}

setup_ssh_keys() {
    if [ "$SETUP_SSH" = false ]; then
        return
    fi
    
    section "SSH Setup"
    
    if [ "${DRY_RUN:-false}" = true ]; then
        info "Would run: $DOTFILES_DIR/scripts/ssh-setup.sh"
    else
        if ask "Set up SSH keys now?" "n"; then
            "$DOTFILES_DIR/scripts/ssh-setup.sh"
        else
            info "Skipping SSH setup (run ./scripts/ssh-setup.sh later)"
        fi
    fi
    
    echo ""
}

run_validation() {
    if [ "$RUN_VALIDATION" = false ] || [ "${DRY_RUN:-false}" = true ]; then
        return
    fi
    
    section "Validation"
    
    info "Running validation checks..."
    "$DOTFILES_DIR/scripts/validate.sh"
    
    echo ""
}

show_completion() {
    section "Setup Complete! 🎉"
    
    echo -e "${GREEN}Your development environment is ready!${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. ${CYAN}Restart your terminal${NC} (or run: source ~/.zshrc)"
    echo "  2. ${CYAN}Edit ~/.dotfiles_env${NC} and add your API keys"
    echo "  3. ${CYAN}Run ./scripts/validate.sh${NC} to verify everything works"
    echo ""
    
    if [ "$SETUP_SSH" = false ]; then
        echo "Optional:"
        echo "  • Run ${CYAN}./scripts/ssh-setup.sh${NC} to configure SSH keys"
        echo ""
    fi
    
    echo "Documentation:"
    echo "  • README.md - Main documentation"
    echo "  • docs/SETUP.md - Detailed setup guide"
    echo "  • ansible/group_vars/all.yml - Customize packages"
    echo ""
    echo -e "${YELLOW}Happy coding!${NC}"
    echo ""
}

# ============================================
# Main Execution
# ============================================

main() {
    show_banner
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full)
                info "Running full setup..."
                ;;
            --minimal)
                INSTALL_LANGUAGES=false
                INSTALL_DOCKER=false
                INSTALL_GUI_APPS=false
                ;;
            --dotfiles-only)
                INSTALL_PACKAGES=false
                INSTALL_LANGUAGES=false
                INSTALL_DOCKER=false
                INSTALL_SHELL=false
                INSTALL_GUI_APPS=false
                ;;
            --dry-run)
                DRY_RUN=true
                info "Dry run mode enabled"
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --full          Full installation (default)"
                echo "  --minimal       Minimal installation (no languages/docker/gui)"
                echo "  --dotfiles-only Only symlink dotfiles"
                echo "  --dry-run       Show what would be installed"
                echo "  --help, -h      Show this help"
                echo ""
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Run with --help for usage"
                exit 1
                ;;
        esac
        shift
    done
    
    # If no arguments, show interactive menu
    if [ "${DRY_RUN:-false}" = false ] && [ $# -eq 0 ]; then
        show_menu
    fi
    
    # Run installation steps
    check_prerequisites
    install_package_manager
    
    # Only install Ansible if we need it
    if [ "$INSTALL_PACKAGES" = true ] || \
       [ "$INSTALL_LANGUAGES" = true ] || \
       [ "$INSTALL_DOCKER" = true ] || \
       [ "$INSTALL_SHELL" = true ] || \
       [ "$INSTALL_GUI_APPS" = true ]; then
        install_ansible
        run_ansible_playbook
    fi
    
    setup_dotfiles
    setup_environment
    setup_ssh_keys
    run_validation
    show_completion
}

# Run main function
main "$@"
