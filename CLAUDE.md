# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Mac Development Ansible Playbook - a fork of Jeff Geerling's playbook that automates the installation and configuration of macOS development environments. It uses Ansible to provision software, configure system settings, and manage dotfiles.

## Key Commands

### Setup and Installation
```bash
# Install Ansible roles/collections
ansible-galaxy install -r requirements.yml

# Run the main playbook (will prompt for sudo password)
ansible-playbook main.yml --ask-become-pass

# Run specific tags only
ansible-playbook main.yml -K --tags "dotfiles,homebrew"
ansible-playbook main.yml -K --tags "mas,extra-packages,osx"

# Check syntax without running
ansible-playbook main.yml --syntax-check

# If Homebrew fails, diagnose issues
brew doctor
```

### Testing
```bash
# Test idempotence (run twice, should have no changes second time)
ansible-playbook main.yml
```

## Architecture

### Configuration System
- **default.config.yml**: Contains all default settings for packages, apps, and system configurations
- **config.yml**: User-created override file (gitignored) for personal customizations
- **vars_private.yml**: Private variables (referenced in main.yml)
- Configuration precedence: config.yml overrides default.config.yml

### Playbook Structure
- **main.yml**: Orchestrates all roles and tasks with these key components:
  - External roles: `elliotweiser.osx-command-line-tools`, `geerlingguy.mac.*` collection
  - Task imports from `tasks/` directory for specific configurations
  - Supports tags for selective execution: `homebrew`, `mas`, `dock`, `dotfiles`, `osx`, `extra-packages`, `ssh`, `sudoers`, `fonts`, `zsh`, `spacemacs`, `tmux`, `post`

### Task Organization
Tasks are modularized in `tasks/` directory:
- **ssh.yml**: SSH key configuration
- **sudoers.yml**: Passwordless sudo setup for admin group
- **fonts.yml**: Font installation
- **zsh.yml**: Z shell configuration
- **spacemacs.yml**: Spacemacs editor setup
- **tmux.yml**: Terminal multiplexer configuration
- **dotfiles.yml**: Dotfile management
- **osx.yml**: macOS system preferences (runs ~/.macos script)
- **extra-packages.yml**: Additional package manager installations (composer, gem, npm, pip)

### Package Management
- **Homebrew**: Main package manager for CLI tools and cask apps
- **Mac App Store (mas)**: For App Store applications
- **Additional managers**: composer, gem, npm, pip (configured but empty by default)

### Key Variables
- `configure_dotfiles`: Enable/disable dotfile management
- `configure_osx`: Enable/disable macOS system configuration
- `configure_dock`: Enable/disable Dock customization via dockutil
- `configure_sudoers`: Enable/disable passwordless sudo
- `homebrew_installed_packages`: List of Homebrew packages
- `homebrew_cask_apps`: List of GUI applications
- `mas_installed_apps`: Mac App Store apps with IDs

### Dependencies
- Requires Xcode Command Line Tools
- Python 3 and pip for Ansible installation
- Uses asdf for version management (.tool-versions specifies nodejs 24.6.0)
- External Ansible roles installed via ansible-galaxy

## Important Notes
- Always test changes with `--syntax-check` before running
- The playbook is idempotent - safe to run multiple times
- User customizations should go in config.yml, not default.config.yml
- Some manual steps still required (see README.md for Terminal theme, trackpad settings, etc.)