#!/bin/bash
###########################################################
# scriptname : dvd-chapter.sh                             #
###########################################################
# RELEASE 0.6C swiss-army-knife                           #
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# description :                                           #
# Reads all chapters from inserted dvd                    #
# - contray to the bluray-funtion there 2 lists           #
# - 1. List contains all video-tracks                     #
# - 2. List contains all audio-tracks                     #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"


echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------

# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2
E_NOCHAPERS=3
E_VOLUMEERROR=4

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/dvd-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script-video-ripper/media/DVD_GUI"

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-chapter.sh p1"
  echo "                            "
  echo "[p1] device"
  echo "                            "
  echo "dvd-chapter.sh was called with wrong arguments" > $OUTPUT_ERROR
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
lsdvd
volname
awk
nohup
tr
tail
EOF`


# Check if all commands are found on your system ...

for REQUIRED_TOOL in ${REQUIRED_TOOLS}
do
   which ${REQUIRED_TOOL} >/dev/null 2>&1
   if [ $? -eq 1 ]; then
        echo ----------------------------------------------------------------------------
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate."
        echo "Please install \"${REQUIRED_TOOL}\"."
        echo ----------------------------------------------------------------------------
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate." > $OUTPUT_ERROR
        echo "Please install \"${REQUIRED_TOOL}\"." > $OUTPUT_ERROR
        exit $E_TOOLNOTF
   fi
done

echo ----------------
echo Clean temp files
echo ----------------

rm $HOME/.xbmc/userdata/addon_data/script-video-ripper/dvd/* >/dev/null 2>&1


echo ---------------
echo Toolchain found
echo ---------------


echo -----------------------------------------
echo get dvd volume-name
echo -----------------------------------------

VOLNAME=$(volname $1 | tr -dc ‘[:alnum:]‘)


echo -----------------------------------------
echo Volume-Name of dvd:[$VOLNAME]
echo $VOLNAME > ~/.xbmc/userdata/addon_data/script-video-ripper/dvd/DVD_VOLUME
echo -----------------------------------------




VTRACKS=$(lsdvd -v $1 2>/dev/null | grep ^Title)
ATRACKS=$(lsdvd -a $1 2>/dev/null | grep Audio:)





exit 0


