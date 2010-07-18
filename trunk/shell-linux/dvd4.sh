###########################################################
# scriptname : dvd4.sh                                    #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/swiss-army-knife/shell-linux"
LOG="$HOME/.xbmc/userdata/addon_data/script-video-ripper/log/dvd-log"

echo
echo --------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script  :" $SCRIPT
cat version
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo --------------------------------------------------------------------

./dvd-atracks.sh $1 $2 >>$LOG 2>&1 &

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0

