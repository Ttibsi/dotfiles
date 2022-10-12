#!/bin/bash

SSH_DIR="$HOME/.ssh"

# apt update && upgrade
echo -e "-----UPDATE && UPGRADE-----"
sudo apt update && sudo apt upgrade -y

# Remove old installs/files
echo -e "-----REMOVE UNNEEDED FILES-----"
sudo rm -rf /usr/local/go
rm -rf $(HOME)/Workspace \
    $(HOME)/.opt \
    $(HOME)/.opt/lua-language-server \

# gnome settings
echo -e "-----GNOME SETTINGS-----"
gsettings set org.gnome.desktop.interface show-battery-percentage true
xdotool key super+y # Enable pop tiling

# File structure setup
echo -e "-----SET UP FILE STRUCTURE-----"
rm -rf $(HOME)/Desktop \
    $(HOME)/Documents \
    $(HOME)/Music \
    $(HOME)/Pictures \
    $(HOME)/Public \
    $(HOME)/Templates \
    $(HOME)/Videos \

mkdir $(HOME)/Workspace \
    $(HOME)/.opt \
    $(HOME)/.opt/lua-language-server \

# apt install everything
echo -e "-----INSTALL PACKAGES-----"
sudo apt-get install \
blueman \
build-essential \
cheese \
cowsay \
curl \
flameshot \
gcc \
git \
libreoffice \
neofetch \
pipes \
powertop \
python3 \
rpi-imager \
tlp \
tmux \
tree \
unzip \
vlc \
xclip \
zsh \
-y

# Other installs
curl -Lo $(HOME)/Downloads/btm.deb https://github.com/ClementTsang/bottom/releases/download/0.6.8/bottom_0.6.8_amd64.deb
sudo dpkg -i $(HOME)/Downloads/btm.deb
flatpak install flathub com.discordapp.Discord

# Python environment - anthony explains 79
echo -e "-----CONFIGURE PYTHON ENVIRONMENT-----"
curl -Lo $(HOME)/Downloads/virtualenv.pyz https://bootstrap.pypa.io/virtualenv.pyz
python3 $(HOME)/Downloads/virtualenv.pyz $(HOME)/.opt/venv
$(HOME)/opt/venv/bin/pip install virtualenv
ln -s $(HOME)/bin/virtualenv $(HOME)/opt/venv/bin/virtualenv

echo -e "-----MANUAL INSTALLATIONS-----"
# manual install - go, fonts, neovim
curl -LO https://go.dev/dl/go1.19.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz

curl -L https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete%20Mono.otf > DroidSansMono_NerdFont
mv DroidSansMono_NerdFont $(HOME)/share/fonts/

git clone git@github.com:neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd ..
rm -rf neovim

git clone git@github.com:savq/paq-nvim.git $(HOME)/.local/share/nvim/site/pack/paqs/start/paq-nvim/

$(HOME)/opt/venv/bin/pip install python-lsp-server

curl -Lo https://github.com/sumneko/lua-language-server/releases/download/3.5.6/lua-language-server-3.5.6-linux-x64.tar.gz $(HOME)/Downloads/lls.tar.gz
sudo tar -C $(HOME)./opt/lua-language-server -xzf $(HOME)/Downloads/lls

go install golang.org/x/tools/gopls@latest

nvim --headless -c 'PaqInstall' +q

# set up symlinks
echo -e "-----SET UP CONFIG SYMLINKS-----"
git clone git@github.com:Ttibsi/dotfiles.git $(HOME)/Workspace/dotfiles

ln -s $(HOME)/Workspace/dotfiles/configs/firefox/policies.json /usr/lib/firefox/distribution/policies.json
ln -s $(HOME)/Workspace/dotfiles/configs/git-config/gitconfig $(HOME)/.gitconfig
ln -s $(HOME)/Workspace/dotfiles/configs/internal-configs/90-touchpad.conf /etc/X11/xorg.conf.d/90-touchpad.conf
ln -s $(HOME)/Workspace/dotfiles/configs/nvim $(HOME)/.config/nvim
ln -s $(HOME)/Workspace/dotfiles/configs/tmux $(HOME)/.config/tmux
ln -s $(HOME)/Workspace/dotfiles/configs/zsh-shell/ $(HOME)/

# Tidy up 
echo -e "-----CLEAN UP-----"
rm -rf $(HOME)/Downloads/*
sudo apt autoclean -y
sudo apt autoremove -y

# Generate SSH key
echo -e "-----GENERATE SSH KEY-----"
if ! [[ -f "$SSH_DIR/authorized_keys" ]]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    ssh-keygen -b 4096 -t rsa -f "$SSH_DIR/id_rsa" -N "" -C "$USER@$HOSTNAME"
    cat "$SSH_DIR/id_rsa.pub" >> "$SSH_DIR/authorized_keys"
fi

cat "$SSH_DIR/id_rsa.pub" | xclip -selection c
echo "Add to account here: https://github.com/settings/keys"

echo -e "Configuration complete"
