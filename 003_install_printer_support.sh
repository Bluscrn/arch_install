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
#Installs Printer Support 
#
#Install cups
sudo pacman -Syy cups cups-filters cups-pdf ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds system-config-printer print-manager --noconfirm --needed
#
#Enable and start the cups services
systemctl start org.cups.cupsd.socket
systemctl enable org.cups.cupsd.socket
#
#Enable and start avahi
systemctl start avahi-daemon
systemctl enable avahi-daemon

###############################################################################################

echo "################################################################"
echo "#                       yay installed                          #"
echo "################################################################"