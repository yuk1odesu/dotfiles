#!/usr/bin/env bash
set -e

# Update system and install base-devel and git for building yay
sudo pacman -Sy --needed --noconfirm base-devel git

# Install yay AUR helper
if ! command -v yay &> /dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
  rm -rf /tmp/yay
fi

# Install packages from pkglist with pacman
sudo pacman -S --needed --noconfirm $(comm -13 <(pacman -Qqq | sort) <(sort pkglist.txt))

# Install packages from aurpkglist with yay
yay -S --needed --noconfirm - < aurpkglist.txt

# Install Oh My Zsh non-interactively
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

chsh -s $(which zsh)

# Install Oh My Zsh plugins: zsh-autosuggestions and zsh-syntax-highlighting
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Install fzf
git clone https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Install zsh theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Copy .zshrc to /home
sudo cp .zshrc /home/$(whoami)/
sudo chown $(whoami):$(whoami) /home/$(whoami)/.zshrc

# Copy .config folder to /home
sudo cp -r .config /home/$(whoami)/
sudo chown -R $(whoami):$(whoami) /home/$(whoami)/.config

# Copy wallpapers folder to /home
sudo cp -r wallpapers /home/$(whoami)/
sudo chown -R $(whoami):$(whoami) /home/$(whoami)/wallpapers

reboot
