#!/bin/bash
###########################################################
# scriptname : setup.sh                                   #
###########################################################
# RELEASE 0.6C swiss-army-knife                           #
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

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"


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

if [ ! -e /home/$1//.xbmc/userdata/addon_data/script-video-ripper ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper/bluray
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper/dvd
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper/log
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper/progress
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper/tmp
   mkdir /home/$1/.xbmc/userdata/addon_data/script-video-ripper/media
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script-video-ripper
fi


# Check to see if the ripp-directorys exists

if [ ! -e /dvdrip ] ; then
   mkdir /dvdrip
   mkdir /dvdrip/iso
   mkdir /dvdrip/dvd
   mkdir /dvdrip/bluray
   chown -R $1:$1 /dvdrip
fi


# Update-Source list

if [ ! -e /etc/apt/sources.list.d/medibuntu.list ] ; then
   sudo wget http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list \
   --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && \
   sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
fi

apt-get install mencoder

# dd

apt-get install netcat original-awk dvdauthor mkisofs


# growisofs

apt-get install dvd+rw-tools lsdvd

# volname

apt-get install submux-dvd subtitleripper transcode mjpegtools libdvdcss2 openssh-server openssh-client

# Transcode to DIVX and H264

apt-get install liba52-0.7.4 libfaac0 libmp3lame0 libmp4v2-0 libogg0 libsamplerate0 libx264-85 libxvidcore4

# Bluray makemv and new Handbrake 0.9.4

apt-get install lynx build-essential libc6-dev libssl-dev libgl1-mesa-dev libqt4-dev libbz2-1.0 libgcc1 libstdc++6 zlib1g


echo 
echo ----------------------------------------------------------------
echo "Important-Note for the next command !"
echo "The command create a ssh-key and will ask for a password. Leave it empty !!!!!!!!"
echo ----------------------------------------------------------------
echo 

sudo -u $1 ssh-keygen -t rsa

RETVAL=$?
if [ $RETVAL -eq 0 ] ; then

   echo  
   echo ---------------------------------------------------------------- 
   echo "Important-Note for the next command !"
   echo "The command will ask for a password.This password is for the user $1"
   echo "and not the current root-password"
   echo "If you don't give the password,the ssh-key that was created can not be transmitted."
   echo ----------------------------------------------------------------
   sudo -u $1 ssh-copy-id -i /home/$1/.ssh/id_rsa.pub $1@localhost
   echo
   echo ----------------------- script rc=0 -----------------------------
   echo -----------------------------------------------------------------
   exit 0
fi

# Ok we have error with the creation of the key


echo
echo ----------------------- script rc=4 -----------------------------
echo -----------------------------------------------------------------
exit $E_SSHKEY





