#!/bin/bash

MODULES=("tuxedo-keyboard")

# warning
printf "This script will upgrade your kernel on a Gentoo Linux system.\n"

## user selects kernel
eselect kernel list
printf "Please select the kernel you want to use [full version or number]: "
read kernelsel
printf "Selecting kernel \"%s\"…\n\n" "${kernelsel}"
eselect kernel set "${kernelsel}"

# getting old kernel config
printf "Restoring from old configuration …\n"
cd "/usr/src/linux"
make oldconfig

# kernel compiling
printf "Compiling kernel …\n"
make
printf "Installing modules …\ņ"
make modules_install
printf "Installing kernel …\n"
make install
# modules
printf "Compiling modules via portage …\n"
emerge -v ${MODULES[@]}
printf "Updating Grub configuration to use newest kernel …\n"
grub-mkconfig -o "/boot/grub/grub.cfg"

# removing old kernel versions
printf "using eclean-kernel to remove all kernel versions except latest 2 …\n"
eclean-kernel -n 2

# rebooting
printf "\nDo you want to reboot now to apply all changes? [y/n]: "
read reboot
if [[ "${reboot}" = "y" ]]
then
    printf "Rebooting now …\n"
    reboot
else
    printf "Not rebooting! Please reboot as soon as possible.\n"
fi
