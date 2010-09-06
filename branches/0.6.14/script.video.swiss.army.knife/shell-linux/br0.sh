###########################################################
# scriptname : br0.sh                                     #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"
LOG="$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/bluray-log"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------


./state.sh $1 >>$LOG 2>&1 $

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0



