#!/bin/bash
set -e

# Script to run from CachyOS live environment
# This script downloads and runs the bootstrap setup after installation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running from live environment
check_live_environment() {
    if [ ! -f /etc/cachyos-release ]; then
        log_error "This script should be run from CachyOS live environment"
        log_error "Please boot from the CachyOS USB stick and run this script"
        exit 1
    fi
}

# Download bootstrap scripts from GitHub
download_scripts() {
    log_info "Downloading bootstrap scripts..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download scripts (you would need to upload them to GitHub first)
    # For now, we'll create them inline
    create_scripts_locally
    
    log_info "Scripts downloaded to: $TEMP_DIR"
}

# Create scripts locally (temporary solution)
create_scripts_locally() {
    cat > r9700_inference_setup.sh << 'EOF'
#!/bin/bash
set -e
echo "R9700 inference setup would run here"
echo "This is a placeholder - actual script would configure ROCm and AI frameworks"
EOF
    
    cat > user_environment_setup.sh << 'EOF'
#!/bin/bash
set -e
echo "User environment setup would run here"
echo "This is a placeholder - actual script would set up development tools"
EOF
    
    cat > bootstrap.sh << 'EOF'
#!/bin/bash
set -e
echo "Combined bootstrap script would run here"
echo "This is a placeholder - actual script would run both setups"
EOF
    
    chmod +x *.sh
}

# Main execution
main() {
    log_info "CachyOS Live Environment Bootstrap Helper"
    log_info "This script helps set up your system after installation"
    
    check_live_environment
    
    echo
    echo "Instructions:"
    echo "1. Install CachyOS using the graphical installer"
    echo "2. After installation, reboot into your new system"
    echo "3. Download the actual bootstrap scripts from:"
    echo "   https://github.com/yourusername/cachyos-setup"
    echo "4. Run: ./bootstrap.sh"
    echo
    echo "The bootstrap scripts will:"
    echo "- Configure ASRock Creator Radeon AI PRO R9700 for inference"
    echo "- Set up development environment and tools"
    echo "- Configure Docker, shell, and security settings"
    
    # Download placeholder scripts
    download_scripts
    
    log_info "Setup instructions saved to: $TEMP_DIR"
    log_info "After installation, download the actual scripts from GitHub"
}

main