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

if [ "$UID" == 0 ] ; then
   clear
   echo This script should not be executed as user root !
   echo You have to remove this lines to run this script as user 
   echo root, what is by the way not recommanded !!
   echo
   echo ----------------------- script rc=254 ---------------------------
   echo -----------------------------------------------------------------
   exit 254
fi

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using something other than /bin/bash.
   echo
   echo ----------------------- script rc=255 ---------------------------
   echo -----------------------------------------------------------------
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
