#!/bin/bash
echo "Welcome to part two of archinstallation!"

echo "Specify timezone (Region/City)"
read timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
echo "Please configure host file, choose editor"
read editor
if [[ $editor = "vim" ]]; then
	vim /etc/hostname
elif [[ $editor = "nano" ]]; then
	nano /etc/hostname
else 
	echo "Not a valid editor"


fi
echo "are you on efi system (y/n)"
read efi
if [[ $efi = "y" ]]; then
	pacman -S efibootmgr
else
	echo "Ok"
fi
echo "Enter home username"
read homeuser
useradd -m $homeuser
usermod -aG wheel,audio,video $homeuser -s /bin/bash
echo "Please password user"
passwd $homeuser
echo "Please password root"
passwd
echo "Shall we install dhcpcd?"
read dhcpcd
if [[ $dhcpcd = "y" ]]; then
	pacman -S dhcpcd
	systemctl enable dhcpcd
else
	echo "Skipping"
fi
if [[ $efi = "y" ]]; then
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg
else
	echo "Enter the disk where grub will be installed, not a parition, generally the where root fs is located"
	read disk
	grub-install --target=i386-pc $disk
	grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Done! stay here to make other changes or you can reboot"
exit 0 

