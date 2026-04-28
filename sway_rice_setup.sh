#!/bin/bash
set -e

# Sway Wayland GUI Setup Script
# Configures Sway with Intel Arc B50 for display, keeping R9700 free for inference

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

# Install Wayland stack
install_wayland_stack() {
    log_info "Installing Wayland stack..."
    
    # Install core Wayland packages
    sudo pacman -S --noconfirm \
        sway \
        swaybg \
        swaylock \
        swayidle \
        waybar \
        fuzzel \
        mako \
        wl-clipboard \
        xdg-desktop-portal-wlr \
        ghostty \
        grim \
        slurp \
        wf-recorder \
        brightnessctl \
        playerctl
    
    log_info "Wayland stack installed successfully"
}

# Create launch wrapper for Sway
create_sway_wrapper() {
    log_info "Creating Sway launch wrapper..."
    
    # Create ~/.local/bin directory if it doesn't exist
    mkdir -p ~/.local/bin
    
    # Create the launch wrapper script
    cat << 'EOF' > ~/.local/bin/start-sway
#!/bin/bash
# Sway launch wrapper - forces rendering on Intel Arc B50
# To find the correct card ID for Intel Arc B50:
# 1. Run: ls -la /dev/dri/by-path/
# 2. Look for the Intel GPU (usually card0 or card1)
# 3. Check with: sudo lspci -v | grep -A 10 "VGA compatible controller"

# Export DRM device to use Intel Arc B50
# This keeps the R9700 free for inference workloads
export WLR_DRM_DEVICES=/dev/dri/card0

# Start Sway
exec sway
EOF
    
    # Make the wrapper executable
    chmod +x ~/.local/bin/start-sway
    
    log_info "Sway launch wrapper created at ~/.local/bin/start-sway"
}

# Configure Sway
configure_sway() {
    log_info "Configuring Sway..."
    
    # Create Sway config directory
    mkdir -p ~/.config/sway
    
    # Create minimal Sway configuration
    cat << 'EOF' > ~/.config/sway/config
# Sway configuration for dual GPU setup
# Intel Arc B50 for display, R9700 for inference

# Variables
set $term ghostty
set $menu fuzzel --dmenu

# Input configuration
input "type:keyboard" {
    xkb_layout us
    xkb_variant altgr-intl
    repeat_delay 250
    repeat_rate 30
}

input "type:touchpad" {
    tap enabled
    natural_scroll enabled
}

# Output configuration
output * {
    bg ~/Pictures/wallpaper.jpg fill
}

# Startup applications
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000'

exec mako
exec waybar

# Key bindings
# Super key (Windows key) as modifier
set $mod Mod4

# Basic movement
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+f fullscreen

# Focus movement
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Window movement
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Workspace switching
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9
bindsym $mod+0 workspace number 10

# Move window to workspace
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9
bindsym $mod+Shift+0 move container to workspace number 10

# Layout
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# Misc
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'

# Media keys
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

# Screenshot
bindsym Print exec grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
bindsym $mod+Print exec grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Include system-specific configuration
include /etc/sway/config.d/*
EOF
    
    log_info "Sway configuration created at ~/.config/sway/config"
}

# Configure Waybar
configure_waybar() {
    log_info "Configuring Waybar..."
    
    # Create Waybar config directory
    mkdir -p ~/.config/waybar
    
    # Create minimal Waybar configuration
    cat << 'EOF' > ~/.config/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["sway/workspaces", "sway/mode"],
    "modules-center": ["sway/window"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "temperature", "battery", "clock", "tray"],
    "sway/mode": {
        "format": "<span style=\"italic\">{}</span>"
    },
    "clock": {
        "format": "{:%Y-%m-%d %H:%M}",
        "tooltip-format": "{:%Y-%m-%d | %H:%M}"
    },
    "cpu": {
        "format": "CPU {usage}%",
        "interval": 5
    },
    "memory": {
        "format": "RAM {percentage}%",
        "interval": 5
    },
    "temperature": {
        "thermal-zone": 0,
        "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
        "format": "{temperatureC}°C",
        "interval": 5
    },
    "battery": {
        "format": "{capacity}% {icon}",
        "format-icons": ["", "", "", "", ""],
        "interval": 5
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ifname} ",
        "format-disconnected": "Disconnected ⚠",
        "interval": 5
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon}",
        "format-muted": "Muted 🔇",
        "format-icons": {
            "headphones": "",
            "handsfree": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "scroll-step": 5,
        "on-click": "pavucontrol"
    }
}
EOF
    
    # Create Waybar style
    cat << 'EOF' > ~/.config/waybar/style.css
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono", "Font Awesome 6 Free", sans-serif;
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: rgba(40, 40, 40, 0.9);
    color: #ffffff;
    border-bottom: 1px solid rgba(100, 100, 100, 0.5);
}

#workspaces button {
    padding: 0 10px;
    background: transparent;
    color: #888888;
    border-bottom: 3px solid transparent;
}

#workspaces button.focused {
    color: #ffffff;
    border-bottom: 3px solid #5294e2;
}

#workspaces button.urgent {
    color: #ff5555;
}

#mode {
    background: #64727d;
    border-bottom: 3px solid #ffffff;
}

#clock, #battery, #cpu, #memory, #temperature, #network, #pulseaudio, #tray {
    padding: 0 10px;
    margin: 0 4px;
}

#clock {
    background-color: #64727d;
}

#battery {
    background-color: #ffffff;
    color: #000000;
}

#battery.charging {
    color: #ffffff;
    background-color: #26a65b;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#cpu {
    background: #2ecc71;
    color: #000000;
}

#memory {
    background: #9b59b6;
}

#temperature {
    background: #f0932b;
}

#temperature.critical {
    background: #eb4d4b;
}

#network {
    background: #2980b9;
}

#network.disconnected {
    background: #f53c3c;
}

#pulseaudio {
    background: #f1c40f;
    color: #000000;
}

#pulseaudio.muted {
    background: #90b1b1;
    color: #2a5c45;
}

#tray {
    background-color: #2980b9;
}
EOF
    
    log_info "Waybar configuration created at ~/.config/waybar/"
}

# Configure Fuzzel
configure_fuzzel() {
    log_info "Configuring Fuzzel..."
    
    # Create Fuzzel config directory
    mkdir -p ~/.config/fuzzel
    
    # Create minimal Fuzzel configuration
    cat << 'EOF' > ~/.config/fuzzel/fuzzel.ini
[main]
font=JetBrains Mono:size=11
dpi-aware=yes
lines=10
width=40
horizontal-pad=20
vertical-pad=20
inner-pad=10

[border]
width=2
radius=8

[colors]
background=2e3440ff
text=e5e9f0ff
match=88c0d0ff
selection=4c566aff
selection-text=e5e9f0ff
border=5e81acff
EOF
    
    log_info "Fuzzel configuration created at ~/.config/fuzzel/fuzzel.ini"
}

# Main execution
main() {
    log_info "Starting Sway Wayland GUI setup..."
    
    install_wayland_stack
    create_sway_wrapper
    configure_sway
    configure_waybar
    configure_fuzzel
    
    log_info "Sway Wayland GUI setup completed successfully!"
    log_info ""
    log_info "To start Sway:"
    log_info "1. Log out of your current session"
    log_info "2. At the login manager, select 'Sway'"
    log_info "3. Or run from terminal: ~/.local/bin/start-sway"
    log_info ""
    log_info "The launch wrapper ensures Sway uses Intel Arc B50 for display"
    log_info "keeping the R9700 free for inference workloads."
}

main