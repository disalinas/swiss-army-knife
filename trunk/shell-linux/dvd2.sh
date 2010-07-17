###########################################################
# scriptname : dvd2.sh                                    #
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

if [ $# -eq 5 ] ; then
   echo
   echo 5 arguments to dvd-handbrake.sh
   echo $1 $2 $3 $4 $5
   echo
   ./dvd-handbrake.sh $1 $2 $3 $4 $5 >>$LOG 2>&1 &
fi

if [ $# -eq 7 ] ; then
    echo
    echo 7 arguments to dvd-handbrake.sh
    echo $1 $2 $3 $4 $5 $6 $7
    echo
    ./dvd-handbrake.sh $1 $2 $3 $4 $5 $6 $7 >>$LOG 2>&1 &
fi

if [ $# -eq 9 ] ; then
   echo
   echo 9 arguments to dvd-handbrake.sh
   echo $1 $2 $3 $4 $5 $6 $7 $8 $9
   echo
    ./dvd-handbrake.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 >>$LOG 2>&1 &
fi

echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------

exit 0
