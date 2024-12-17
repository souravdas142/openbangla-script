#!/bin/env bash

#### OpenBangla Keyboard (Develop Branch) for fcitx5 Installation Script ####
#### ( https://github.com/asifakonjee ) ####

# fcitx5.sh ( install script with fcitx5 )

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\x1b[38;5;214m"
end="\e[1;0m"

# initial texts
attention="[${orange} ATTENTION ${end}]"
action="[${green} ACTION ${end}]"
note="[${magenta} NOTE ${end}]"
done="[${cyan} DONE ${end}]"
ask="[${orange} QUESTION ${end}]"
error="[${red} ERROR ${end}]"

display_text() {
    cat << "EOF"
  ____                   ___                    __     
 / __ \ ___  ___  ___   / _ ) ___ _ ___  ___ _ / /___ _
/ /_/ // _ \/ -_)/ _ \ / _  |/ _ `// _ \/ _ `// // _ `/
\____// .__/\__//_//_//____/ \_,_//_//_/\_, //_/ \_,_/ 
     /_/                               /___/           
   __ __            __                      __         
  / //_/___  __ __ / /  ___  ___ _ ____ ___/ /         
 / ,<  / -_)/ // // _ \/ _ \/ _ `// __// _  /          
/_/|_| \__/ \_, //_.__/\___/\_,_//_/   \_,_/           
           /___/                                       

EOF
}

clear && display_text
printf " \n \n"


###------ Startup ------###

# finding the presend directory and log file
present_dir="$(dirname "$(realpath "$0")")"
cache_dir="$present_dir/.cache"

# log directory
log="$present_dir/Install.log"
if [[ ! -f "$log" ]]; then
    touch "$log"
fi


# Detect package manager
if command -v pacman &> /dev/null; then
    pkg="pacman"
elif command -v dnf &> /dev/null; then
    pkg="dnf"
elif command -v zypper &> /dev/null; then
    pkg="zypper"
elif command -v xbps-install &> /dev/null; then
    pkg="xbps-install"
elif command -v apt &> /dev/null; then
    pkg="apt"
elif command -v eopkg &> /dev/null; then
    pkg="eopkg"
elif command -v apk &> /dev/null; then
    pkg="apk"
else
    printf "${error}\n! No supported package manager found!\n"
    exit 1
fi


# Print message about installing necessary packages
printf "${attention}\n!! Installing necessary packages using ${pkg} \n"

# Install required packages based on the detected package manager
case "$pkg" in
    pacman)
        sudo pacman -S --noconfirm base-devel rust cmake qt5-base libibus zstd fcitx5 fcitx5-configtool fcitx5-qt fcitx5-gtk git
        ;;
    dnf)
        sudo dnf install -y @development-tools rust cargo cmake qt5-qtdeclarative-devel ibus-devel libzstd-devel git fcitx5 fcitx5-configtool fcitx5-devel fcitx5-qt5
        ;;
    zypper)
        sudo zypper in -y libQt5Core-devel libQt5Widgets-devel libQt5Network-devel libzstd-devel libzstd1 cmake make ninja rust ibus-devel ibus clang gcc patterns-devel-base-devel_basis git fcitx5-devel fcitx5 fcitx5-configtool
        ;;
    xbps-install)
        sudo xbps-install -y base-devel make cmake rust cargo qt5-declarative-devel libzstd-devel qt5-devel git ibus ibus-devel fcitx5 libfcitx5-devel fcitx5-configtool
        ;;
    apt)
        sudo apt install -y build-essential rustc cargo cmake libibus-1.0-dev qtbase5-dev qtbase5-dev-tools libzstd-dev libfcitx5core-dev fcitx5 fcitx5-config-qt git
        ;;
    *)
        printf "${error}\n! Unsupported package manager: $pkg\n"
        exit 1
        ;;
esac

printf "${action}\n==> Now building ${orange}Openbangla Keyboard${end}...\n"

if [[ -d "$cache_dir/openbangla-keyboard" ]]; then
    printf "${note}\n* Directory '${orange}openbangla-keyboard${end}' was located in the '${cache_dir}' directory. Removing it.\n" && sleep 1
    sudo rm -r "$cache_dir/openbangla-keyboard"
fi

git clone --recursive https://github.com/OpenBangla/OpenBangla-Keyboard.git "$cache_dir/openbangla-keyboard" 2>&1 | tee -a "$log" || { printf "${error} - Sorry, could not clone openbangla-keyboard repository\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Move into the cloned directory
cd "$cache_dir/openbangla-keyboard" || { printf "${error}\n! Unable to change directory\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Create build directory
git checkout develop 2>&1 | tee -a "$log" || { printf "${error}\n! Unable to checkout develop branch\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Create build directory
git submodule update 2>&1 | tee -a "$log" || { printf "${error}\n! Unable to update git submodule\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Create build directory
mkdir build 2>&1 | tee -a "$log" || { printf "${error}\n! Unable to create build directory\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

cd build || { printf "${error}\n! Unable to change directory\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Run CMake to configure the build
cmake .. -DCMAKE_INSTALL_PREFIX="/usr" -DENABLE_FCITX=ON 2>&1 | tee -a "$log" || { printf "${error}\n! CMake configuration failed\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Build the project
make 2>&1 | tee -a "$log" || { printf "${error}\n! Build failed\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

# Install the project
sudo make install 2>&1 | tee -a "$log" || { printf "${error}\n! Installation failed\n" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log"); exit 1; }

exit 0
