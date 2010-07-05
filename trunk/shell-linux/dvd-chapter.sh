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
cut
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


lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | cut -d: -f1 >  ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvdh
lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | cut -d: -f2 >  ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvdm
lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | cut -d: -f3 >  ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvds
lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $6}' | sed  's/,/ /g' > ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvdc

chapter=$(lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | wc -l)

echo ----------------------
echo found $chapter Titles
echo ---------------------


echo ------------------
echo Generate Tracklist
echo ------------------


index=0
track=0
while read HOUR
do
  index=`expr $index + 1`

  MIN=$(head -$index ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvdm | tail -1)
  SEC=$(head -$index ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvds | tail -1)
  CAP=$(head -$index ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvdc | tail -1)


  if [ $track -lt 10 ] ; then
     echo track:[0$track] length:[$HOUR:$MIN:$SEC] chapters:[$CAP]
  fi
  if [ $track -gt 9 ] ; then
     echo track:[$track] length:[$HOUR:$MIN:$SEC] chapters:[$CAP]
  fi
  track=`expr $track + 1`
done < ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/dvdh





exit 0

