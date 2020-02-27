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
#Sets up smartcards
#
#Install needed software
sudo pacman -Syy pcsc-tools opensc ccid firefox ark --needed --noconfirm
#
#Enable and start the services
sudo systemctl enable pcscd
sudo systemctl start pcscd
#
################################################################################################

echo "################################################################"
echo "#                         Completed                            #"
echo "################################################################"
echo "#                        										 #"
echo "#                         In firefox							 #"
echo "# 															 #"
echo "# Click the hamburger menu Preferences > Privacy & Security    #"
echo "# Scroll to the bottom and click Security Devices				 #"
echo "# Click Load													 #"
echo "# Enter /usr/lib/pkcs11/opensc-pkcs11.so in the Module filename#"
echo "# Click OK 													 #"
echo "# https://public.cyber.mil/pki-pke/end-users/getting-started/  #"
echo "# Download and Extract the certificates_pkcs**_dod.zip file    #"
echo "# Back to Preferences > Privacy & Security Tab				 #"
echo "# Click View certificates 									 #"
echo "# Click Import 												 #"
echo "# Navigate to the certificates folder that you just extracted  #"
echo "# Install each cert in turn 									 #"
echo "# 															 #"
echo "#          You should now have a working CAC Reader			 #"
echo "################################################################"
