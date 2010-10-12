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




###########################################################
#                                                         #
# Check that not user root is running this script         #
#                                                         #
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
   echo ----------------------- script rc=255 ---------------------------
   echo -----------------------------------------------------------------
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/bluray-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI"
OUTPUT="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/bluray-chapter"

EXPECTED_ARGS=0
E_BADARGS=1
E_INVALID_LICENCE=2
E_TOOLNOTF=50
E_SUID0=254
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
tail
makemkvcon
EOF`

###########################################################




###########################################################
#                                                         #
# Check startup-parameters and show usage if needed       #
#                                                         #
###########################################################

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: bluray-chapter.sh"
  echo 
  echo "bluray-chapter.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi

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
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate." > $OUTPUT_ERROR
        echo "Please install \"${REQUIRED_TOOL}\"." > $OUTPUT_ERROR
        echo
        echo ----------------------- script rc=2 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi
done

###########################################################









###########################################################
#                                                         #
# Check makekmkv licence key over commandline             #
#                                                         #
###########################################################

rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv* > /dev/null 2>&1

STATE=$(makemkvcon info | tail -1)

INVALID=$(echo $STATE | grep -c "^This application")

if [ $INVALID == "1" ] ; then
   echo
   echo makemkvcon is using a expired licence-key
   echo 1 > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv.invalid
   echo
   echo ----------------------- script rc=2 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_INVALID_LICENCE
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

###########################################################

