#!/bin/bash
###########################################################
# scriptname : deinstall.sh                               #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# none                                                    #
# description :                                           #
# Remove all sofwtare that was installed during setup.sh  #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using something other than /bin/bash.
   echo
   exit 255
fi

clear
echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------




# Error-codes

E_BADARGS=1
E_TOOLNOTF=50
E_NOROOT=3
E_SSHKEY=4
E_LICENCE_NOT_ACCEPTED=5
E_DPKG=6
E_WRONG_SHELL=255




###########################################################
#            Check installed software                     #
###########################################################
REQUIRED_TOOLS=`cat << EOF
echo
apt-get
awk
tar
gunzip
wget
EOF`

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
###########################################################




###########################################################
#            Who is running the script ?                  #
###########################################################
if [ "$UID" -ne 0 ] ; then
   clear
   echo "you must be root to run this script !"
   echo "sudo ./setup.sh"
   echo
   echo ----------------------- script rc=3 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_NOROOT
fi
###########################################################





###########################################################
#            Is licence-file allready local ?             #
###########################################################
if [ ! -e EULA-0.6.15 ] ; then
   clear
   echo
   echo download licence file from google-code
   echo
   wget http://swiss-army-knife.googlecode.com/files/EULA-0.6.15
fi

if [ -e EULA-0.6.15 ] ; then
   clear
   cat EULA-0.6.15
   echo
   echo -n "Do you want to accept this enduser-licnce ? (y)"
   read ans
   if [ $ans == "y" ] ; then
      clear
      echo "EULA 0.6.15 accepted"
      echo
      echo all software-installations from setup.sh will be removed !!!!
      echo all data-containers are not touched or a single file removed !!!
      echo the ssh-keys remaining on the system and have to be deleted by you !!
      echo
      echo -n press any key to continue ..
      echo
      read any
   else
      echo "licence was not accepted !"
      echo
      echo ----------------------- script rc=5 -----------------------------
      echo -----------------------------------------------------------------
      exit $E_LICENCE_NOT_ACCEPTED
   fi
fi
###########################################################


apt-get remove --purge  mencoder
apt-get remove --purge  netcat original-awk dvdauthor mkisofs gddrescue
apt-get remove --purge  dvd+rw-tools lsdvd vobcopy
apt-get remove --purge  submux-dvd subtitleripper transcode mjpegtools libdvdcss2 openssh-server openssh-client
apt-get remove --purge  liba52-0.7.4 libfaac0 libmp3lame0 libmp4v2-0 libogg0 libsamplerate0 libx264-85 libxvidcore4
apt-get remove --purge  libbz2-1.0 libgcc1 libstdc++6 zlib1g
apt-get remove --purge  build-essential lynx libc6-dev libssl-dev libgl1-mesa-dev libqt4-dev

packets1=$(dpkg -l | grep ^ii | grep handbr | awk '{print $2}')
packets2=$(dpkg -l | grep ^ii | grep makemkv | awk '{print $2}')


clear
echo the following packets from setup.sh have ben found.
echo $packets1 $packets2
echo
echo You should remove them with the command dpkg -r
echo You should also remove the directory ~./ssh
echo
echo by by ..


