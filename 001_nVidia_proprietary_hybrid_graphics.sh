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
#Installs and sets up nVidia hybrid graphics
#
#Install nVidia proprietary graphics
sudo pacman -Syy nvidia --needed --noconfirm
#
#Install optimus-manager
yay -Sy optimus-manager optimus-manager-qt
#
#Enable and start the services
sudo systemctl enable optimus-manager
sudo systemctl start optimus-manager
#
#Set optimus to start in hybrid mode
optimus-manager --set-startup hybrid
#
################################################################################################

echo "################################################################"
echo "#                         Completed                            #"
echo "################################################################"
echo "#                 Please reboot your system                    #"
echo "################################################################"