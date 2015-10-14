### In the case of a unexpected error please try to execute this commands without ssh over a console. ###
##  ##
  * http://code.google.com/p/swiss-army-knife/wiki/LinuxShell
##  ##
###  ###
###  ###
###  ###
### Error-Message : "Prior to run this addon setup.sh must be executed" ###

---

###  ###
  * You should read a file called README inside of the addon-directory ... ;-)
  * **PLEASE DO RUN SETUP.SH AFTER EVERY UPDATE OR UPGRADE OF THE ADDON !**
###  ###
###  ###
### Error-Message : "Licence-key for makemkv expired" ###

---

###  ###
  * You should read a file called README inside of the addon-directory ... ;-)
###  ###
###  ###
### Error-Message : "Configured ssh-user is not current user" ###

---

###  ###
  * The user inside the settings of the addon is not the same user under witch the xbmc system ist started.
  * The login-name of the user who is running xbmc has to be same as inside the settings.
###  ###
###  ###
### What is the Rescue-copy? ###

---

###  ###
  * A clean dvd-filesystem copy can be made with dd without any problem as long the css of the inserted dvd is open and dvd-filesystem has no erorrs.
  * I guess most of the dvd's purchased prior to 2005 are not "crippled dvd's"
  * After 2005 the big players from hollywood began to sell "crippled dvd's". This kind of dvd's can be played on allmost all players but are copy protected.For further information please have a look here (http://en.wikipedia.org/wiki/ARccOS_Protection)
  * With a copy protected dvd it can be very hard to produce a backup with dd or to transcode with handbrake.
  * The rescue-copy mode use ddresque to copy instead of dd.I had a case in where this mode  was the only way to backup a dvd (I used over one hour to backup this dvd)

###  ###
###  ###
### I have several of this timeout-errors or could not read errors. What should I do ? ###

---

###  ###
  * With the relese 0.6.14 I do add a few settings to be more flexible.

  * Prior to release 0.6.14 I made the timeout hard-coded inside the code like the following example.
```
    WCycles = 3
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[30])):
               if (__verbose__ == 'true'):
                   OSlog("state-files exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 1
               time.sleep(1)
           if (WCycles >= 20):
               if (__verbose__ == 'true'):
                   OSlog("Timeout 20 secounds reached for track-file  ...")
                   OSlog("increase timeout value on line 362 / Linux.py  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 2

```
  * In release 0.6.14 all timeout-parts are removed and will be replaced with a value from the settings.

  * Increase the timeout a few-secounds and test again.

###  ###
###  ###

### What Linux Filesystem should I use for my rip-containers ? ###

---

###  ###
  * At least the container should be very big.(more than just a few GB)
  * With linux you have the choice between : ext2,ext3,ext4,xfs and reiserfs. I would choose xfs.
###  ###
###  ###
### I do not like the the default place /dvdrip to store my videos ? ###

---

###  ###
  * By default 8 directorys inside the **/** root-fs are created
##  ##
  * **/dvdrip/iso**
  * **/dvdrip/dvd**
  * **/dvdrip/bluray**
  * **/dvdrip/network**
  * **/dvdrip/vobcopy**
  * **/dvdrip/transcode**
  * **/dvdrip/portable/ip**
  * **/dvdrip/portable/psp**
##  ##
  * You can replace this 8 directorys to any directory you like to do.
##  ##
  * No spaces " " inside the direcory-name are allowed ...
  * The 8 directorys you have chosen must be writeable with your current xbmc-user.
  * Change the addon settings to your desired directorys.
###  ###
###  ###
### Could the rip-containers be placed inside a NAS ? ###

---

###  ###
  * Yes . Configure /etc/fstab to mount the NAS at booting.
###  ###
###  ###
### Where is the script livecd.sh gone ? ###

---

