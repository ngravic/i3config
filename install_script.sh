#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# some vars
SUDO_HOME=$(eval echo ~$SUDO_USER)
DISTRO=bionic   #v18
#DISTRO=xenial  #v16
APT_REPOS=("ppa:gnome-terminator" "ppa:jasonpleau/rofi" "ppa:numix/ppa")
APT_PATH=/etc/apt/sources.list

# modify apt sources 
echo "deb http://ar.archive.ubuntu.com/ubuntu/ $DISTRO main restricted universe multiverse" > $APT_PATH
echo "deb http://ar.archive.ubuntu.com/ubuntu/ $DISTRO-updates main restricted universe multiverse" >> $APT_PATH
echo "deb http://ar.archive.ubuntu.com/ubuntu/ $DISTRO-backports main restricted universe multiverse" >> $APT_PATH
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> $APT_PATH
echo "deb http://repository.spotify.com stable non-free" >> $APT_PATH
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >> $APT_PATH


apt install software-properties-common gnupg -y   # needed for add-apt-repository and add apt-key
# gpg signs repos
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90

# add repos
for rep in "${APT_REPOS[@]}"; do
  add-apt-repository $rep -n -y
done

# update apt 
apt update

# install common packages
apt install net-tools ubuntu-drivers-common mesa-utils mesa-utils-extra gnupg \
  numlockx xautolock scrot xorg xserver-xorg xinit wget unzip wpasupplicant \
  vim git apt-transport-https mate-polkit feh galculator thunar \
  thunar-archive-plugin numix-icon-theme-circle i3 rofi code \
  google-chrome-stable spotify-client terminator \
  -y 

# install playerctl
wget http://ftp.nl.debian.org/debian/pool/main/p/playerctl/libplayerctl2_2.0.1-1_amd64.deb -O /tmp/lib.deb
wget http://ftp.nl.debian.org/debian/pool/main/p/playerctl/playerctl_2.0.1-1_amd64.deb -O /tmp/player.deb
dpkg -i /tmp/lib.deb /tmp/player.deb

# start i3 when login 
echo "if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then startx; fi" > $SUDO_HOME/.bash_profile
chown $SUDO_USER $SUDO_HOME/.bash_profile

# set icon theme 
echo "gtk-icon-theme-name=\"Numix-Circle\"" > $SUDO_HOME/.gtkrc-2.0
echo "gtk-theme-name=\"Breeze-dark-gtk\"" >> $SUDO_HOME/.gtkrc-2.0
chown $SUDO_USER $SUDO_HOME/.gtkrc-2.0

# copy breeze dark theme
mkdir -p /usr/share/themes/
cp -r Breeze-dark-gtk /usr/share/themes/Breeze-dark-gtk

# copy icons fonts
mkdir -p /usr/local/share/fonts
cp fontawesome/* /usr/local/share/fonts/

# copy i3 config
mkdir -p $SUDO_HOME/.config/i3/i3status
cp i3/config $SUDO_HOME/.config/i3/
cp i3/i3status/config $SUDO_HOME/.config/i3/i3status/
chown -R $SUDO_USER $SUDO_HOME/.config/i3

# copy rofi theme
mkdir -p $SUDO_HOME/.config/rofi/
cp rofi/* $SUDO_HOME/.config/rofi/
chown -R $SUDO_USER $SUDO_HOME/.config/rofi/

# VS Code custom title bar
mkdir -p $SUDO_HOME/.config/Code/User
echo "{ \"window.titleBarStyle\" : \"custom\" }" > $SUDO_HOME/.config/Code/User/settings.json
chown -R $SUDO_USER $SUDO_HOME/.config/Code


# ask restart
read -p "Want to restart the machine? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  shutdown -r now
fi