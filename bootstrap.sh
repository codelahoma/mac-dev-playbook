#!/bin/bash

# Mac Development Playbook Bootstrap Script
# 
# This script installs everything needed to run the Mac Development Playbook
# Usage: curl -fsSL https://raw.githubusercontent.com/codelahoma/mac-dev-playbook/master/bootstrap.sh | bash
#
# Or for a specific fork:
# curl -fsSL https://raw.githubusercontent.com/[username]/mac-dev-playbook/[branch]/bootstrap.sh | bash

set -e  # Exit on error

# Configuration
REPO_URL="${REPO_URL:-https://github.com/codelahoma/mac-dev-playbook.git}"
REPO_BRANCH="${REPO_BRANCH:-master}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/github/mac-dev-playbook}"
VAULT_PASS="${ANSIBLE_VAULT_PASSWORD:-}"
SKIP_XCODE_CHECK="${SKIP_XCODE_CHECK:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_info() { echo -e "${GREEN}[i]${NC} $1"; }

# Header
echo ""
echo "============================================"
echo "   Mac Development Playbook Bootstrap"
echo "============================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is for macOS only!"
    exit 1
fi

print_info "Starting Mac setup process..."

# 1. Install Xcode Command Line Tools
if [[ "$SKIP_XCODE_CHECK" == "true" ]]; then
    print_warning "Skipping Xcode Command Line Tools check (SKIP_XCODE_CHECK=true)"
elif ! xcode-select -p &> /dev/null; then
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install 2>/dev/null || true
    
    # Wait for installation to complete
    print_warning "Please complete the Xcode Command Line Tools installation in the popup window."
    print_warning "This may take several minutes..."
    print_warning "Press ENTER when the installation is complete..."
    read -r < /dev/tty
    
    # Verify installation with a retry
    if ! xcode-select -p &> /dev/null; then
        print_warning "Checking installation status..."
        sleep 2
        
        # Check one more time
        if ! xcode-select -p &> /dev/null; then
            print_error "Xcode Command Line Tools installation not detected."
            print_info "If you cancelled the installation, please run this script again."
            print_info "If you believe the tools are installed, try running: xcode-select --reset"
            exit 1
        fi
    fi
    print_status "Xcode Command Line Tools installation verified"
else
    print_status "Xcode Command Line Tools already installed"
fi

# 2. Install Homebrew
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_status "Homebrew already installed"
fi

# 3. Update PATH for this session
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$HOME/Library/Python/3.8/bin:$PATH"

# 4. Install Python 3 and pip if needed
if ! command -v python3 &> /dev/null; then
    print_info "Installing Python 3..."
    brew install python@3.11
else
    print_status "Python 3 already installed"
fi

# 5. Upgrade pip
print_info "Upgrading pip..."
python3 -m pip install --upgrade pip --user --break-system-packages 2>/dev/null || \
    python3 -m pip install --upgrade pip --user

# 6. Install Ansible
if ! command -v ansible &> /dev/null; then
    print_info "Installing Ansible..."
    python3 -m pip install ansible --user --break-system-packages 2>/dev/null || \
        python3 -m pip install ansible --user
    
    # Verify Ansible installation
    if ! command -v ansible &> /dev/null; then
        print_warning "Ansible not found in PATH. Adding Python bin directories to PATH..."
        export PATH="$HOME/Library/Python/3.11/bin:$HOME/Library/Python/3.10/bin:$HOME/Library/Python/3.9/bin:$PATH"
        
        if ! command -v ansible &> /dev/null; then
            print_error "Ansible installation failed!"
            exit 1
        fi
    fi
else
    print_status "Ansible already installed"
fi

# 7. Clone or update the repository
if [[ -d "$INSTALL_DIR" ]]; then
    print_info "Updating existing repository..."
    cd "$INSTALL_DIR"
    git pull origin "$REPO_BRANCH"
else
    print_info "Cloning repository..."
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone -b "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# 8. Install Ansible requirements
print_info "Installing Ansible Galaxy requirements..."
ansible-galaxy install -r requirements.yml

# 9. Set up vault password if provided or prompt for it
if [[ -n "$VAULT_PASS" ]]; then
    print_info "Setting up Ansible vault password..."
    echo "$VAULT_PASS" > ~/.ansible_vault_pass
    chmod 600 ~/.ansible_vault_pass
    VAULT_ARGS="--vault-password-file ~/.ansible_vault_pass"
