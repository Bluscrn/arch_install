#!/bin/bash
set -e
##################################################################################################################
# Author 	: Bluscrn
# Website	: https://github.com/Bluscrn/
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
#
#Installs yay the AUR helper 
#
#Install git
sudo pacman -Syy git --needed --noconfirm
#
#Create a folder for loose AUR files and clone the yay.git repository into it
mkdir -p ~/Downloads/aur && cd ~/Downloads/aur
git clone https://aur.archlinux.org/yay.git
cd yay
#
#Compile the pkg
makepkg -sric


###############################################################################################

echo "################################################################"
echo "#                         Completed                            #"
echo "################################################################"
