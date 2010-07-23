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
# test if makekmkv is using a old licence-key             #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------


#STATE="This application version is too old"
STATE=$(makemkvcon info | tail -1)

INVALID=$(echo $STATE | grep -c "^This application")

if [ $INVALID == "1" ] ; then
   echo
   echo makekmkvcon is using a expired licence-key
fi

if [ $INVALID == "0" ] ; then
   echo
   echo makekmkvcon is using a valid licence-key
fi

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0
