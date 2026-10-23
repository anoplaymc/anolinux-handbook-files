#!/bin/bash
set -e

echo "Installing AnoLinux Packages..."
pacman -S --noconfirm sddm plasma-meta konsole kitty fastfetch firefox git python-pyqt6 python-requests

echo "Setting AnoLinux parameters..."

# Устанавливаем hostname и зашиваем локальный домен в /etc/hosts
echo "anolinux" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\tanolinux.localdomain\tanolinux" > /etc/hosts

cat << 'OSRELEASE' > /etc/os-release
NAME="AnoLinux"
ID=anolinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="36;1"
HOME_URL="https://github.com/anoplaymc/anolinux"
DOCUMENTATION_URL="https://github.com/anoplaymc/anolinux"
SUPPORT_URL="https://github.com/anoplaymc/anolinux"
BUG_REPORT_URL="https://github.com/anoplaymc/anolinux"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=anolinux
OSRELEASE

echo "Setting GRUB"
sed -i 's/TITLE=Arch Linux/TITLE=AnoLinux/g' /etc/grub.d/10_linux || true

echo "Installing Ano Package Manager..."
cat << 'ANO_SCRIPT' > /usr/local/bin/ano
#!/bin/bash
if [ "$1" = "update" ]; then
    sudo pacman -Syu
elif [ "$1" = "install" ]; then
    shift
    sudo pacman -S "$@"
elif [ "$1" = "remove" ]; then
    shift
    sudo pacman -R "$@"
elif [ "$1" = "removeall" ]; then
    shift
    sudo pacman -Rns "$@"
elif [ "$1" = "search" ]; then
    shift
    sudo pacman -Ss "$@"
else
    echo "=== AnoLinux Package Manager (ano) ==="
    echo "Usage:"
    echo "  ano update   - Synchronize and upgrade system"
    echo "  ano install  - Install software packages"
    echo "  ano remove   - Remove software packages"
    echo "  ano removeall- Remove software packages and needed for it"
    echo "  ano search   - Search in AnoLinux repositories"
fi
ANO_SCRIPT

# Делаем скрипт исполняемым
chmod +x /usr/local/bin/ano

echo "Setting additional firmware..."
mkdir -p /etc/fastfetch

cat << 'FASTFETCH_CONF' > /etc/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "source": "linux"
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "display",
    "de",
    "separator",
    "wm",
    "wmtheme",
    "theme",
    "icons",
    "font",
    "cursor",
    "separator",
    "terminal",
    "terminalfont",
    "cpu",
    "gpu",
    "memory",
    "swap",
    "disk",
    "battery",
    "poweradapter",
    "localip",
    "locale",
    "break",
    "colors"
  ]
}
FASTFETCH_CONF

echo "Enabling SDDM..."
systemctl enable sddm
