#!/bin/bash
###########################################################
# scriptname : dvd-handbrake.sh                           #
###########################################################
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


SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/handbrake-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
JOBERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd-transcode.log"

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
  echo
  echo "dvd-handbrake.sh was called with wrong arguments"
  echo
  echo example :
  echo
  echo ./dvd-handbrake /dev/sr0 /dvdrip/dvd stargate 1 0 -a 1 -s 0
  echo
  echo would use device /dev/sr0
  echo store the file insie /dvdrip/dvd
  echo the filename inside the directory will be stargate.mkv
  echo Track 1 will be extracted
  echo Audio-track 0 will be extracted
  echo Audio-track 1 will be extracted
  echo Subtitle-track 0 will be extracted 
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

# clean-up


if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR" ] ; then
    rm "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR" > /dev/null 2>&1
fi

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" ] ; then
    rm "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" > /dev/null 2>&1
fi



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





####################################################################################
#                                                                                  #
#                       transcode job with 1 audio-track                           #
#                                                                                  #
####################################################################################
if [ $# -eq 5 ]; then
    AUDIO1=$(($5 +  1))

    echo $1 > $JOBFILE
    echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

    echo 32152 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
    echo 32153 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions

    echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
    echo $2/$3.mkv > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files

    echo
    echo INFO starting HandBrakeCLI

    (
     HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
     -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:t$
     -a $AUDIO1 -E ac3 &
    ) > $OUT_TRANS 2>&1 &

    echo INFO HandBrakeCLI command executed
    echo

    sleep 10

    echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
    ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
    PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

    echo
    echo INFO processing data pass 1 of 2
    echo

    LOOP=1
    while [ $LOOP -eq '1'  ];
    do
      echo -n .
      PASS1=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
      PASS2=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
      if [ -n "$PASS1" ] ; then
         echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
         if [ $PASS1 -eq 99 ] ; then

            echo
            echo
            echo INFO processing data pass 1 of 2 done
            echo

            echo
            echo INFO processing data pass 2 of 2
            echo

            sleep  5
            echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            sleep 1
            echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
         fi
      fi

      if [ -n "$PASS2" ] ; then
         echo $PASS2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
         if [ $PASS2 -eq 98 ] ; then
             sleep 15
             echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
             echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
             echo
             echo
             echo INFO processing data pass 2 of 2 done
             echo
             LOOP=0
         fi
      fi
      sleep 0.7
    done
fi





####################################################################################
#                                                                                  #
#                       transcode job with 2 audio-track                           #
#                                                                                  #
####################################################################################
if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-a ]] ; then
       AUDIO1=$(($5 +  1))
       AUDIO2=$(($7 +  1))

       echo $1 > $JOBFILE
       echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter
   
       echo 32152 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
       echo 32153 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions

       echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
       echo $2/$3.mkv > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files


       echo
       echo INFO starting HandBrakeCLI

       (
       HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
       -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs$
       -a $AUDIO1,$AUDIO2 -A "Audio-1","Audio-2" -B auto,160 \
       -R auto,auto -6 auto,auto -E ac3,acc &
       ) > $OUT_TRANS 2>&1 &


       echo INFO HandBrakeCLI command executed
       echo

       sleep 10

       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

       echo
       echo INFO processing data pass 1 of 2
       echo

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         PASS1=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         PASS2=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS1" ] ; then 
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS1 -eq 99 ] ; then
               sleep 5
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress

               echo
               echo
               echo INFO processing data pass 1 of 2 done
               echo

               echo
               echo INFO processing data pass 2 of 2
               echo

               sleep 1
               echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
            fi
         fi

         if [ -n "$PASS2" ] ; then
            echo $PASS2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS2 -eq 98 ] ; then
               sleep 15
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
               echo
               echo
               echo INFO processing data pass 2 of 2 done
               echo
               LOOP=0
            fi
         fi
         sleep 0.7
       done
    fi
fi





