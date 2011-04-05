#!/bin/bash
###########################################################
# scriptname : dvd-chapter-mkv.sh                         #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 user                                                 #
# description :                                           #
# Reads all chapters from inserted dvd                    #
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
echo "copyright : (C) <2010-2011>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
if [ -z "$1" ] ; then
   echo no parameters to script detected
else
   if [ -f $1 ] ; then
      echo scipt is using a iso-file as source [$1]
   else
      echo scipt is using a device as source [$1]
   fi
fi
echo ----------------------------------------------------------------------------

###########################################################



###########################################################
#                                                         #
# Definition of files and internal variables              #
#                                                         #
###########################################################

OUTPUT_ERROR="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/bluray-error.log"
GUI_RETURN="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI"
OUTPUT="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp/bluray-chapter"

ZERO=0
EXPECTED_ARGS=1
E_BADARGS=1
E_NOCHAPTERS=3
E_VOLUMEERROR=4
E_WEBERROR=5
E_TOOLNOTF=50
E_SUID0=254
E_WRONG_SHELL=255

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

###########################################################



###########################################################
#                                                         #
# Check startup-parameters and show usage if needed       #
#                                                         #
###########################################################

if [ $# -lt $EXPECTED_ARGS ]; then
  echo "Usage: dvd-chapter-mkv.sh p1"
  echo "                            "
  echo "[p1] device"
  echo "                            "
  echo "dvd-chapter-mkv.sh was called with wrong arguments" > $OUTPUT_ERROR
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi

###########################################################



###########################################################
#                                                         #
# Cleanup a few files on startup of the script            #
#                                                         #
###########################################################

rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/* >/dev/null 2>&1

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
        echo ----------------------------------------------------------------------------
        echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate." > $OUTPUT_ERROR
        echo "Please install \"${REQUIRED_TOOL}\"." > $OUTPUT_ERROR
        echo
        echo ----------------------- script rc=50 ----------------------------
        echo -----------------------------------------------------------------
        exit $E_TOOLNOTF
   fi
done

###########################################################










###########################################################
#                                                         #
# We read the chapters and returning back the list        #
#                                                         #
###########################################################

if [ $1 == '/dev/sr0' ] ; then
   PARA="disc:0"
fi
if [ $1 == '/dev/sr1' ] ; then
   PARA="disc:1"
fi
if [ $1 == '/dev/sr2' ] ; then
   PARA="disc:2"
fi

# We need the chapters (counting)

chapter=$(makemkvcon info $PARA | grep '^Title' | grep -v skipped | wc -l)

if [ $# -eq 0 ]; then
  echo
  echo ----------------------- script rc=3 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_NOCHAPTERS
fi

(
makemkvcon --messages=/dev/null stream $PARA & >/dev/null 2>&1
) > $OUTPUT 2>&1

echo
echo "INFO generating track-list ... please be patient."
echo "INFO this operation may needs a lot of time to complet...."
echo 

# Wait until webserver is ready

TIMOUT=0
LOOP=1
while [ $LOOP -eq '1'  ];
do
    SUCCESS=$(netstat -lt | grep 51000)
    sleep 1
    if [ -n "$SUCCESS" ] ; then
        echo
        echo
        echo INFO webserver on port 51000 ready
        echo INFO operation successfull
        echo
        LOOP=0
    else
        echo -n .
    fi
    TIMEOUT=`expr $TIMEOUT + 1`
    if [ $TIMEOUT -eq "480" ] ; then
        echo
        echo
        echo ERROR webserver on port 51000 is not ready
        echo
        echo ----------------------- script rc=5 -----------------------------
        echo -----------------------------------------------------------------
        exit $E_WEBERROR
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

# We do not longer needd the makemkvcon process ...

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

while [ $chapter -gt $Tindex ]
do
    TITLE=~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/br$Tindex.000
    duration=$(cat $TITLE | grep duration | awk '{print $2}')
    chaps=$(cat $TITLE | grep chaptercount | awk '{print $2}')


    if [ -n "$chaps" ] ; then
       echo INFO track-index:[$Tindex] length:[$duration] chapters:[$chaps]
       echo $duration $Tindex >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP 
    fi

    echo track:[$Tindex] length:[$duration] chapters:[$chaps] >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_TRACKS
    Tindex=`expr $Tindex + 1`
done

LONGTRACK=$(cat $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP | sort -r | head -1 | awk '{print $2}')
LONGDURATION=$(cat $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_HELP | sort -r | head -1 | awk '{print $1}')

echo "INFO track summery"
echo "INFO [track:[$LONGTRACK]  duration:[$LONGDURATION]]"
echo "INFO [volname:[$VOLNAME]]"
echo
echo $1 > ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI
echo $LONGTRACK >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI
echo $LONGDURATION >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI
echo $VOLNAME >> ~/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI

###########################################################









echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit $ZERO


