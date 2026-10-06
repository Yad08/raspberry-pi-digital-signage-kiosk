#!/bin/bash

set -e

echo "=========================================="
echo " Raspberry Pi Digital Signage Kiosk"
echo " Installer"
echo "=========================================="
echo

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Repository directory:"
echo "$REPO_DIR"
echo

echo "Installing required packages..."
sudo apt update
sudo apt install -y feh wlopm

echo
echo "Creating Labwc configuration directory..."
mkdir -p "$HOME/.config/labwc"

echo
echo "Installing kiosk scripts..."

cp "$REPO_DIR/scripts/screen_on.sh" "$HOME/screen_on.sh"
cp "$REPO_DIR/scripts/screen_off.sh" "$HOME/screen_off.sh"
cp "$REPO_DIR/scripts/screen_state.sh" "$HOME/screen_state.sh"

chmod +x "$HOME/screen_on.sh"
chmod +x "$HOME/screen_off.sh"
chmod +x "$HOME/screen_state.sh"

echo
echo "Installing Labwc autostart configuration..."

cp "$REPO_DIR/config/labwc-autostart" "$HOME/.config/labwc/autostart"

echo
echo "Core kiosk files installed successfully."
echo

echo "------------------------------------------"
echo " Remaining Setup Steps"
echo "------------------------------------------"
echo

echo "1. Place your menu image in a permanent location."
echo
echo "   Example:"
echo "   /boot/firmware/kiosk_images/menu.png"
echo

echo "2. Verify the image path in:"
echo "   ~/.config/labwc/autostart"
echo

echo "3. Configure the display schedule:"
echo
echo "   crontab -e"
echo
echo "   Example:"
echo "   0 7 * * * $HOME/screen_on.sh"
echo "   0 22 * * * $HOME/screen_off.sh"
echo

echo "4. Verify your timezone:"
echo
echo "   timedatectl"
echo

echo "5. Test the display scripts:"
echo
echo "   ~/screen_off.sh"
echo "   ~/screen_on.sh"
echo

echo "6. Reboot when ready:"
echo
echo "   sudo reboot"
echo

echo "=========================================="
echo " Installation Complete"
echo "=========================================="
