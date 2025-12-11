#!/bin/bash

# nvidia_drivers_install.sh - Модульный скрипт установки NVIDIA драйверов
# Вызывается из основного скрипта setup_system.sh

echo "🔧 Начинаем установку NVIDIA драйверов..."

# Функция для удаления первого символа (#) в указанных строках /etc/pacman.conf
edit_pacman_conf() {
    echo "   → Редактируем /etc/pacman.conf (строки 92-93)..."
    sudo sed -i '92s/^#//' /etc/pacman.conf
    sudo sed -i '93s/^#//' /etc/pacman.conf
}

# Функция для установки пакетов из файла ifinvidia.txt
install_nvidia_packages() {
    if [ -f "ifinvidia.txt" ]; then
        echo "   → Читаем пакеты из ifinvidia.txt..."
        mapfile -t packages < ifinvidia.txt
        echo "   → Устанавливаем пакеты: ${packages[*]}"
        yay -S "${packages[@]}" --noconfirm
    else
        echo "Файл ifinvidia.txt не найден!"
        exit 1
    fi
}

# Функция для редактирования /etc/mkinitcpio.conf
edit_mkinitcpio() {
    echo "   → Настраиваем MODULES в /etc/mkinitcpio.conf..."
    sudo sed -i 's/^MODULES=.*/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
}

# 1. Редактируем /etc/pacman.conf
edit_pacman_conf

# 2. Обновляем yay
echo "   → Обновляем репозитории (yay -Syyu)..."
yay -Syyu --noconfirm

# 3. Устанавливаем пакеты из ifinvidia.txt
install_nvidia_packages

# 4. Редактируем MODULES в mkinitcpio.conf
edit_mkinitcpio

# 5. Пересобираем initramfs
echo "   → Пересобираем initramfs (mkinitcpio -P)..."
sudo mkinitcpio -P

echo "NVIDIA драйверы успешно установлены!"
echo "ℹ️  Не забудьте перезагрузить систему после завершения основной установки."

