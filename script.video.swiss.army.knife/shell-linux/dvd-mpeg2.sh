#!/bin/bash
###########################################################
# scriptname : dvd-mpeg2.sh                               #
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
# generates a native mpeg2 of a dvd                       #
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

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/transcode-error.log"
JOBFILE="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB"
JOBERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB.ERROR"
OUT_TRANS="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd-mpeg2.log"

# Define the counting commands we expect inside the script

EXPECTED_ARGS=5

# Error-codes

E_BADARGS=1
E_TOOLNOTF=50

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-mpeg2.sh p1 p2 p3 p4 p5"
  echo "                                      "
  echo "[p1] device or complet path to ripfile"
  echo "[p2] directory for rip"
  echo "[p3] export-name (excluding mpg)"
  echo "[p4] chapter to extract [1-X]"
  echo "[p5] audio channel to extract [0-X]"
  echo "The above paramters p1-p5 are allways needet"
  echo "                                            "
  echo "There are 2 addional parameters to pass to the script"
  echo "                                            "
  echo "p6,7  second audio-track   -a 3 [0-X]"
  echo "p8,9  subtitle             -s 0 [0-X]"
  echo
  echo "dvd-mpeg2.sh was called with wrong arguments"
  echo
  echo example :
  echo
  echo ./dvd-mpeg2.sh /dev/sr0 /dvdrip/dvd stargate 1 0 -a 1 -s 0
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
cut
echo
grep
head
lsdvd
mencoder
mplayer
mkfifo
mktemp
mplex
mv
rm
sed
stat
tccat
tcextract
transcode
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




####################################################################################
#                                                                                  #
#                       Delete output                                              #
#                                                                                  #
####################################################################################
cd $2 > /dev/null 2> $OUTPUT_ERROR
if [ -e "$3.mpg" ] ; then
   rm $3.mpg > /dev/null 2>&1
fi


####################################################################################
#                                                                                  #
#                       Create temporary directory and break css                   #
#                                                                                  #
####################################################################################

temp_file=$$
mkdir $temp_file 2> $OUTPUT_ERROR
cd $temp_file 2> $OUTPUT_ERROR
lsdvd -a $1 1>/dev/null 2>&1




####################################################################################
#                                                                                  #
#                       transcode job with 1 audio-track                           #
#                                                                                  #
####################################################################################

