#!/bin/bash
###########################################################
# scriptname : dvd-chapter.sh                             #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# $2 auto-mode                                            #
# description :                                           #
# Reads all chapters from inserted dvd                    #
# - 1. List contains all video-tracks                     #
# - 2. Every track has a own audio-list                   #
# - 3. Every track has a own subtitle-list                #
###########################################################


SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

if [ $SHELL -ne "/bin/bash" ] ; then
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using somehting other than /bin/bash.
   echo
   exit 255
fi

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------


# Define the counting commands we expect inside the script

EXPECTED_ARGS=2

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2
E_NOCHAPERS=3
E_VOLUMEERROR=4
E_AUDIO1_ERROR=5
E_AUDIO2_ERROR=6
E_SUB_ERROR=7

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/dvd-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/DVD_GUI"

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-chapter.sh p1 p2"
  echo "                            "
  echo "[p1] device"
  echo "[p2] auto-mode 0 or 1"
  echo "                            "
  echo "dvd-chapter.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
lsdvd
volname
awk
cut
sed
tr
tail
EOF`


# Check if all commands are found on your system ...

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
        echo ----------------------- script rc=2 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi
done


rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/* >/dev/null 2>&1


VOLNAME=$(volname $1 | tr -dc ‘[:alnum:]‘)

echo $VOLNAME > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/DVD_VOLUME

lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | cut -d: -f1 >  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdh
lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | cut -d: -f2 >  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdm
lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | cut -d: -f3 >  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvds
lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $6}' | sed  's/,//g' > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdc

chapter=$(lsdvd -v $1 2>/dev/null | grep ^Title | awk  '{print $4}' | wc -l)


index=0
track=0

echo
while read HOUR
do
  index=`expr $index + 1`

  MIN=$(head -$index ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdm | tail -1)
  SEC=$(head -$index ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvds | tail -1)
  CAP=$(head -$index ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdc | tail -1)

  if [ $track -lt 10 ] ; then
     echo INFO track-index:[0$track] length:[$HOUR:$MIN:$SEC] chapters:[$CAP]
     echo track:[0$track] length:[$HOUR:$MIN:$SEC] chapters:[$CAP] >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/DVD_TRACKS
  fi
  if [ $track -gt 9 ] ; then
     echo INFO track-index:[$track] length:[$HOUR:$MIN:$SEC] chapters:[$CAP]
     echo track:[$track] length:[$HOUR:$MIN:$SEC] chapters:[$CAP] >>  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/DVD_TRACKS
  fi
  track=`expr $track + 1`
done < ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdh
echo


if [ $2 -eq "1" ] ; then

     # Automode is activ

     AUTO_SELECT_TRACK=$(lsdvd -v 2>/dev/null | grep "Longest" | awk '{print $3}')
     echo

     echo INFO volume-name of the current inserted dvd is [$VOLNAME]
     echo INFO automatic selected track from inserted dvd [$AUTO_SELECT_TRACK][line-index]


     if [ -e  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG1 ] ; then
         LANG1=$(cat  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG1)
         echo INFO default language 1 [$LANG1]
         LANG1_SELECT=$(lsdvd -a -t $AUTO_SELECT_TRACK 2>/dev/null | grep "Language" | grep -m 1 -n " $LANG1 " | awk '{print $3}' | tr -dc ‘[:digit:]‘)
         if [ -z "$LANG1_SELECT" ] ; then
            echo INFO default language 1 [$LANG1] not found inside track [$AUTO_SELECT_TRACK]
            echo INFO default language 1 [$LANG1] not found inside track [$AUTO_SELECT_TRACK] > $OUTPUT_ERROR
            echo
            echo ----------------------- script rc=5 -----------------------------
            echo -----------------------------------------------------------------
            exit $E_AUDIO1_ERROR
         fi

         if [ -n "$LANG1_SELECT" ] ; then
            LANG1_SELECT=`expr $LANG1_SELECT - 1`
         fi
     fi

     if [ -e  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG2 ] ; then
         LANG2=$(cat  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG2)
         echo INFO default language 2 [$LANG2]
         LANG2_SELECT=$(lsdvd -a -t $AUTO_SELECT_TRACK 2>/dev/null | grep "Language" | grep -m 1 -n " $LANG2 " | awk '{print $3}' | tr -dc ‘[:digit:]‘)
         if [ -z "$LANG2_SELECT" ] ; then
            echo INFO default language 1 [$LANG2] not found inside track [$AUTO_SELECT_TRACK]
            echo INFO default language 1 [$LANG2] not found inside track [$AUTO_SELECT_TRACK] > $OUTPUT_ERROR
            echo
            echo ----------------------- script rc=6 -----------------------------
            echo -----------------------------------------------------------------
            exit $E_AUDIO2_ERROR
         fi

         if [ -n "$LANG2_SELECT" ] ; then
            LANG2_SELECT=`expr $LANG2_SELECT - 1`
         fi
     fi

     if [ -e  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_SUB ] ; then
         SUB1=$(cat  ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_SUB)
         echo INFO default subtitle [$SUB1]
         SUB1_SELECT=$(lsdvd -s -t $AUTO_SELECT_TRACK 2>/dev/null |  grep -n -m 1  " $SUB1 " | awk '{print $3}' | tr -dc ‘[:digit:]‘)
         if [ -z "$SUB1_SELECT" ] ; then
            echo INFO default subtitle [$SUB1] not found inside track [$AUTO_SELECT_TRACK]
            echo INFO default subtitle [$SUB1] not found inside track [$AUTO_SELECT_TRACK] > $OUTPUT_ERROR
            echo
            echo ----------------------- script rc=7 -----------------------------
            echo -----------------------------------------------------------------
            exit $E_SUB_ERROR
         fi

         if [ -n "$SUB1_SELECT" ] ; then
            SUB1_SELECT=`expr $SUB1_SELECT - 1`
         fi
     fi

     echo $1 > $GUI_RETURN
     echo $VOLNAME >> $GUI_RETURN
     echo $AUTO_SELECT_TRACK >> $GUI_RETURN

     if [ -n "$LANG1_SELECT" ] ; then
        echo "INFO default lang-1 :" index=$LANG1_SELECT
        echo $LANG1_SELECT >> $GUI_RETURN
     fi

     if [ -z "$LANG1_SELECT" ] ; then
        echo none >> $GUI_RETURN
     fi

     if [ -n "$LANG2_SELECT" ] ; then
        echo "INFO default lang-2 :" index=$LANG2_SELECT
        echo $LANG2_SELECT >> $GUI_RETURN
     fi

     if [ -z "$LANG2_SELECT" ] ; then
        echo none >> $GUI_RETURN
     fi

     # Warning : do not send <LF> after the last parameter 
     # or the python reads a line to much ...

     if [ -n "$SUB1_SELECT" ] ; then
        echo "INFO default sub    :" index=$SUB1_SELECT
        echo -n $SUB1_SELECT >> $GUI_RETURN
     fi

     if [ -z "$SUB1_SELECT" ] ; then
        echo -n none >> $GUI_RETURN
     fi

     echo
     echo ----------------------- script rc=0 -----------------------------
     echo -----------------------------------------------------------------
     exit 0

fi



if [ $2 -eq "0" ] ; then

     echo automode is inactive
fi



aindex=0
atrack=0

while read HOUR
do
  aindex=`expr $aindex + 1`


  # echo $atrack $aindex

  TMP=$(lsdvd -a -t $aindex 2>/dev/null | grep Audio: > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/chap)
  AUDIOS=$(cat ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/chap | wc -l)

  atrack=`expr $atrack + 1`

  cat ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/chap > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/dvd/DVD_A$atrack

done < ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdh


aindex=0
atrack=0

while read HOUR
do
  aindex=`expr $aindex + 1`

  #   echo $atrack $aindex

  TMP=$(lsdvd -s -t $aindex 2>/dev/null | grep Subtitle: > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/chap)
  STITLES=$(cat ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/chap | wc -l)

  atrack=`expr $atrack + 1`

  cat ~/.xbmc/userdata/addon_data/script-video-ripper/tmp/chap > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/dvd/DVD_S$atrack

done < ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp/dvdh

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

