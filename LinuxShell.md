### Commands inside the shell-linux folder ###

Inside the folder shell-linux are several shell-scripts that can be executed over
ssh or manually.In the case of a unexpected error I would try to run them in a terminal.

### PLEASE DO NEVER EXECUTE THIS SHELL-SCRIPTS AS USER ROOT !!! ###

  * Only execute the script as the xbmc user you did run setup.sh
  * After the release 0.6.15 it is not longer possible to run the scripts as user root.

---

## state.sh ##

---

  * Number of arguments : 1

---

  * $1 device for bluray or dvd /dev/sr0

---

  * Description : Do detect if a DVD or a Bluray is inside the device (par.1)
  * Sample : **./state.sh /dev/sr0**
  * Output :

```
----------------------------------------------------------------------------
script    : state.sh
version   : 0.6.16 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO [media:[DVD-ROM]]

----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

The following codes are returned :

```
ZERO                         0
EXPECTED_ARGS                1
E_BADARGS                    1  
E_INACTIVE                   3
E_CRC_ERROR                  4
E_UNKNOWN_MEDIA              5
E_TOOLNOTF                   50
E_SUID0                      254
E_WRONG_SHELL                255
```



---

## bluray-chapter.sh ##

---

  * Number of arguments : 1

---

  * $1 device for bluray /dev/sr0

---

  * Description : Generate a list of all tracks from a Bluray (par.1)
  * Sample : **./bluray-chapter.sh /dev/sr0**
  * Output :
```
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./bluray-chapter.sh /dev/sr0

---------------------------------------------------------------------
script    : bluray-chapter.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
---------------------------------------------------------------------

INFO generating track-list ... please be patient.


INFO webserver on port 51000 ready


INFO track-index:[0] length:[1:56:38] chapters:[29]
INFO track-index:[1] length:[0:05:30] chapters:[32]
INFO track-index:[2] length:[0:38:23] chapters:[11]
INFO track-index:[3] length:[0:24:36] chapters:[0]
INFO track-index:[4] length:[0:04:32] chapters:[0]
INFO track-index:[5] length:[0:06:43] chapters:[0]
INFO track-index:[6] length:[0:14:42] chapters:[0]
INFO track-index:[7] length:[0:03:40] chapters:[0]
INFO track-index:[8] length:[0:03:23] chapters:[0]
INFO track-index:[9] length:[0:05:51] chapters:[0]

INFO [track:[0]  duration:[1:56:38]]
INFO [volname:[300]]


----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

---

## bluray-transcode.sh ##

---

  * Number of arguments : 4

---

  * $1 device for bluray /dev/sr0
  * $2 directory to store mkv file /dvdrip/bluray
  * $3 name of mkv-file without any extension
  * $4 bluraytrack to export

---

  * Description : Generates a mkv file from a specific track from a bluray.
  * Sample : **./bluray-transcode.sh /dev/sr0 /dvdrip/bluray 300tr1 1**
  * Output :
```
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./bluray-transcode.sh /dev/sr0 /dvdrip/bluray 300tr1 1

----------------------------------------------------------------------------
script    : bluray-transcode.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO processing data

......

INFO processing data done

----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
```


---

## check-mkv.sh ##

---

  * Number of arguments : none

---

  * Description : Do check if makemkv is running with a expired licence-key
  * Sample : **./check-mkv.sh**
  * Output :
```
root@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux# ./check-mkv.sh 

----------------------------------------------------------------------------
script    : check-mkv.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

makemkvcon is using a valid licence-key

----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
root@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux# 
```

---

## dvd-chapter.sh ##

---

  * Number of arguments : 2

---

  * $1 device for dvd /dev/sr0
  * $2 automode 1 or 0 (default 1)

---

  * Description : Generate a list of all tracks from a DVD (par.1)
  * Sample : **./dvd-chapter.sh /dev/sr0 1**
  * Output :
```
ser@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./dvd-chapter.sh /dev/sr0 1

----------------------------------------------------------------------------
script    : dvd-chapter.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO track-index:[00] length:[01:51:50.240] chapters:[30]
INFO track-index:[01] length:[00:00:12.020] chapters:[01]
INFO track-index:[02] length:[00:06:41.240] chapters:[01]
INFO track-index:[03] length:[00:00:47.020] chapters:[01]
INFO track-index:[04] length:[00:04:43.050] chapters:[02]
INFO track-index:[05] length:[00:00:47.160] chapters:[01]


INFO volume-name of the current inserted dvd is [300]
INFO automatic selected track from inserted dvd [01][line-index]
INFO default language 1 [en]
INFO default lang-1 : index=0

----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

---

## dvd-atracks.sh ##

---

  * Number of arguments : 2

---

  * $1 device for dvd /dev/sr0
  * $2 track from dvd (warning : indexes do start with 1 !!!)

---

  * Description : Generate a list of all tracks from a DVD (par.1)
  * Sample : **./dvd-atracks.sh /dev/sr0 1**
  * Output :
```
----------------------------------------------------------------------------
script    : dvd-atracks.sh
version   : 0.6.16 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO audio-tracks from dvd-track [1]

Audio: 1 Language: en - English
Audio: 2 Language: de - Deutsch
Audio: 3 Language: es - Espanol
Audio: 4 Language: en - English
Audio: 5 Language: en - English
Audio: 6 Language: en - English
Audio: 7 Language: en - English
Audio: 8 Language: en - English


INFO subtitles-tracks from dvd-track [1]

