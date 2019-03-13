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

# firmas repositorios 
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

# update apt 

apt update

# install packages
apt install ubuntu-drivers-common mesa-utils mesa-utils-extra gnupg numlockx xautolock scrot xorg xserver-xorg xinit wget unzip wpasupplicant gnome-terminal software-properties-common vim git apt-transport-https mate-polkit feh galculator -y 

apt install i3 code google-chrome-stable spotify-client -y

# install rofi
add-apt-repository ppa:jasonpleau/rofi
apt install rofi -y

# start i3 when login 
echo "if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then;startx;fi" > $PWD/.bash_profile

# copy i3 config
mkdir -p $HOME_SUDO/.config/i3/i3status
cp i3/config $HOME_SUDO/.config/i3/
cp i3/i3status/config $HOME_SUDO/.config/i3/i3status/
chown -R $SUDO_USER $HOME_SUDO/.config/i3

# copy rofi theme
mkdir -p $HOME_SUDO/.config/rofi/
cp rofi/* $HOME_SUDO/.config/rofi/
chown -R $SUDO_USER $HOME_SUDO/.config/rofi/


