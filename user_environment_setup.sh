#!/bin/bash
set -e

# Comprehensive User Environment Setup Script

# Update system and install base packages
system_update() {
    echo "Updating system and installing base packages..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm \
        base-devel \
        git \
        fish \
        starship \
        tmux \
        neovim \
        docker \
        docker-compose \
        vscode \
        cmake \
        ninja \
        python-pip \
        nodejs \
        npm \
        rust \
        go
}

# Configure shell
setup_shell() {
    echo "Configuring shell environment..."
    
    # Install fish shell and starship prompt
    echo "Installing fish shell and starship prompt..."
    
    # Set fish as default shell
    chsh -s $(which fish)
    
    # Configure fish shell
    mkdir -p ~/.config/fish
    cat << 'EOF' > ~/.config/fish/config.fish
# Fish shell configuration
set -gx EDITOR nvim
set -gx VISUAL nvim

# Aliases
alias vim nvim
alias k kubectl
alias docker-clean 'docker system prune -af --volumes'

# Development environment paths
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin

# Initialize starship prompt
starship init fish | source
EOF
    
    # Install starship prompt
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    
    # Configure starship
    mkdir -p ~/.config
    cat << 'EOF' > ~/.config/starship.toml
# Starship prompt configuration
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$rust\
$golang\
$nodejs\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
truncation_length = 3
truncate_to_repo = false

[git_branch]
symbol = "🌱 "
format = "on [$symbol$branch]($style) "

[git_status]
conflicted = "🏳"
ahead = "🏎💨"
behind = "😰"
diverged = "😵"
untracked = "🤷"
stashed = "📦"
modified = "📝"
staged = "➕"
renamed = "👅"
deleted = "🗑"
EOF
}

# Docker setup
configure_docker() {
    echo "Configuring Docker..."
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
}

# Development environment setup
dev_environment() {
    echo "Setting up development environments..."
    
    # Python virtual environment management
    python -m pip install --user pipx
    python -m pipx ensurepath
    pipx install poetry
    pipx install black
    pipx install mypy
    
    # Rust setup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # Go setup
    mkdir -p ~/go
    
    # Node.js setup via NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
}

# SSH and GPG setup
security_setup() {
    echo "Configuring SSH and GPG..."
    
    # Generate SSH key
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    
    # Set up GPG key
    gpg --full-generate-key
}

# Dotfiles and configuration management
dotfiles_setup() {
    echo "Setting up dotfiles..."
    
    # Clone dotfiles repository (replace with your actual dotfiles repo)
    git clone https://github.com/yourusername/dotfiles.git ~/dotfiles || true
    cd ~/dotfiles
    
    # Install dotfiles (assuming a standard install script)
    ./install.sh || true
}

# Main execution
main() {
    system_update
    setup_shell
    configure_docker
    dev_environment
    security_setup
    dotfiles_setup
}

main