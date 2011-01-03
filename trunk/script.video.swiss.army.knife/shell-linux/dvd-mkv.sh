#!/bin/bash
###########################################################
# scriptname : dvd-mkv.sh                                 #
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
# Convert dvd track to mkv container                      #
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
# Only one job is supported with gui-interaction          #
#                                                         #
###########################################################

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" ] ; then
   clear
   echo
   echo There is allready a other job runnung.
   echo
   echo ----------------------- script rc=101 ---------------------------
   echo -----------------------------------------------------------------
   exit 101
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
echo "copyright : (C) <2010-2011>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
if [ -z "$1" ] ; then
   echo no parameters to script detected
else
   if [ -f $1 ] ; then
      echo scipt is using a iso-file as source [$1]
   else
      echo scipt is using a device as source [$1]
   fi
fi

echo ----------------------------------------------------------------------------

###########################################################






###########################################################
#                                                         #
# Definition of files and internal variables              #
#                                                         #
###########################################################

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/handbrake-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
JOBERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR"
EJECT="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/EJECT"
PWATCH="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/PWATCH"

SHELL_CANCEL=0
TERM_ALL="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/TERM_ALL"
KILL_FILES="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/KILL_FILES"
if [ -e $TERM_ALL ] ; then
   rm $TERM_ALL > /dev/null 2>&1
fi

ZERO=0
EXPECTED_ARGS=4
E_BADARGS=1
E_TOOLNOTF=50
E_TERMINATE=100
E_JOBRUNNING=101
E_HANDBRAKE=253
E_SUID0=254
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
nohup
sed
sort
makemkvcon
eject 
EOF`

###########################################################





###########################################################
#                                                         #
# Check startup-parameters and show usage if needed       #
#                                                         #
###########################################################

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-mkv.sh p1 p2 p3 p4"
  echo "                            "
  echo "[p1] device"
  echo "[p2] rip-directory"
  echo "[p3] name of mkv (excluding mkv)"
  echo "[p4] Track to extract 0-X"
  echo "                            "
  echo "dvd-mk.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi

###########################################################




###########################################################
#                                                         #
# Cleanup a few files on startup of the script            #
#                                                         #
###########################################################

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR" ] ; then
    rm "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR" > /dev/null 2>&1
fi

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" ] ; then
    rm "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" > /dev/null 2>&1
fi

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done" ] ; then
   rm  "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done" > /dev/null 2>&1
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
# Start the transcoding process                           #
#                                                         #
###########################################################

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

echo
echo INFO starting makemkvcon

(
makemkvcon --messages=/dev/null --progress=bluray.progress mkv $PARA $4 $2 > /dev/null 2>&1  &
) > /dev/null 2>&1

echo INFO makemkvcon command executed

sleep 30

# We need to be sure that makemkvcon is running in background ...
# If this is not the case we exit the script.

PID1=$(ps axu | grep "makemkvcon \-\-m" | grep -v grep | awk '{print $2}')
if [ -z "$PID1" ] ; then
    echo
    echo makemkvcon is not running after 30 secounds. Please check your
    echo settings and configuration and licence-key
    echo
    exit $E_MAKEMKV
fi

echo $PID1 > $PWATCH

echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32159 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current

if [ $4 -lt '10' ] ; then
   echo -n $2/title0$4.mkv > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
   tr_file=$2/title0$4.mkv
fi

if [ $4 -gt '10' ] ; then
   echo -n $2/title$4.mkv > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
   tr_file=$2/title$4.mkv
fi

echo $SCRIPTDIR/bluray.progress >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files

echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
ps axu | grep makemkvcon | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid

echo INFO processing data pass 1 of 1
echo

while [ 1=1 ];
do
   echo -n .
   progress=$(cat bluray.progress | tail -1 | awk '{print $4}'| sed "s/[^0-9]//g")
   echo $progress > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
   sleep 2

   if [ $progress -eq "100" ] ; then
       rm bluray.progress > /dev/null 2>&1
       echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done

       echo
       echo
       echo INFO processing data pass 1 of 1 done
       echo
       break
   fi

   sleep 2

   # Terminate Looping -> Main-Process was killed

   if [ -e $TERM_ALL ] ; then
      echo
      SHELL_CANCEL=1
      break
   fi
done

###########################################################







###########################################################
#                                                         #
# We are done / Decition depends on success or error      #
#                                                         #
###########################################################

if [ "$SHELL_CANCEL" == "0" ] ; then

   rm $JOBFILE > /dev/null 2>&1

   sleep 1

   rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/* > /dev/null 2>&1
   rm $PWATCH > /dev/null 2>&1

   if [ -e $EJECT ] ; then
      if [ -f $1 ] ; then
          echo eject command can no be used with a regular file as source
      else
          eject $1
      fi
   fi

   echo
   echo ----------------------- script rc=0 -----------------------------
   echo -----------------------------------------------------------------

   exit $ZERO

else

   echo
   echo INFO processing task have ben killed or ended unexpected !!!
   echo

   # ups ... something was going very wrong
   # we only erase file depend on the setttings of the addon

   if [ -e $KILL_FILES ] ; then
      rm $tr_file > /dev/null 2>&1
   fi

   rm $JOBFILE > /dev/null 2>&1
   rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/* > /dev/null 2>&1
   rm $PWATCH > /dev/null 2>&1

   echo
   echo ERROR : This job was not successsfully
   echo
   echo ----------------------- script rc=100 ---------------------------
   echo -----------------------------------------------------------------
   exit $E_TERMINATE
fi

##########################################################
