# XBMC Addon for transcoding videos from dvd's and bluray's #

#### Project news 31.01.2014 ####

After a long period of time that I for one would call a nightmare I'm back.
Expect a new Release of swiss-army-knife for XBMC 13 soon.


#### Project news 14.11.2011 ####
  * Current Project-Team welocmes new member tehninjo0

#### Project news 03.11.2011 ####
  * mkv release 1.6.16 is ready to use.

#### Project news 31.08.2011 ####
  * mkv release 1.6.14 is ready to use.

#### Project news 12.07.2011 ####
  * mkv release 1.6.12 for 32 bit systems is ready to use.

#### Project news 23.06.2011 ####
  * Release 0.6.20 is ready and can be installed over the repository luxeria.


#### Project news 13.06.2011 ####
  * Updated repository zip file for installation over addon-manager

### Project news 01.02.2011 ###
  * Release 0.6.18 is finished and can be installed over repository luxeria (http://code.google.com/p/luxeria-repository/)
  * The addon speaks English / German and French.
  * Please run setup.sh after installation
  * Please execute the settings of the addon prior to starting.


### Project news 10.08.2010 ###
  * Release 0.6.15 is ready to download over the luxeria-repository.
  * The addon speaks English / German and French.
####  ####
####  ####
####  ####


### Is it possible to view Bluray's directly with this addon ? ###

---

  * No. This tools was only provided to create a mkv-backup.
  * Too watch a Bluray directly from the disk, you could use a existing addon called plugin.video.makemkv (http://forum.xbmc.org/showthread.php?t=67420)
  * But you could use my prebuilded binarys for makemkv if don't like to compile makemkv.
  * The provided binarys are only tested on ubuntu 10.04 LTS.

####  ####
####  ####
####  ####
### Will there be a release like the Red-Pill and the Blue-Pil ? ###

---

####  ####
  * No. There will be only one release of this addon.
  * The initial code-base for this addon is the latest Red-Pill release including latest patches.
####  ####
####  ####
####  ####
### On wich systems does this addon working  ? ###

---

####  ####
  * Ubuntu 10.04 LTS or higher
  * XBMC 10.0 or higher
####  ####
####  ####
####  ####
### What about Windows and Mac OS X ? ###

---

####  ####
  * Maybe later releases are portet to Windows and Mac OS X.
  * At the time of this writing (june 2010) I use Windows only inside a Virtual PC (Virtualbox) and I don't have a Mac to do any Mac related parts.
  * Feel free to provide me with the patches to support this two Operating-Systems.
  * How you can create patches is linked  here.http://www.yolinux.com/TUTORIALS/Subversion.html
  * This new python code has a clean GUI and OS part.This may speed up the processing to port this addon to other operating-systems than linux.
####  ####
####  ####
####  ####
### What was the reason to call it "Swiss-Army-Knife" ? ###

---

####  ####
  * A closer look inside the addon shows that it is a collection of externel tools provided with a nice looking gui for XBMC (like the knife)
  * I live in switzerland.
  * I have a swiss-army-knife.
  * The knife is red ( :-) red-pill)
####  ####
####  ####
####  ####
### What external tools are used inside the addon ? ###

---

####  ####
I provide only a short-list of the most important external programms.

  * dd
  * Handbrake
  * Makemkv
  * Transcode
  * MPlayer
  * Lynx
  * MJPEG Tools

and many tools more ....
####  ####
####  ####
####  ####
### Is it allowed to make a copy of any media (cd / dvd / blueray) I own ? ###

---

####  ####
Yes ! Inside the following countrys it is allowed:

  * Switzerland
  * Spain
  * Sweden
  * Canada
  * Australia

This is not a complete list of countrys with a faire-use-law. For further information look here http://en.wikipedia.org/wiki/Ripping.

  * The following links describe the law inside switzerland.


---

  * English http://www.suisa.ch/en/services/questions-answers/internet-mp3-cd-pressing/
  * Deutsch http://www.suisa.ch/de/services/questions-answers/internet-mp3-cd-pressing/
  * France  http://www.suisa.ch/fr/services/questions-answers/internet-mp3-cd-pressing/
  * Italia  http://www.suisa.ch/it/services/questions-answers/internet-mp3-cd-pressing/

---

  * http://www.admin.ch/ch/d/sr/231_1/a19.html

---


Neither the author of this addon or the xbmc-team are responsible for:

  * Using this addon inside a country where it is not allowed to be used.
  * Linking this website inside a url or a forum.
  * Or any other action caused by this tool.

According to general law the use (all functions) of this addon is may not allowed inside:

  * USA
  * UK
  * Germany

There are a few other countrys like France that allow to copy a dvd as long the css remains intact.

  * Inside France as a example,the iso copy function would be allowed.

###  ###
###  ###
###  ###
### Why can some DVD's not be saved as IS0's and others can  ? ###

---

###  ###
  * Some newer DVD's contains a lot of invalid CRC-Checksumms on the media to prevent this kind of copy.(Thanks Hollywod and Sony)
  * Try to Transcode the DVD instead.
  * ddrescue compared to dd may produce more ISO's that are play fine inside xbmc, but there is still no warranty that it will allways works.
  * http://en.wikipedia.org/wiki/Compact_Disc_and_DVD_copy_protection
  * http://en.wikipedia.org/wiki/List_of_copy_protection_schemes#Commercial_DVD_protection_schemes
  * http://en.wikipedia.org/wiki/Libdvdcss
###  ###
###  ###
###  ###
### Can Blurays be saved as ISO's like the DVD's? ###

---

###  ###
  * No. This is not possible but patches are weclome ;-)
###  ###
###  ###
###  ###
### Contact the author of the script ###

---

###  ###
  * You can send me a email to **linuxluemmel.ch@gmail.com**
  * Use the feedback URL http://code.google.com/p/swiss-army-knife/wiki/Feedback
###  ###
###  ###
###  ###
### Bluray Disc is not converted.Where I can get help ? ###

---

###  ###
###  ###
This addon is only a nice gui to the programm makemkv and for this reason you should
visit the linux-forums.

  * http://www.makemkv.com/forum2/index.php
###  ###
###  ###
### Can the provided debian-files be installed on a older Ubuntu than 10.04 ? ###

---

###  ###
###  ###
  * No. The debian-packages for 32 and 64 bit are only provided for Ubuntu 10.04 LTS
  * Inside the download-section You find the source-code of both packages (Handbrake and makemkv).In this case you should build them on your own system.
  * To build your own debian-packages follow the instructions inside of both source-directorys.
  * I do not recommand to install the software with the command "make install". I guess checkinstall is a better solution for you.https://help.ubuntu.com/community/CheckInstall


