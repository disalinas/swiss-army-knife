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


###########################################################
# Current version of makemkv for 32 and 64 bit            #
###########################################################

MAKEMKV="1.6.6"
MAKEKMKV32="makemkv-swiss-army-knife-32-04-03-2011.tar.gz"
MAKEMKVBIN="makemkv-v1.6.6-bin_20110403-1_i386.deb"
MAKEMKVOSS="makemkv-v1.6.6-oss_20110403-1_i386.deb"

###########################################################




###########################################################
#                                                         #
# We must be root for this script                         #
#                                                         #
###########################################################
if [ "$UID" -ne 0 ] ; then
   clear
   echo "you must be root to run this script !"
   echo "sudo ./setup.sh"
   echo
   echo ----------------------- script rc=3 -----------------------------
   echo -----------------------------------------------------------------
   exit 3
fi
###########################################################



###########################################################
#                                                         #
# We can only run with bash as default shell              #
#                                                         #
###########################################################

SHELLTEST="/bin/bash"
if [ $SHELL != $SHELLTEST ] ; then
   clear
   echo
   echo only bash shell is supported by this shell-script.
   echo It looks like you are using something other than /bin/bash.
   echo
   exit 255
fi

###########################################################




###########################################################
#                                                         #
# Show disclaimer / copyright note on top of the screen   #
#                                                         #
###########################################################

clear
echo
echo ----------------------------------------------------------------------------
SCRIPT=$(basename $0)
echo "script    :" $SCRIPT
cat version
echo "copyright : (C) <2010-2011>  <linuxluemmel.ch@gmail.com>"
cd "$SCRIPTDIR" && echo changed to $SCRIPTDIR
echo ----------------------------------------------------------------------------

###########################################################



###########################################################
#                                                         #
# Definition of files and internal variables              #
#                                                         #
###########################################################

ZERO=0
EXPECTED_ARGS=1
E_BADARGS=1
E_TOOLNOTF=50
E_NOROOT=3
E_SSHKEY=4
E_LICENCE_NOT_ACCEPTED=5
E_DPKG=6
E_WRONG_SHELL=255

REQUIRED_TOOLS=`cat << EOF
echo
apt-get
awk
tar
gunzip
wget
EOF`

###########################################################



###########################################################
#                                                         #
# Check startup-parameters and show usage if needed       #
#                                                         #
###########################################################

