###########################################################
# scriptname : show-ssh-output.sh                         #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters : none                                       #
###########################################################



if [ -e $HOME/swiss.army.knife/ssh/output  ] ; then
  echo
  cat $HOME/swiss.army.knife/ssh/output
  echo
fi
