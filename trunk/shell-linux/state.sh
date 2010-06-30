#!/bin/bash
###########################################################
# scriptname : state.sh                                   #
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
# returns the state of the dvd or blueray-drive           #
# 0              Media inserted                           #
# 1              Media not reconized                      #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"

echo
echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------
echo

# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes 

E_BADARGS=1
E_TOOLNOTF=2

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/media-error.log"
MEDIA_TYPE="$HOME/.xbmc/userdata/addon_data/script-video-ripper/media/media.log"
MEDIA_RETURN="$HOME/.xbmc/userdata/addon_data/script-video-ripper/media/state"

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: state.sh p1"
  echo "                            "
  echo "[p1] device"
  echo "                            "
  echo "state.sh was called with wrong arguments" > $OUTPUT_ERROR
  exit $E_BADARGS
fi

REQUIRED_TOOLS=`cat << EOF
dvd+rw-mediainfo
awk
head
lsdvd
makemkvcon
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

echo
echo ---------------
echo Toolchain found
echo ---------------
echo


OUTPUT=$(dvd+rw-mediainfo $1 > $MEDIA_TYPE 2>/dev/null)
RETVAL1=$?
if [ $RETVAL1 -eq 0 ] ; then

   # In booth cases (dvd or blureay) the return valaue is zero

   lsdvd -a $1 > /dev/null 2>&1
   RETVAL2=$?

   if [ $RETVAL2 -eq 0 ] ; then

       # Ok we have a dvd inserted into the drive specified by paramater $1

       cat $MEDIA_TYPE | head -3 | tail -1 | awk '{print $4}' > $MEDIA_RETURN

       echo  
       echo -------------------
       echo DVD found inside $1
       echo -------------------
       echo 

       # If the filesystem of the inserted dvd is incorrect we should not copy the dvd with dd

       exit 0
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

      echo  
      echo -------------------
      echo BLUERAY found inside $1
      echo -------------------
      echo 

      echo 'BLUERAY'  > $MEDIA_RETURN
      exit 0
   fi

   # The ripper script do only support dvd and blueray .....

   exit 1
fi












