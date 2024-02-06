#!/bin/bash
archsetup() {
	echo "Welcome to archlinux setup!"
	pacman -Sy
	echo "what partitioning tool would you like to use"
	read partool
	echo "Please specify disk."
	read disk
	if [[ $partool = "fdisk" ]]; then
		fdisk $disk
	elif [[ $partool = "cfdisk" ]]; then
		cfdisk $disk
	else
		echo "Not a valid partitioning tool."
		exit 1
	fi
	echo "Please specify mount points"
	echo "/ parition?"
	read $paroot
	echo "Are you using a EFI SYSTEM PARITION? (y/n)"
	read $efi
	if [[ $efi = "y" ]]; then
		echo "Specify EFI Partition"
		read $efimnt
	else
		echo "Ok"
	fi

	if [[ $efi = "y" ]]; then
		mkfs.fat -F 32 $efimnt
	else 
		echo "Skipping efi creation"
	fi
	mkfs.ext4 $paroot
	mount $paroot /mnt
	if [[ $efi = "y" ]]; then
		mount --mkdir $efimnt /mnt/boot
	else
		echo "No efi, skipping efi mount"
	fi

	pacstrap -K /mnt base linux linux-firmware sudo nano vim grub

	genfstab -U /mnt >> /mnt/etc/fstab
	arch-chroot /mnt ./part2.sh


}
echo "Would you like to install arch linux"
read ans

if [[ $ans = "y" ]]; then
	archsetup
else
	echo "nah"
fi
exit 1 
echo "Welcome to my install script for my dotfiles, run at your own risk, no helps or issues will be answered!"
sudo pacman -S $(cat configs/scripts/todeps.txt)
sudo systemctl enable NetworkManager
mkdir ~/.config
mkdir ~/.local/share/dwm
cp autostart/autostart.sh ~/.local/share/dwm
mv configs/alacritty ~/.config/
mv configs/dwm_w_flexipatch ~/.config/
mv configs/scripts ~/
mv bashrc ~/.bashrc
mv bash_profile ~/.bash_profile
#mv configs/dmenu ~/.config
mv config/* -r ~/
cd ~/.config/dwm_w_flexipatch
sudo make clean install
git clone https://git.suckless.org/dmenu ~/.config/dmenu
cd ~/.config/dmenu
sudo make clean install
sudo systemctl enable sddm

echo "All done! reboot and have fun!"
