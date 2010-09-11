#!/bin/bash
###########################################################
# scriptname : state.sh                                   #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device to controll                                   #
# description :                                           #
# returns the state of the dvd or bluray-drive            #
# 0              Media inserted                           #
# 1              Media not reconized                      #
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

# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes 

E_BADARGS=1
E_TOOLNOTF=2
E_INACTIVE=3

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/media-error.log"
MEDIA_TYPE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/media.log"
MEDIA_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/state"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI"


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage  : state.sh p1"
  echo "                            "
  echo "[p1] device to check.example /dev/sr0 or /dev/sr1"
  echo "                            "
  echo "state.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi

REQUIRED_TOOLS=`cat << EOF
dvd+rw-mediainfo
awk
head
lsdvd
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


OUTPUT=$(dvd+rw-mediainfo $1 > $MEDIA_TYPE 2>/dev/null)
RETVAL1=$?
if [ $RETVAL1 -eq 0 ] ; then

   # In booth cases (dvd or blureay) the return valaue is zero

   lsdvd -a $1 > /dev/null 2>&1
   RETVAL2=$?

   if [ $RETVAL2 -eq 0 ] ; then

       # Ok we have a dvd inserted into the drive specified by paramater $1

       cat $MEDIA_TYPE | head -3 | tail -1 | awk '{print $4}' > $MEDIA_RETURN

       # If the filesystem of the inserted dvd is incorrect we should not copy the dvd with dd

       echo
       echo "INFO [media:[DVD-ROM]]"
       echo

       echo ----------------------- script rc=0 -----------------------------
       echo -----------------------------------------------------------------

       exit 0
   fi

   # In the case the bluray function are not enabled we do exit the script now
   # if the script is not allready finished over the above dvd-part
 
   if [ -e  $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/BLURAY_DISABLED ] ; then 
       echo
       echo bluray-functions are disabled 
       echo
       exit $E_INACTIVE 
   fi 


   # If the command makemkvcon is not installed during the execution of 
   # setup.sh and the bluray function is enabled we stop now .....

   which makemkvcon >/dev/null 2>&1
   if [ $? -eq 1 ]; then
        echo "ERROR! \" makemkvcon is missing. ${0} requires it to operate."
        echo "Please install \"makemkvcon\"."
        echo
        echo Please run setup.sh again to install makemkv 
        echo 
        echo ----------------------- script rc=2 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi

   if [ $1 == '/dev/sr0' ] ; then
      PARA="disc:0"
   fi

   if [ $1 == '/dev/sr1' ] ; then
      PARA="disc:1"
   fi

   if [ $1 == '/dev/sr2' ] ; then
      PARA="disc:2"
   fi

   makemkvcon info -r $PARA | head -2 > /dev/null 2>&1
   RETVAL3=$?

   if [ $RETVAL3 -eq 0 ] ; then

      echo 'BLURAY'  > $MEDIA_RETURN

      # No we prepare the GUI-List for execution ...
      # We allready have all values ...

      echo
      echo "INFO [media:[BLURAY]]"
      echo

      echo ----------------------- script rc=0 -----------------------------
      echo -----------------------------------------------------------------

      exit 0
   fi

   # The ripper script do only support dvd and bluray .....

   echo
   echo "INFO [media:[!unknown!]]"
   echo


   echo ----------------------- script rc=1 -----------------------------
   echo -----------------------------------------------------------------

   exit 1
fi

