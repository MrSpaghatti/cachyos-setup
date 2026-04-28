#!/bin/bash
set -e

# Script to copy bootstrap files to USB stick
# Run this after the USB stick is mounted

USB_MOUNT="/mnt/usb"
SETUP_DIR="/home/spag/cachyos_setup"

# Check if USB is mounted
if [ ! -d "$USB_MOUNT" ]; then
    echo "Error: USB mount point $USB_MOUNT not found"
    echo "Please mount the USB stick first:"
    echo "  sudo mkdir -p /mnt/usb"
    echo "  sudo mount /dev/sda1 /mnt/usb"
    exit 1
fi

# Create setup directory on USB
USB_SETUP_DIR="$USB_MOUNT/cachyos_setup"
sudo mkdir -p "$USB_SETUP_DIR"

# Copy all setup files
echo "Copying setup files to USB stick..."
sudo cp -r "$SETUP_DIR"/* "$USB_SETUP_DIR"/

# Set permissions
sudo chmod -R 755 "$USB_SETUP_DIR"

echo "Setup files copied to: $USB_SETUP_DIR"
echo "Files available:"
ls -la "$USB_SETUP_DIR"