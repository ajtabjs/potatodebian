#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Visual formatting configurations
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Linux Debian Bluetooth & PipeWire Setup ===${NC}"

# 1. Elevate permissions checking
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Please run this script as a normal user with sudo privileges, not root.${NC}"
    echo "The script needs to configure user-level systemd services for your account."
    exit 1
fi

# Ensure sudo availability early
sudo -v

# 2. Package Installation
echo -e "\n${BLUE}[1/4] Installing PipeWire, Bluez, and required modules...${NC}"
sudo apt-get update

# Install PipeWire audio components (replaces native pulseaudio packages)
sudo apt-get install -y pipewire pipewire-audio pipewire-pulse wireplumber libspa-0.2-bluetooth pulseaudio-utils

# Install Blueman UI elements explicitly referenced in the documentation
sudo apt-get install -y bluez bluez-tools blueman

# 3. Configure Bluetooth System Policies (/etc/bluetooth/main.conf)
echo -e "\n${BLUE}[2/4] Injecting configuration rules into /etc/bluetooth/main.conf...${NC}"
BT_CONF="/etc/bluetooth/main.conf"

if [ -f "$BT_CONF" ]; then
    # Create a timestamped backup before touching configuration files
    sudo cp "$BT_CONF" "${BT_CONF}.bak.$(date +%F_%H%M%S)"
    
    # Ensure [General] block configurations are active
    # Handle 'Enable' directive
    if grep -q "^#\?Enable\s*=" "$BT_CONF"; then
        sudo sed -i 's/^#\?Enable\s*=.*/Enable=Control,Gateway,Headset,Media,Sink,Socket,Source/' "$BT_CONF"
    else
        sudo sed -i '/^\[General\]/a Enable=Control,Gateway,Headset,Media,Sink,Socket,Source' "$BT_CONF"
    fi

    # Handle 'Experimental' directive
    if grep -q "^#\?Experimental\s*=" "$BT_CONF"; then
        sudo sed -i 's/^#\?Experimental\s*=.*/Experimental = true/' "$BT_CONF"
    else
        sudo sed -i '/^\[General\]/a Experimental = true' "$BT_CONF"
    fi

    # Handle 'KernelExperimental' directive
    if grep -q "^#\?KernelExperimental\s*=" "$BT_CONF"; then
        sudo sed -i 's/^#\?KernelExperimental\s*=.*/KernelExperimental = true/' "$BT_CONF"
    else
        sudo sed -i '/^\[General\]/a KernelExperimental = true' "$BT_CONF"
    fi
    echo "Bluetooth system files altered successfully."
else
    echo -e "${YELLOW}Warning: /etc/bluetooth/main.conf not found. Skipping file edits.${NC}"
fi

# 4. System-wide Daemons
echo -e "\n${BLUE}[3/4] Restarting system Bluetooth daemon...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable bluetooth.service
sudo systemctl restart bluetooth.service

# 5. User-space Audio Engines (PipeWire Architecture)
echo -e "\n${BLUE}[4/4] Activating User-space Audio Daemons...${NC}"
# Enable and start user units
systemctl --user daemon-reload
systemctl --user --now enable wireplumber.service
systemctl --user --now enable pipewire.service
systemctl --user --now enable pipewire-pulse.service

# Restart instances to guarantee new codec initialization hookups
systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service

echo -e "\n${GREEN}=== Script Execution Completed! ===${NC}"
echo -e "${YELLOW}CRITICAL NEXT STEPS:${NC}"
echo "1. Log out of your desktop environment and log back in (or reboot)."
echo "2. Once logged back in, verify the running backend engine state by typing:"
echo "   pactl info | grep 'Server Name'"
echo "   (It should print: 'Server Name: PulseAudio (on PipeWire 0.x.x)')"
