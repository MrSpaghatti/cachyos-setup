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
        zsh \
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
    
    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Set Zsh as default shell
    chsh -s $(which zsh)
    
    # Basic zshrc configuration
    cat << 'EOF' > ~/.zshrc
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker python rust)
source $ZSH/oh-my-zsh.sh

# Custom aliases
alias vim=nvim
alias k=kubectl
alias docker-clean='docker system prune -af --volumes'

# Development environment paths
export PATH=$HOME/.cargo/bin:$HOME/go/bin:$PATH
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