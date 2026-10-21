#!/bin/bash
set -e

echo "=================================================="
echo "       ANOLINUX CONFIGURING (HANDBOOK EDITION)    "
echo "=================================================="

# 1. Запрос на установку драйверов NVIDIA
read -p "Install NVIDIA Drivers? (Required for normally working) (Not fully configuring drivers) [y/n]: " NVIDIA_CHOICE

if [[ "$NVIDIA_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing NVIDIA drivers & linux-headers via pacman ==="
    pacman -S --noconfirm nvidia-dkms nvidia-utils nvidia-settings linux-headers
else
    echo "=== Skipping NVIDIA drivers installation ==="
fi

echo "--------------------------------------------------"

# 2. Выбор альтернативной оболочки / окружения
echo "Install another shell from list?"
echo "  1) Gnome"
echo "  2) Xfce4"
echo "  3) Hyprland"
echo "  4) No, keep KDE Plasma"
read -p "Enter choice [1-4]: " SHELL_CHOICE

case "$SHELL_CHOICE" in
    1)
        echo "=== Installing GNOME desktop environment ==="
        pacman -S --noconfirm gnome gdm
        systemctl disable sddm || true
        systemctl enable gdm
        ;;
    2)
        echo "=== Installing Xfce4 desktop environment ==="
        pacman -S --noconfirm xfce4 xfce4-goodies
        ;;
    3)
        echo "=== Installing Hyprland window manager ==="
        pacman -S --noconfirm hyprland kitty waybar rofi mako
        ;;
    4|*)
        echo "=== Keeping default KDE Plasma configuration ==="
        ;;
esac

echo "--------------------------------------------------"

# 3. Установка AUR helper (yay)
read -p "Install AUR (yay) (git included)? [y/n]: " YAY_CHOICE

if [[ "$YAY_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing base-devel, git and building yay ==="
    pacman -S --noconfirm --needed base-devel git
    
    # Сборка yay из-под root в chroot требует создания временного неполномочного пользователя, 
    # так как makepkg запрещает сборку от root напрямую.
    if [ ! -d "yay" ]; then
        git clone https://aur.archlinux.org/yay.git
    fi
    chown -R nobody:nobody yay
    cd yay
    sudo -u nobody makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "=== Skipping AUR (yay) installation ==="
fi

echo "--------------------------------------------------"

# 4. Выбор звукового сервера
echo "Install PipeWire or PulseAudio?"
echo "  1) Pipewire"
echo "  2) PulseAudio"
echo "  3) No, i will use system without sound"
read -p "Enter choice [1-3]: " SOUND_CHOICE

case "$SOUND_CHOICE" in
    1)
        echo "=== Installing PipeWire ==="
        pacman -S --noconfirm pipewire
        ;;
    2)
        echo "=== Installing PulseAudio ==="
        pacman -S --noconfirm pulseaudio
        ;;
    3|*)
        echo "=== Skipping sound server installation ==="
        ;;
esac

echo "--------------------------------------------------"

# 5. Установка регулятора громкости
read -p "Install Volume Control? (pavucontrol) [y/n]: " PAVU_CHOICE

if [[ "$PAVU_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing pavucontrol ==="
    pacman -S --noconfirm pavucontrol
else
    echo "=== Skipping pavucontrol installation ==="
fi

echo "=================================================="
echo "               Installation Finished!             "
echo "=================================================="
