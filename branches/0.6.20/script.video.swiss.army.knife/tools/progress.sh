###########################################################
# scriptname : progress.sh                                #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters : none                                       #
###########################################################


if [ -e $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress ] ; then
  PERCENT=$(cat $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress)
  echo
  echo current progress [$PERCENT%]
  echo
else
  echo
  echo no active job found
  echo
fi
