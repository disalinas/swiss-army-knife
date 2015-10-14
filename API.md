####  ####
####  ####
####  ####
### Generic api-functions for all shell-scripts ###

  * Are valid for any action -> copy to iso , transcoding or copy
  * The gui-handling will only work with the above files.
  * You could replace a internal shell-scipt with your own, if you like to do this.
  * As long you are using this functions to report-back to the gui-part, you can replace the linux-shell-scripts with anything you like.
  * You could use a local installed Python or anything other that is executeable.
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/JOB ###

---

  * As long a transcode or ripping function is running this file do exist
  * Valid values : /dev/sr0 or a file-name
  * Example (JOB)
```
/dev/sr0
```

Note : This file is used as a lock.
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/media/state ###

---

  * Contains a detailed state about the inserted disk
  * Valid values : BLURAY or DVD-ROM
  * Example (state)
```
BLURAY
```
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress/progress ###

---

  * Progress from 0-101. This value will be used to display progress-bar inside the gui
  * Valid Values : 0-101
  * Only integer-values are allowed ... no float-values or %

```
0 .. 100  this progress will be shown as %
101       this stage doesn't have a progress-bar to show (information inside the gui if value 101)
```
  * Example (progress)

```
87
```
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress/progress-pid ###

---

  * contains all the pid's that would be needed to kill the current transaction over the gui
  * On or more PIDs that should be killed.If multiple pid are writtem has every a single line.
  * If multiple pid's are written , the kill order is from botton to top
  * Example (progress-pid)
```
30889
20903
88939
```

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress/progress-files ###

---

  * contains all the files including full path that could be removed in the case th user wishes to abbort.
  * Every file use at least one line.
  * Example (progress-files)
```
/dvdrip/iso/300.iso
```


---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress/progress-done ###

---

  * This file is the trigger for the GUI that all actions are done
  * Example (progress-done)
```
DONE 
```
####  ####
####  ####
####  ####
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress/stages-counter ###

---

  * How may stages the pending process or processes will have ....
  * Valid Values : 1-XX
  * Only Integer-Values are alloewd and if you have 3 stages you must have 3 lines inside description file.
  * Example (stages-counter)
```
 3
```
####  ####
####  ####
####  ####
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/progress/stages-descriptions ###

---

  * Descriptions to stages. This text will be shown inside the gui
  * Example (stages-descriptions)
```
 1 copy subtitle 1
 2 copy subtitle 2
 3 transcode vob
```
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script-video-ripper/progress/stages-current ###

---

  * Only contains the nummer (index) of the possible stages
  * Valid Values : 1-XX
  * Example (stages-current)
```
 2
```
####  ####
####  ####
####  ####
# bluray  api-functions for all shell-scripts #
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/bluray/BR\_VOLUME ###

---

  * Contains the volume name of bluray
  * All spaces or non asci chars should be removed inside the script.
  * Example (BR\_VOLUME)
```
300
```
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/bluray/BR\_TRACKS ###

---

  * Contains the list of all tracks witch could be later selected inside the gui.
    * The shell-script musst produce this list or the selection list will not show up.
  * Example (BR\_TRACKS)
```
TRACK : [0] DURATION : [1:56:38] CHAPTERS : [29]
TRACK : [1] DURATION : [0:05:30] CHAPTERS : [32]
TRACK : [2] DURATION : [0:38:23] CHAPTERS : [11]
TRACK : [3] DURATION : [0:24:36] CHAPTERS : [0]
TRACK : [4] DURATION : [0:04:32] CHAPTERS : [0]
TRACK : [5] DURATION : [0:06:43] CHAPTERS : [0]
TRACK : [6] DURATION : [0:14:42] CHAPTERS : [0]
TRACK : [7] DURATION : [0:03:40] CHAPTERS : [0]
TRACK : [8] DURATION : [0:03:23] CHAPTERS : [0]
TRACK : [9] DURATION : [0:05:51] CHAPTERS : [0]
```




####  ####
####  ####
####  ####
# dvd api-functions for all shell-scripts #
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script.video.swiss.army.knife/dvd/DVD\_VOLUME ###

---

  * Contains the volume name of dvd
  * All spaces or non asci chars should be removed inside the script.
  * Example (DVD\_VOLUME)
```
STARGATE
```
####  ####
####  ####
####  ####

---

### File .xbmc/userdata/addon\_data/script-video-ripper/dvd/DVD\_TRACKS ###

---

  * Contains the list of all tracks witch could be later selected inside the gui.
    * The shell-script musst produce this list or the selection list will not show up.
  * Example (DVD\_TRACKS)
```

```