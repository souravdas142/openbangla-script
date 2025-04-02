#!/bin/env bash

#### OpenBangla Keyboard (Develop Branch) for ibus Installation Script ####
#### ( https://github.com/asifakonjee ) ####

# ibus.sh ( install script with ibus )

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
    echo "No supported package manager found!"
    exit 1
fi


# Print message about installing necessary packages
printf "${attention}\n!! Installing necessary packages using ${pkg} \n"

# Install required packages based on the detected package manager
case "$pkg" in
    pacman)
        sudo pacman -S --noconfirm base-devel rust cmake qt5-base libibus zstd git
        ;;
    dnf)
        sudo dnf install -y @development-tools rust cargo cmake qt5-qtdeclarative-devel ibus-devel libzstd-devel git
        ;;
    zypper)
        sudo zypper install -y libQt5Core-devel libQt5Widgets-devel libQt5Network-devel libzstd-devel libzstd1 cmake make ninja rust ibus-devel ibus clang gcc patterns-devel-base-devel_basis git
        ;;
    xbps-install)
        sudo xbps-install -y base-devel make cmake rust cargo qt5-declarative-devel libzstd-devel qt5-devel git ibus ibus-devel
        ;;
    apt)
        sudo apt-get install -y build-essential rustc cargo cmake libibus-1.0-dev qtbase5-dev qtbase5-dev-tools libzstd-dev git
        ;;
    eopkg)
        sudo eopkg install -c system.devel rust qt5-base-devel ibus-devel zstd-devel git
        ;;
    apk)
        sudo apk add git cmake build-base gcc g++ rust cargo ibus-dev gettext-dev qt5-qtbase-dev qt5-qttools-dev qt5-qtdeclarative-dev 
        ;;
    *)
        printf "${error}\n! Unsupported package manager: $pkg\n"
        exit 1
        ;;
esac

sleep 1 && clear

printf "${action}\n==> Now building ${orange}Openbangla Keyboard${end}...\n"

if [[ -d "$cache_dir/openbangla-keyboard" ]]; then
    printf "${note}\n* Directory '${orange}openbangla-keyboard${end}' was located in the '${cache_dir}' directory. Removing it.\n" && sleep 1
    sudo rm -r "$cache_dir/openbangla-keyboard"
fi

# Clone repository
git clone --recursive https://github.com/OpenBangla/OpenBangla-Keyboard.git "$cache_dir/openbangla-keyboard" 2>&1 | tee -a "$log" || {
    printf "${error} - Could not clone OpenBangla Keyboard repository\n"
    exit 1
}

# Move into the cloned directory
cd "$cache_dir/openbangla-keyboard" || {
    printf "${error}\n! Unable to change directory\n"
    exit 1
}

# Checkout the develop branch
git checkout develop 2>&1 | tee -a "$log" || {
    printf "${error}\n! Unable to checkout develop branch\n"
    exit 1
}

# Update submodules
git submodule update --init --recursive 2>&1 | tee -a "$log" || {
    printf "${error}\n! Unable to update git submodules\n"
    exit 1
}

# Create and enter the build directory
mkdir build && cd build || {
    printf "${error}\n! Unable to create and change to build directory\n"
    exit 1
}

# Run CMake
if [[ "$pkg" == "pacman" ]]; then
    cmake .. -DCMAKE_INSTALL_PREFIX="/usr" -DENABLE_IBUS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 2>&1 | tee -a "$log" || {
        printf "${error}\n! CMake configuration failed\n"
        exit 1
    }
else
    cmake .. -DCMAKE_INSTALL_PREFIX="/usr" -DENABLE_IBUS=ON 2>&1 | tee -a "$log" || {
        printf "${error}\n! CMake configuration failed\n"
        exit 1
    }
fi

# Build the project
make -j$(nproc) 2>&1 | tee -a "$log" || { 
    printf "${error}\n! Build failed\n"
    exit 1
}

# Install the project
sudo make install 2>&1 | tee -a "$log" || {
    printf "${error}\n! Installation failed\n"
    exit 1
}

printf "${done}\n==> Installation completed successfully!\n"

exit 0
