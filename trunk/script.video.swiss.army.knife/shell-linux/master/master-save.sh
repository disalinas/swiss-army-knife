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
# save a file over network                                #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat ../version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/iso-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/dvd-dd.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes

E_BADARGS=1
E_TIMEOUT=2

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: master-save.sh p1"
  echo
  echo "[p1] netcat master port"
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
EOF`

echo
echo INFO processing data
echo

nc -4 -l $1 | dd of=/dvdrip/network/file.transfer &

echo timeout 120 secounds for slave-connection is starting now

sleep 120

# We kneed to know from where we are connected

REMOTE_IP=$(netstat -natup | grep $1 | awk '{print $4}' | tr ':' ' ' | awk '{print $1}')

# If we do not have a connection it is time to say goodbye .....

if [ $REMOTE_IP == "0.0.0.0" ] ; then

   # the timeout-value -w has no effect in mode -l
   # therefore we need to kill with -9

   PID2=$(ps axu | grep "dd of=/dvdrip/network/file.transfer" | grep -v grep |awk '{print $2}')
   PID1=$(ps axu | grep "nc -4 -l $1" | grep -v grep |awk '{print $2}')

   kill -9 $PID2 $PID1  > /dev/null 2>&1

   echo
   echo no connection from a client to port $1 was made.
   echo master-script do exit now ...
   echo
   echo ----------------------- script rc=2 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_TIMEOUT
fi

LOOP=1
while [ $LOOP -eq '1'  ];
do
  echo -n .
  SIZET=$(ls -la /dvdrip/network/file.transfer | awk '{print $5}')
  echo $SIZET | nc -4 $REMOTE_IP $2
  sleep 10
done


echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

