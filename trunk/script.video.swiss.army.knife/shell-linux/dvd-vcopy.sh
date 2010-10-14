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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/vobcopy-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/vobcopy.log"
PWATCH="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/PWATCH"

SHELL_CANCEL=0
TERM_ALL="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/TERM_ALL"
KILL_FILES="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/KILL_FILES"
if [ -e $TERM_ALL ] ; then 
   rm $TERM_ALL > /dev/null 2>&1
fi

EXPECTED_ARGS=2
E_BADARGS=1
E_BADB=2
E_NOMOUNT=3
E_TOOLNOTF=50
E_TERMINATE=100
E_VOBCOPY=253
E_SUID0=254
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
isoinfo
mount
vobcopy
tr
bc
awk
eject
strings
EOF`

###########################################################



###########################################################
#                                                         #
# Check startup-parameters and show usage if needed       #
#                                                         #
###########################################################

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
# We generate a vobcopy from the inserted bluray          #
#                                                         #
###########################################################

DVDDIR=$(mount | grep $1 | awk '{print $3}')

if [ -z $DVDDIR ] ; then
   echo
   echo ERROR : dvd was not montet and therefore can vobcopy no be startet  > $OUTPUT_ERROR
   echo ERROR : dvd was not montet and therefore can vobcopy no be startet
   echo
   echo
   exit $E_NOMOUNT
fi

VOLNAME=$(volname $1 | tr -dc ‘[:alnum:]‘)

rm -rf $2/$VOLNAME >/dev/null 2>&1
mkdir $2/$VOLNAME > /dev/null 2>&1
cd $2/$VOLNAME > /dev/null 2>&1

echo
echo INFO volume-name[$VOLNAME]
echo VOB-DIRECTORY [$2/$VOLNAME]
echo INFO starting vobcopy

(
vobcopy > $OUT_TRANS 2>&1
) > $OUT_TRANS 2>&1 &
echo INFO vobcopy started

sleep 10

PID=$(ps axu | grep "vobcopy" | grep -v grep |awk '{print $2}')
if [ -z "$PID" ] ; then
    echo
    echo vobcopy is not running after 10 secounds. Please check your
    echo settings and configuration.
    echo
    exit $E_VOBCOPY 
fi

echo INFO processing data
echo


echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32156 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
echo $PID >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
echo $PID > $PWATCH

LOOP=1
while [ $LOOP -eq '1'  ];
do
  echo -n .
  PROGRESS=$(strings $OUT_TRANS | grep of | tail -1 | awk '{print $5}' | tr -dc ‘[:digit:]‘)
  echo $PROGRESS > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
  if [ $PROGRESS  == "100" ] ; then
     echo
     echo
     echo INFO processing data done
     echo
     LOOP=0
  fi

  sleep 3

  if [ -e $TERM_ALL ] ; then
     LOOP=0
     SHELL_CANCEL=1
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

   eject $1

 
   echo
   echo ----------------------- script rc=0 -----------------------------
   echo -----------------------------------------------------------------

   exit 0

else

   echo
   echo
   echo INFO processing task have ben killed or ended unexpected !!! 
   echo

   # ups ... something was going very wrong    
   # we only erase file depend on the setttings of the addon

   if [ -e $KILL_FILES ] ; then
      cd $2
      rm -rf $2/$VOLNAME >/dev/null 2>&1  
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


