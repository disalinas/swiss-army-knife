###########################################################
# scriptname : br2.sh                                     #
###########################################################

echo ------------------------------------------------------
echo entering script br1.sh $1 $2 $3 $4
echo ------------------------------------------------------

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"
LOG="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/bluray-log"

echo -----------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------

echo -----------------------------------------------------
echo starting script bluray-transcode.sh $1 $2 $3 $4
echo -----------------------------------------------------

./bluray-transcode.sh $1 $2 $3 $4  >>$LOG 2>&1 $

echo -----------------------------------------------------
echo bluray-transcode $1 $2 $3 $4 put into background
echo -----------------------------------------------------

echo -----------------------------------------------------
echo exit script br2.sh $1 $2 $3 $4
echo -----------------------------------------------------

exit
