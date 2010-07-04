###########################################################
# scriptname : br1.sh                                     #
###########################################################

echo -------------------------------
echo entering script br1.sh $1
echo -------------------------------

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"
LOG="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/bluray-log"

echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------

echo ------------------------------------------
echo starting script bluray-chapter.sh $1
echo ------------------------------------------

./bluray-chapter.sh $1 >>$LOG 2>&1 $

echo ------------------------------------------
echo bluray-chapter.sh $1 put into background
echo ------------------------------------------

echo ----------------------------
echo exit script br1.sh $1
echo ----------------------------

exit
