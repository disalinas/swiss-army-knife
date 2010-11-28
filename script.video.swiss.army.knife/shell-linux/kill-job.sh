###########################################################
# scriptname : kill-job.sh                                #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters : none                                       #
###########################################################

clear
PID_TO_KILL=$(cat "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/PWATCH")
kill -9 $PID_TO_KILL > /dev/null 2>&1

echo KILL ALL PROCESSES AND STOP LOOPING > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/TERM_ALL

echo the current active job should be stopped ...
echo

