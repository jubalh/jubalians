#! /usr/bin/env bash

#get portage tree
emerge --sync

#localization
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG="de_DE.UTF-8"" >> /etc/env.d/02locale
echo "LANGUAGE=\"de_DE.UTF-8\"" >> /etc/env.d/02locale
locale-get && env-update && source /etc/profile
###search in /etc/conf.d/keymaps after "keymap="en" and replace with de

#edit fstab
nano -w /etc/fstab

#time
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

copy make.conf
eselect list
select

echo "sys-kernel/debian-sources binary" >> /etc/portage/package.use
emerge debian-sources

emerge boot-update
replace /etc/boot.conf default "Funtoo Linux" mit "Funtoo Linux genkernel"
grub-install --no-floppy /dev/sda
boot-update

emerge linux-firmware
#or networkmanager
# + nm-applet. if networkmanager then dont add dhcpcd otherwise it wont manage connections
#launch from xinitrc: dbus-launch nm-applet &
rc-update add dhcpcd default

emerge x11-base/xorg-x11
emerge x11-wm/i3
emerge x11-apps/xrandr
emerge x11-mist/dmenu

/etc/init.d/dbus start
rc-update add dbus default

/etc/init.d/consolekit start
rc-update add consolekit default

##alternative .xinitrc:
##exec ck-launch-session dbus-launch --sh-syntax --exit-with-session i3

emerge x11-misc/lightdm
## lightdm-gtk-greeter
##replace in /etc/conf.d/xdm "DISPLAYMANAGER="" with "lightdm"
rc-update add xdm default
/etc/init.d/xdm start

emerge $(< packages.list)

emerge vim
eselect editor list
##read in
eselect editor set _read_

useradd -m -g users -G audio,video,cdrom,wheel,plugdev _user_
passwd _user_

#change root password
passwd

echo "Finished!"

