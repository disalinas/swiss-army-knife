###########################################################
# scriptname : br0.sh                                     #
###########################################################

echo -------------------------------
echo entering script br0.sh $1
echo -------------------------------

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"
LOG="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/bluray-log"

echo -----------------------------------------------------------------
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo -----------------------------------------------------------------

echo ------------------------------------------
echo starting script state.sh $1
echo ------------------------------------------

./state.sh $1 >>$LOG 2>&1 $

echo ------------------------------------------
echo state.sh $1 put into background
echo ------------------------------------------

echo ----------------------------
echo exit script br0.sh $1
echo ----------------------------

exit
