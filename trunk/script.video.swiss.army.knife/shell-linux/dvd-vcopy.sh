#!/bin/bash
###########################################################
# scriptname : dvd-vcopy.sh                               #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 directory for rip                                    #
# $2 dvd-device                                           #
#                                                         #
# description :                                           #
# generates a copy of all vob files from a dvd            #
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/vobcopy-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/vobcopy.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=2

# Error-codes

E_BADARGS=1
E_BADB=2

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-vcopy.sh p1 p2"
  echo
  echo "[p1] directory for rip"
  echo "[p2] dvd-device"
  echo
  echo "dvd-vcopy.sh was called with wrong arguments"
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi



# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
isoinfo
mount
vobcopy
tr
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

VOLNAME=$(volname $2 | tr -dc ‘[:alnum:]‘)

echo
echo INFO volume-name[$VOLNAME]
echo
echo INFO starting vobcopy
echo
echo

(
vobcopy -v -m -o $1 -t $VOLNAME 2>/dev/null
) > $OUT_TRANS 2>&1 &


LOOP=1
while [ $LOOP -eq '1'  ];
do
  # /dvdrip/vobcopy/DUNE_KINOFASSUNG/VIDEO_TS$ du -c -h
  # cat $OUT_TRANS | tail -1
  sleep 4
done


echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

