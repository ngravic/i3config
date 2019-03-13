#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# some vars
HOME_SUDO=$(eval echo ~$SUDO_USER)

# modify apt sources 

APT_PATH=/etc/apt/sources.list
echo "deb http://ar.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse" > $APT_PATH
echo "deb http://ar.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse" >> $APT_PATH
echo "deb http://ar.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" >> $APT_PATH
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> $APT_PATH
echo "deb http://repository.spotify.com stable non-free" >> $APT_PATH
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >> $APT_PATH

# gpg signs repos
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

# add repos
add-apt-repository ppa:gnome-terminator -n -y
add-apt-repository ppa:jasonpleau/rofi -n -y
add-apt-repository ppa:numix/ppa -n -y
# update apt 

apt update

# install common packages
apt install net-tools ubuntu-drivers-common mesa-utils mesa-utils-extra gnupg numlockx xautolock scrot xorg xserver-xorg xinit wget unzip wpasupplicant software-properties-common vim git apt-transport-https mate-polkit feh galculator thunar thunar-archive-plugin numix-icon-theme-circle -y 

# i3wm, chrome, spotify, vs code
apt install i3 rofi code google-chrome-stable spotify-client terminator -y

# install playerctl
wget http://ftp.nl.debian.org/debian/pool/main/p/playerctl/libplayerctl2_2.0.1-1_amd64.deb -O /tmp/lib.deb
wget http://ftp.nl.debian.org/debian/pool/main/p/playerctl/playerctl_2.0.1-1_amd64.deb -O /tmp/player.deb
dpkg -i /tmp/lib.deb /tmp/player.deb

# start i3 when login 
echo "if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then;startx;fi" > $HOME_SUDO/.bash_profile
chown $SUDO_USER $HOME_SUDO/.bash_profile

# set icon theme 
echo "gtk-icon-theme-name=\"Numix-Circle\"" > $HOME_SUDO/.gtkrc-2.0
echo "gtk-theme-name=\"Breeze-dark-gtk\"" >> $HOME_SUDO/.gtkrc-2.0
chown $SUDO_USER $HOME_SUDO/.gtkrc-2.0

# copy breeze dark theme
cp -r Breeze-dark-gtk /usr/share/themes/Breeze-dark-gtk

# copy icons fonts
cp fontawesome/* /usr/local/share/fonts/

# copy i3 config
mkdir -p $HOME_SUDO/.config/i3/i3status
cp i3/config $HOME_SUDO/.config/i3/
cp i3/i3status/config $HOME_SUDO/.config/i3/i3status/
chown -R $SUDO_USER $HOME_SUDO/.config/i3

# copy rofi theme
mkdir -p $HOME_SUDO/.config/rofi/
cp rofi/* $HOME_SUDO/.config/rofi/
chown -R $SUDO_USER $HOME_SUDO/.config/rofi/

# VS Code custom title bar
mkdir -p $HOME_SUDO/.config/Code/User
echo "{ 'window.titleBarStyle' : 'custom' }" > $HOME_SUDO/.config/Code/User/settings.json
chown -R $SUDO_USER $HOME_SUDO/.config/Code
