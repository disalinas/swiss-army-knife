#!/bin/bash
###########################################################
# scriptname : master-save.sh                             #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 master-netcat-port 1                                 #
# $2 master-netcat-port 2                                 #
#                                                         #
# description :                                           #
# save a file over the network to this master             #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux/master"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat ../version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/master-save.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=2

# Error-codes

E_BADARGS=1
E_TIMEOUT=2
E_TOOLNOTF=3


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: master-save.sh p1 p2"
  echo
  echo "[p1] netcat master port 1 dd-operation"
  echo "[p2] netcat master port 2 transfer size"
  echo
  echo "master-save.sh was called with wrong arguments"
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

nc -4 -l $1 | dd of=/dvdrip/network/file.transfer &

echo timeout 120 secounds for slave-connection is starting now

CONNECT=0
TIMEOUT=1
LOOP=1
while [ $LOOP -eq '1'  ];
do
  # We kneed to know from where we are connected

  REMOTE_IP=$(netstat -ltn | grep $1 | awk '{print $4}' | tr ':' ' ' | awk '{print $1}')

  if [ "$REMOTE_IP" != "0.0.0.0" ] ; then
      echo -n .
      SIZET=$(ls -la /dvdrip/network/file.transfer | awk '{print $5}')
      echo $SIZET | nc -4 $REMOTE_IP $2
  else

     # After 120 secounds and no active connection we have reached timeout

     if [ $TIMEOUT -gt 120 ] ; then
        if [ $REMOTE_IP == "0.0.0.0" ] ; then

           PID2=$(ps axu | grep "dd of=/dvdrip/network/file.transfer" | grep -v grep |awk '{print $2}')
           PID1=$(ps axu | grep "nc -4 -l $1" | grep -v grep |awk '{print $2}')
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
  fi

  sleep 1
  TIMEOUT=`expr $TIMEOUT + 1`

done

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

