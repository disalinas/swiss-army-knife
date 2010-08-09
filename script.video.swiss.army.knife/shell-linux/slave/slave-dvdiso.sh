#!/bin/bash
###########################################################
# scriptname : slave-dvdiso.sh                            #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 master-netcat-port 1                                 #
# $2 master-netcat-port 5                                 #
# $3 dvd-devive to send image over the network            #
# $4 master ip-adress or dns-name                         #
#                                                         #
# description :                                           #
# save a file over the network to a master station        #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux/slave"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat ../version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/slave-dvdiso.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=4

# Error-codes

E_BADARGS=1
E_TIMEOUT=2
E_TOOLNOTF=3
E_BADB=4


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: slave-dvdiso.sh p1 p2 p3 p4"
  echo
  echo "[p1] netcat master port 1 dd-operation"
  echo "[p2] netcat master port 2 transfer size"
  echo "[p3] dvd-device"
  echo "[p4] master ip-adress or dns-name"
  echo
  echo "slave-dvdiso.sh was called with wrong arguments"
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
isoinfo
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

# break css by force

lsdvd -a $3 >/dev/null 2>&1

blocksize=`isoinfo -d -i $3  | grep "^Logical block size is:" | cut -d " " -f 5`
if test "$blocksize" = ""; then
   echo
   echo catdevice FATAL ERROR: Blank blocksize
   echo catdevice FATAL ERROR: Blank blocksize > $OUTPUT_ERROR
   echo
   echo ----------------------- script rc=4 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_BADB
fi


# Get Blockcount

blockcount=`isoinfo -d -i $3 | grep "^Volume size is:" | cut -d " " -f 4`
if test "$blockcount" = ""; then
   echo
   echo catdevice FATAL ERROR: Blank blockcount
   echo catdevice FATAL ERROR: Blank blockcount > $OUTPUT_ERROR
   echo
   echo ----------------------- script rc=4 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_BADB
fi


SIZE1=$(($blocksize * $blockcount))
echo
echo INFO expected iso-size in bytes [$(($blocksize * $blockcount))]

dd bs=2048 if=$3 | nc -4 -u $4 $1 >/dev/null 2>&1  &

echo
echo timeout 5 secounds for master-connection is starting now

sleep 5

PID1=$(ps axu | grep "nc \-4 \-u $4 $1" | grep -v grep |awk '{print $2}')

if [ -z $PID1 ] ; then
   echo
   echo no connection to master port $1 with ip:$4 possible.
   echo slave-script do exit now ...
   echo
   echo ----------------------- script rc=2 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_TIMEOUT
fi

echo
echo INFO connected to host:$4
echo
echo INFO copy data with netcat
echo

CONNECT=0
TIMEOUT=1
LOOP=1

cd "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp"

while [ $LOOP -eq '1'  ];
do
  nc -4 -u -l $2 -w 1 > transfer_from_master_to_slave.tmp
  sleep 20
  echo -n .
done

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0



