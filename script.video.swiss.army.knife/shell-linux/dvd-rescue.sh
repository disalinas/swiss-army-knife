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



# Define the counting commands we expect inside the script

EXPECTED_ARGS=3

# Error-codes

E_BADARGS=1
E_BADB=2
E_TOOLNOTF=50
E_TERMINATE=100

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



# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
isoinfo
ddrescue
awk
nohup
eject
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

echo INFO starting ddrescue

(
ddrescue -r -1 -d -b 2048 $1 $2/$3.iso &
) > $OUT_TRANS 2>&1 &

sleep 3

echo $1 > $JOBFILE
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
echo 32154 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
echo -n $2/$3.iso > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files
echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
ps axu | grep "ddrescue" | head -1 |  grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
ps axu | grep "ddrescue" | head -1 |  grep -v grep |awk '{print $2}' > $PWATCH

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
  # from the generated iso -> you can send your donation to the content-owner 
  # the company who made the dvd don't like that a copy can made ... 

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
     echo
     echo
     echo INFO processing task  have ben killed or ended unexpected ..... 
     echo
     LOOP=0
     SHELL_CANCEL=1
  fi

done


if [ "$SHELL_CANCEL" == "0" ] ; then 
 
   # Delete jobfile

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


