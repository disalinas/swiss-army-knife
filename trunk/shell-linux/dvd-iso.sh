#!/bin/bash
###########################################################
# scriptname : dvd-iso.sh                                 #
###########################################################
# RELEASE 0.6C swiss-army-knife                           #
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# $2 directory for rip                                    #
# $3 iso-name (excluding extension iso                    #
#                                                         #
# description :                                           #
# generates a iso file of a dvd                           #
###########################################################


SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"

echo
echo --------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script  :" $SCRIPT
cat version
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo --------------------------------------------------------------------


OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/iso-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script-video-ripper/JOB"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=3

# Error-codes

E_BADARGS=1

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
dd
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

# For the GUI-progress-bar we need the exact size in bytes for the 
# saved iso-file 



# Delete jobfile

rm $JOBFILE > /dev/null 2>&1


echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit

