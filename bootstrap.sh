#!/bin/bash
set -e

# Combined Bootstrap Script for CachyOS Setup
# This script runs both the R9700 inference setup and user environment setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "This script should not be run as root"
        log_error "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

# Check for required files
check_files() {
    local required_files=(
        "$SCRIPT_DIR/r9700_inference_setup.sh"
        "$SCRIPT_DIR/user_environment_setup.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Required file not found: $file"
            exit 1
        fi
    done
    
    log_info "All required files found"
}

# Run R9700 inference setup
run_inference_setup() {
    log_info "Starting R9700 inference setup..."
    
    if [ ! -x "$SCRIPT_DIR/r9700_inference_setup.sh" ]; then
        chmod +x "$SCRIPT_DIR/r9700_inference_setup.sh"
    fi
    
    "$SCRIPT_DIR/r9700_inference_setup.sh"
    
    if [ $? -eq 0 ]; then
        log_info "R9700 inference setup completed successfully"
    else
        log_error "R9700 inference setup failed"
        exit 1
    fi
}

# Run user environment setup
run_user_setup() {
    log_info "Starting user environment setup..."
    
    if [ ! -x "$SCRIPT_DIR/user_environment_setup.sh" ]; then
        chmod +x "$SCRIPT_DIR/user_environment_setup.sh"
    fi
    
    "$SCRIPT_DIR/user_environment_setup.sh"
    
    if [ $? -eq 0 ]; then
        log_info "User environment setup completed successfully"
    else
        log_error "User environment setup failed"
        exit 1
    fi
}

# Main execution
main() {
    log_info "Starting CachyOS bootstrap setup..."
    log_info "Script directory: $SCRIPT_DIR"
    
    check_root
    check_files
    
    # Ask for confirmation
    echo
    echo "This script will:"
    echo "1. Configure ASRock Creator Radeon AI PRO R9700 for inference"
    echo "2. Set up development environment and tools"
    echo
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled"
        exit 0
    fi
    
    run_inference_setup
    run_user_setup
    
    log_info "CachyOS bootstrap setup completed successfully!"
    log_info "Please reboot your system for all changes to take effect"
}

main