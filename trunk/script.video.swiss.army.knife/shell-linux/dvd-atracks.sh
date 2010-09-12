#!/bin/bash
###########################################################
# scriptname : dvd-atracks.sh                             #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# $2 Track                                                #
# description :                                           #
# Reads all subtitles and audio-languages form a track    #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using somehting other than /bin/bash.
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

# Define the counting commands we expect inside the script

EXPECTED_ARGS=2

# Error-codes

E_BADARGS=1
E_TOOLNOTF=50


OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/dvd-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/DVD_GUI"
ADVD="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/ADVD"
SDVD="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/SDVD"


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-atrack.sh p1 p2"
  echo "                            "
  echo "[p1] device"
  echo "[p2] video-track"
  echo "                            "
  echo "dvd-atrack.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
lsdvd
volname
awk
cut
sed
tr
tail
EOF`


# Check if all commands are found on your system ...

for REQUIRED_TOOL in ${REQUIRED_TOOLS}
do
   which ${REQUIRED_TOOL} >/dev/null 2>&1
   if [ $? -eq 1 ]; then
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate."
        echo "Please install \"${REQUIRED_TOOL}\"."
        echo ----------------------------------------------------------------------------
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate." > $OUTPUT_ERROR
        echo "Please install \"${REQUIRED_TOOL}\"." > $OUTPUT_ERROR
        echo
        echo ----------------------- script rc=2 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi
done

echo
echo INFO audio-tracks from dvd-track [$2]
echo
lsdvd -a -t $2 $1  2>/dev/null | grep "Language" | cut -d' ' -f1-6 | sed  's/,//g' | tr -d '\001'-'\011''\013''\014''\016'-'\037''\200'-'\377'
lsdvd -a -t $2 $1  2>/dev/null | grep "Language" | cut -d' ' -f1-6 | sed  's/,//g' | tr -d '\001'-'\011''\013''\014''\016'-'\037''\200'-'\377' > $ADVD
echo

echo
echo INFO subtitles-tracks from dvd-track [$2]
echo
lsdvd -s -t $2 $1  2>/dev/null | grep "Language" | cut -d' ' -f1-6 | sed  's/,//g' | tr -d '\001'-'\011''\013''\014''\016'-'\037''\200'-'\377'
lsdvd -s -t $2 $1  2>/dev/null | grep "Language" | cut -d' ' -f1-6 | sed  's/,//g' | tr -d '\001'-'\011''\013''\014''\016'-'\037''\200'-'\377' > $SDVD
echo

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0