###  ###
  * inside /linux-shell/setup.sh is a replacement script.This script is for the user root.

  * Following user directorys are created if you run the script with **./setup.sh xbmc**.

  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife
  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife/bluray
  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife/dvd
  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife/log
  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress
  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife/tmp
  * /home/xbmc/.xbmc/userdata/addon\_data/script.video.swiss.army.knife/media
  * /home/xbmc/swiss.army.knife

  * Following rip-containers are created.

  * /dvdrip/iso
  * /dvdrip/dvd
  * /dvdrip/bluray
  * /dvdrip/network
  * /dvdrip/vobcopy

  * medibuntu is added to your /etc/apt/sources.list and the following software is installed

  * mencoder
  * netcat
  * original-awk
  * dvdauthor
  * vobcopy
  * mkisofs
  * dvd+rw-tools
  * lsdvd
  * gddresque
  * submux-dvd
  * submux-dvd
  * transcode
  * mjpegtools
  * libdvdcss2
  * openssh-server
  * openssh-client
  * liba52-0.7.4
  * libfaac0
  * libmp3lame0
  * libmp4v2-0
  * libogg0
  * libsamplerate0
  * libx264-85
  * libxvidcore4
  * lynx
  * build-essential
  * libc6-dev
  * libssl-dev
  * libgl1-mesa-dev
  * libqt4-dev
  * libbz2-1.0
  * libgcc1
  * libstdc++6
  * zlib1g


  * The following packages from the above list are used by makemkv and must not be present if you disable bluray-functions.

  * build-essential lynx libc6-dev libssl-dev libgl1-mesa-dev libqt4-dev

###  ###
###  ###
### I only a have dvd-drive. Can I use this addon without a blueray ? ###

---

###  ###
  * Yes. Inside the script-settings is a radio-button to enable / disable all bluray functions.
  * If you would like to transcode a dvd to mkv you have to activate the bluray-part.

###  ###
###  ###
### Is this script setup.sh running only on Ubuntu 10.04 LTS based systems ? ###

---

###  ###
  * Yes.But it should be easy to change it for a system other than Ubuntu.
###  ###
###  ###
### Could the provided shell-scripts be replaced with own scripts ? ###

---

###  ###
  * Yes. You can replace the shell-scripts with allmost all that is running on linux.
  * You have to use the API of this addon to be compatible with the GUI-part .

### I would like to improve the addon with patches. What should I do ? ###

---

###  ###
  * I only accept svn diff patches against the current trank.
  * If your diff contains binary exectuable files the full source-code of this binarys must be within the  diff-file or the patch will not be integrated.
  * Only GPL licenced code will be accepted. Any none GPL code or binary will not be accpeted !
  * If you decide to extend the plugin for one of the missing os (windows / mac) please include binarys for 32 and 64 bit systems.

###  ###
###  ###
### The addon speaks only English / French and German . Could my own native language be added ? ###

---

###  ###
  * send me a diff-file

###  ###
### To run makemkvcon do I neeed to purchase a licence-key  ? ###

---

###  ###
  * No . As long makemkv remains beta there will allways be a key to onbtain here (http://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053)

  * If you receive the Message "Licence-key for makemkv expired" inside the addon You have to replace your current licence-key with a valid-key.

You can set the licence key here :
```
user@xbmcdev:~$ cd .MakeMKV/
user@xbmcdev:~/.MakeMKV$ ls -al
total 16
drwxr-xr-x  2 root root   26 2010-07-10 18:01 .
drwxr-xr-x 45 user user 8192 2010-08-23 21:58 ..
-rw-r--r--  1 root root  187 2010-08-23 20:57 settings.conf
user@xbmcdev:~/.MakeMKV$ 
```

Inside the file settings.conf the licence key can be updated or deleted.

###  ###
### What is the default password for the Expert-Mode ? ###

---

###  ###
  * 1234
### If I transcode a DVD do I have AC3 sound ? ###

---

###  ###
  * Yes , but only for the primary audio-language.The secound audio-language is downmixed to be faster with the transcoding.
  * If you wish to have also the secound audio track in AC3 do edit dvd-handbrake.sh

### I found a error. What should I do ? ###

---

###  ###
  * read the xbmc.log and make a copy for the error-ticket.
  * Create a error-ticket. (http://code.google.com/p/swiss-army-knife/issues/list
  * Tickets without a valid xbmc.log (and may other logs from the log-directory) are be set to invalid.

##  ##
##  ##
### Where is the output from all this shell-scripts writen ? ###

---

###  ###
  * If you are running the scripts interactive you see the output on the console.
  * After the release of 0.6.15 all shell-scripts executed over the addon have a single file in wich the output will be written.
  * **$HOME/swiss.army.knife/ssh**