if [ $# -ne $EXPECTED_ARGS ] ; then
  clear
  echo "Usage: setup.sh p1"
  echo
  echo " [p1] username"
  echo
  echo "setup.sh was called without arguments"
  echo
  echo example of usage :
  echo ./setup.sh xbmc 
  echo
  echo ----------------------- script rc=1 -----------------------------
  echo -----------------------------------------------------------------
  exit $E_BADARGS
fi

###########################################################



###########################################################
#                                                         #
# We must be certain that all software is installed       #
#                                                         #
###########################################################

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
#                                                         #
# Is licence-file 0.6.19 allready local ?                 #
#                                                         #
###########################################################

if [ ! -e EULA-0.6.19 ] ; then
   clear
   echo
   echo download licence file from google-code
   echo
   wget http://swiss-army-knife.googlecode.com/files/EULA-0.6.19
fi

if [ -e EULA-0.6.19 ] ; then
   clear
   cat EULA-0.6.19
   echo
   echo -n "Do you want to accept this enduser-licnce ? (y)"
   read ans
   if [ $ans == "y" ] ; then
      clear
      echo "EULA 0.6.19 accepted"
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
   echo The EULA-FILE can not be downloaded and therefore you must
   echo use a svn release of this addon.
   echo You do this at your own risk .....
   echo the last stable puplic released version was 0.6.18
   echo
   echo -n press any key to continue or ctrl-c to abort..
   read any
fi

###########################################################



###########################################################
#                                                         #
# Set all +x attributes for the shell-folder              #
#                                                         #
########################################################### 

chmod +x *sh > /dev/null 2>&1

###########################################################



###########################################################
#                                                         #
# Create local directorys                                 #
###########################################################

clear
echo
echo Would you like to create the default directorys
echo inside /dvdrip and the default user-script directory
echo inside the home-folder of /home/$1 ?
echo All directorys inside the addon-directorys itself are
echo created as well.
echo If you answer "no" you have to create all directorys
echo by yourself and the shell-scripts may not working.
echo You should let this script create them.
echo
echo -n "Should this setup script create all needed directorys ? (y/n)"
read ans

if [ $ans == "y" ] ; then
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

   # Do store all user defined functions ... because this directory is outside the addon 
   # directory structure the functions inside this directory are save from being deleted.

   if [ ! -e /home/$1/swiss.army.knife ] ; then
      mkdir /home/$1/swiss.army.knife
      chown -R $1:$1 /home/$1/swiss.army.knife
   fi

   # All shell-scripts run in non interactive mode do send the output into this directory

   if [ ! -e /home/$1/swiss.army.knife/ssh ] ; then
      mkdir /home/$1/swiss.army.knife/ssh
      chown -R $1:$1 /home/$1/swiss.army.knife/ssh
   fi

   # Create all data-containers

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

   if [ ! -e /dvdrip/transcode ] ; then
      mkdir /dvdrip/transcode
      chown -R $1:$1 /dvdrip/transcode
   fi

   if [ ! -e /dvdrip/portable ] ; then
      mkdir /dvdrip/portable
      chown -R $1:$1 /dvdrip/portable
   fi

   if [ ! -e /dvdrip/portable/ip ] ; then
      mkdir /dvdrip/portable/ip
      chown -R $1:$1 /dvdrip/portable/ip
   fi

   if [ ! -e /dvdrip/portable/psp ] ; then
      mkdir /dvdrip/portable/psp
      chown -R $1:$1 /dvdrip/portable/psp
   fi
fi

if [ $ans == "n" ] ; then
   clear
   echo
   echo -----------------------------------------------------------
   echo No directorys have ben created by this shell-script.
   echo If you later decide to create them then run setup.sh again.
   echo
   echo -n press any key to continue ..
   read any
fi

###########################################################




###########################################################
#                                                         #
# Install Software for all parts of this addon            #
#                                                         #
###########################################################
if [ ! -e /etc/apt/sources.list.d/medibuntu.list ] ; then
   sudo wget http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list \
   --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && \
   sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
fi


apt-get install mencoder
apt-get install netcat original-awk dvdauthor mkisofs gddrescue
apt-get install dvd+rw-tools lsdvd dvdbackup
apt-get install submux-dvd subtitleripper transcode mjpegtools libdvdcss2 openssh-server openssh-client
apt-get install liba52-0.7.4 libfaac0 libmp3lame0 libmp4v2-0 libogg0 libsamplerate0 libx264-85 libxvidcore4
apt-get install libbz2-1.0 libc6 libgcc1 libstdc++6 zlib1g

###########################################################



###########################################################
#                                                         #
# Section Bluray only needed if makemkv should used       #
#                                                         #
###########################################################

clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used allready blurays with the addon you can answer no.
echo This section do only install software to install succcessfull
echo makekmkv.The software makemkv itself is not installed.
echo If you would like to transcode a dvd to mkv you have to answer
echo yes.
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
   echo If you later decide to use them then run setup.sh again.
   echo
   echo -n press any key to continue ..
   read any
   BL=0
fi

###########################################################





###########################################################
#                                                         #
#            Section SSH                                  #
#                                                         #
###########################################################

clear
echo
echo -----------------------------------------------------------
echo If you allreaday installed a previous version of this addon
echo and have used ssh with the addon you can answer no.
echo Inside this section the ssh-system will be configured.
echo Warning : The local ssh must be configured or this addon is 
echo not running as expected.
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
   if [ $RETVAL -eq 1 ] ; then
      clear
      echo the command to create the ssh-keys was not successfull.
      echo the error-code was [$RETVAL]
      exit $E_SSHKEY
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
#                                                         #
# Section Handbrake                                       #
#                                                         #
###########################################################

# We test if the command HandBrakeCLI is allready installed ...

which HandBrakeCLI >/dev/null 2>&1
if [ $? -eq 1 ] ; then
   clear
   echo The command HandBrakeCLI was not found on your system.
   echo Should HandBrakeCLI 0.9.5 be installed ?
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
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.5-32.tar.gz
         tar xvzf handbrake-0.9.5-32.tar.gz
         dpkg -i handbrake-cli_0.9.5ppa1~lucid1_i386.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of handbrake-cli_0.9.5ppa1~lucid1_i386.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         else
            rm handbrake-cli_0.9.5ppa1~lucid1_i386.deb > /dev/null 2>&1
         fi
      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.5-64.tar.gz
         tar xvzf handbrake-0.9.5-64.tar.gz
         dpkg -i handbrake-cli_0.9.5ppa1~lucid1_amd64.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of handbrake-cli_0.9.5ppa1~lucid1_amd64.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         else
            rm handbrake-cli_0.9.5ppa1~lucid1_amd64.deb > /dev/null 2>&1
         fi
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
   echo The script can download and install : [0.9.5]
   echo
   echo Should HandBrakeCLI [0.9.5] be installed over
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
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.5-32.tar.gz
         tar xvzf handbrake-0.9.5-32.tar.gz
         dpkg -i handbrake-cli_0.9.5ppa1~lucid1_i386.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of handbrake-cli_0.9.5ppa1~lucid1_i386.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         else
            rm handbrake-0.9.5-32.tar.gz
         fi
      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp
         wget http://swiss-army-knife.googlecode.com/files/handbrake-0.9.5-32.tar.gz
         tar xvzf handbrake-0.9.5-32.tar.gz
         dpkg -i handbrake-cli_0.9.5ppa1~lucid1_amd64.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of handbrake-cli_0.9.5ppa1~lucid1_amd64.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         else
            rm handbrake-0.9.5-32.tar.gz > /dev/null 2>&1
         fi
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
#                                                         #
# Section makemkvcon                                      #
#                                                         #
###########################################################

# Test command makemkvcon ...

which makemkvcon >/dev/null 2>&1
if [ $? -eq 1 ] ; then
   clear
   echo The command makemkvcon was not found on your system.
   echo Should makemkv $MAKEMKV to be installed ?
   echo Even if there is no bluray installed you have to answer
   echo yes if you plan to transcode a dvd to the mkv format.
   echo
   echo -n "Do you want to install makemkv (y/n)"
   read ans
   if [ $ans == "y" ] ; then
      architecture=`uname -m`
      if [ "$architecture" != "x86_64" ] && [ "$architecture" != "ia64" ]; then


         # Installation for a 32 bit-system 


         clear
         echo
         echo download software for 32 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp

         # Download the curremt release from project url for 32 bit 

         wget http://swiss-army-knife.googlecode.com/files/$MAKEKMKV32  
         tar xvzf $MAKEKMKV32 
 
         # Install oss part for makemkv 
        
         dpkg -i $MAKEMKVOSS
         if [ $? -eq 1 ]; then
            clear
            echo the installation of $MAKEMKVOSS
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi

         # Install binary part for makemkv 

         dpkg -i $MAKEMKVBIN
         if [ $? -eq 1 ]; then
            clear
            echo the installation of $MAKEMKVBIN
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi

         # delete downloaded archive

         rm $MAKEKMKV32

      else


         # Installation for a 32 bit-system

         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp

         # Download release 1.6.5 from project url for 64 bit 
         
         wget http://swiss-army-knife.googlecode.com/files/makemkv-swiss-army-knife-64-02-20-2011.tar.gz 
         tar xvzf makemkv-swiss-army-knife-64-02-20-2011.tar.gz 

         # Install oss part for makemkv  

         dpkg -i makemkv-v1.6.5-oss_20110220-1_amd64.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of makemkv-v1.6.5-oss_20110220-1_amd64.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi
          
         # Install bin part for makemkv   

         dpkg -i makemkv-v1.6.5-bin_20110220-1_amd64.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of makemkv-v1.6.5-bin_20110220-1_amd64.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi
         rm makemkv-swiss-army-knife-64-02-20-2011.tar.gz
      fi
   fi
   if [ $ans == "n" ] ; then
      clear
      echo
      echo -----------------------------------------------------------
      echo makemkv is not installed.
      echo You can not transcode a bluray as long this tool is not installed.
      echo It is also not possible to transcode a dvd to mkv.
      echo If you decide to transcode blurays pleas do run this tool again.
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
   echo The script can download and install : [$MAKEMKV]
   echo
   echo Should makemkv [$MAKEMKV] be installed over
   echo the existing release on your system ?
   echo
   echo Warning : This may make makemkv unuseable ...
   echo It is may more save to remove the old release
   echo by the command dpkg -r or do not touch the
   echo the current installed makekmkv release [$MINSTALLED] 
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

         wget http://swiss-army-knife.googlecode.com/files/$MAKEKMKV32
         tar xvzf $MAKEKMKV32 

         # Install oss part for makemkv           

         dpkg -i $MAKEMKVOSS
         if [ $? -eq 1 ]; then
            clear
            echo the installation of $MAKEMKVOSS
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi

         # Install bin part for makemkv   

         dpkg -i $MAKEMKVBIN
         if [ $? -eq 1 ]; then
            clear
            echo the installation of $MAKEMKVBIN
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi

         rm $MAKEKMKV32

      else
         clear
         echo
         echo download software for 64 bit
         echo
         cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/tmp

         wget http://swiss-army-knife.googlecode.com/files/makemkv-swiss-army-knife-64-02-20-2011.tar.gz
         tar xvzf makemkv-swiss-army-knife-64-02-20-2011.tar.gz

         # Install oss part for makemkv  

         dpkg -i makemkv-v1.6.5-oss_20110220-1_amd64.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of makemkv-v1.6.5-oss_20110220-1_amd64.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi
          
         # Install bin part for makemkv   

         dpkg -i makemkv-v1.6.5-bin_20110220-1_amd64.deb
         if [ $? -eq 1 ]; then
            clear
            echo the installation of makemkv-v1.6.5-bin_20110220-1_amd64.deb
            echo was not successfull.
            echo please do confirm that the installation was not successfull.
            echo
            echo -n press any key to continue ..
            read any
            exit $E_DPKG
         fi

         rm makemkv-swiss-army-knife-64-02-20-2011.tar.gz
      fi
   fi
   if [ $ans == "n" ] ; then
      clear
      echo
      echo -----------------------------------------------------------
      echo current makemkv is not updated to release 1.6.5 and remains 
      echo as it is.
      echo
      echo -n press any key to continue ..
      read any
   fi
fi

###########################################################



###########################################################
#                                                         #
# Section setup.done                                      #
#                                                         #
###########################################################

clear
cd /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife
if [ ! -e 0.6.19-setup.done ] ; then
   echo
   echo -----------------------------------------------------------
   echo create setup.done and licence-file inside addon-data directory
   echo
   echo "0.6.19" > /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/0.6.19-setup.done
   chown $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/0.6.19-setup.done
fi

if [ ! -e EULA-0.6.19 ] ; then
   cp /home/$1/.xbmc/addons/script.video.swiss.army.knife/shell-linux/EULA-0.6.18 EULA-0.6.19
   chown $1:$1 /home/$1/.xbmc/userdata/addon_data/script.video.swiss.army.knife/EULA-0.6.19
fi

###########################################################




###########################################################
#                                                         #
# Setup is now finished                                   #
#                                                         #
###########################################################

clear
echo
echo Addon release 0.6.19 can now be running over xbmc  ......
echo
echo
echo - Please do updates the settings with the addon-manager.
echo - Do not forget to replace the default name xbmc@localhost
echo   if your username is not xbmc.
echo - If you did not created the directorys. You have to create them
echo   now and to change all directorys inside the settings.
echo - Without a configured ssh system this addon is not working.
echo - Please remember that no "spaces" inside the directory-names
echo   are allowed.
echo - Please be sure that the user has full write permissions to all
echo   folders !
echo - A description of all addon-settings can be found within APPENDIX A
echo   of the README.Linux 
echo
echo Have fun with this addon and I wish you happy ripping.
echo Feel free to send me a few notes about your expirience with
echo this addon on the feedback url or inside the xbmc-forum.
echo
echo http://code.google.com/p/swiss-army-knife/wiki/Feedback
echo
echo Greetings from switzerland
echo Hans
echo ----------------------- script rc=0 -----------------------------
echo -----------------------------------------------------------------
echo
echo
exit $ZERO

###########################################################

