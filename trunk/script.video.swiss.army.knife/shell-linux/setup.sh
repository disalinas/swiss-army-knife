#!/bin/bash
###########################################################
# scriptname : setup.sh                                   #
###########################################################
# This script is part of the addon swiss-army-knife for   #
# xbmc and is licenced under the gpl-licence              #
# http://code.google.com/p/swiss-army-knife/              #
###########################################################
# author     : linuxluemmel.ch@gmail.com                  #
# parameters :                                            #
# $1 user                                                 #
# description :                                           #
# Setup all files and directorys for the addon            #
###########################################################

SCRIPTDIR="$HOME/.xbmc/addons/script.video.swiss.army.knife/shell-linux"

echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------


# Define the counting commands we expect inside the script

EXPECTED_ARGS=1

# Error-codes

E_BADARGS=1
E_TOOLNOTF=2
E_NOROOT=3
E_SSHKEY=4
E_LICENCE_NOT_ACCEPTED=5



###########################################################
#            Check-Arguments to Script                    #
###########################################################
if [ $# -ne $EXPECTED_ARGS ] ; then
  clear 
  echo "Usage: setup.sh p1"
  echo
  echo " [p1] username"
  echo
  echo "setup.sh was called without arguments"
  echo
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi
###########################################################




###########################################################
#            Check installed software                     #
###########################################################
REQUIRED_TOOLS=`cat << EOF
echo
apt-get
awk
tar
gunzip
wget
EOF`

for REQUIRED_TOOL in ${REQUIRED_TOOLS}
do
   which ${REQUIRED_TOOL} >/dev/null 2>&1
   if [ $? -eq 1 ]; then
      echo "ERROR! \"${REQUIRED_TOOL}\" is missing. ${0} requires it to operate."
      echo "Please install \"${REQUIRED_TOOL}\"."
      echo ----------------------------------------------------------------------------
      echo
      echo ----------------------- script rc=2 -----------------------------
      echo -----------------------------------------------------------------
      exit $E_TOOLNOTF
   fi
done
###########################################################




###########################################################
#            Who is running the script ?                  #
###########################################################
if [ "$UID" -ne 0 ] ; then
   clear 
   echo "you must be root to run this script !"
   echo "sudo ./setup.sh"
   echo
   echo ----------------------- script rc=3 -----------------------------
   echo -----------------------------------------------------------------
   exit $E_NOROOT
fi
###########################################################





###########################################################
#            Is licence-file allready local ?             #
###########################################################
if [ ! -e EULA-0.6.14 ] ; then
   clear
   echo
   echo download licence file from google-code
   echo
   wget http://swiss-army-knife.googlecode.com/files/EULA-0.6.14
fi


if [ -e EULA-0.6.14 ] ; then
   clear
   cat EULA-0.6.14
   echo
   echo -n "Do you want to accept this enduser-licnce ? (y)"
   read ans
   if [ $ans == "y" ] ; then
      clear
      echo "EULA 0.6.14 accepted"
      echo
      echo -n press any key to continue ..
      read any
   else
      echo "licence was not accepted !"
      echo
      echo ----------------------- script rc=5 -----------------------------
      echo -----------------------------------------------------------------
      exit $E_LICENCE_NOT_ACCEPTED
   fi
else 
   clear 
   echo The EULA-FILE can no be downloaded and therefore you must 
   echo use a svn release of this addon.
   echo You do this at you own risk .....
   echo the last stable puplic released version was 0.6.13
   echo 
   echo -n press any key to continue or ctrl-c to abort..
   read any   
fi 
###########################################################




###########################################################
#            Create directorys                            #
###########################################################
if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media
fi

if [ ! -e /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp ] ; then
   mkdir /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp
   chown -R $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/tmp
fi

if [ ! -e /dvdrip ] ; then
   mkdir /dvdrip
   chown -R $1:$1 /dvdrip
fi

if [ ! -e /dvdrip/iso ] ; then
   mkdir /dvdrip/iso
   chown -R $1:$1 /dvdrip/iso
fi

if [ ! -e /dvdrip/dvd ] ; then
   mkdir /dvdrip/dvd
   chown -R $1:$1 /dvdrip/dvd
fi

if [ ! -e /dvdrip/bluray ] ; then
   mkdir /dvdrip/bluray
   chown -R $1:$1 /dvdrip/bluray
fi

if [ ! -e /dvdrip/network ] ; then
   mkdir /dvdrip/network
   chown -R $1:$1 /dvdrip/network
fi

if [ ! -e /dvdrip/vobcopy ] ; then
   mkdir /dvdrip/vobcopy
   chown -R $1:$1 /dvdrip/vobcopy
fi
###########################################################




###########################################################
#            Install Software for all parts               #
###########################################################
if [ ! -e /etc/apt/sources.list.d/medibuntu.list ] ; then
   sudo wget http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list \
   --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && \
   sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
fi

apt-get install mencoder
apt-get install netcat original-awk dvdauthor mkisofs gddrescue
apt-get install dvd+rw-tools lsdvd vobcopy
apt-get install submux-dvd subtitleripper transcode mjpegtools libdvdcss2 openssh-server openssh-client
apt-get install liba52-0.7.4 libfaac0 libmp3lame0 libmp4v2-0 libogg0 libsamplerate0 libx264-85 libxvidcore4
apt-get install libbz2-1.0 libgcc1 libstdc++6 zlib1g
###########################################################





###########################################################
#            Section Bluray                               #
###########################################################
clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used allready blurays with the addon you can answer no.
echo This section do only install software to install succcessfull 
echo makekmkv.The software makemkv itself is not installed.
echo
echo -n "Do you want to use bluray-discs inside the addon (y/n)"
read ans
if [ $ans == "y" ] ; then
   echo
   echo install software for bluray-functions
   echo
   apt-get install build-essential lynx libc6-dev libssl-dev libgl1-mesa-dev libqt4-dev
   BL=1
   echo
   echo -n press any key to continue ..
   read any
fi

if [ $ans == "n" ] ; then
   clear
   echo
   echo -----------------------------------------------------------
   echo software for installation of the bluray-functions is not installed.
   echo If you later decide to use them then run setup.sh
   echo again.
   echo
   echo -n press any key to continue ..
   read any
   BL=0
fi
###########################################################




###########################################################
#            Section SSH                                  #
###########################################################
clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used ssh with the addon you can answer no.
echo Inside this section the ssh-system will be configured.
echo
echo -n "Do you want to configure ssh for the addon (y/n)"
read ans
if [ $ans == "y" ] ; then
   clear
   echo
   echo ----------------------------------------------------------------
   echo "Important-Note for the next command !"
   echo "The command do create a ssh-key and will ask for a password. Leave it empty !!!!!!!!"
   echo ----------------------------------------------------------------
   echo

   sudo -u $1 ssh-keygen -t rsa

   RETVAL=$?
   if [ $RETVAL -eq 0 ] ; then
      clear
      echo
      echo ----------------------------------------------------------------
      echo "Important-Note for the next command !"
      echo "The command will ask for a password.This password is for the user $1"
      echo "and not the current root-password"
      echo "If you don't give the password,the ssh-key that was created can not be transmitted."
      echo ----------------------------------------------------------------
      sudo -u $1 ssh-copy-id -i /home/$1/.ssh/id_rsa.pub $1@localhost
      echo
      echo -n press any key to continue ..
      read any
   fi
fi

if [ $ans == "n" ] ; then
   clear
   echo
   echo -----------------------------------------------------------
   echo the ssh-subsystem is not configured.
   echo
   echo -n press any key to continue ..
   read any
fi
###########################################################






###########################################################
#            Section Handbrake                            #
###########################################################
which HandBrakeCLI >/dev/null 2>&1
if [ $? -eq 1 ] ; then
   clear
   echo The command HandBrakeCLI was not found on your system.
   echo Should HandBrakeCLI svn3416 be installed ?
   echo
   echo -n "Do you want to install HandbrakeCLI (y/n)"
   read ans
   if [ $ans == "y" ] ; then
      architecture=`uname -m`
      if [ "$architecture" != "x86_64" ] && [ "$architecture" != "ia64" ]; then
         clear
         echo
         echo download software for 32 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.4-32.tar.gz
         tar xvzf handbrake-0.9.4-32.tar.gz
         dpkg -i handbrake-cli_lucid1_i386.deb
      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.4-64.tar.gz
         tar xvzf handbrake-0.9.4-64.tar.gz
         dpkg -i handbrake-cli_lucid1_amd64.deb
      fi
   fi
   if [ $ans == "n" ] ; then
      clear
      echo
      echo -----------------------------------------------------------
      echo HandbrakeCLI is not installed.
      echo You can not transcode a dvd as long this tool is not installed.
      echo
      echo -n press any key to continue ..
      read any
   fi
else
   HINSTALLED=$(HandBrakeCLI -i /dev/null -o /dev/null 2>&1 | grep ^Hand | head -1 | awk '{print $2}')
   clear
   echo The command HandBrakeCLI was found on your system.
   echo
   echo The release found on your system is : [$HINSTALLED]
   echo The script can download and install : [svn3416]
   echo
   echo Should HandBrakeCLI [svn3416] be installed over
   echo the existing release on your system ?
   echo
   echo Warning : This may make HandbrakeCLI unusable ...
   echo
   echo -n "Do you want to update HandbrakeCLI (y/n)"
   read ans
   if [ $ans == "y" ] ; then
      architecture=`uname -m`
      if [ "$architecture" != "x86_64" ] && [ "$architecture" != "ia64" ]; then
         clear
         echo
         echo download software for 32 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.4-32.tar.gz
         tar xvzf handbrake-0.9.4-32.tar.gz
         dpkg -i handbrake-cli_lucid1_i386.deb
         rm handbrake-0.9.4-32.tar.gz 
      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.4-64.tar.gz
         tar xvzf handbrake-0.9.4-64.tar.gz
         dpkg -i handbrake-cli_lucid1_amd64.deb
         rm handbrake-0.9.4-64.tar.gz
      fi
   fi
   if [ $ans == "n" ] ; then
      clear
      echo
      echo -----------------------------------------------------------
      echo HandbrakeCLI is not updated and remains as it is
      echo
      echo -n press any key to continue ..
      read any
   fi
fi
###########################################################






###########################################################
#            Section makemkvcon                           #
###########################################################
which makemkvcon >/dev/null 2>&1
if [ $? -eq 1 ] ; then
   clear
   echo The command makemkvcon was not found on your system.
   echo Should makemkv 1.5.8 to be installed ?
   echo
   echo -n "Do you want to install makemkv (y/n)"
   read ans
   if [ $ans == "y" ] ; then
      architecture=`uname -m`
      if [ "$architecture" != "x86_64" ] && [ "$architecture" != "ia64" ]; then
         clear
         echo
         echo download software for 32 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/makemkv-v1.5.8-32.tar.gz
         tar xvzf makemkv-v1.5.8-32.tar.gz
         dpkg -i makemkv-v1.5.8-bin_20100818-1_i386.deb
         dpkg -i makemkv-v1.5.8-oss_20100818-1_i386.deb
         rm xvzf makemkv-v1.5.8-32.tar.gz 
      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/makemkv-1.5.8-64.tar.gz
         tar xvzf makemkv-1.5.8-64.tar.gz
         dpkg -i makemkv-v1.5.8-bin_20100819-1_amd64.deb
         dpkg -i makemkv-v1.5.8-oss_20100819-1_amd64.deb
         rm makemkv-1.5.8-64.tar.gz
      fi
   fi
   if [ $ans == "n" ] ; then
      clear
      echo
      echo -----------------------------------------------------------
      echo makemkv is not installed.
      echo You can not transcode a bluray as long this tool is not installed.
      echo
      echo -n press any key to continue ..
      read any
   fi
else
   MINSTALLED=$(makemkvcon info /dev/null | head -1 | awk '{print $2}')
   clear
   echo The command makemkvcon was found on your system.
   echo
   echo The release found on your system is : [$MINSTALLED]
   echo The script can download and install : [v1.5.8]
   echo
   echo Should makemkv [v1.5.8] be installed over
   echo the existing release on your system ?
   echo
   echo Warning : This may make makemkv unusable ...
   echo
   echo -n "Do you want to update makemkv (y/n)"
   read ans
   if [ $ans == "y" ] ; then
      architecture=`uname -m`
      if [ "$architecture" != "x86_64" ] && [ "$architecture" != "ia64" ]; then
         clear
         echo
         echo download software for 32 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/makemkv-v1.5.8-32.tar.gz
         tar xvzf makemkv-v1.5.8-32.tar.gz
         dpkg -i makemkv-v1.5.8-bin_20100818-1_i386.deb
         dpkg -i makemkv-v1.5.8-oss_20100818-1_i386.deb
         rm xvzf makemkv-v1.5.8-32.tar.gz

      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/makemkv-1.5.8-64.tar.gz
         tar xvzf makemkv-1.5.8-64.tar.gz
         dpkg -i makemkv-v1.5.8-bin_20100819-1_amd64.deb
         dpkg -i makemkv-v1.5.8-oss_20100819-1_amd64.deb
         rm makemkv-1.5.8-64.tar.gz 
      fi
   fi
   if [ $ans == "n" ] ; then
      clear
      echo
      echo -----------------------------------------------------------
      echo makemkv is not updated and remains as it is.
      echo
      echo -n press any key to continue ..
      read any
   fi
fi
###########################################################


###########################################################
#            Section setup.done                           #
###########################################################
clear
cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife
if [ ! -e 0.6.14-setup.done ] ; then
   echo
   echo -----------------------------------------------------------
   echo create setup.done and licence-file inside addon-data directory 
   echo
   echo "0.6.14" > /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/0.6.14-setup.done
   chown $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/0.6.14-setup.done
fi

if [ ! -e EULA-0.6.14 ] ; then
   cp /home/$1/.xbmc/addons/script.video.swiss.army.knife/shell-linux/EULA-0.6.14 EULA-0.6.14
   chown $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/EULA-0.6.14
fi


clear
echo
echo Addon can now be running over xbmc  ......
echo
echo
echo - Please do updates the settings with the addon-manager.
echo
echo Have fun with this addon and I wish you happy ripping.
echo Feel free to send me a few notes about your expirience with
echo this addon on the feedback url.
echo
echo http://code.google.com/p/swiss-army-knife/wiki/Feedback
echo
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------
echo
echo
###########################################################

