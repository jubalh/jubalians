#!/bin/env bash
# JUBALIAN DISTRIBUTIONS
# chevette

# by Michael "jubalh" Vetter
#URL

#http://wiki.bash-hackers.org/howto/getopts_tutorial
#abort if one command faild
set -e
#set -x

#------------------
# variables
#------------------
ROOT_UID=0     # Only users with $UID 0 have root privileges.
E_NOTROOT=87   # Non-root exit error.
SOURCES_LIST=/etc/apt/sources.list

#------------------
# functions
#------------------
function say_done() {
	echo "done"
	echo 
}

#------------------
# code
#------------------

#are we root?
if [ "$UID" -ne "$ROOT_UID" ]
then
	echo "No root privileges."
	exit $E_NOTROOT
fi

while getopts ":u:" opt; do
	case $opt in
		u)
			USRNAME=$OPTARG
			eval PTH_HOME="$(printf "~%q" "$USRNAME")"
			eval PTH_SRC_DWM="$(printf "~%q/dwm" "$USRNAME")"
			echo $PTH_SRC_DWM
			;;
		:)
			echo "no username set"
			;;
	esac
done

#add contrib/non-free and so on to sources.list
echo "Going to Manipulate /etc/apt/sources.list"
(
	echo "deb http://ftp.halifax.rwth-aachen.de/debian/ wheezy main contrib non-free"
	echo "deb-src http://ftp.halifax.rwth-aachen.de/debian/ wheezy main contrib non-free"
	echo "deb http://ftp.debian.org/debian/ wheezy-updates main contrib non-free"
	echo "deb-src http://ftp.debian.org/debian/ wheezy-updates main contrib non-free"
	echo "deb http://security.debian.org/ wheezy/updates main contrib non-free"
	echo "deb-src http://security.debian.org/ wheezy/updates main contrib non-free"
	echo "#Third Parties Repos"
	echo "#Debian Mozilla team"
	echo "#deb http://your-mirror.debian.org/debian experimental main" #TODO check url
) > $SOURCES_LIST
say_done

echo "Updating..."
aptitude update
aptitude upgrade && aptitude dist-upgrade
say_done

echo "Installing basic programs..."
aptitude install xorg alsa-base oss-compat sudo vim zsh git tmux hotkey-setup vifm build-essential xfce4-power-manager xfce4-notifyd
say_done

#configure with: xfce4-notifyd-config
#xfce4-power-manager -c
#in autostart "xfce4-power-manager &"
#feh —bg-scale /PATH/TO/WALLPAPER
#alsamixer

#tweakmemaybe
echo "Installing specific programs..."
aptitude install firmware-linux-nonfree laptop-mode-tools
say_done

#STAGE2
setfont /usr/share/consolefonts/Uni3-Terminus20x10.psf.gz

echo "Installing basic GUI programs..."
aptitude install lxappearance feh conky suckless-tools scrot xfce4-volumed xfce4-power-manager vlock powertop rxvt-unicode-256color
say_done
#volumed und power manager starten!

echo "Installing common programs..."
aptitude install vlc iceweasel flashplugin-nonfree-extrasound xul-ext-adblock-plus xul-ext-noscript
say_done

#security
aptitude install clamav clamtk

#powerline
#aptitude install python-pip
#pip install git+git://github.com/Lokaltog/powerline
#TODO: fontpatch (only if i dont change the characters in the config. so waiting for now)
#source powerline in tmux.conf
#vim anyway airline?

echo "Installing dwm dependencies..."
aptitude install libx11-dev libxinerama-dev xfonts-terminus
say_done

if [ -n "$USRNAME" ]
then
echo "Downloading and compiling dwm..."
	cd $PTH_HOME
	sudo -u $USRNAME git clone https://github.com/jubalh/dwm $PTH_SRC_DWM
	cd $PTH_SRC_DWM
	sudo -u $USRNAME make
	make install

	(
		echo "#System dwm:"
		echo "exec dwm"
		echo "#Local dwm:"
		echo "#exec $PTH_SRC_DWM/dwm"
	#TODO: power management etc
	) > "$PTH_HOME/.xinitrc"
	chown $USRNAME "$PTH_HOME/.xinitrc"
	say_done
fi

exit 0
