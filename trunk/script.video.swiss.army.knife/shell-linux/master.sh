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
# $2 master-netcat-port 2                                 #
# $3 master-netcat-port 3                                 #
# $4 master-netcat-port 4                                 #
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

# Define the counting commands we expect inside the script

EXPECTED_ARGS=4

# Error-codes

E_BADARGS=1
E_TIMEOUT=2
E_TOOLNOTF=3


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: master.sh p1 p2 p3 p4"
  echo
  echo "[p1] netcat master port 1 dd-operation"
  echo "[p2] netcat master port 2 transfer size"
  echo "[p3] name of volume"
  echo "[p4] cancel rip from slave"
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

echo
echo INFO processing data
echo

nc -4 -u -l $1 | dd of=/dvdrip/network/file.transfer > /dev/null 2>&1  &

echo timeout 120 secounds for slave-connection is starting now
echo

CONNECT=""
TIMEOUT=1
LOOP=1

cd "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp"

while [ $LOOP -eq '1'  ];
do

  # We kneed to know from where we are connected

  REMOTEIP=$(netstat -tunl | grep $1 | awk '{print $4}' | tr ':' ' ' | awk '{print $1}')

  if [ "$REMOTEIP" == "0.0.0.0" ] ; then
      CONNECT=0
  else
      echo -n .
      PID1=$(ps axu | grep "nc \-4 \-u \-l $1" | grep -v grep | awk '{print $2}')
      if [-z "PID1" ] ; then
          echo
          echo
          echo INFO processing data done
          echo
          LOOP=0
          SIZET=$(ls -la /dvdrip/network/file.transfer | awk '{print $5}')
          echo $SIZET > $SIZE_TRANSFER
          cat $SIZE_TRANSFER | nc -4 -u $REMOTEIP $2 -q 1  >/dev/null

          # to rename the file we need the volname from the remote side

          nc -4 -u -l $3 -w 1 > $NAME_AFTER_TRANSFER
          NAME=$(cat $NAME_AFTER_TRANSFER)

          mv /dvdrip/network/file.transfer /dvdrip/network/$NAME

          # We can exit now

      else
          netstat -tunp > $TMP 2>$TMP
          REMOTEIP=$(cat $TMP  | grep $1 | grep $PID1 | awk '{print $5}' | tr ':' ' ' | awk '{print $1}')
          SIZET=$(ls -la /dvdrip/network/file.transfer | awk '{print $5}')
          echo $SIZET > $SIZE_TRANSFER
          CONNECT=1
          cat $SIZE_TRANSFER | nc -4 -u $REMOTEIP $2 -q 1  >/dev/null
     fi
  fi

  # After 120 secounds and no active connection we have reached timeout

  if [ $CONNECT -eq 0 ] ; then
     if [ $TIMEOUT -gt 120 ] ; then

           PID2=$(ps axu | grep "dd of=/dvdrip/network/file.transfer" | grep -v grep |awk '{print $2}')
           PID1=$(ps axu | grep "nc \-4 \-u \-l $1" | grep -v grep |awk '{print $2}')
           kill -9 $PID2 $PID1 > /dev/null 2>&1

           echo
           echo no connection from a client to port $1 was made.
           echo master-script do exit now ...
           echo
           echo ----------------------- script rc=2 -----------------------------
           echo -----------------------------------------------------------------
           exit $E_TIMEOUT
     fi
  fi

  sleep 1

  # Increment timeout value

  TIMEOUT=`expr $TIMEOUT + 1`
done

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

