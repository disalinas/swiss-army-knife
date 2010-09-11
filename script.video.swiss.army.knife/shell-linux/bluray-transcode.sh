#!/bin/bash
###########################################################
# scriptname : bluray-transcode.sh                        #
###########################################################
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
# Convert bluray track to mkv container                   #
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

EXPECTED_ARGS=4

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/bluray-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: bluray-transcode.sh p1 p2 p3 p4"
  echo "                            "
  echo "[p1] device"
  echo "[p2] rip-directory"
  echo "[p3] name of mkv (excluding mkv)"
  echo "[p4] Track to extract 0-X"
  echo "                            "
  echo "bluray-transcode.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
nohup
sed
sort
makemkvcon
EOF`


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


if [ $1 == '/dev/sr0' ] ; then
   PARA="disc:0"
fi

if [ $1 == '/dev/sr1' ] ; then
   PARA="disc:1"
fi

if [ $1 == '/dev/sr2' ] ; then
   PARA="disc:2"
fi


if [ -e bluray.progress ] ; then
   rm bluray.progress > /dev/null 2>&1 
fi

(
makemkvcon --messages=/dev/null --progress=bluray.progress mkv $PARA $4 $2 > /dev/null 2>&1  &
) > /dev/null 2>&1

sleep 30

echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32150 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current

if [ $4 -lt '10' ] ; then
   echo -n $2/title0$4.mkv > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
fi

if [ $4 -gt '10' ] ; then
   echo -n $2/title$4.mkv > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
fi

echo $SCRIPTDIR/bluray.progress >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files

echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
ps axu | grep makemkvcon | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid


echo
echo INFO processing data
echo

while [ 1=1 ];
do
   echo -n .
   progress=$(cat bluray.progress | tail -1 | awk '{print $4}'| sed "s/[^0-9]//g")
   echo $progress > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
   sleep 2

   if [ $progress -eq "100"  ] ; then
       rm bluray.progress > /dev/null 2>&1
       echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
       echo
       echo
       echo INFO processing data done
       echo
       break
   fi

   sleep 2
done

if [ $4 -lt '10' ] ; then
   mv $2/title0$4.mkv $2/$3.mkv
fi

if [ $4 -gt '10' ] ; then
   mv $2/title$4.mkv $2/$3.mkv
fi

# Delete jobfile

rm $JOBFILE > /dev/null 2>&1



# Delete all progress-files 

sleep 1
rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/* > /dev/null 2>&1

echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0


