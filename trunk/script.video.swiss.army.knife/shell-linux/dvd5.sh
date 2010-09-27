###########################################################
# scriptname : dvd5.sh                                    #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"
LOG="$HOME/swiss.army.knife/ssh/output"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

./dvd-rescue.sh $1 $2 $3 >>$LOG 2>&1 &

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0
