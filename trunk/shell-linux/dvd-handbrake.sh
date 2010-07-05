#!/bin/bash
###########################################################
# scriptname : dvd-handbrake.sh                           #
###########################################################
# RELEASE 0.6C swiss-army-knife                           #
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# $2 directory for rip                                    #
# $3 export-name                                          #
# $4 chapter to extract (starting with index 1 !!!!! )    #
# $5 audio channel to extract                             #
#                                                         #
# optional $6,7 -a secound-audio language (0-x)   -a 2    #
# optional $8,9 -s subtitle-nummer        (0-x)   -s 0    #
#                                                         #
# description :                                           #
# generates a mkv container of a dvd                      #
###########################################################


SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"

echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------


OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/handbrake-error.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=5

# Error-codes

E_BADARGS=1

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-handbrake.sh p1 p2 p3 p4 p5"
  echo "                                      "
  echo "[p1] device or complet path to ripfile"
  echo "[p2] directory for rip"
  echo "[p3] export-name (excluding mkv)"
  echo "[p4] chapter to extract [1-X]"
  echo "[p5] audio channel to extract [0-X]"
  echo "The above paramters p1-p5 are allways needet"
  echo "                                            "
  echo "There are 2 addional parameters to pass to the script"
  echo "                                            "
  echo "p6,7  second audio-track   -a 3 [0-X]"
  echo "p8,9  subtitle             -s 0 [0-X]"
  echo "dvd-handbrake.sh was called with wrong arguments"
  echo
  exit $E_BADARGS
fi


if [ $4 -eq 0 ]; then
  echo "the parameter 4 must be starting with 1 !"
  echo
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
HandBrakeCLI
sleep
mencoder
nohup
EOF`


# Check if all commands are found on your system ...

for REQUIRED_TOOL in ${REQUIRED_TOOLS}
do
   which ${REQUIRED_TOOL} >/dev/null 2>&1
   if [ $? -eq 1 ]; then
        echo ----------------------------------------------------------------------------
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate."
        echo "Please install \"${REQUIRED_TOOL}\"."
        echo ----------------------------------------------------------------------------
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate." > $OUTPUT_ERROR
        echo "Please install \"${REQUIRED_TOOL}\"." > $OUTPUT_ERROR
        exit $E_TOOLNOTF
   fi
done

echo ---------------
echo Toolchain found
echo ---------------


echo ------------------
echo Starting transcode
echo ------------------


if [ $# -eq 5 ]; then
    AUDIO1=$(($5 +  1))
    echo -----------------------------------
    echo 5 paramters $1 $2 $3 $4 $5
    echo -----------------------------------
 
    echo --------------------------------------------
    echo Send back current progress data to XBMC-GUI
    echo --------------------------------------------

    echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-counter
    echo "1 Pass 1/2 for transcoding" > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
    echo "2 Pass 2/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
    echo 1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
    echo $2/$3.mkv > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-files

    nohup HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
    -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile"  \
    -a $AUDIO1 -E ac3 &

    echo ------------------------------
    echo Handbrake has startet ...
    echo ------------------------------

    sleep 15
    while [ 1=1 ];
     do
      PASS1=$(cat nohup.out | grep "task 1 of 2" | tail -1 | sed  's/,//g' | sed  's/%//g' | sed  's/(//g' | sed  's/)//g' | sed  's/\./ /g' | sed  's/\://g')
      echo ....
      echo $PASS1
      echo ....
      sleep 2
    done
fi









if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-a ]] ; then
       AUDIO1=$(($5 +  1))
       AUDIO2=$(($7 +  1))
       echo 7 parameters 2 audio  $1 $2 $3 $4 $5 $6 $7
       HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
       -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile" -a $AUDIO1,$AUDIO2 -A "Audio-1","Audio-2" -B auto,160 -R auto,auto -6 auto,auto -E ac3,acc
    fi
fi

if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-s ]] ; then
       AUDIO1=$(($5 + 1))
       echo 7 parameters 1 audio 1 sub $1 $2 $3 $4 $5 $6 $7
       mencoder dvd://$4 -dvd-device $1 -ovc frameno -nosound -o /dev/null -sid $7 -vobsubout $2/$3
       HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
       -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile" -a $AUDIO1 -E ac3
    fi
fi

if [ $# -eq 9 ]; then
     AUDIO1=$(($5 +  1))
     AUDIO2=$(($7 +  1))
     echo 9 parameters $1 $2 $3 $4 $5 $6 $7 $8 $9
     mencoder dvd://$4 -dvd-device $1 -ovc frameno -nosound -o /dev/null -sid $9 -vobsubout $2/$3
     HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
     -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile" -a $AUDIO1,$AUDIO2 -A "Audio-1","Audio-2" -B auto,160 -R auto,auto -6 auto,dpl2 -E ac3,acc
fi




exit

