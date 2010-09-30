

cp $HOME/.xbmc/temp/xbmc.log .
cp $HOME/swiss.army.knife/ssh/output .
cp -r $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/* settings/

tar cvzf collected-error.tar.gz *

rm xbmc.log >/dev/null 2>&1
rm output >/dev/null 2>&1
rm -rf settings/* >/dev/null 2>&1
