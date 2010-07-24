#!/bin/bash
###########################################################
# scriptname : dvd-iso.sh                                 #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# $2 directory for rip                                    #
# $3 iso-name (excluding extension iso)                   #
#                                                         #
# description :                                           #
# generates a iso file of a dvd                           #
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/iso-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/dvd-dd.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=3

# Error-codes

E_BADARGS=1
E_BADB=2

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-iso.sh p1 p2 p3"
  echo
  echo "[p1] device or complet path to ripfile"
  echo "[p2] directory for rip"
  echo "[p3] Name of iso (excluding iso)"
  echo
  echo "dvd-iso.sh was called with wrong arguments"
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi



# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
isoinfo
dd
awk
nohup
EOF`


# Check if all commands are found on your system ...

for REQUIRED_TOOL in ${REQUIRED_TOOLS}
do
   which ${REQUIRED_TOOL} >/dev/null 2>&1
   if [ $? -eq 1 ]; then
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate."
        echo "Please install \"${REQUIRED_TOOL}\"."
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate." > $OUTPUT_ERROR
        echo "Please install \"${REQUIRED_TOOL}\"." > $OUTPUT_ERROR
        echo
        echo ----------------------- script rc=2 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi
done

if [ -e $2/$3.iso ] ; then
   rm $2/$3.iso > /dev/null 2>&1
fi


# For the GUI-progress-bar we need the exact size in bytes for the saved iso-file


# Get Blocksize

blocksize=`isoinfo -d -i $1  | grep "^Logical block size is:" | cut -d " " -f 5`
if test "$blocksize" = ""; then
   echo catdevice FATAL ERROR: Blank blocksize > $OUTPUT_ERROR
   exit $E_BADB
fi


# Get Blockcount

blockcount=`isoinfo -d -i $1 | grep "^Volume size is:" | cut -d " " -f 4`
if test "$blockcount" = ""; then
   echo catdevice FATAL ERROR: Blank blockcount > $OUTPUT_ERROR
   exit $E_BADB
fi


SIZE1=$(($blocksize * $blockcount))
echo
echo INFO expected iso-size in bytes [$(($blocksize * $blockcount))]

# break css by force ;-)

lsdvd -a $1 1>/dev/null 2>&1

echo INFO starting dd

(
dd bs=2048 if=$1 of=$2/$3.iso &
) > $OUT_TRANS 2>&1 &

sleep 3

echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32154 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
echo -n $2/$3.iso > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
ps axu | grep "dd bs=2048" | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid

echo INFO processing data
echo

T1=$(bc -l <<< "scale=0; ($SIZE1 / 100)")

LOOP=1
while [ $LOOP -eq '1'  ];
do
  echo -n .
  SIZE2=$(ls -la $2/$3.iso | awk '{print $5}')
  PROGRESS=$(bc -l <<< "scale=0; ($SIZE2 / $T1)")
  echo $PROGRESS > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
  if [ $SIZE1 == $SIZE2 ] ; then
     echo
     echo
     echo INFO processing data done
     echo
     LOOP=0
  fi
  sleep 4
done

# Delete jobfile

rm $JOBFILE > /dev/null 2>&1

sleep 1
rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/* > /dev/null 2>&1

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

