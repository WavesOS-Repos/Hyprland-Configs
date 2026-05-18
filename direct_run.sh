#!/bin/bash

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\e[1;38;5;214m"
end="\e[1;0m"

clear && sleep 1

printf "${orange}=>${end} Starting the script...\n" && sleep 2

packages=(
    git
    gum
    unzip
    wget
)

for pkg in "${packages[@]}"; do

    if command -v pacman &> /dev/null; then
        if sudo pacman -Q "$pkg" &> /dev/null; then
            printf "${magenta}[ SKIP ]${end} Skipping $pkg, it was already installed..\n"
        else
            printf "${green}=>${end} Installing $pkg...\n"
            sudo pacman -S --noconfirm "$pkg" &> /dev/null

            if sudo pacman -Q "$pkg" &> /dev/null; then
                printf "${cyan}::${end} $pkg was installed successfully!\n"
            fi
        fi
    elif command -v zypper &> /dev/null; then

        if sudo zypper se -i "$pkg" &>/dev/null; then
            printf "${magenta}[ SKIP ]${end} Skipping $pkg, it was already installed..\n"
        else
            printf "${green}=>${end} Installing $pkg...\n"
            sudo zypper in -y "$pkg";

            if sudo zypper se -i "$pkg" &> /dev/null; then
                printf "${cyan}::${end} $pkg was installed sucessfully!\n"
            fi
        fi
    fi

done

# install base-devel for arch linux
if command -v pacman &> /dev/null; then
    if sudo pacman -Q base-devel &> /dev/null; then
        printf "${magenta}[ SKIP ]${end} Skipping base-devel, it was already installed..\n"
    else
        sudo pacman -S --needed base-devel --noconfirm &> /dev/null
        if sudo pacman -Q base-devel &> /dev/null; then
            printf "${cyan}::${end} base-devel was installed successfully!\n"
        fi
    fi
fi

# only for fedora
if command -v dnf &> /dev/null; then

    for _pkg in git unzip wget; do

        if rpm -q $_pkg &> /dev/null; then
            printf "${magenta}[ SKIP ]${end} Skipping $_pkg, it was already installed..\n"
        else
            printf "${green}=>${end} Installing $_pkg...\n"
            sudo dnf install -y $_pkg
            
            if rpm -q $_pkg; then
                printf "${cyan}::${end} $_pkg was installed successfully!\n"
            fi
        fi
        
    done

    sleep 1

    if rpm -q gum &> /dev/null; then
        printf "${magenta}[ SKIP ]${end} Skipping gum, it was already installed..\n"
    else
        printf "${green}=>${end} Installing gum...\n"
    echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo &>/dev/null

        sudo yum install --assumeyes gum
    fi

    if rpm -q gum &> /dev/null; then
        printf "${cyan}::${end} Gum was installed successfully!\n"
    fi
fi

sleep 1 && clear
 
[[ ! "$(pwd)" == "$HOME" ]] && cd "$HOME"

printf "${green}=>${end} Preparing the installation scripts...\n" && echo

curl -L https://github.com/WavesOS-Repos/archive/refs/heads/main.zip -o Hyprland-configs.zip && sleep 1

if [[ -f "$HOME/Hyprland-configs.zip" ]]; then
    mkdir Hyprland-configs &> /dev/null
    unzip Hyprland-configs.zip 'Hyprland-configs-main/*' -d Hyprland-configs &> /dev/null
    cd Hyprland-configs &> /dev/null
    mv Hyprland-configs-main/* . && rmdir Hyprland-configs-main &> /dev/null
    rm "$HOME/Hyprland-configs.zip"
fi

clear

if [[ -d "$HOME/Hyprland-configs" ]]; then
    printf "${cyan}::${end} Starting the main script..\n" && sleep 1 && clear

    cd "$HOME/Hyprland-configs-main"
    chmod +x start.sh
    ./start.sh
fi
