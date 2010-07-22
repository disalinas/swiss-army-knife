#!/bin/bash
###########################################################
# scriptname : setup.sh                                   #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 user                                                 #
# description :                                           #
# Setup all files and directorys for the addon            #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife"

echo
echo --------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script  :" $SCRIPT
cat version
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo --------------------------------------------------------------------


# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2
E_NOROOT=3
E_SSHKEY=4

if [ $# -ne $EXPECTED_ARGS ] ; then
  echo "Usage: setup.sh p1"
  echo "                                      "
  echo " [p1] usernmae                          "
  echo
  echo "setup.sh was called without arguments"
  echo "                                     "
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
echo
apt-get
wget
EOF`

# Check if all commands are found on your system ...

for REQUIRED_TOOL in ${REQUIRED_TOOLS}
do
   which ${REQUIRED_TOOL} >/dev/null 2>&1
   if [ $? -eq 1 ]; then
      echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate."
      echo "Please install \"${REQUIRED_TOOL}\"."
      echo ----------------------------------------------------------------------------
      echo
      echo ----------------------- script rc=2 -----------------------------
      echo -----------------------------------------------------------------
      exit $E_TOOLNOTF
   fi
done


# Who is running this script ?

if [ "$UID" -ne 0 ] ; then
   echo "you must be root to run this script !"
   echo "sudo ./setup.sh"
   echo
   echo ----------------------- script rc=3 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_NOROOT
fi


# Check to see if all data-directory exists ...

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media
fi


# Check to see if the ripp-directorys exists

if [ ! -e /dvdrip ] ; then
   mkdir /dvdrip
   chown -R $1:$1 /dvdrip
fi

if [ ! -e /dvdrip/iso ] ; then
   mkdir /dvdrip/iso
   chown -R $1:$1 /dvdrip/iso
fi


if [ ! -e /dvdrip/bluray ] ; then
   mkdir /dvdrip/bluray
   chown -R $1:$1 /dvdrip/bluray
fi

# Update-Source list

if [ ! -e /etc/apt/sources.list.d/medibuntu.list ] ; then
   sudo wget http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list \
   --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && \
   sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
fi

apt-get install mencoder
apt-get install netcat original-awk dvdauthor mkisofs gddrescue
apt-get install dvd+rw-tools lsdvd
apt-get install submux-dvd subtitleripper transcode mjpegtools libdvdcss2 openssh-server openssh-client
apt-get install liba52-0.7.4 libfaac0 libmp3lame0 libmp4v2-0 libogg0 libsamplerate0 libx264-85 libxvidcore4
apt-get install libbz2-1.0 libgcc1 libstdc++6 zlib1g

# This sections is only needet in the case bluray-functions are used.

clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used blurays with the addon you can answer no
echo
echo -n "Do you want to use bluray-discs inside the addon (y/n)"
read ans
if [ $ans == "y" ] ; then
   echo
   echo install software for bluray-functions
   echo
   apt-get install build-essential lynx libc6-dev libssl-dev libgl1-mesa-dev libqt4-dev
   BL=1
   echo
   echo -n press any key to continue ..
   read any
fi

if [ $ans == "n" ] ; then
   clear
   echo
   echo -----------------------------------------------------------
   echo software for bluray-functions is not installed.
   echo If you later decide to use them then run setup.sh
   echo again.
   echo
   echo -n press any key to continue ..
   read any
   BL=0
fi


clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used ssh with the addon you can answer no
echo
echo -n "Do you want to configure ssh for the addon (y/n)"
read ans
if [ $ans == "y" ] ; then
   clear
   echo
   echo ----------------------------------------------------------------
   echo "Important-Note for the next command !"
   echo "The command do create a ssh-key and will ask for a password. Leave it empty !!!!!!!!"
   echo ----------------------------------------------------------------
   echo

   sudo -u $1 ssh-keygen -t rsa

   RETVAL=$?
   if [ $RETVAL -eq 0 ] ; then
      clear
      echo
      echo ----------------------------------------------------------------
      echo "Important-Note for the next command !"
      echo "The command will ask for a password.This password is for the user $1"
      echo "and not the current root-password"
      echo "If you don't give the password,the ssh-key that was created can not be transmitted."
      echo ----------------------------------------------------------------
      sudo -u $1 ssh-copy-id -i /home/$1/.ssh/id_rsa.pub $1@localhost
      echo
      echo -n press any key to continue ..
      read any
   fi
fi

if [ $ans == "n" ] ; then
   clear
   echo
   echo -----------------------------------------------------------
   echo the ssh-subsystem is not configured.
   echo
   echo -n press any key to continue ..
   read any
fi


clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used handbrake or makemkv with the addon you can
echo answer no
echo
echo -n "Do you want to install handbrake and the optional makemkv (y/n)"
read ans
if [ $ans == "y" ] ; then
   architecture=`uname -m`
   if [ "$architecture" != "x86_64" ] && [ "$architecture" != "ia64" ]; then
      echo
      echo download software for 32 bit
      echo
      cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
      wget http://swiss-army-knife.googlecode.com/files/swiss-army-knife-deb-32.zip
      unzip swiss-army-knife-deb-32.zip
      echo
      echo install software handbrake
      echo
      dpkg -i handbrake-cli_lucid1_i386.deb
      if [ $BL == "1" ] ; then
          echo
          echo install software makemkv
          echo
          dpkg -i makemkv-v1.5.6-beta-bin_20100613-1_i386.deb
          dpkg -i makemkv-v1.5.6-beta-oss_20100613-1_i386.deb
      fi
      rm swiss-army-knife-deb-32.zip
      echo
      echo -n press any key to continue ..
      read any
   else
      echo
      echo download software for 64 bit
      echo
      cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
      wget http://swiss-army-knife.googlecode.com/files/swiss-army-knife-deb-64.zip
      unzip swiss-army-knife-deb-64.zip
      echo
      echo install software handbrake
      echo
      dpkg -i handbrake-cli_lucid1_amd64.deb
      if [ $BL == "1" ] ; then
         echo
         echo install software makemkv
         echo
         dpkg -i makemkv-v1.5.6-beta-bin_20100629-1_amd64.deb
         dpkg -i makemkv-v1.5.6-beta-oss_20100629-1_amd64.deb
      fi
      rm swiss-army-knife-deb-64.zip
      echo
      echo -n press any key to continue ..
      read any
   fi
fi

if [ $ans == "n" ] ; then
   clear
   echo
   echo -----------------------------------------------------------
   echo handbrake and makekmkv is not installed.
   echo
   echo -n press any key to continue ..
   read any
fi

clear
echo
echo -----------------------------------------------------------
echo create setup.donw inside addon-data directory
echo
echo "0.6.11" > /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/setup.done
chown user:user /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/setup.done
echo
echo -n press any key to continue ..
read any

clear
echo
echo addon can now be running over xbmc  ......
echo
echo have fun with this addon and I wish you happy ripping
echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------
echo
echo