if [ $# -eq $EXPECTED_ARGS ]; then

     # Get the DVD name and video properties with lsdvd

     DVD_INFO=`mktemp`
     lsdvd -x $1 > ${DVD_INFO} 2>/dev/null

     if [ $4 -lt 10 ] ; then
         DVD_TITLE=0$4
     else
         DVD_TITLE=$4
     fi


     DVD_NAME=`grep "Disc Title:" ${DVD_INFO} | cut -f2 -d':' | sed 's/ //g'`

     TITLE_INFO=`mktemp`
     lsdvd -x -t ${DVD_TITLE} $1 > ${TITLE_INFO} 2>/dev/null

     # Video format, PAL or NTSC

     VIDEO_FORMAT=`grep "VTS: ${DVD_TITLE}" ${DVD_INFO} | cut -d':' -f5 | cut -d',' -f1 | sed 's/ //g' | tr [A-Z] [a-z]`

     # Video aspect ratio, 4:3 or 16:9

     VIDEO_AR=`grep "VTS: ${DVD_TITLE}" ${DVD_INFO} | cut -d':' -f6 | cut -d',' -f1 | sed 's/ //g' | sed 's-/-:-g'`

     # What are the widescreen options.

     VIDEO_DF=`grep "VTS: ${DVD_TITLE}" ${DVD_INFO} | cut -d':' -f9 | cut -d',' -f1 | sed 's/ //g'`

     # Get some useful information from mplayer and store it in a temp file

     STREAM_INFO=`mktemp`
     mplayer -quiet -nojoystick -nolirc -dvd-device $1 dvd://${DVD_TITLE} -vo null -ao null -frames 0 -identify > ${STREAM_INFO} 2>/dev/null

     # make it mplayer compatible.

     DVD_TITLE=`echo ${DVD_TITLE} | sed 's/0//'`

     # Get the first video track

     VIDEO_TRACK=`grep "ID_VIDEO_ID" ${STREAM_INFO} | head -n1 | cut -d'=' -f2`
     VIDEO_WIDTH=`grep "ID_VIDEO_WIDTH" ${STREAM_INFO} | cut -d'=' -f2`
     VIDEO_HEIGHT=`grep "ID_VIDEO_HEIGHT" ${STREAM_INFO} | cut -d'=' -f2`

     # Get the last audio track id (MPEG) format then convert it the to numeric format.

     AUDIO_TRACK=`grep "ID_AUDIO_ID" ${STREAM_INFO} | tail -n1 | cut -d'=' -f2`
     AUDIO_TRACK=`grep "aid: ${AUDIO_TRACK}" ${STREAM_INFO} | cut -d' ' -f3 | sed 's/ //g'`

     AUDIO_TRACK_USER=$5

     # Validate the audio track

     AUDIO_TRACK_VALIDATE=`grep "audio stream: ${AUDIO_TRACK_USER}" ${STREAM_INFO}`

     # Is the user selected audio track valid

     if [ -n "${AUDIO_TRACK_VALIDATE}" ] && [ -n "${AUDIO_TRACK_USER}" ]; then

          # audio is valid

          AUDIO_TRACK=${AUDIO_TRACK_USER}
          AUDIO_TRACK_DETAILS=`grep "audio stream: ${AUDIO_TRACK_USER}" ${STREAM_INFO}`
     else

          # invalid audio track

          AUDIO_TRACK_DETAILS=`grep "audio stream: ${AUDIO_TRACK}" ${STREAM_INFO}` > $OUTPUT_ERROR
          echo "Using ${AUDIO_TRACK_DETAILS}" > $OUTPUT_ERROR
          exit $E_INVALID_AUDIO
     fi

     # Get the format of the select audio track ...

     AUDIO_FORMAT=`grep "audio stream: ${AUDIO_TRACK}" ${STREAM_INFO} | cut -d':' -f3 | cut -d'(' -f1 | sed 's/ //g'`
     AUDIO_LANG=`grep "audio stream: ${AUDIO_TRACK}" ${STREAM_INFO} | cut -d':' -f4 | cut -d' ' -f2 | sed 's/ //g'`

     # Change lpcm to pcm
     if [ "${AUDIO_FORMAT}" == "lpcm" ]; then
           AUDIO_FORMAT="pcm"
     fi

     # Get chapter and angle details

     DVD_TITLE_CHAPTERS=`grep ID_DVD_TITLE_${DVD_TITLE}_CHAPTERS} ${STREAM_INFO} | cut -d'=' -f2`
     DVD_TITLE_ANGLES=`grep ID_DVD_TITLE_${DVD_TITLE}_ANGLES ${STREAM_INFO} | cut -d'=' -f2`
     DVD_TITLE_CHAPTER_POINTS=`grep CHAPTERS: ${STREAM_INFO} | sed 's/CHAPTERS: //' | sed 's/,$//'`

     # Remove temp files

     rm ${DVD_INFO} > /dev/null 2>&1
     rm ${TITLE_INFO} > /dev/null 2>&1
     rm ${STREAM_INFO} > /dev/null 2>&1

     # Setup some variables

     AUDIO_FILE=${DVD_NAME}.${AUDIO_FORMAT}
     VIDEO_FILE=${DVD_NAME}.m2v
     MPLEX_FILE=$3.mpg

     AUDIO_FIFO=`mktemp`
     VIDEO_FIFO=`mktemp`
     MPLEX_FIFO=`mktemp`

     # Create the FIFOs

     rm ${AUDIO_FIFO} ${VIDEO_FIFO} ${MPLEX_FIFO} > /dev/null 2>&1

     echo
     echo INFO create fifo for communication

     mkfifo ${AUDIO_FIFO} > /dev/null 2>&1
     mkfifo ${VIDEO_FIFO} > /dev/null 2>&1
     mkfifo ${MPLEX_FIFO} > /dev/null 2>&1

     echo INFO fifo created
     echo

     # Get audio 01 over fifo

     echo INFO extract audio language [$5] from track [$4]
     tcextract -i ${AUDIO_FIFO} -a ${AUDIO_TRACK} -t vob -x ${AUDIO_FORMAT} > ${AUDIO_FILE} &
     echo INFO background process started ....

     # Get video over fifo

     echo
     echo INFO extract video track [$4]
     tcextract -i ${VIDEO_FIFO} -a ${VIDEO_TRACK} -t vob -x mpeg2 > ${VIDEO_FILE} &
     echo INFO background process started ....

     # Start transcode and send output to fifo

     echo
     echo INFO starting transcode

     (
      tccat -i $1 -T ${DVD_TITLE},-1,${DVD_TITLE_ANGLE} -P -d 0 | tee ${AUDIO_FIFO} ${VIDEO_FIFO} &
     ) > $OUT_TRANS 2>&1 &

     echo INFO background process started ....


     echo INFO processing data
     echo
     LOOP=1
     while [ $LOOP -eq '1'  ];
     do
       echo -n .

       sleep 15

       # Stay inside loop until tccat is finished

       PID1=$(ps axu | grep "tccat \-i" | grep -v grep | awk '{print $2}')
       if [ -z "$PID1" ] ; then
          LOOP=0
          echo
          echo
          echo INFO processing data done
          echo
       fi
     done


     echo
     echo INFO starting mplex

     (
      mplex -M -f 8 -o ${MPLEX_FILE} ${VIDEO_FILE} ${AUDIO_FILE} &
     ) > $OUT_TRANS 2>&1 &

     echo INFO background process started ....
     echo INFO processing data
     echo
     LOOP=1
     while [ $LOOP -eq '1'  ];
     do
       echo -n .

       sleep 1

       # Stay inside loop until tccat is finished

       PID1=$(ps axu | grep "mplex \-M" | grep -v grep | awk '{print $2}')
       if [ -z "$PID1" ] ; then
          LOOP=0
          echo
          echo
          echo INFO processing data done
          echo
       fi
     done

     # Clean-up files

     rm ${AUDIO_FILE} 2>/dev/null
     rm ${VIDEO_FILE} 2>/dev/null

     mv ${MPLEX_FILE} ../${MPLEX_FILE} 2>/dev/null
     rm ${AUDIO_FIFO} ${VIDEO_FIFO} ${MPLEX_FIFO} 2>/dev/null

     cd ..

     # We remove the complet directory path that we created
     # and we leave only the generated mpeg2

     rm -rf $temp_file 2> $OUTPUT_ERROR

     exit 0
fi




if [ $# -eq 7 ]; then


    ####################################################################################
    #                                                                                  #
    #                       transcode job with 2 audio-tracks                          #
    #                                                                                  #
    ####################################################################################
    if [[ "$6" =~ ^-a ]] ; then

       # Get the DVD name and video properties with lsdvd

       DVD_INFO=`mktemp`
       lsdvd -x $1 > ${DVD_INFO} 2>/dev/null

       if [ $4 -lt 10 ] ; then
          DVD_TITLE=0$4
       else
          DVD_TITLE=$4
       fi

       DVD_NAME=`grep "Disc Title:" ${DVD_INFO} | cut -f2 -d':' | sed 's/ //g'`

       TITLE_INFO=`mktemp`
       lsdvd -x -t ${DVD_TITLE} $1 > ${TITLE_INFO} 2>/dev/null

       # Video format, PAL or NTSC

       VIDEO_FORMAT=`grep "VTS: ${DVD_TITLE}" ${DVD_INFO} | cut -d':' -f5 | cut -d',' -f1 | sed 's/ //g' | tr [A-Z] [a-z]`

       # Video aspect ratio, 4:3 or 16:9

       VIDEO_AR=`grep "VTS: ${DVD_TITLE}" ${DVD_INFO} | cut -d':' -f6 | cut -d',' -f1 | sed 's/ //g' | sed 's-/-:-g'`

       # What are the widescreen options.

       VIDEO_DF=`grep "VTS: ${DVD_TITLE}" ${DVD_INFO} | cut -d':' -f9 | cut -d',' -f1 | sed 's/ //g'`

       # Get some useful information from mplayer and store it in a temp file

       STREAM_INFO=`mktemp`
       mplayer -quiet -nojoystick -nolirc -dvd-device $1 dvd://${DVD_TITLE} -vo null -ao null -frames 0 -identify > ${STREAM_INFO} 2>/dev/null

       # make it mplayer compatible.

       DVD_TITLE=`echo ${DVD_TITLE} | sed 's/0//'`

       # Get the first video track

       VIDEO_TRACK=`grep "ID_VIDEO_ID" ${STREAM_INFO} | head -n1 | cut -d'=' -f2`
       VIDEO_WIDTH=`grep "ID_VIDEO_WIDTH" ${STREAM_INFO} | cut -d'=' -f2`
       VIDEO_HEIGHT=`grep "ID_VIDEO_HEIGHT" ${STREAM_INFO} | cut -d'=' -f2`

       # Get the last audio track id (MPEG) format then convert it the to numeric format.

       AUDIO_TRACK=`grep "ID_AUDIO_ID" ${STREAM_INFO} | tail -n1 | cut -d'=' -f2`
       AUDIO_TRACK=`grep "aid: ${AUDIO_TRACK}" ${STREAM_INFO} | cut -d' ' -f3 | sed 's/ //g'`

       AUDIO_TRACK_USER=$5

       # Validate the audio track

       AUDIO_TRACK_VALIDATE=`grep "audio stream: ${AUDIO_TRACK_USER}" ${STREAM_INFO}`

       # Is the user selected audio track valid

       if [ -n "${AUDIO_TRACK_VALIDATE}" ] && [ -n "${AUDIO_TRACK_USER}" ]; then

          # audio is valid

          AUDIO_TRACK=${AUDIO_TRACK_USER}
          AUDIO_TRACK_DETAILS=`grep "audio stream: ${AUDIO_TRACK_USER}" ${STREAM_INFO}`

       else

          # invalid audio track

          AUDIO_TRACK_DETAILS=`grep "audio stream: ${AUDIO_TRACK}" ${STREAM_INFO}` > $OUTPUT_ERROR
          echo "Using ${AUDIO_TRACK_DETAILS}" > $OUTPUT_ERROR
          exit $E_INVALID_AUDIO

       fi

       # Get the format of the select audio track ...

       AUDIO_FORMAT=`grep "audio stream: ${AUDIO_TRACK}" ${STREAM_INFO} | cut -d':' -f3 | cut -d'(' -f1 | sed 's/ //g'`
       AUDIO_LANG=`grep "audio stream: ${AUDIO_TRACK}" ${STREAM_INFO} | cut -d':' -f4 | cut -d' ' -f2 | sed 's/ //g'`

       # Change lpcm to pcm

       if [ "${AUDIO_FORMAT}" == "lpcm" ]; then
           AUDIO_FORMAT="pcm"
       fi

       # Get chapter and angle details

       DVD_TITLE_CHAPTERS=`grep ID_DVD_TITLE_${DVD_TITLE}_CHAPTERS} ${STREAM_INFO} | cut -d'=' -f2`
       DVD_TITLE_ANGLES=`grep ID_DVD_TITLE_${DVD_TITLE}_ANGLES ${STREAM_INFO} | cut -d'=' -f2`
       DVD_TITLE_CHAPTER_POINTS=`grep CHAPTERS: ${STREAM_INFO} | sed 's/CHAPTERS: //' | sed 's/,$//'`

       # Remove temp files

       rm ${DVD_INFO} > /dev/null 2>&1
       rm ${TITLE_INFO} > /dev/null 2>&1
       rm ${STREAM_INFO} > /dev/null 2>&1

       # Setup some variables

       AUDIO_FILE=${DVD_NAME}.${AUDIO_FORMAT}
       VIDEO_FILE=${DVD_NAME}.m2v
       MPLEX_FILE=$3.mpg

       AUDIO_FIFO=`mktemp`
       VIDEO_FIFO=`mktemp`
       MPLEX_FIFO=`mktemp`

       # Create the FIFOs

       rm ${AUDIO_FIFO} ${VIDEO_FIFO} ${MPLEX_FIFO} > /dev/null 2>&1

       echo
       echo INFO create fifo for communication

       mkfifo ${AUDIO_FIFO} > /dev/null 2>&1
       mkfifo ${VIDEO_FIFO} > /dev/null 2>&1
       mkfifo ${MPLEX_FIFO} > /dev/null 2>&1

       echo INFO fifo created
       echo

       # Get audio 01 over fifo

       echo INFO extract audio language [$5] from track [$4]
       tcextract -i ${AUDIO_FIFO} -a ${AUDIO_TRACK} -t vob -x ${AUDIO_FORMAT} > ${AUDIO_FILE} &
       echo INFO background process started ....

       # Get video over fifo

       echo
       echo INFO extract video track [$4]
       tcextract -i ${VIDEO_FIFO} -a ${VIDEO_TRACK} -t vob -x mpeg2 > ${VIDEO_FILE} &
       echo INFO background process started ....

       # Start transcode and send output to fifo

       echo
       echo INFO starting transcode

       (
        tccat -i $1 -T ${DVD_TITLE},-1,${DVD_TITLE_ANGLE} -P -d 0 | tee ${AUDIO_FIFO} ${VIDEO_FIFO} &
       ) > $OUT_TRANS 2>&1 &

       echo INFO background process started ....

       echo INFO processing data
       echo
       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .

         sleep 15

         # Stay inside loop until tccat is finished

         PID1=$(ps axu | grep "tccat \-i" | grep -v grep | awk '{print $2}')
         if [ -z "$PID1" ] ; then
            LOOP=0
            echo
            echo
            echo INFO processing data done
            echo
         fi
       done

       echo
       echo INFO starting mplex

       (
        mplex -M -f 8 -o ${MPLEX_FILE} ${VIDEO_FILE} ${AUDIO_FILE} &
       ) > $OUT_TRANS 2>&1 &

       echo INFO background process started ....
       echo INFO processing data
       echo
       LOOP=1
       while [ $LOOP -eq '1'  ];
       do
         echo -n .

         sleep 1

         # Stay inside loop until tccat is finished

         PID1=$(ps axu | grep "mplex \-M" | grep -v grep | awk '{print $2}')
         if [ -z "$PID1" ] ; then
            LOOP=0
            echo
            echo
            echo INFO processing data done
            echo
         fi
       done

       # Clean-up files

       rm ${AUDIO_FILE} 2>/dev/null
       rm ${VIDEO_FILE} 2>/dev/null

       mv ${MPLEX_FILE} ../${MPLEX_FILE} 2>/dev/null
       rm ${AUDIO_FIFO} ${VIDEO_FIFO} ${MPLEX_FIFO} 2>/dev/null

       cd ..

       # We remove the complet directory path that we created
       # and we leave only the generated mpeg2

       rm -rf $temp_file 2> $OUTPUT_ERROR

       exit 0
    fi


    ####################################################################################
    #                                                                                  #
    #                       transcode job with 1 audio and 1 subttitle                 #
    #                                                                                  #
    ####################################################################################

    if [[ "$6" =~ ^-s ]] ; then
       echo 1
    fi        
fi


if [ $# -eq 9 ] ; then
    echo all 
fi

exit


 