Subtitle: 01 Language: en - English
Subtitle: 02 Language: de - Deutsch
Subtitle: 03 Language: es - Espanol
Subtitle: 04 Language: xx - Unknown
Subtitle: 05 Language: xx - Unknown
Subtitle: 06 Language: xx - Unknown
Subtitle: 07 Language: xx - Unknown
Subtitle: 08 Language: xx - Unknown
Subtitle: 09 Language: xx - Unknown
Subtitle: 10 Language: xx - Unknown
Subtitle: 11 Language: xx - Unknown
Subtitle: 12 Language: xx - Unknown
Subtitle: 13 Language: xx - Unknown
Subtitle: 14 Language: xx - Unknown
Subtitle: 15 Language: xx - Unknown
Subtitle: 16 Language: xx - Unknown
Subtitle: 17 Language: xx - Unknown
Subtitle: 18 Language: xx - Unknown
Subtitle: 19 Language: xx - Unknown
Subtitle: 20 Language: xx - Unknown
Subtitle: 21 Language: xx - Unknown
Subtitle: 22 Language: xx - Unknown
Subtitle: 23 Language: xx - Unknown
Subtitle: 24 Language: xx - Unknown
Subtitle: 25 Language: xx - Unknown
Subtitle: 26 Language: xx - Unknown
Subtitle: 27 Language: xx - Unknown
Subtitle: 28 Language: xx - Unknown
Subtitle: 29 Language: xx - Unknown
Subtitle: 30 Language: xx - Unknown
Subtitle: 31 Language: xx - Unknown
Subtitle: 32 Language: xx - Unknown


----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

The following codes are returned :

```
ZERO                         0
E_BADARGS                    1
EXPECTED_ARGS                2
E_TOOLNOTF                   50
E_SUID0                      254
E_WRONG_SHELL                255
```


---

## dvd-handbrake.sh ##

---

  * Number of arguments : 5 (optional up to 9)

---

  * $1 device for dvd /dev/sr0
  * $2 directory to store the generated mkv file
  * $3 name of the mkv-file without any extension
  * $4 track from dvd (warning : indexes do start with 1 !!!)
  * $5 audio-language to extract (index only)

---

  * Description : Create a mkv from a DVD-Track
  * Sample : **./dvd-handbrake.sh /dev/sr0 /dvdrip/dvd 300tr3 3 0 -a 1 -s 0**
  * Output :
```
ser@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./dvd-handbrake.sh /dev/sr0 /dvdrip/dvd 300tr3 3 0 -a 1 -s 0

----------------------------------------------------------------------------
script    : dvd-handbrake.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO starting mencoder
INFO mencoder command executed


INFO processing data pass 1 of 3

........................................................................................................................................................................................................................................................................

INFO processing data pass 1 of 3 done


INFO starting HandBrakeCLI
INFO HandBrakeCLI command executed


INFO processing data pass 2 of 3

.....................................................................................

INFO processing data pass 2 of 3 done


INFO processing data pass 3 of 3

...............................................................................................................................................................................................................................................................................................................................................................................................

INFO processing data pass 3 of 3 done


processing data done

----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

---

## dvd-iso.sh ##

---

  * Number of arguments : 3

---

  * $1 device for bluray /dev/sr0
  * $2 directory to store the iso
  * $3 iso-name without any extension

---

  * Description : save a dvd to a local iso file
  * Sample : **./dvd-iso.sh /dev/sr0 /dvdrip/iso 300**
  * Output :
```
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./dvd-iso.sh /dev/sr0 /dvdrip/iso 300 

----------------------------------------------------------------------------
script    : dvd-iso.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO expected iso-size in bytes [6332686336]
INFO starting dd
INFO processing data

..........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................

INFO processing data done


----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

---

## dvd-resque.sh ##

---

  * Number of arguments : 3

---

  * $1 device for dvd (example /dev/sr0)
  * $2 directory to store the iso
  * $3 iso-name without any extension

---

  * Description : save a dvd to a local iso file even with possible crc-errors
  * Sample : **./dvd-resque.sh /dev/sr0 /dvdrip/iso 300**
  * Output :
```
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./dvd-rescue.sh /dev/sr0 /dvdrip/iso 300resque 

----------------------------------------------------------------------------
script    : dvd-rescue.sh
version   : 0.6.11 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------

INFO expected iso-size in bytes [6332686336]
INFO starting ddrescue
INFO processing data

........................................................................................................................................................................................................................................................................................................................................................................................................................................

INFO processing data done


----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```

---

## dvd-vcopy.sh ##

---

  * Number of arguments : 2

---

  * $1 device for dvd (example /dev/sr0)
  * $2 directory to store the copy of the vobs

---

  * Description : save all vobs to a local directory based on the volname of the dvd
  * Sample : **./dvd-resque.sh /dev/sr0 /dvdrip/vobcopy**
  * Output :
```
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ ./dvd-vcopy.sh /dev/sr0 /dvdrip/vobcopy

----------------------------------------------------------------------------
script    : dvd-vcopy.sh
version   : 0.6.12 [swiss-army-knife addon]
copyright : (C) <2010>  <linuxluemmel.ch@gmail.com>
changed to /home/user/.xbmc/addons/script.video.swiss.army.knife/shell-linux
----------------------------------------------------------------------------


INFO get size of all vob-files[/media/DUNE_KINOFASSUNG/VIDEO_TS]
INFO volume-name[DUNEKINOFASSUNG]
INFO starting vobcopy


..............................................................................................................................................................................................................

INFO processing data done


----------------------- script rc=0 -----------------------------
-----------------------------------------------------------------
user@xbmcdev:~/.xbmc/addons/script.video.swiss.army.knife/shell-linux$ 
```