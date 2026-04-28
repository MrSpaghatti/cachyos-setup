#!/bin/bash
set -e

# Simple script to download and run CachyOS bootstrap from GitHub
# Run this from CachyOS live environment or after installation

echo "========================================="
echo "CachyOS Bootstrap Setup"
echo "========================================="
echo ""
echo "This script will download and run the CachyOS bootstrap setup"
echo "for ASRock Creator Radeon AI PRO R9700 inference configuration."
echo ""
echo "Repository: https://github.com/MrSpaghatti/cachyos-setup"
echo ""

# Ask for confirmation
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

# Clone repository
echo "Cloning bootstrap repository..."
git clone https://github.com/MrSpaghatti/cachyos-setup.git ~/cachyos-bootstrap
cd ~/cachyos-bootstrap

# Make scripts executable
echo "Making scripts executable..."
chmod +x *.sh

# Run bootstrap
echo "Running bootstrap setup..."
echo ""
echo "The bootstrap will:"
echo "1. Configure R9700 GPU for AI/ML inference"
echo "2. Set up development environment"
echo "3. Install necessary tools and dependencies"
echo ""
echo "This may take some time..."
echo ""

./bootstrap.sh

echo ""
echo "========================================="
echo "Setup complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Reboot your system if prompted"
echo "2. Verify GPU detection: rocm-smi"
echo "3. Test inference: python -c 'import torch; print(torch.cuda.is_available())'"
echo ""
echo "For issues, see: https://github.com/MrSpaghatti/cachyos-setup"
echo ""