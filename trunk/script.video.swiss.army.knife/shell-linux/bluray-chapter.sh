#!/bin/bash
###########################################################
# scriptname : bluray_chapter.sh                          #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 user                                                 #
# description :                                           #
# Reads all chapters from inserted bluray                 #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using something other than /bin/bash.
   echo
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

# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes

E_BADARGS=1
E_TOOLNOTF=50
E_NOCHAPERS=3
E_VOLUMEERROR=4
E_TO_OLD=5

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/bluray-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI"
OUTPUT="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/bluray-chapter"


if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: bluray-chapter.sh p1"
  echo "                            "
  echo "[p1] device"
  echo "                            "
  echo "bluray-chapter.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi


# Define the commands we will be using inside the script ...

REQUIRED_TOOLS=`cat << EOF
awk
lynx
netstat
nohup
grep
sed
sleep
tr
tail
makemkvcon
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


rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/* >/dev/null 2>&1


if [ $1 == '/dev/sr0' ] ; then
   PARA="disc:0"
fi

if [ $1 == '/dev/sr1' ] ; then
   PARA="disc:1"
fi

if [ $1 == '/dev/sr2' ] ; then
   PARA="disc:2"
fi

#echo  "This application version is too old"

# We need the chapters (counting)

chapter=$(makemkvcon info $PARA | grep '^Title' | grep -v skipped | wc -l)

if [ $# -eq 0 ]; then
  echo
  echo ----------------------- script rc=3 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_NOCHAPERS
fi


# We do not like noise about terminated jobs
# But now it works like I would .......

(
makemkvcon --messages=/dev/null stream $PARA & >/dev/null 2>&1
) > $OUTPUT 2>&1

echo
echo "INFO generating track-list ... please be patient."
echo


# Wait until webserver is ready

LOOP=1
while [ $LOOP -eq '1'  ];
do
    SUCCESS=$(netstat -lt | grep 51000)
    if [ -n "$SUCCESS" ] ; then
        echo
        echo INFO webserver on port 51000 ready
        echo
        LOOP=0
    fi
done

lynx --dump  http://127.0.0.1:51000/web/titles > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/brmain.000
max=`expr $chapter - 1`
index=0
while [ $chapter -gt $index ]
do
      link="http://127.0.0.1:51000/web/title$index"
      lynx --dump $link > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/br$index.000
      index=`expr $index + 1`
done


kill -15 $(ps axu | grep makemkvcon | grep -v grep | awk '{print $2}') > /dev/null 2>&1


VOLNAME=$(cat ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/brmain.000 | grep name | tail -1 | awk '{print $2}' | tr -dc ‘[:alnum:]‘ )


echo $VOLNAME > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_VOLUME


Tindex=0


if [ -e ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP ] ; then
   rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP > /dev/null 2>&1
fi

if [ -e ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_TRACKS ] ; then
   rm ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_TRACKS  > /dev/null 2>&1
fi

echo
while [ $chapter -gt $Tindex ]
do
    TITLE=~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/br$Tindex.000
    duration=$(cat $TITLE | grep duration | awk '{print $2}')
    chaps=$(cat $TITLE | grep chaptercount | awk '{print $2}')

    echo INFO track-index:[$Tindex] length:[$duration] chapters:[$chaps]

    echo $duration $Tindex >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP

    echo track:[$Tindex] length:[$duration] chapters:[$chaps] >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_TRACKS
    Tindex=`expr $Tindex + 1`
done


LONGTRACK=$(cat $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP | sort -r | head -1 | awk '{print $2}')
LONGDURATION=$(cat $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP | sort -r | head -1 | awk '{print $1}')

echo
echo "INFO [track:[$LONGTRACK]  duration:[$LONGDURATION]]"
echo "INFO [volname:[$VOLNAME]]"
echo
echo $1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI
echo $LONGTRACK >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI
echo $LONGDURATION >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI
echo $VOLNAME >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0


