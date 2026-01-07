#!/bin/bash

# 1. Install Official Packages
echo "Installing Official Packages..."
sudo pacman -S --noconfirm intel-ucode xf86-video-nouveau xorg-server xorg-xinit base-devel git bspwm sxhkd lightdm lightdm-webkit2-greeter lightdm-gtk-greeter polkit-gnome picom polybar rofi feh dunst libnotify ttf-jetbrains-mono-nerd networkmanager network-manager-applet pipewire pipewire-pulse wireplumber pavucontrol kitty thunar thunar-volman thunar-archive-plugin flameshot nano

# 2. Install Yay (AUR Helper)
echo "Installing Yay..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# 3. Install AUR Packages
echo "Installing Edge and Voiceprint..."
yay -S --noconfirm microsoft-edge-stable-bin pam-voiceprint

# 4. Create Config Directories
echo "Creating Directories..."
mkdir -p ~/.config/bspwm
mkdir -p ~/.config/sxhkd
mkdir -p ~/.config/polybar
mkdir -p ~/.config/picom

# 5. Copy Dotfiles (From your repo to the system)
echo "Copying Configs..."
cp bspwm/bspwmrc ~/.config/bspwm/
chmod +x ~/.config/bspwm/bspwmrc

cp sxhkd/sxhkdrc ~/.config/sxhkd/

cp picom/picom.conf ~/.config/picom/

cp polybar/launch.sh ~/.config/polybar/
chmod +x ~/.config/polybar/launch.sh
cp polybar/config.ini ~/.config/polybar/

# 6. Configure LightDM (Login Screen)
echo "Configuring Login Screen..."
# Backup the original config
sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bak
# Set the Greeter to Webkit2
sudo sed -i 's/^#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf

# 7. Enable Services
echo "Enabling Services..."
sudo systemctl enable NetworkManager
sudo systemctl enable lightdm.service

echo "Detecting Network Interfaces..."

# 1. Find the WiFi Interface name (starts with 'w')
wifi_interface=$(ip link | grep -oP 'w\w+' | grep -v 'wlan0' | head -1)
# If found, replace 'wlan0' in the config with the real name
if [ -n "$wifi_interface" ]; then
    sed -i "s/interface = wlan0/interface = $wifi_interface/" ~/.config/polybar/config.ini
fi

# 2. Find the Ethernet Interface name (starts with 'e')
eth_interface=$(ip link | grep -oP 'e\w+' | grep -v 'eth0' | head -1)
# If found, replace 'eth0' in the config with the real name
if [ -n "$eth_interface" ]; then
    sed -i "s/interface = eth0/interface = $eth_interface/" ~/.config/polybar/config.ini
fi

echo "SETUP COMPLETE! Please run 'voiceprint -c' to train your voice, then reboot."