####################################################################################
#                                                                                  #
#                       transcode job with 1 audio-track and 1 subtitle            #
#                                                                                  #
####################################################################################
if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-s ]] ; then
       AUDIO1=$(($5 + 1))

       echo $1 > $JOBFILE
       echo 3 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

       echo 32151 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
       echo 32152 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
       echo 32153 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions

       echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current


       echo
       echo INFO starting mencoder

       (
        mencoder dvd://$4 -dvd-device $1 -ovc frameno -nosound -o /dev/null -sid $7 -vobsubout $2/$3 &
       ) > $OUT_TRANS 2>&1 &

       echo INFO mencoder command executed
       echo

       sleep 1

       echo
       echo INFO processing data pass 1 of 3
       echo


       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep mencoder | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}') 

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         TMP=$(strings $OUT_TRANS | grep % | tail -1 | awk 'BEGIN{ RS="("; FS=")"} {print  $1}' | tr ' ' ',' | cut -d ',' -f2 | grep %)
         PASS1=$(echo $TMP | tr '%' ' ')
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS1 -eq 99 ] ; then
               sleep 5
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               sleep 2
               echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
               echo
               echo
               echo INFO processing data pass 1 of 3 done
               echo
               LOOP=0
            fi
         fi
         sleep 0.3
       done

       echo
       echo INFO starting HandBrakeCLI

       (
       HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
       -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=$
       -a $AUDIO1 -E ac3 &
       ) > $OUT_TRANS 2>&1 &

       echo INFO HandBrakeCLI command executed
       echo

       sleep 10

       echo
       echo INFO processing data pass 2 of 3
       echo

       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}')

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         PASS2=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         PASS3=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS2" ] ; then 
            echo $PASS2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS2 -eq 98 ] ; then
               sleep 5
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               sleep 1
               echo
               echo
               echo INFO processing data pass 2 of 3 done
               echo
               echo
               echo INFO processing data pass 3 of 3
               echo

               echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo 3 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
            fi
         fi
         if [ -n "$PASS3" ] ; then
            echo $PASS3 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS3 -eq 98 ] ; then
               sleep 3
               echo
               echo
               echo INFO processing data pass 3 of 3 done
               echo
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
               echo
               echo processing data done
               LOOP=0
            fi
         fi
         sleep 0.7
       done
    fi
fi




####################################################################################
#                                                                                  #
#                       transcode job with 2 audio-track and 1 subtitle            #
#                                                                                  #
####################################################################################
if [ $# -eq 9 ]; then
     AUDIO1=$(($5 +  1))
     AUDIO2=$(($7 +  1))

     echo $1 > $JOBFILE 
     echo 3 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

     echo 32151 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
     echo 32152 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
     echo 32153 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions

     echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current

     echo
     echo INFO starting mencoder

     (
      mencoder dvd://$4 -dvd-device $1 -ovc frameno -nosound -o /dev/null -sid $9 -vobsubout $2/$3 &
     ) > $OUT_TRANS 2>&1 &

     echo INFO mencoder command executed
     echo

     sleep 1

     echo
     echo INFO processing data pass 1 of 3
     echo

     echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
     ps axu | grep mencoder | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
     PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}')

     LOOP=1
     while [ $LOOP -eq '1'  ];
     do
       echo -n .
       TMP=$(strings $OUT_TRANS | grep % | tail -1 | awk 'BEGIN{ RS="("; FS=")"} {print  $1}' | tr ' ' ',' | cut -d ',' -f2 | grep %)
       PASS1=$(echo $TMP | tr '%' ' ')
       if [ -n "$PASS1" ] ; then
          echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
          if [ $PASS1 -eq 98 ] ; then
             sleep 10
             echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
             sleep 2
             echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
             echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
             echo
             echo
             echo INFO processing data pass 1 of 3 done
             echo
             LOOP=0
          fi
       fi
       sleep .3
     done

     echo
     echo INFO starting HandBrakeCLI

     (
     HandBrakeCLI -i $1 /dev/sr0 -o $2/$3.mkv -t $4 -f mkv -m -S 1200 -e x264 -2 \
     -T -x ref=3:mixed-refs:bframes=6:b-pyramid=1:bime=1:b-rdo=1:weightb=1:analyse=all:8x8dct=1:subme=6:me=um h:merange=24:filter=-2,-2:ref=6:mixed-refs=1:t$
     -a $AUDIO1,$AUDIO2 -A "Audio-1","Audio-2" -B auto,160 -R auto,auto -6 auto,dpl2 -E ac3,acc &
     ) > $OUT_TRANS 2>&1 &

     echo INFO HandBrakeCLI command executed
     echo

     echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
     ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
     PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

     sleep 10

     echo
     echo INFO processing data pass 2 of 3
     echo

     LOOP=1
     while [ $LOOP -eq '1'  ];
     do
       echo -n .
       PASS2=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
       PASS3=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "2 of 2" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
       if [ -n "$PASS2" ] ; then
          echo $PASS2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
          if [ $PASS2 -eq 99 ] ; then
               sleep 5
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               sleep 1
               echo
               echo
               echo INFO processing data pass 2 of 3 done
               echo
               echo
               echo INFO processing data pass 3 of 3
               echo
               echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo 3 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
          fi
       fi
       if [ -n "$PASS3" ] ; then
          echo $PASS3 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
          if [ $PASS3 -eq 98 ] ; then
               sleep 3
               echo
               echo
               echo INFO processing data pass 3 of 3 done
               echo
               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
               echo
               echo processing data done
               LOOP=0
          fi
       fi
       sleep 0.7
     done
fi

# Delete jobfile

rm $JOBFILE > /dev/null 2>&1


sleep 1
rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/* > /dev/null 2>&1

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit

