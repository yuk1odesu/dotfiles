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

# Запрос про NVIDIA GPU
echo "Проверяем наличие NVIDIA GPU..."
read -p "Do u have nvidia gpu? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Обнаружена NVIDIA GPU. Устанавливаем драйверы..."

    # Проверяем наличие скрипта nvidia_drivers_install.sh
    if [ -f "./nvidia_drivers_install.sh" ]; then
        sudo chmod +x ./nvidia_drivers_install.sh
        ./nvidia_drivers_install.sh
        NVIDIA_STATUS="установлены"
    else
        echo "Файл nvidia_drivers_install.sh не найден!"
        NVIDIA_STATUS="file not found"
    fi
else
    echo "NVIDIA GPU не обнаружена. Пропускаем установку драйверов."
    NVIDIA_STATUS="не установлены"
fi

echo "NVIDIA драйверы: $NVIDIA_STATUS"

# Install packages from aurpkglist with yay
yay -S --needed --noconfirm - < allpkglist.txt

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

# Enable sddm and install theme 
sudo systemctl enable sddm.service
sudo sh -c 'printf "[Theme]\nCurrent=obscure\n" > /etc/sddm.conf'

# Install grub theme
sudo cp -r teleport-abyss /boot/grub/themes
sudo tee -a /etc/default/grub << EOF
GRUB_TIMEOUT=5
GRUB_TIMEOUT_STYLE=menu
GRUB_TERMINAL_OUTPUT=gfxterm
GRUB_GFXMODE="1920x1080,auto"
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_THEME="/boot/grub/themes/teleport-abyss/theme.txt"
EOF

# reload grub config
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install useful github repos
mkdir repos
cd repos
git clone https://github.com/poach3r/pywal-obsidianmd
cd pywal-obsidianmd
sudo chmod +x pywal-obsidianmd.sh
cd

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
