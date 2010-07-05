#!/bin/bash
###########################################################
# scriptname : dvd-chapter.sh                             #
###########################################################
# RELEASE 0.6C swiss-army-knife                           #
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 device                                               #
# description :                                           #
# Reads all chapters from inserted dvd                    #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"


echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------

# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2
E_NOCHAPERS=3
E_VOLUMEERROR=4

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/bluray-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script-video-ripper/media/BR_GUI"

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-chapter.sh p1"
  echo "                            "
  echo "[p1] device"
  echo "                            "
  echo "dvd-chapter.sh was called with wrong arguments" > $OUTPUT_ERROR
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
awk
nohup
grep
sed
sleep
tr
tail
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

echo ----------------
echo Clean temp files
echo ----------------

rm $HOME/.xbmc/userdata/addon_data/script-video-ripper/bluray/* >/dev/null 2>&1


echo ---------------
echo Toolchain found
echo ---------------



if [ $1 == '/dev/sr0' ] ; then
   PARA="disc:0"
fi

if [ $1 == '/dev/sr1' ] ; then
   PARA="disc:1"
fi

if [ $1 == '/dev/sr2' ] ; then
   PARA="disc:2"
fi


echo ---------------------------------
echo parameter for transcoder : $PARA
echo ---------------------------------


# We need the chapters (counting)

chapter=$(makemkvcon info $PARA | grep '^Title' | grep -v skipped | wc -l)

if [ $# -eq 0 ]; then
  echo -------------------
  echo "No Chapters found"
  echo -------------------
  echo
  exit $E_NOCHAPERS
fi

echo ----------------------
echo found $chapter Titles
echo ----------------------

echo -----------------------------------
echo starting makemkvcon in stream-mode
echo -----------------------------------

nohup makemkvcon --messages=/dev/null stream $PARA & >/dev/null 2>&1

echo -----------------------------------------
echo wait 40 secounds until webserver is ready
echo -----------------------------------------
sleep 40.0

lynx --dump  http://127.0.0.1:51000/web/titles > ~/.xbmc/userdata/addon_data/script-video-ripper/bluray/brmain.000
echo --------------------------------------
echo get titel info with the http-protocoll
echo --------------------------------------
max=`expr $chapter - 1`
index=0
while [ $chapter -gt $index ]
do
      link="http://127.0.0.1:51000/web/title$index"
      lynx --dump $link > ~/.xbmc/userdata/addon_data/script-video-ripper/bluray/br$index.000
      index=`expr $index + 1`
done

echo -----------------------------------------
echo Kill webserver
echo -----------------------------------------

kill -15 $(ps axu | grep makemkvcon | grep -v grep | awk '{print $2}') > /dev/null 2>&1


echo -----------------------------------------
echo get bluray volume-name
echo -----------------------------------------

VOLNAME=$(cat ~/.xbmc/userdata/addon_data/script-video-ripper/bluray/brmain.000 | grep name | tail -1 | awk '{print $2}' | tr -dc ‘[:alnum:]‘ )


echo -----------------------------------------
echo Volume-Name of bluray :[$VOLNAME]
echo $VOLNAME > ~/.xbmc/userdata/addon_data/script-video-ripper/bluray/BR_VOLUME
echo -----------------------------------------


Tindex=0
echo ------------------------------
echo Generate track-list for script
echo ------------------------------

while [ $chapter -gt $Tindex ]
do
    TITLE=~/.xbmc/userdata/addon_data/script-video-ripper/bluray/br$Tindex.000
    duration=$(cat $TITLE | grep duration | awk '{print $2}')
    chaps=$(cat $TITLE | grep chaptercount | awk '{print $2}')
    echo track:[$Tindex] length:[$duration] chapters:[$chaps]

    # We need a list to prepare for the GUI with other options

    echo $duration $Tindex >> ~/.xbmc/userdata/addon_data/script-video-ripper/media/BR_HELP

    echo track:[$Tindex] length:[$duration] chapters:[$chaps] >> ~/.xbmc/userdata/addon_data/script-video-ripper/bluray/BR_TRACKS
    Tindex=`expr $Tindex + 1`
done


echo ------------------------------
echo Generate Info GUI-Exec List
echo ------------------------------

LONGTRACK=$(cat $HOME/.xbmc/userdata/addon_data/script-video-ripper/media/BR_HELP | sort -r | head -1 | awk '{print $2}')
LONGDURATION=$(cat $HOME/.xbmc/userdata/addon_data/script-video-ripper/media/BR_HELP | sort -r | head -1 | awk '{print $1}')

echo $LONGTRACK >> ~/.xbmc/userdata/addon_data/script-video-ripper/media/BR_GUI
echo $LONGDURATION >> ~/.xbmc/userdata/addon_data/script-video-ripper/media/BR_GUI
echo $VOLNAME >> ~/.xbmc/userdata/addon_data/script-video-ripper/media/BR_GUI

echo --------------
echo all jobs done
echo --------------


exit 0


