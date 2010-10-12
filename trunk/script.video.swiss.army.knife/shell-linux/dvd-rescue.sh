#!/bin/bash
###########################################################
# scriptname : dvd-rescue.sh                              #
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
# generates a iso file of a dvd even with crc-errors on   #
# the dvd                                                 #
###########################################################
SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"



###########################################################
#                                                         #
# Check that not user root is not running this script     #
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/iso-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/dvd-dd.log"
PWATCH="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/PWATCH"

SHELL_CANCEL=0
TERM_ALL="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/TERM_ALL"
KILL_FILES="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/KILL_FILES"
if [ -e $TERM_ALL ] ; then 
   rm $TERM_ALL > /dev/null 2>&1
fi

EXPECTED_ARGS=3
E_BADARGS=1
E_BADB=2
E_TOOLNOTF=50
E_TERMINATE=100
E_DD=253
E_SUID0=254
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
isoinfo
ddrescue
awk
nohup
eject
EOF`

###########################################################



###########################################################
#                                                         #
# Check startup-parameters and show usage if needed       #
#                                                         #
###########################################################

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-rescue.sh p1 p2 p3"
  echo
  echo "[p1] device or complet path to ripfile"
  echo "[p2] directory for rip"
  echo "[p3] Name of iso (excluding iso)"
  echo
  echo "dvd-rescue.sh was called with wrong arguments"
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

if [ -e $2/$3.iso ] ; then
   rm $2/$3.iso > /dev/null 2>&1
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
# Calulate the iso-size for the iso-copy process          #
#                                                         #
###########################################################

blocksize=`isoinfo -d -i $1  | grep "^Logical block size is:" | cut -d " " -f 5`
if test "$blocksize" = ""; then
   echo catdevice FATAL ERROR: Blank blocksize > $OUTPUT_ERROR
   exit $E_BADB
fi

blockcount=`isoinfo -d -i $1 | grep "^Volume size is:" | cut -d " " -f 4`
if test "$blockcount" = ""; then
   echo catdevice FATAL ERROR: Blank blockcount > $OUTPUT_ERROR
   exit $E_BADB
fi

SIZE1=$(($blocksize * $blockcount))
echo
echo INFO expected iso-size in bytes [$(($blocksize * $blockcount))]

###########################################################










###########################################################
#                                                         #
# Copy dvd with ddrescue                                  #
#                                                         #
###########################################################

lsdvd -a $1 1>/dev/null 2>&1
echo INFO starting ddrescue

(
ddrescue -r -1 -d -b 2048 $1 $2/$3.iso &
) > $OUT_TRANS 2>&1 &
echo INFO ddrescue command executed
sleep 3

PID=$(ps axu | grep "ddrescue" | head -1 |  grep -v grep |awk '{print $2}')
if [ -z "$PID" ] ; then
   echo
   echo ddrescue is not running after 3 secounds. Please check your
   echo settings and log-files.
   echo
   exit $E_DD
fi

echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32154 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
echo -n $2/$3.iso > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
echo $PID >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
echo $PID > $PWATCH

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

  # This should be the normal entry-point .... but this entry-point do not work on some 
  # copy-protected dvd's the iso is allmost copy but few bytes are missing ....

  if [ $SIZE1 == $SIZE2 ] ; then
     echo
     echo
     echo INFO processing data done to the file-size 
     echo the rescue process may run longer...
     echo
     echo wait now until the main-process is terminated.
     echo 
     LOOP=0

     # we do wait until the rescue process is finsished 
     # I saw a few times this process needs longer to finish ....
 
     LOOP2=1
     while [ $LOOP2 -eq '1'  ];
     do
       PID=$(ps axu | grep "ddrescue" | head -1 |  grep -v grep |awk '{print $2}' )
       echo -n .
       if [ -n "$PID" ] ; then
           LOOPP2=1
       else
           echo 
           echo 
           echo INFO processing data done and process terminated 
           echo
           LOOPP2=0
       fi
       sleep 0.7
     done
  fi

  # This is the secound entry-point .... in the case that only a few bytes are missing 

  if [ "$PROGRESS" == "100" ] ; then
     if [ "$LOOP" == "1" ] ; then
        echo
        echo
        echo INFO processing data done to the percent-size 
        echo the rescue process may run longer...
        echo
        echo wait now until the main-process is terminated.
        echo after 4 minutes the process will be killed
        echo 
        LOOP=0

        # we do wait until the rescue process is finsished 
        # I saw a few times this process needs longer to finish ....
 
        LOOP2=1
        TIMOUT=0 
        while [ $LOOP2 -eq '1'  ];
        do
              PID=$(ps axu | grep "ddrescue" | head -1 |  grep -v grep |awk '{print $2}' )
              echo -n .
              if [ -n "$PID" ] ; then
                 LOOPP2=1
              else
                echo 
                echo 
                echo INFO processing data done and process terminated 
                echo
                LOOPP2=0
              fi
              sleep 1
              TIMEOUT=`expr $TIMEOUT + 1`
              if [ $TIMEOUT -eq "240" ] ; then
                 LOOP2=0
                 kill -9 $PID > /dev/null 2>&1 
              fi
        done
     fi
  fi

  sleep 4

  # Terminate Looping -> Main-Process was killed 

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
   echo 
   echo
   echo ----------------------- script rc=0 -----------------------------
   echo -----------------------------------------------------------------

   exit 0

else

   # ups ... something was going very wrong    
   # we only erase file depend on the setttings of the addon

   if [ -e $KILL_FILES ] ; then
      rm $2/$3.iso > /dev/null 2>&1  
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

###########################################################

