#!/bin/bash
# TurukOS Enhanced Configuration Script
# turuk-setup-enhanced.sh

echo ">>> Starting TurukOS Enhanced Build Process..."

# 1. System Update
apt-get update && apt-get upgrade -y

# 2. Core Desktop Environment
apt-get install -y \
    ubuntu-desktop-minimal \
    gnome-shell \
    gnome-shell-extensions \
    gnome-tweaks \
    gnome-shell-extension-manager \
    dconf-editor \
    git \
    curl \
    wget \
    zsh \
    fonts-powerline \
    fonts-firacode \
    build-essential

# 3. Required Applications
apt-get install -y \
    firefox \
    code \
    gimp \
    vlc \
    gparted \
    gnome-software \
    software-properties-common

# 4. Gaming & Multimedia
# Wine for Windows compatibility
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main'
apt-get update
apt-get install -y --install-recommends winehq-stable

# Steam
apt-get install -y steam-installer

# VirtualBox
apt-get install -y virtualbox virtualbox-ext-pack

# 5. VPN & Security
# Proton VPN CLI (if available)
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-2_all.deb
dpkg -i protonvpn-stable-release_1.0.3-2_all.deb
apt-get update
apt-get install -y protonvpn

# 6. Theme Installation - WhiteSur
echo ">>> Installing WhiteSur Theme Suite..."

# GTK Theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk
/tmp/WhiteSur-gtk/install.sh -c Light -o normal -p 60 -P smaller -i ubuntu

# Icon Theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icons
/tmp/WhiteSur-icons/install.sh -b

# Cursor Theme
git clone https://github.com/vinceliuice/WhiteSur-cursors.git /tmp/WhiteSur-cursors
mkdir -p /usr/share/icons/WhiteSur-cursors
cp -r /tmp/WhiteSur-cursors/dist/* /usr/share/icons/WhiteSur-cursors/

# 7. GNOME Extensions Installation
echo ">>> Configuring GNOME Extensions..."

# Create extension directory for system-wide installation
mkdir -p /usr/share/gnome-shell/extensions/

# Install extensions manually (example for one extension)
# Dash to Panel
DASH_TO_PANEL_UUID="dash-to-panel@jderose9.github.com"
wget https://extensions.gnome.org/extension-data/dash-to-paneljderose9.github.com.v74.shell-extension.zip
mkdir -p /usr/share/gnome-shell/extensions/$DASH_TO_PANEL_UUID
unzip dash-to-paneljderose9.github.com.v74.shell-extension.zip -d /usr/share/gnome-shell/extensions/$DASH_TO_PANEL_UUID

# 8. ZSH Configuration with Oh-My-Zsh
echo ">>> Configuring ZSH with Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/oh-my-zsh/custom/themes/powerlevel10k

# Create default .zshrc template
cat <<EOF > /etc/skel/.zshrc
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh
# TurukOS Custom Prompt
PROMPT="%F{white}┌─[%F{blue}%n@TurukOS%f] - [%F{green}%~%f]
└─╼ %F{white}$ %f"
EOF

# 9. System-wide Default Settings
echo ">>> Applying TurukOS Default Settings..."

# Create dconf profile
cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF

# Create dconf database with our settings
mkdir -p /etc/dconf/db/local.d/01-turukos

cat <<EOF > /etc/dconf/db/local.d/01-turukos
[org/gnome/desktop/interface]
gtk-theme='WhiteSur-Light'
icon-theme='WhiteSur'
cursor-theme='WhiteSur-cursors'
font-name='Ubuntu 11'
document-font-name='Sans 11'
monospace-font-name='Ubuntu Mono 13'
color-scheme='prefer-light'

[org/gnome/desktop/wm/preferences]
button-layout='close,minimize,maximize:'

[org/gnome/shell]
favorite-apps=['firefox.desktop', 'org.gnome.Nautilus.desktop', 'code.desktop', 'org.gnome.Terminal.desktop']

[org/gnome/shell/extensions/dash-to-panel]
panel-position='BOTTOM'
panel-size=48
trans-use-custom-opacity=true
trans-panel-opacity=0.7
EOF

# Update dconf
dconf update

# 10. Create TurukOS Welcome Application
cat <<EOF > /usr/share/applications/turukos-welcome.desktop
[Desktop Entry]
Name=Welcome to TurukOS
Comment=Get started with TurukOS
Exec=gnome-terminal -- bash -c "echo 'Welcome to TurukOS!'; echo 'Please install recommended extensions:'; echo '1. Dash to Panel'; echo '2. ArcMenu'; echo '3. Blur My Shell'; echo '4. Just Perfection'; read -p 'Press Enter to open Extension Manager...'; gnome-extensions-app; bash"
Terminal=false
Type=Application
Icon=gnome-help
Categories=System;
EOF

# 11. Cleanup
apt-get autoremove -y
apt-get clean
rm -rf /tmp/*

echo ">>> TurukOS Enhanced Configuration Complete!"
echo ">>> Remember to install GNOME Extensions from Extension Manager on first boot."
