#!/bin/bash

# Stop script on error
set -e

echo "=========================================="
echo "    Arch Linux Qtile Setup (CyberSec)     "
echo "=========================================="

# 1. Install Official Packages
echo "[*] Installing Official Packages..."
# Swapped bspwm/polybar for qtile, python-pywal, and required tools
sudo pacman -S --noconfirm base-devel git qtile python-pywal python-psutil \
    lightdm lightdm-webkit2-greeter lightdm-gtk-greeter polkit-gnome picom \
    rofi feh dunst libnotify ttf-jetbrains-mono-nerd ttf-fira-sans \
    networkmanager network-manager-applet pipewire pipewire-pulse wireplumber pavucontrol \
    kitty thunar thunar-volman thunar-archive-plugin flameshot nano unzip \
    intel-ucode xf86-video-nouveau xorg-server xorg-xinit \
    imagemagick scrot xclip  # <--- ADD THESE 3

# NOTE: 'xf86-video-nouveau' is for Nvidia. If you use Intel GPU only, remove it. 
# If you use AMD, swap it for 'xf86-video-amdgpu'.

# 2. Install Yay (AUR Helper)
if ! command -v yay &> /dev/null; then
    echo "[*] Installing Yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "[*] Yay is already installed."
fi

# 3. Install AUR Packages
echo "[*] Installing AUR Packages..."
# qtile-extras is REQUIRED for your config (PowerLine decorations)
yay -S --noconfirm microsoft-edge-stable-bin pam-voiceprint qtile-extras

# 4. Create Config Directories
echo "[*] Creating Directories..."
mkdir -p ~/.config/qtile/scripts
mkdir -p ~/.config/picom
mkdir -p ~/.config/rofi
# Create directory for wallpapers if it doesn't exist
mkdir -p ~/Pictures/Wallpapers

# 5. Copy Dotfiles
# Assumes you are running this script from a folder containing your config files
echo "[*] Copying Configs..."

# Copy Qtile config
if [ -f "qtile/config.py" ]; then
    cp qtile/config.py ~/.config/qtile/
else
    echo "WARNING: qtile/config.py not found in current directory!"
fi

# Copy Scripts (Autostart, Screenshot, etc.)
# You need to put your shell scripts in a folder named 'scripts' alongside this installer
if [ -d "scripts" ]; then
    cp scripts/* ~/.config/qtile/scripts/
    chmod +x ~/.config/qtile/scripts/*
fi

# Copy Picom
[ -f "picom/picom.conf" ] && cp picom/picom.conf ~/.config/picom/

# 6. FIX PATHS in config.py
# Your config used ~/.config/ml4w. We change it to ~/.config/qtile/scripts automatically.
echo "[*] Patching config.py paths..."
sed -i 's|.config/ml4w/settings|.config/qtile/scripts|g' ~/.config/qtile/config.py
sed -i 's|.config/qtile/scripts|.config/qtile/scripts|g' ~/.config/qtile/config.py

# 7. Configure LightDM
echo "[*] Configuring Login Screen..."
if [ ! -f "/etc/lightdm/lightdm.conf.bak" ]; then
    sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bak
fi
sudo sed -i 's/^#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf

# 8. Enable Services
echo "[*] Enabling Services..."
sudo systemctl enable NetworkManager
sudo systemctl enable lightdm.service

# 9. Prevent Qtile Crash (Generate Colors)
echo "[*] Generating default Pywal colors..."
# We need a default wallpaper to generate colors, or Qtile will crash reading colors.json
# Using a placeholder color if no wallpaper exists
if [ -z "$(ls -A ~/Pictures/Wallpapers)" ]; then
    wal --theme dark
else
    # Pick first wallpaper found
    wal -i "$(find ~/Pictures/Wallpapers -type f | head -n 1)"
fi

echo "=========================================="
echo "   SETUP COMPLETE! "
echo "   1. Run 'voiceprint -c' to train voice."
echo "   2. Reboot."
echo "=========================================="