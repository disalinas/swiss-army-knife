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




###########################################################
#                                                         #
# We must be root for this script                         #
#                                                         #
###########################################################
if [ "$UID" -ne 0 ] ; then
   clear
   echo "you must be root to run this script !"
   echo "sudo ./setup.sh"
   echo
   echo ----------------------- script rc=3 -----------------------------
   echo -----------------------------------------------------------------
   exit 3
fi
###########################################################



###########################################################
#                                                         #
# We can only run with bash as default shell              #
#                                                         #
###########################################################

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using something other than /bin/bash.
   echo
   exit 255
fi

###########################################################



###########################################################
#                                                         #
# Show disclaimer / copyright note on top of the screen   #
#                                                         #
###########################################################

clear
echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

###########################################################



###########################################################
#                                                         #
# Definition of files and internal variables              #
#                                                         #
###########################################################

ZERO=0
E_BADARGS=0
E_TOOLNOTF=50
E_NOROOT=3
E_DPKG=6
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
echo
dpkg 
apt-get
awk
tar
gunzip
wget
EOF`

###########################################################




###########################################################
#                                                         #
# We must be certain that all software is installed       #
#                                                         #
###########################################################

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
exit $ZERO

