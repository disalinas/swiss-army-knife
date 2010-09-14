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
# $1 dvd-device                                           #
# $2 directory to store vob-copys                         #
#                                                         #
# description :                                           #
# generates a copy of all vob files from a dvd            #
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/vobcopy-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/vobcopy.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=2

# Error-codes

E_BADARGS=1
E_BADB=2
E_NOMOUNT=3
E_TOOLNOTF=50

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-vcopy.sh p1 p2"
  echo
  echo "[p1] dvd-device"
  echo "[p2] rip-directory"
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
bc
awk
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

DVDDIR=$(mount | grep $1 | awk '{print $3}')

if [ -z $DVDDIR ] ; then
   echo ERROR : dvd was not montet and therefore can vobcopy no be startet  > $OUTPUT_ERROR
   echo ERROR : dvd was not montet and therefore can vobcopy no be startet
   echo
   echo
   exit $E_NOMOUNT
fi

echo
echo
echo INFO get size of all vob-files[$DVDDIR/VIDEO_TS]

SIZE1=$(du -b $DVDDIR/VIDEO_TS | tail -1 | awk '{print $1}')
T1=$(bc -l <<< "scale=0; ($SIZE1 / 100)")
VOLNAME=$(volname $1 | tr -dc ‘[:alnum:]‘)

rm -rf $2/$VOLNAME >/dev/null 2>&1

echo INFO volume-name[$VOLNAME]
echo INFO starting vobcopy
echo
echo

(
vobcopy -v -m -o $2 -t $VOLNAME 2>/dev/null
) > $OUT_TRANS 2>&1 &

sleep 10

echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32156 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
ps axu | grep "vobcopy -v -m" | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid

LOOP=1
while [ $LOOP -eq '1'  ];
do
  echo -n .
  SIZE2=$(cd /dvdrip/vobcopy/$VOLNAME/VIDEO_TS && du -b | tail -1 | awk '{print $1}')
  PROGRESS=$(bc -l <<< "scale=0; ($SIZE2 / $T1)")
  echo $PROGRESS > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress

  # We neeed to update the file-list on every loop

  LIST1=$(ls -al $2/$VOLNAME/VIDEO_TS/* | awk '{print $8}')
  echo $LIST1 | tr  [:blank:] '\n' > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
  echo $2/$VOLNAME >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files

  if [ $PROGRESS  == "100" ] ; then
     echo
     echo
     echo INFO processing data done
     echo
     LOOP=0
  fi
  sleep 10
done

# Delete jobfile

rm $JOBFILE > /dev/null 2>&1

sleep 1
rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/* > /dev/null 2>&1

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

