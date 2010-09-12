#!/bin/bash
###########################################################
# scriptname : master.sh                                  #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 master-netcat-port 1                                 #
# $2 directory to save incoming files                     #
#                                                         #
# description :                                           #
# save a file over the network to this master             #
#                                                         #
# port 1          < transfer dd image from slave          #
# port 2          > send back transferd bytes to client   #
# port 3          < name of the file                      #
# port 4          < cancel rip from slave                 #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using somehting other than /bin/bash.
   echo
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/master-save.log"
TMP="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/master-save.tmp"
SIZE_TRANSFER="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/size-transfer-to-client.tmp"
NAME_AFTER_TRANSFER="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/name-from-slave"
CANCEL_ALL="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/cancel-from-slave"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=2

# Error-codes

E_BADARGS=1
E_TIMEOUT=2
E_TOOLNOTF=3


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: master.sh p1 p2"
  echo
  echo "[p1] netcat master port 1 dd-operation"
  echo "[p2] directory to store incoming files"
  echo
  echo "master.sh was called with wrong arguments"
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
tr
awk
dd
netstat
nc
grep
sleep
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
        echo ----------------------- script rc=3 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi
done


# Define the ports we are using to communicate over netcat

PORT1=$1
PORT2=`expr $1 + 1`
PORT3=`expr $1 + 2`
PORT4=`expr $1 + 3`

echo
echo "[$PORT1] from slave dd"
echo "[$PORT2] to slave size of file"
echo "[$PORT3] from slave name of file after transprt"
echo "[$PORT4] from slave Cancel operation"
echo

# cleanup

if [ -e $CANCEL_ALL ] ; then
     rm $CANCEL_ALL >/dev/null 2>&1
fi

if [ -e $2/file.transfer  ] ; then
     rm $2//file.transfer >/dev/null 2>&1
fi


echo
echo INFO processing data
echo

nc -4 -l $PORT1 | dd of=$2/file.transfer > /dev/null 2>&1  &

echo timeout 120 secounds for slave-connection is starting now
echo

CSTART=0
CONNECT=0
TIMEOUT=1
LOOP=1

cd "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp"

while [ $LOOP -eq '1'  ];
do

  # We kneed to know from where we are connected

  REMOTEIP=$(netstat -tun | grep $PORT1 | grep ESTABLISHED | awk '{print $4}' | grep $PORT1 | tr ':' ' ' | awk '{print $1}')

  if [ -z  "$REMOTEIP" ] ; then
     if [ $CSTART -eq 0 ] ; then
        CONNECT=0
     fi
  else

      PID1=$(ps axu | grep "nc \-4 \-l $PORT1" | grep -v grep | awk '{print $2}')

      # we only need 1 instance for the remote cancel

      if [ $CSTART -eq 0 ] ; then
           (
            nc -4 -l $PORT4 -w 1 > $CANCEL_ALL 2>/dev/null  &
           ) > /dev/null 2>&1 &

           echo
           echo
           echo INFO copy data with netcat
           echo
           CSTART=1
           CONNECT=1
      fi

      netstat -tunp > $TMP 2>$TMP
      SLAVE=$(cat $TMP  | grep $PORT1 | grep $PID1 | awk '{print $5}' | tr ':' ' ' | awk '{print $1}')
      SIZET=$(ls -la $2/file.transfer | awk '{print $5}')
      echo $SIZET > $SIZE_TRANSFER
      CONNECT=1
      cat $SIZE_TRANSFER | nc -4 $SLAVE $PORT2 -q 1  >/dev/null
  fi


  # After 120 secounds and no active connection we have reached timeout

  if [ $CONNECT -eq 0 ] ; then
     if [ $TIMEOUT -gt 120 ] ; then
        if [ $CSTART -eq 0 ] ; then

           PID2=$(ps axu | grep "dd of=$2/file.transfer" | grep -v grep |awk '{print $2}')
           PID1=$(ps axu | grep "nc \-4 \-l $PORT1" | grep -v grep |awk '{print $2}')
           kill -9 $PID2 $PID1 > /dev/null 2>&1

           echo
           echo
           echo no connection from a client to port $1 was made.
           echo master-script do exit now ...
           echo
           echo ----------------------- script rc=2 -----------------------------
           echo -----------------------------------------------------------------
           exit $E_TIMEOUT
        fi
     fi
  fi

  if [ $CONNECT -eq 0 ] ; then
     echo -n .
  fi

  if [ $CONNECT -eq 1 ] ; then
     echo -n .
     if [ -z  "$REMOTEIP" ] ; then
          echo
          echo
          echo INFO processing data done
          echo

          sleep 5

          LOOP=0
          SIZET=$(ls -la $2/file.transfer | awk '{print $5}')
          echo $SIZET > $SIZE_TRANSFER
          cat $SIZE_TRANSFER | nc -4 $SLAVE $PORT2 -q 1  >/dev/null &

          # to rename the file we need the volname from the remote side

          nc -4 -l $PORT3 -w 1 > $NAME_AFTER_TRANSFER &

          echo
          echo INFO renmame filter after transfer
          echo

          sleep 3

          NAME=$(cat $NAME_AFTER_TRANSFER)
          mv $2/file.transfer $2/$NAME
     fi
  fi

  sleep 1

  # Increment timeout value

  TIMEOUT=`expr $TIMEOUT + 1`

  # Test for cancel from  the remote side

  if [ -e $CANCEL_ALL ] ; then
     grep CANCEL $CANCEL_ALL
     retval=$?
     if [ $retval -eq 0 ] ; then
       echo
       echo
       echo INFO processing data canceld from the remote-side
       echo
       PID2=$(ps axu | grep "dd of=$2/file.transfer" | grep -v grep |awk '{print $2}')
       PID1=$(ps axu | grep "nc \-4 \-l $PORT1" | grep -v grep |awk '{print $2}')
       kill -9 $PID2 $PID1 > /dev/null 2>&1
     fi
  fi

done

# In the case we have started a port4 netcat process we have kill the process.....

PID1=$(ps axu | grep "nc \-4 \-l $PORT4 \-w" | grep -v grep |awk '{print $2}')
kill -9 $PID1 > /dev/null 2>&1


echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

