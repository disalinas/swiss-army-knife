#!/bin/bash
###########################################################
# scriptname : check_mkv.sh                               #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 user                                                 #
# description :                                           #
# test if makemkv is using a old licence-key              #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

if [ $SHELL -ne "/bin/bash" ] ; then
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using somehting other than /bin/bash.
   echo
   exit 255
fi

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv* > /dev/null 2>&1

STATE=$(makemkvcon info | tail -1)

INVALID=$(echo $STATE | grep -c "^This application")

if [ $INVALID == "1" ] ; then
   echo
   echo makemkvcon is using a expired licence-key
   echo 1 > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv.invalid
fi

if [ $INVALID == "0" ] ; then
   echo
   echo makemkvcon is using a valid licence-key
   echo 1 > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv.valid
fi

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0