else
    # Check if vars_private.yml exists (which requires vault password)
    if [[ -f "$INSTALL_DIR/vars_private.yml" ]]; then
        print_warning "Found encrypted vars_private.yml file."
        echo ""
        read -sp "Enter Ansible vault password (or press ENTER to skip): " vault_password < /dev/tty
        echo ""
        
        if [[ -n "$vault_password" ]]; then
            echo "$vault_password" > ~/.ansible_vault_pass
            chmod 600 ~/.ansible_vault_pass
            VAULT_ARGS="--vault-password-file ~/.ansible_vault_pass"
            print_status "Vault password saved temporarily"
        else
            VAULT_ARGS="--ask-vault-pass"
            print_info "You will be prompted for the vault password during playbook execution"
        fi
    else
        VAULT_ARGS=""
        print_info "No encrypted files detected"
    fi
fi

# 10. Create config.yml if user wants to customize
if [[ ! -f "$INSTALL_DIR/config.yml" ]]; then
    print_info "No config.yml found. You can create one to override defaults."
    echo ""
    read -p "Would you like to create a minimal config.yml now? (y/N): " -n 1 -r < /dev/tty
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat > "$INSTALL_DIR/config.yml" <<EOF
---
# Override any variables from default.config.yml here
# For example:
# configure_sudoers: false
# configure_osx: false
# configure_dock: false

# Add any custom configurations below:

EOF
        print_status "Created config.yml - you can edit it before running the playbook"
    fi
fi

# 11. Run the playbook
echo ""
print_info "Ready to run the Ansible playbook!"
print_warning "The playbook will configure your Mac with development tools and settings."
echo ""
read -p "Do you want to run the playbook now? (y/N): " -n 1 -r < /dev/tty
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Running Ansible playbook..."
    
    # Trigger sudo timestamp to avoid multiple password prompts
    print_info "Authenticating sudo (you may be prompted for your password)..."
    sudo -v
    
    # Keep sudo timestamp alive in background
    while true; do sudo -n true; sleep 50; done 2>/dev/null &
    SUDO_KEEPER_PID=$!
    
    # Determine which passwords we need
    PLAYBOOK_ARGS=""
    
    # Add vault arguments if set
    if [[ -n "$VAULT_ARGS" ]]; then
        PLAYBOOK_ARGS="$PLAYBOOK_ARGS $VAULT_ARGS"
    fi
    
    # Check if we need sudo password
    if [[ -f "$INSTALL_DIR/vars_private.yml" ]] && [[ "$VAULT_ARGS" == *"--vault-password-file"* ]]; then
        # Try to decrypt and check for ansible_become_password
        if ansible-vault view vars_private.yml --vault-password-file ~/.ansible_vault_pass 2>/dev/null | grep -q "ansible_become_password"; then
            print_info "Using sudo password from vault"
        else
            print_warning "You will be prompted for your sudo password..."
            PLAYBOOK_ARGS="$PLAYBOOK_ARGS --ask-become-pass"
        fi
    else
        print_warning "You will be prompted for your sudo password..."
        PLAYBOOK_ARGS="$PLAYBOOK_ARGS --ask-become-pass"
    fi
    
    # Run the playbook
    ansible-playbook main.yml $PLAYBOOK_ARGS
    PLAYBOOK_EXIT_CODE=$?
    
    # Kill the sudo keeper process
    if [[ -n "$SUDO_KEEPER_PID" ]]; then
        kill $SUDO_KEEPER_PID 2>/dev/null || true
    fi
    
    if [[ $PLAYBOOK_EXIT_CODE -eq 0 ]]; then
        print_status "Playbook completed successfully!"
        echo ""
        print_info "Your Mac has been configured!"
        print_info "Some changes may require a logout/login or restart to take effect."
        echo ""
        print_info "Manual steps still required:"
        echo "  1. Configure Terminal.app theme"
        echo "  2. Set up Trackpad preferences in System Preferences"
        echo "  3. Sign in to App Store for mas apps to install"
        echo "  4. Install Setapp apps manually (see SETAPP_APPS.md)"
        echo "  5. Configure application-specific settings"
    else
        print_error "Playbook execution failed. Check the errors above."
        exit 1
    fi
else
    print_info "Skipping playbook execution."
    echo ""
    print_info "To run the playbook later:"
    echo "  cd $INSTALL_DIR"
    echo "  ansible-playbook main.yml --ask-become-pass"
fi

echo ""
echo "============================================"
echo "   Bootstrap Complete!"
echo "============================================"
echo ""

# Cleanup
unset VAULT_PASS
unset vault_password

# Remove temporary vault password file if we created it during this session
if [[ -z "$ANSIBLE_VAULT_PASSWORD" ]] && [[ -f ~/.ansible_vault_pass ]]; then
    print_info "Cleaning up temporary vault password file..."
    rm -f ~/.ansible_vault_pass
fi

# Source the new shell configuration if zsh
if [[ "$SHELL" == *"zsh"* ]]; then
    print_info "Reloading shell configuration..."
    source ~/.zshrc 2>/dev/null || true
fi