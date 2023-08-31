#!/bin/bash

# Disable Commercial Repo
sed -i "s/^deb/\#deb/" /etc/apt/sources.list.d/pve-enterprise.list

apt update -y && apt upgrade -y && apt update -y

# Add PVE Community Repo
echo "deb http://download.proxmox.com/debian/pve $(grep "VERSION=" /etc/os-release | sed -n 's/.*(\(.*\)).*/\1/p') pve-no-subscription" > /etc/apt/sources.list.d/pve-no-enterprise.list 

apt update -y

# Remove nag
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/no-nag-script

apt --reinstall install proxmox-widget-toolkit

# Update proxmox pve to newest available version
apt dist-upgrade -y

# Alt update everything (has been warned against, I never had any issue so use at own risk)
apt upgrade -y

# House cleaning
apt clean
apt autoremove --purge

#reboot
echo " Your system will reboot in 10 seconds, ctrl+c to cancel "
i=1

while [ $i -le 9 ]; do
  echo "$i"
  i=$(($i+1))
        sleep 1
done
echo " Here we goooooo! "
reboot

# Install Dark Theme for Proxmox GUI
# bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
