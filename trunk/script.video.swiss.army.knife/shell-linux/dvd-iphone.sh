#!/bin/bash
###########################################################
# scriptname : dvd-iphone.sh                              #
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
# generates a h264 container of a dvd for iPhone          #
###########################################################
SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"



###########################################################
#                                                         #
# Check that not user root is running this script         #
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/handbrake-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
JOBERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/iphone-transcode.log"
PWATCH="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/PWATCH"

SHELL_CANCEL=0
TERM_ALL="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/TERM_ALL"
KILL_FILES="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/KILL_FILES"
if [ -e $TERM_ALL ] ; then 
   rm $TERM_ALL > /dev/null 2>&1
fi

EXPECTED_ARGS=5
E_BADARGS=1
E_TOOLNOTF=50
E_TERMINATE=100
E_HANDBRAKE=253
E_SUID0=254
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
HandBrakeCLI
sed
tr
strings
sleep
mencoder
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
  echo "Usage: dvd-iphone.sh p1 p2 p3 p4 p5"
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
  echo "dvd-iphone.sh was called with wrong arguments"
  echo
  echo example :
  echo
  echo ./dvd-iphone.sh /dev/sr0 /dvdrip/portable/ip stargate 1 0 -a 1 -s 0
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

###########################################################




###########################################################
#                                                         #
# Cleanup a few files on startup of the script            #
#                                                         #
###########################################################

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR" ] ; then
    rm "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR" > /dev/null 2>&1
fi

if [ -e "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" ] ; then
    rm "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB" > /dev/null 2>&1
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
# transcode job with 1 audio-track                        #
#                                                         #
###########################################################

if [ $# -eq 5 ]; then
    AUDIO1=$(($5 +  1))

    echo $1 > $JOBFILE
    echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

    echo 32160 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions

    echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
    echo $2/$3.mp4 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files

    echo 
    echo INFO starting HandBrakeCLI

    (
     HandBrakeCLI -i $1 -o $2/$3.mp4 -t $4 -e x264 -q 20.0 -a $AUDIO1 -E faac -B 128 -6 dpl2 -R 48 -D 0.0 -f mp4 \
     -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0 &
    ) > $OUT_TRANS 2>&1 &

    echo INFO HandBrakeCLI command executed

    sleep 6

    PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}')
    echo $PID > $PWATCH

    if [ -z "$PID" ] ; then
       echo
       echo HandBrakeCLI is not running after 6 secounds. Please check your
       echo settings and log-files.
       echo
       exit $E_HANDBRAKE
    fi

    echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
    echo $PID >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
    echo $PID > $PWATCH 

    echo INFO transcode job with 1 audio-track
    echo INFO processing data pass 1 of 1
    echo

    LOOP=1
    while [ $LOOP -eq '1'  ];
    do
      echo -n .
      PASS1=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 1" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
      if [ -n "$PASS1" ] ; then
         echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
         if [ $PASS1 -eq 99 ] ; then

            LOOPP2=0
            while [ $LOOPP2 -eq '0' ];
            do
                PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}')
                echo -n .
                if [ -n "$PID" ] ; then
                   LOOPP2=1
                else
                   LOOPP2=0
                fi
                sleep 0.7
                if [ -e $TERM_ALL ] ; then 
                    SHELL_CANCEL=1 
                    break 
                fi
            done

            echo
            echo
            echo INFO processing data pass 1 of 1 done
            echo

            echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
            LOOP=0
         fi
      fi
      sleep 0.7
      if [ -e $TERM_ALL ] ; then 
         echo
         SHELL_CANCEL=1 
         LOOP=0
      fi 
    done
fi

###########################################################










###########################################################
#                                                         #
# transcode job with 2 audio-tracks                       #
#                                                         #
###########################################################

if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-a ]] ; then
       AUDIO1=$(($5 +  1))
       AUDIO2=$(($7 +  1))

       echo
       echo INFO transcode job with 2 audio-tracks

       echo $1 > $JOBFILE
       echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

       echo 32160 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions

       echo 1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
       echo $2/$3.mp4 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files

       echo
       echo INFO starting HandBrakeCLI

       (
        HandBrakeCLI -i $1 -o $2/$3.mp4 -t $4 -e x264 -q 20.0  -A "Audio-1","Audio-2" -a $AUDIO1,$AUDIO2 -E faac,faac -B 128 -6 dpl2 -R 48 -D 0.0 -f mp4 \
        -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0 &
       ) > $OUT_TRANS 2>&1 &

       echo INFO HandBrakeCLI command executed
       echo

       sleep 10

       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

       echo $PID > $PWATCH  

       echo
       echo INFO processing data pass 1 of 1
       echo

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         PASS1=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 1" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
            if [ $PASS1 -eq 99 ] ; then

               LOOPP2=0
               while [ $LOOPP2 -eq '0' ];
               do
                   PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}')
                   echo -n .
                   if [ -n "$PID" ] ; then
                      LOOPP2=1
                   else
                      LOOPP2=0
                   fi
                   sleep 0.7
               done

               echo
               echo
               echo INFO processing data pass 1 of 1 done
               echo

               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
               echo
               echo
               LOOP=0
            fi
         fi
         sleep 0.7
       done
    fi
fi

###########################################################




