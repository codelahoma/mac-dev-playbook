# Mac Development Playbook - Testing Checklist

## Pre-Bootstrap Verification
- [ ] Fresh macOS virtual machine or test system
- [ ] No Xcode Command Line Tools installed
- [ ] No Homebrew installed
- [ ] No Python/pip modifications
- [ ] Document macOS version: _____________

## Bootstrap Script Execution

### Initial Download & Run
- [ ] Bootstrap script downloads correctly via curl
- [ ] Script detects macOS correctly
- [ ] Clear colored output (green checkmarks, yellow warnings)
- [ ] All `read` commands work properly (no 'cho: command not found' errors)

### Xcode Command Line Tools
- [ ] Xcode installation prompt appears
- [ ] Installation completes successfully
- [ ] Script waits appropriately for completion
- [ ] Verification passes after installation

### Homebrew Installation
- [ ] Homebrew installs without errors
- [ ] Correct path for architecture (Intel: `/usr/local`, Apple Silicon: `/opt/homebrew`)
- [ ] `brew` command available in PATH

### Python & Ansible Setup
- [ ] Python 3 detected or installed
- [ ] pip upgrades successfully
- [ ] Ansible installs via pip
- [ ] `ansible` command available in PATH

### Repository Setup
- [ ] Repository clones to `~/github/mac-dev-playbook`
- [ ] Correct branch checked out
- [ ] Ansible Galaxy requirements install

### Configuration
- [ ] Prompted to create config.yml
- [ ] Vault password prompt appears if vars_private.yml exists
- [ ] Vault password handling works (saves to temp file)
- [ ] Prompted to run playbook
- [ ] Sudo password handled correctly (from vault or prompt)

## Playbook Execution

### Core Roles
- [ ] Command Line Tools role completes
- [ ] Homebrew role configures taps
- [ ] Homebrew packages install (35+ items)
- [ ] Homebrew cask apps install (20+ items)
- [ ] Mac App Store apps queue for installation

### Development Tools Installed
Check for presence of:
- [ ] `git` command works
- [ ] `go` command works
- [ ] `docker` alternative (OrbStack) installed
- [ ] `asdf` command works
- [ ] `direnv` via asdf works
- [ ] `node` via asdf works
- [ ] `fzf` command works
- [ ] `ripgrep` (rg) command works
- [ ] `tmux` command works
- [ ] `arduino-cli` command works
- [ ] `eza` command works (ls replacement)
- [ ] `zoxide` command works (z for directory jumping)
- [ ] `lua` command works
- [ ] `bat` command works (cat with syntax highlighting)

### Applications Installed
Verify in `/Applications`:
- [ ] 1Password.app
- [ ] Alfred.app
- [ ] Arduino IDE.app
- [ ] ChatGPT.app
- [ ] Claude.app
- [ ] OrbStack.app
- [ ] Google Chrome.app
- [ ] Google Drive.app
- [ ] iTerm.app
- [ ] Karabiner-Elements.app
- [ ] Keyboard Maestro.app
- [ ] LM Studio.app
- [ ] Setapp.app
- [ ] Slack.app
- [ ] Spotify.app

### Shell Environment

#### Zsh Configuration
- [ ] Oh-My-Zsh installed at `~/.oh-my-zsh`
- [ ] Powerlevel10k theme installed
- [ ] zsh-autosuggestions plugin works
- [ ] zsh-syntax-highlighting works
- [ ] fzf-git.sh cloned to `~/fzf-git.sh`

#### Tmux Configuration
- [ ] Oh-My-Tmux installed at `~/.tmux`
- [ ] Symlink created at `~/.tmux.conf`

#### Dotfiles
- [ ] Homeshick installed
- [ ] Dotfiles repository cloned
- [ ] Dotfiles linked to home directory

### Fonts
Open Font Book and verify:
- [ ] 3270 Nerd Font
- [ ] Cousine Nerd Font
- [ ] Fira Code Nerd Font
- [ ] Fira Mono Nerd Font
- [ ] Fira Sans (all variants)
- [ ] Hack Nerd Font
- [ ] Inconsolata variants
- [ ] Iosevka variants
- [ ] Sauce Code Pro Nerd Font

### System Configuration
- [ ] Dock cleaned of default apps
- [ ] `.macos` script executed
- [ ] Sudoers configured for passwordless admin (if enabled)

### Version Management
- [ ] `.tool-versions` file created
- [ ] Node.js 24.6.0 available via asdf
- [ ] direnv 2.31.0 available via asdf

## Post-Installation Verification

### Shell Session Test
Open new terminal and verify:
- [ ] No error messages on startup
- [ ] Prompt displays correctly (Powerlevel10k)
- [ ] Command suggestions work (type partial command)
- [ ] Syntax highlighting works (valid commands green, invalid red)
- [ ] `z` command available for directory jumping (after cd to a few dirs)
- [ ] `eza` aliases work (la, ll, etc if configured)

### Development Environment Test
- [ ] `git status` works
- [ ] `node --version` shows 24.6.0
- [ ] `python3 --version` works
- [ ] `brew list` shows installed packages
- [ ] Claude Code (`claude`) command available

### AI Tools Test
- [ ] ChatGPT app launches
- [ ] Claude app launches
- [ ] LM Studio app launches
- [ ] Claude Code CLI works

## Manual Tasks Required

### App Store
- [ ] Sign into Mac App Store
- [ ] Perplexity AI installing/installed
- [ ] Other App Store apps queued

### Setapp
- [ ] Setapp launched and signed in
- [ ] Review SETAPP_APPS.md for manual installations

### Application Setup
- [ ] 1Password configured
- [ ] Alfred preferences set
- [ ] Karabiner-Elements configured
- [ ] iTerm2 preferences/theme set

### System Preferences
- [ ] Trackpad settings configured
- [ ] Display settings configured
- [ ] Keyboard settings verified

## Error Checks

### Common Issues to Verify Fixed
- [ ] No Docker completion file errors
- [ ] No missing zsh plugin errors
- [ ] No direnv path errors
- [ ] No broken symlinks
- [ ] No deprecated package errors (exa→eza, fasd→zoxide, lua@5.3→lua)

### Idempotency Test
- [ ] Run playbook again: `cd ~/github/mac-dev-playbook && ansible-playbook main.yml --ask-become-pass`
- [ ] Second run shows mostly "ok" status (no changes)
- [ ] No errors on second run

## Performance & Resource Check
- [ ] System responsive during installation
- [ ] Disk space adequate (check with `df -h`)
- [ ] No excessive CPU usage after completion
- [ ] Memory usage normal

## Bootstrap Script Features Test

### Environment Variables Test
Test with different configurations:
- [ ] `REPO_URL` override works
- [ ] `REPO_BRANCH` override works
- [ ] `INSTALL_DIR` override works
- [ ] `SKIP_XCODE_CHECK=true` works
- [ ] `ANSIBLE_VAULT_PASSWORD` works

## Final Verification
- [ ] All critical development tools functional
- [ ] No error messages in shell startup
- [ ] System ready for development work
- [ ] Playbook can be re-run without errors

---

## Notes Section

### Issues Encountered:
_Document any problems here_

### Deviations from Expected:
_Note any differences from checklist_

### Time Taken:
- Bootstrap script: _______ minutes
- Playbook execution: _______ minutes
- Total time: _______ minutes

### System Specifications:
- macOS Version: _____________
- Processor: _____________
- RAM: _____________
- VM Software (if applicable): _____________

---

**Test Date:** _____________
**Tester:** _____________
**Result:** [ ] PASS [ ] FAIL

## If Failed, Primary Issues:
1. _____________
2. _____________
3. _____________