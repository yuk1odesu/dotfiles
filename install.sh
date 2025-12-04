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
if [ -f pkglist ]; then
  sudo pacman -S --needed --noconfirm - < pkglist
fi

# Install packages from aurpkglist with yay
if [ -f aurpkglist ]; then
  yay -S --needed --noconfirm - < aurpkglist
fi

# Install Oh My Zsh non-interactively
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Oh My Zsh plugins: zsh-autosuggestions and zsh-syntax-highlighting
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Copy .zshrc to /home
sudo cp .zshrc /home/
sudo chown $(whoami):$(whoami) /home/.zshrc

# Copy .config folder to /home
sudo cp -r .config /home/
sudo chown -R $(whoami):$(whoami) /home/.config

# Copy wallpapers folder to /home
sudo cp -r wallpapers /home/
sudo chown -R $(whoami):$(whoami) /home/wallpapers