####################################################################################
#                                                                                  #
#                       transcode job with 1 audio-track and 1 subtitle            #
#                                                                                  #
####################################################################################
if [ $# -eq 7 ]; then
    if [[ "$6" =~ ^-s ]] ; then
       AUDIO1=$(($5 + 1))

       echo
       echo INFO transcode job with 1 audio-track and 1 subtitle

       echo $1 > $JOBFILE
       echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

       echo 32151 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
       echo 32160 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions


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
       echo INFO processing data pass 1 of 2
       echo


       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep mencoder | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}')

       echo $PID > $PWATCH  

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         TMP=$(strings $OUT_TRANS | grep % | tail -1 | awk 'BEGIN{ RS="("; FS=")"} {print  $1}' | tr ' ' ',' | cut -d ',' -f2 | grep %)
         PASS1=$(echo $TMP | tr '%' ' ')
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS1 -eq 99 ] ; then

               LOOPP2=0
               while [ $LOOPP2 -eq '0' ];
               do
                   PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}')
                   echo -n .
                   if [ -n "$PID" ] ; then
                     LOOPP2=1
                   else
                     LOOPP2=0
                   fi
                   sleep 0.7
               done

               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               sleep 2
               echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
               echo
               echo
               echo INFO processing data pass 1 of 2 done
               echo
               LOOP=0
            fi
         fi
         sleep 0.3
       done

       echo
       echo INFO starting HandBrakeCLI

       (
        HandBrakeCLI -i $1 -o $2/$3.mp4 -t $4 -e x264 -q 20.0 -a $AUDIO1 -E faac -B 128 -6 dpl2 -R 48 -D 0.0 -f mp4 \
        -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0 &
       ) > $OUT_TRANS 2>&1 &

       echo INFO HandBrakeCLI command executed
       echo

       sleep 10

       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

       echo $PID > $PWATCH  

       echo
       echo INFO processing data pass 2 of 2
       echo

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         PASS1=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 1" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
            if [ $PASS1 -eq 99 ] ; then

               LOOPP2=0
               while [ $LOOPP2 -eq '0' ];
               do
                   PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}')
                   echo -n .
                   if [ -n "$PID" ] ; then
                      LOOPP2=1
                   else
                      LOOPP2=0
                   fi
                   sleep 0.7
               done

               echo
               echo
               echo INFO processing data pass 2 of 2 done
               echo

               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
               echo
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
#                       transcode job with 2 audio-track and 1 subtitle            #
#                                                                                  #
####################################################################################
if [ $# -eq 9 ]; then
     AUDIO1=$(($5 +  1))
     AUDIO2=$(($7 +  1))

       echo
       echo INFO transcode job with 2 audio-tracks and 1 subtitle

       echo $1 > $JOBFILE
       echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter

       echo 32151 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions
       echo 32160 >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions


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
       echo INFO processing data pass 1 of 2
       echo


       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep mencoder | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}')

       echo $PID > $PWATCH  

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         TMP=$(strings $OUT_TRANS | grep % | tail -1 | awk 'BEGIN{ RS="("; FS=")"} {print  $1}' | tr ' ' ',' | cut -d ',' -f2 | grep %)
         PASS1=$(echo $TMP | tr '%' ' ')
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
            if [ $PASS1 -eq 99 ] ; then

               LOOPP2=0
               while [ $LOOPP2 -eq '0' ];
               do
                   PID=$(ps axu | grep mencoder | grep -v grep |awk '{print $2}')
                   echo -n .
                   if [ -n "$PID" ] ; then
                     LOOPP2=1
                   else
                     LOOPP2=0
                   fi
                   sleep 0.7
               done

               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               sleep 2
               echo 0 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo 2 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current
               echo
               echo
               echo INFO processing data pass 1 of 2 done
               echo
               LOOP=0
            fi
         fi
         sleep 0.3
       done

       echo
       echo INFO starting HandBrakeCLI

       (
        HandBrakeCLI -i $1 -o $2/$3.mp4 -t $4 -e x264 -q 20.0  -A "Audio-1","Audio-2" -a $AUDIO1,$AUDIO2 -E faac,faac -B 128 -6 dpl2 -R 48 -D 0.0 -f mp4 \
        -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0 &
       ) > $OUT_TRANS 2>&1 &

       echo INFO HandBrakeCLI command executed
       echo

       sleep 10

       echo $$ > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}' >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid
       PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}') 

       echo $PID > $PWATCH 

       echo
       echo INFO processing data pass 2 of 2
       echo

       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .
         PASS1=$(strings $OUT_TRANS | tail -1 | grep Encoding | grep "1 of 1" | tail -1 | awk '{print $6}' | cut -d '.' -f1 )
         if [ -n "$PASS1" ] ; then
            echo $PASS1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress 
            if [ $PASS1 -eq 99 ] ; then

               LOOPP2=0
               while [ $LOOPP2 -eq '0' ];
               do
                   PID=$(ps axu | grep HandBrakeCLI | grep -v grep |awk '{print $2}')
                   echo -n .
                   if [ -n "$PID" ] ; then
                      LOOPP2=1
                   else
                      LOOPP2=0
                   fi
                   sleep 0.7
               done

               echo
               echo
               echo INFO processing data pass 2 of 2 done
               echo

               echo 100 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress
               echo DONE > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done
               echo
               echo
               LOOP=0
            fi
         fi
         sleep 0.7
       done
fi












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
   echo ----------------------- script rc=0 -----------------------------
   echo -----------------------------------------------------------------

   exit 0

else

   echo
   echo INFO processing task have ben killed or ended unexpected !!! 
   echo

   # ups ... something was going very wrong    
   # we only erase file depend on the setttings of the addon

   if [ -e $KILL_FILES ] ; then
      rm $2/$3.mkv > /dev/null 2>&1

      # In the case we have a subtitle-file it will also be deleted ...

      rm $2/$3.idx > /dev/null 2>&1 
      rm $2/$3.sub > /dev/null 2>&1 
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

