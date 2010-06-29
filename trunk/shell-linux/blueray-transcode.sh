#!/bin/bash
###########################################################
# scriptname : blueray-transcode.sh                       #
###########################################################
# RELEASE 0.6C swiss-army-knife                           #
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# $2 rip-directory                                        #
# $3 name of mkv (excluding extension mkv)                #
# $4 Track to extract (Tracks starting at index 0)        #
# description :                                           #
# Convert blueray track to mkv container                  #
###########################################################


SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"

echo
echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------
echo


# Define the counting commands we expect inside the script

EXPECTED_ARGS=4

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/bluray-error.log"


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: blueray-transcode.sh p1 p2 p3 p4"
  echo "                            "
  echo "[p1] device"
  echo "[p2] rip-directory"
  echo "[p3] name of mkv (excluding mkv)"
  echo "[p4] Track to extract 0-X"
  echo "                            "
  echo "blueray-transcode.sh was called with wrong arguments" > $OUTPUT_ERROR
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
nohup
sed
makemkvcon
EOF`


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


if [ $1 == '/dev/sr0' ] ; then
   PARA="disc:0"
fi

if [ $1 == '/dev/sr1' ] ; then
   PARA="disc:1"
fi

if [ $1 == '/dev/sr2' ] ; then
   PARA="disc:2"
fi


echo ---------------------------------
echo parameter for transcoder : $PARA
echo ---------------------------------


if [ -e blueray.progress ] ; then
   rm blueray.progress > /dev/null 2>&1 
fi


echo -----------------------------------
echo starting makemkvcon in stream-mode
echo -----------------------------------

nohup makemkvcon --messages=/dev/null --progress=blueray.progress mkv $PARA $4 $2 > /dev/null 2>&1  &

sleep 40

while [ 1=1 ];
do
   progress=$(cat blueray.progress | tail -1 | awk '{print $4}'| sed "s/[^0-9]//g")
   echo progress transcoding mkv $progress%
   echo $progress > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
   sleep 2
   if [ $progress -eq "100"  ] ; then
       echo ----------------------------
       echo finished transcode track $4
       echo ----------------------------
       rm blueray.progress > /dev/null 2>&1
       break
   fi
done

if [ $4 -lt '10' ] ; then
   echo ------------------------
   echo rename file title0$4.mkv
   echo ------------------------
   mv $2/title0$4.mkv $2/$3.mkv
fi

if [ $4 -gt '10' ] ; then
   echo ------------------------
   echo rename file  title$4.mkv
   echo ------------------------
   mv $2/title$4.mkv $2/$3.mkv
fi




