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

echo
echo --------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script  :" $SCRIPT
cat version
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo --------------------------------------------------------------------


OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/handbrake-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script-video-ripper/JOB"
JOBERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/JOB.ERROR"

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
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


if [ $4 -eq 0 ]; then
  echo "the parameter 4 must be starting with 1 !"
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


if [ $# -eq 9 ]; then
    if [[ "$6" =~ ^-s ]] ; then
     echo "with 9 parameters the subtitle -s must be the last  !"
     echo
     echo ----------------------- script rc=1 -----------------------------
     echo -----------------------------------------------------------------
     exit $E_BADARGS
    fi 
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
HandBrakeCLI
sed
tr
strings
sleep
mencoder
nohup
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

if [ $# -eq 5 ]; then
    AUDIO1=$(($5 +  1))

    echo $1 > $JOBFILE  
    echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-counter
    echo "1 Pass 1/2 for transcoding" > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
    echo "2 Pass 2/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
    echo 1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
    echo $2/$3.mkv > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-files

    nohup HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
    -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile"  \
    -a $AUDIO1 -E ac3 &

    sleep 10

    echo $$ > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
    ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
    PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

    echo processing data

    while [ 1=1 ];
    do
      echo -n .
      PASS1=$(strings nohup.out | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
      PASS2=$(strings nohup.out | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
      if [ -n "$PASS1" ] ; then
         #  echo stage 1 [$PASS1] % completed
         echo $PASS1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress 
         if [ $PASS1 -eq 99 ] ; then
            sleep 5
            echo 100 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
            sleep 1
            echo 0 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
            echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
         fi
      fi
      if [ -n "$PASS2" ] ; then
         # echo stage 2 [$PASS2] % completed
         echo $PASS2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
         if [ $PASS2 -eq 100 ] ; then
             sleep 2
             echo DONE > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-done
             echo
             echo processing data done
             break
         fi
      fi
      PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 
      sleep 3  
    done
fi





if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-a ]] ; then
       AUDIO1=$(($5 +  1))
       AUDIO2=$(($7 +  1))

       echo $1 > $JOBFILE 
       echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-counter
       echo "1 Pass 1/2 for transcoding" > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
       echo "2 Pass 2/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
       echo 1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
       echo $2/$3.mkv > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-files

       nohup HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
       -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile" \
       -a $AUDIO1,$AUDIO2 -A "Audio-1","Audio-2" -B auto,160 \
       -R auto,auto -6 auto,auto -E ac3,acc &

       sleep 10

       echo $$ > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

       echo processing data

       while [ 1=1 ];
       do
         echo -n .
         PASS1=$(strings nohup.out | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         PASS2=$(strings nohup.out | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
            if [ $PASS1 -eq 99 ] ; then
               sleep 5
               echo 100 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
               sleep 1
               echo 0 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
               echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
            fi
         fi

         if [ -n "$PASS2" ] ; then
            echo $PASS2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
            if [ $PASS2 -eq 100 ] ; then
               sleep 2
               echo DONE > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-done
               echo
               echo processing data done
               break
            fi
         fi
         PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 
         sleep 3
       done
    fi
fi



if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-s ]] ; then
       AUDIO1=$(($5 + 1))

       echo $1 > $JOBFILE 
       echo 3 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-counter

       echo "1 copy subtitle" > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
       echo "2 Pass 1/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
       echo "3 Pass 2/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions

       echo 1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current

       nohup  mencoder dvd://$4 -dvd-device $1 -ovc frameno -nosound -o /dev/null -sid $7 -vobsubout $2/$3 &

       sleep 10

       echo $$ > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
       ps axu | grep mencoder | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
       PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}') 
 
       echo processing subtitle

       while [ 1=1 ];
       do
         echo -n .
         TMP=$(strings nohup.out | grep % | tail -1 | awk 'BEGIN{ RS="("; FS=")"} {print  $1}' | tr ' ' ',' | cut -d ',' -f2 | grep %)
         PASS1=$(echo $TMP | tr '%' ' ')
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
            if [ $PASS1 -eq 99 ] ; then
               sleep 10
               echo 100 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
               sleep 2
               echo 0 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
               echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
               echo
               echo processing subtitle done
               echo
               break
            fi
         fi
         PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}') 
         sleep 3
       done


       nohup HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
       -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile" \
        -a $AUDIO1 -E ac3 &

       echo $$ > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

       sleep 10

       echo processing data

       while [ 1=1 ];
       do
         echo -n .
         PASS2=$(strings nohup.out | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         PASS3=$(strings nohup.out | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS2" ] ; then
            echo $PASS2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress 
            if [ $PASS2 -eq 99 ] ; then
               sleep 5
               echo 100 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
               sleep 1
               echo 0 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
               echo 3 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
            fi
         fi
         if [ -n "$PASS3" ] ; then
            echo $PASS3 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
            if [ $PASS3 -eq 100 ] ; then
               sleep 2
               echo DONE > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-done
               echo
               echo processing data done
               break
            fi
         fi
         PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 
         sleep 3
       done
    fi
fi





if [ $# -eq 9 ]; then
     AUDIO1=$(($5 +  1))
     AUDIO2=$(($7 +  1))

     echo $1 > $JOBFILE 
     echo 3 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-counter

     echo "1 copy subtitle" > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
     echo "2 Pass 1/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions
     echo "3 Pass 2/2 for transcoding" >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions

     echo 1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current

     nohup mencoder dvd://$4 -dvd-device $1 -ovc frameno -nosound -o /dev/null -sid $9 -vobsubout $2/$3 &

     sleep 10

     echo $$ > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
     ps axu | grep mencoder | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
     PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}')       

     echo processing subtitle

     while [ 1=1 ];
     do
       echo -n .
       TMP=$(strings nohup.out | grep % | tail -1 | awk 'BEGIN{ RS="("; FS=")"} {print  $1}' | tr ' ' ',' | cut -d ',' -f2 | grep %)
       PASS1=$(echo $TMP | tr '%' ' ')
       if [ -n "$PASS1" ] ; then
          echo $PASS1 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
          if [ $PASS1 -eq 99 ] ; then
             sleep 10
             echo 100 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
             sleep 2
             echo 0 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
             echo 2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
             echo
             echo processing subtitle done
             echo
             break
          fi
       fi
       PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}') 
       sleep 3
     done

     nohup HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
     -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:trellis=1:no-fast-pskip=1:no-dct-decimate=1:direct=auto:cqm="dvd-handbrake-profile" \
     -a $AUDIO1,$AUDIO2 -A "Audio-1","Audio-2" -B auto,160 -R auto,auto -6 auto,dpl2 -E ac3,acc &

     echo $$ > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
     ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid
     PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 
     sleep 10

     echo processing data

     while [ 1=1 ];
     do
       echo -n .
       PASS2=$(strings nohup.out | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
       PASS3=$(strings nohup.out | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
       if [ -n "$PASS2" ] ; then
          echo $PASS2 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress 
          if [ $PASS2 -eq 99 ] ; then
             sleep 5
             echo 100 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
             sleep 1
             echo 0 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
             echo 3 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current
          fi
       fi
       if [ -n "$PASS3" ] ; then
          echo $PASS3 > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress
          if [ $PASS3 -eq 100 ] ; then
             sleep 2
             echo DONE > ~/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-done
             echo
             echo processing data done
             break
          fi
       fi
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 
       sleep 3
     done
fi


# Delete jobfile 

rm $JOBFILE > /dev/null 2>&1


echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit

