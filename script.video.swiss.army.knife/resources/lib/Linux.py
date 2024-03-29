#!/usr/bin/python
# -*- coding: utf-8 -*-
#########################################################
# SCRIPT  : Linux.py                                    #
#########################################################
# AUTHOR  : Hans Weber                                  #
# EMAIL   : linuxluemmel.ch@gmail.com                   #
# XBMC    : Version 10.0 or higher                      #
# PYTHON  : internal xbmc python 2.4.X                  #
# OS      : Linux                                       #
# TASKS   : This python code contains only os-dependet  #
#           functions and must be rewritten for every   #
#           os that should exexcute this addon.         #
# VERSION : 0.6.21                                      #
# DATE    : 23-06-11                                    #
# STATE   : Beta 5                                      #
# LICENCE : GPL 3.0                                     #
#########################################################
#                                                       #
# Project-Homepage :                                    #
# http://code.google.com/p/swiss-army-knife/            #
#                                                       #
#########################################################




####################### IMPORTS #########################

import xbmc, xbmcgui,xbmcaddon
import os, sys, thread, stat, time, string, re

#########################################################




####################### GLOBAL DATA #####################

__settings__       = xbmcaddon.Addon(id='script.video.swiss.army.knife')
__language__       = __settings__.getLocalizedString

__configLinux__    = []
__temp_files__     = []
__data_container__ = []
__exec_bluray__    = []
__exec_dvd__       = []
__verbose__        = 'false'
__stage_percent__  = 0
__stage_last__     = False

__lock__ = thread.allocate_lock()

#########################################################





#########################################################
# Function  : OSIlog                                    #
#########################################################
# Parameter :                                           #
#                                                       #
# msg         String to be shown inside GUI             #
#                                                       #
# Returns   : none                                      #
#########################################################
def OSlog(msg):

    if (__verbose__ == 'true'):   
       __lock__.acquire(1)    
       xbmc.output("[%s]: [OSlog]  %s\n" % ("swiss-army-knife",str(msg)))
       __lock__.release()  
    return

#########################################################





#########################################################
# Function  : OSConfiguration                           #
#########################################################
# Parameter :                                           #
#                                                       #
# index       index how many config-entrys are used     #
#                                                       #
# Returns   :                                           #
#                                                       #
# config      List with all configurations settings     #
#                                                       #
#########################################################
def OSConfiguration(index):

    global __configLinux__
    global __temp_files__
    global __data_container__
    global __exec_bluray__
    global __exec_dvd__ 
    global __verbose__

    config = []

    for i in range(0,index):
	config.append("empty")

    # Default settings addon

    config[0] =  __settings__.getAddonInfo("profile")
    config[1] =  __settings__.getSetting("id-device-dvd")
    config[2] =  __settings__.getSetting("id-device-bluray")
    config[3] =  __settings__.getSetting("id-iso")
    config[4] =  __settings__.getSetting("id-dvd")
    config[5] =  __settings__.getSetting("id-bluray")
    config[6] =  __settings__.getSetting("id-command")
    config[7] =  __settings__.getSetting("id-lang1")
    config[8] =  __settings__.getSetting("id-lang2")
    config[9] =  __settings__.getSetting("id-def-dvd")
    config[10] = __settings__.getSetting("id-show-bluray")
    config[11] = __settings__.getSetting("id-show-network")
    config[12] = __settings__.getSetting("id-show-burning")
    config[13] = __settings__.getSetting("id-transcode")
    config[14] = __settings__.getSetting("id-customer")
    config[15] = __settings__.getSetting("id-burn")
    config[16] = __settings__.getSetting("id-netcat")
    config[17] = __settings__.getSetting("id-verbose")
    config[18] = __settings__.getSetting("id-dvd-subt")
    config[19] = __settings__.getSetting("id-expert")
    config[20] = __settings__.getSetting("id-password")
    config[21] = __settings__.getSetting("id-vobcopy")
    config[22] = __settings__.getSetting("id-network")

    # Timeout values that are definied inside the settings
    # If you receive a Timeout-Error you should increase the value 

    config[23] = __settings__.getSetting("id-t1") 
    config[24] = __settings__.getSetting("id-t2")
    config[25] = __settings__.getSetting("id-t3")


    # More configuration settings after last alpha 

    config[50] = __settings__.getSetting("id-iphone")
    config[51] = __settings__.getSetting("id-psp")   
    config[55] = __settings__.getSetting("id-delete")   
    config[56] = __settings__.getSetting("id-eject")   
    config[57] = __settings__.getSetting("id-file-source")
    config[58] = __settings__.getSetting("id-use-allways-default")   
    config[59] = __settings__.getSetting("id-disable-protect")
    config[60] = __settings__.getSetting("id-disable-mkv-licence")
    config[61] = __settings__.getSetting("id-notifications") 
    config[62] = __settings__.getSetting("id-struct-protect")  
    config[63] = __settings__.getSetting("id-check-update")  
  
    # Modul-global variable to detect if debug-log is active

    __verbose__ = config[17]

    # On startup we need to check that all data-containers are writeable

    # Index 0 : dvd-iso container 
    # Index 1 : dvd-h264 container 
    # Index 2 : bluray-mkv container 
    # Index 3 : dvd-vobcopy container
    # Index 4 : network container  
    # Index 5 : transcode-dvd container 
    # Index 6 : ssh-log directory
    # Index 7 : iphone-dvd container 
    # Index 8 : psp-dvd container 

    __data_container__.append(config[3])  
    __data_container__.append(config[4])
    __data_container__.append(config[5])
    __data_container__.append(config[21])
    __data_container__.append(config[22]) 
    __data_container__.append(config[13])  
    __data_container__.append(os.getenv("HOME") + '/swiss.army.knife/ssh')  
    __data_container__.append(config[50])  
    __data_container__.append(config[51])  

    # We need to write a few files on startup inside the addon-dirctory

    # DVD_LANG1
    # DVD_LANG2
    # DVD_SUB
    # KILL_FILES

    # Over these files we know inside the shell-scripts witch languages and
    # subtitles we would like to transcode

    # Without this files placed inside the addon-directory the shell-scripts 
    # can not transcode default languages ..

    if (config[7] != 'none'):
        sys.platform.startswith('linux')
        command ="echo -n " + config[7] + " > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG1"
        __lock__.acquire(1)   
        status = os.system("%s" % (command))
        __lock__.release() 

    if (config[8] != 'none'):
        sys.platform.startswith('linux')         
        command = "echo -n " + config[8] + " > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG2"
        __lock__.acquire(1)  
        status = os.system("%s" % (command))
        __lock__.release()  
    else:
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_LANG2 > /dev/null 2>&1"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release()  

    if (config[18] != 'none'):
        sys.platform.startswith('linux')
        command = "echo -n " + config[18] + " > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_SUB"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release() 
    else:
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_SUB > /dev/null 2>&1"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release()   

    if (config[55] == 'true'):
        sys.platform.startswith('linux')
        command = "echo -n DELETE ALL FILES IF PROCESS TERMINATE ! > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/KILL_FILES"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release() 
    else:
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/KILL_FILES > /dev/null 2>&1"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release() 

    if (config[56] == 'true'):
        sys.platform.startswith('linux')
        command = "echo -n EJECT MEIDUM AFTER SUCCESS ! > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/EJECT"
        __lock__.acquire(1)  
        status = os.system("%s" % (command))
        __lock__.release()  
    else:
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/EJECT > /dev/null 2>&1"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release() 

    if (config[62] == 'true'):
        sys.platform.startswith('linux')
        command = "echo -n STRUCTUR-PROTECTION FOR DVD IS ACTIVE ! > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_STRUCTUR_PROTECTION"
        __lock__.acquire(1)  
        status = os.system("%s" % (command))
        __lock__.release()  
    else:
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_STRUCTUR_PROTECTION > /dev/null 2>&1"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release() 


    # All the options that can be enabled or disabled over settings or during the execution of setup.sh 
    # are reported back to the shell-scripts.
  
    if (config[10] == 'true'):
        sys.platform.startswith('linux')
        command = "echo -n BLURAY ENABLED > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/BLURAY_ENABLED"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release()   

        # If the file BLURAY_DISABLED exist we remove it now ....

        command = "rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/BLURAY_DISABLED >/dev/null 2>&1"
        __lock__.acquire(1)  
        status = os.system("%s" % (command))
        __lock__.release()  

    else:
        command = "echo -n BLURAY DISABLED > $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/BLURAY_DISABLED"
        __lock__.acquire(1)  
        status = os.system("%s" % (command))
        __lock__.release()  

        # If the file BLURAY_ENABLED exist we remove it now ....

        command = "rm $HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/BLURAY_ENABLED >/dev/null 2>&1"
        __lock__.acquire(1)  
        status = os.system("%s" % (command))
        __lock__.release()  

        # Even if the paramter [62] is set to true .... we can not enable a option that needs makemkvcon in any case 

        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script.video.swiss.army.knife/DVD_STRUCTUR_PROTECTION > /dev/null 2>&1"
        __lock__.acquire(1) 
        status = os.system("%s" % (command))
        __lock__.release() 


    # All used internal files are stored inside after here ...

    config[26] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/username'  
    config[27] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv.valid' 
    config[28] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/makemkv.invalid'

    # Every release has a sepeperate setup.done file .....

    config[29] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/0.6.20-setup.done'


    config[30] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/state'
    config[31] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress'
    config[32] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-pid'
    config[33] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-files'
    config[34] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/progress-done'
    config[35] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-counter'
    config[36] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-descriptions'
    config[37] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/progress/stages-current'
    config[38] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/ssh-log'
    config[39] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/log/ssh-test'
    config[40] = os.getenv("HOME") + '/.xbmc/addons/script.video.swiss.army.knife/shell-linux/'
    config[41] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_VOLUME'
    config[42] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/bluray/BR_TRACKS'
    config[43] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/BR_GUI'
    config[44] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/DVD_VOLUME'
    config[45] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/JOB'
    config[46] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/dvd/DVD_TRACKS'
    config[47] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/DVD_GUI'
    config[48] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/ADVD'
    config[49] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/SDVD'

    # More configuration settings 

    config[52] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/media/DVD-CRC'
    config[53] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/PWATCH'
    config[54] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script.video.swiss.army.knife/TERM_ALL'
   
    # With a list the delete of multiple files is very easy ;-)

    __temp_files__.append(config[30])
    __temp_files__.append(config[31])
    __temp_files__.append(config[32])
    __temp_files__.append(config[33])
    __temp_files__.append(config[34])
    __temp_files__.append(config[35])
    __temp_files__.append(config[36])
    __temp_files__.append(config[37])
    __temp_files__.append(config[38])
    __temp_files__.append(config[39])
    __temp_files__.append(config[41])
    __temp_files__.append(config[42])
    __temp_files__.append(config[43])
    __temp_files__.append(config[44])
    __temp_files__.append(config[45])
    __temp_files__.append(config[46])
    __temp_files__.append(config[47])
    __temp_files__.append(config[48])
    __temp_files__.append(config[49])


    # Store configuration inside modul global list

    __configLinux__ = config
       
    return config

#########################################################




#########################################################
# Function  : OSRun                                     #
#########################################################
# Parameter :                                           #
#                                                       #
# command     command to execute over ssh               #
# backg       boolean :                                 #
#             - true  command is put into background &  #
#             - false command is not startet over ssh   #
#               (very dangerous .... )                  #
# busys       boolean :                                 #
#             - show busy-dialog during the operation   #
#                                                       #
# Returns   :                                           #
#                                                       #
#             rc-val from os.system call                #
#                                                       #
#########################################################
def OSRun(command,backg,busys):

    global __configLinux__
    global __verbose__

    if (busys):
        xbmc.executebuiltin("ActivateWindow(busydialog)")
    sys.platform.startswith('linux')

    if (backg == True):
        sshlog ="echo \"" + command + "\" >> " + __configLinux__[38]
        status = os.system("%s" % (sshlog))
    else:
        sshlog = ""

    if (__verbose__ == 'true'):
        OSlog("Command to log inside ssh:" + sshlog)
        OSlog ("OSRun start")

    if (backg == True):
        commandexec = "ssh " + __configLinux__[6] + " " + __configLinux__[40] + command + " "
        commandexec = commandexec + " > /dev/null 2>&1 &"
        __lock__.acquire(1)  
        status = os.system("%s" % (commandexec))
        __lock__.release() 
        if (__verbose__ ==  "true"):
            OSlog("Command to run :" + commandexec)
            OSlog("status command [" + commandexec + "] is rc:=[" + str(status) +"]")
            OSlog ("OSRun end")
    else:
        commandexec = "/bin/bash  " + __configLinux__[40] + command + " "
        commandexec = commandexec + " > /dev/null 2>&1"
        status = os.system("%s" % (commandexec))
        if (__verbose__ ==  "true"):
            OSlog("Command to run :" + commandexec)
            OSlog("status command [" + commandexec + "] is rc:=[" + str(status) +"]")
            OSlog ("OSRun end") 

    if (busys):
        xbmc.executebuiltin("Dialog.Close(busydialog)")

    return status

#########################################################





#########################################################
# Function  : OSCheckMedia                              #
#########################################################
# Parameter :                                           #
#                                                       #
# Media       String with "BLURAY" or "DVD-ROM"         #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           Checked media is inside drive             #
# 1           No media found inside drive               #
# 2           State file do not exist                   #
# 3           DVD has a invalid file-system or use a    #
#             copy prevention !!!                       # 
#                                                       #
#########################################################
def OSCheckMedia(Media):

    global __configLinux__
    global __verbose__

    OSCleanTemp()

    # Execution of shell-script state.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("state.sh command ready to start")
 
    if (Media == 'BLURAY'):
        OSRun("br0.sh " +  __configLinux__[2],True,False)
    if (Media == 'DVD-ROM'):
        OSRun("dvd0.sh " +  __configLinux__[1],True,False)

    if (__verbose__ == "true"):
        OSlog("state.sh command executed")
    time.sleep(1) 

    WCycles = 3
    Waitexit = True
    rc = 0 

    xbmc.executebuiltin("ActivateWindow(busydialog)")  
    while (Waitexit):
           if (os.path.exists(__configLinux__[30])):
               if (__verbose__ ==  "true"):
                   OSlog("state-files exist ...exit loop")
                   OSlog("WCycles Value :" + str(WCycles))
                   OSlog("Timeout t1 :" + str(__configLinux__[23]))
               Waitexit = False
               rc = 0 
           else:
               WCycles = WCycles + 1
               time.sleep(1)
           if (WCycles >= __configLinux__[23]):
               if (__verbose__ ==  "true"):
                  OSlog("Timeout t1 reached for track-file  ...")
                  OSlog("increase timeout value for timeout t1")
               Waitexit = False 
               rc = 2

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    
    if (rc != 0): 
        return 2      

    # We should now have the file with the state

    if (os.path.exists(__configLinux__[30])):
        f = open(__configLinux__[30],'r')
        media = f.readline()
        media = media.strip()
        if (__verbose__ ==  "true"):
           OSlog("Media detected")
        f.close

        if (media == Media):

            # In a few cases the dvd that is inserted do not use 
            # a proper file-system -> any kind of copy-prevention 
            
            if (os.path.exists(__configLinux__[52])):
                os.remove(__configLinux__[52])
                return 3
            else:
                return 0
        else:
            return 1

#########################################################





#########################################################
# Function  : OSChapterBluray                           #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# tracklist   contains tracks or only "none"            #
#                                                       #
#########################################################
def OSChapterBluray():

    global __configLinux__
    global __verbose__

    tracklist = []

    # Execution of shell-script br1.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("bluray-chapter.sh command ready to start")

    OSRun("br1.sh " +  __configLinux__[2],True,False)

    if (__verbose__ == "true"):
        OSlog("bluray-chapter.sh command executed")

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We must wait until the file with the track-information could be read
    # Without the list of tracks we can not select inside the list .....
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(30)

    WCycles = 30
    Waitexit = True
    OSlog("Waiting until track-files exist ... WCycles:=" + str(WCycles))
    while (Waitexit):
           if (os.path.exists(__configLinux__[42])):
               if (__verbose__ == "true"):
                   OSlog("track-files exist ... WCycles:=" + str(WCycles))
               Waitexit = False
           else:
               WCycles = WCycles + 1
               time.sleep(1)
           time.sleep(1)

           if (WCycles >= __configLinux__[25]):
               if (__verbose__ == "true"):
                  OSlog("Timeout t3 reached for bluraytrack-file  ...")
                  OSlog("increase timeout value for timeout t3")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               tracklist.append('none')
               return tracklist

    xbmc.executebuiltin("Dialog.Close(busydialog)")

    if (__verbose__ ==  "true"):
        OSlog("track-files exist . Create list for GUI")

    # We should have the file with the state

    if (os.path.exists(__configLinux__[42])):
        trackfile = open(__configLinux__[42],'r')
        for line in trackfile.readlines():
                line = line.strip()

                #######################################################################
                # Warning : In the case we use makemkv it is not allowed to add       #
                # a track that is shorter than 120 secounds or all indexes are wrong  #
                #######################################################################

                tracklist.append(line)
        trackfile.close
        return tracklist
    else:
        tracklist.append('none')
        return tracklist

#########################################################




#########################################################
# Function  : OSCleanTemp                               #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   : none                                      #
#########################################################
def OSCleanTemp():

    global __temp_files__
    global __verbose__

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We have a global list that contains all temp. files
    # as it looks easy do delete all file inside the list

    for item in __temp_files__:
         if (os.path.exists(item)):
             os.remove(item)
             if (__verbose__ == "true"):
                 OSlog("file delete : " + item)
    time.sleep(1)
    xbmc.executebuiltin("Dialog.Close(busydialog)")

    return

#########################################################





#########################################################
# Function  : OSBlurayExecuteList                       #
#########################################################
# Parameter : none                                      #
#                                                       #
# auto_mode   Boolean : if true do set the parameters   #
#             for the execution                         #
#                                                       #
# Returns   :                                           #
#                                                       #
# GUIList     List of all parameters for transcoding    #
#                                                       #
#########################################################
def OSBlurayExecuteList(auto_mode):

    global __configLinux__
    global __exec_bluray__
    global __verbose__

    GUIList = []
    tmp = []


    xbmc.executebuiltin("ActivateWindow(busydialog)")

    if (os.path.exists(__configLinux__[43])):

       GUIFile = open(__configLinux__[43],'r')
       for line in GUIFile.readlines():
           line = line.strip()
           tmp.append(line)
       GUIFile.close

       # We prepare the arguments for bluray-transcode.sh


       if (auto_mode == True):
           OSlog ("Bluray-paramter set for automode")
           __exec_bluray__.append(tmp[0])
           __exec_bluray__.append(__configLinux__[5])
           __exec_bluray__.append(tmp[3])
           __exec_bluray__.append(tmp[1])
       else:
           OSlog ("Bluray-paramter not set for automode")

       # Add device
       GUIList.append(__language__(32151) + tmp[0])

       # Add track
       GUIList.append(__language__(32152) + tmp[1])

       # Add audio
       GUIList.append(__language__(32153))

       # Add length
       GUIList.append(__language__(32154) + tmp[2])

       # Add name excluding extension mkv

       GUIList.append(__language__(32155) + tmp[3])

       # Add accept and cancel button
       GUIList.append(__language__(32156))
       GUIList.append(__language__(32157))

       time.sleep(1)
       xbmc.executebuiltin("Dialog.Close(busydialog)")
       return GUIList

    else:

       time.sleep(1)
       xbmc.executebuiltin("Dialog.Close(busydialog)")
       GUIList.append("none")


       # Array-Index :
       # [0] bluray-device
       # [1] track
       # [2] audio
       # [3] length
       # [4] name of mkv excluding extenstion mkv

       return GUIList

#########################################################





#########################################################
# Function  : OSBlurayTranscode                         #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           Transcode process not started             #
# 1           Transcode process started                 #
#                                                       #
#########################################################
def OSBlurayTranscode():

    global __configLinux__
    global __exec_bluray__
    global __verbose__

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script br2.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("bluray-transcode.sh command ready to start")
        OSlog ("Bluray-paramter [0] : " + __exec_bluray__[0])
        OSlog ("Bluray-paramter [1] : " + __exec_bluray__[1])
        OSlog ("Bluray-paramter [2] : " + __exec_bluray__[2])
        OSlog ("Bluray-paramter [3] : " + str(__exec_bluray__[3]))

    OSRun("br2.sh " +  __exec_bluray__[0] + " " + __exec_bluray__[1] + " " + __exec_bluray__[2] + " " +  __exec_bluray__[3],True,False)


    if (__verbose__ == "true"):
        OSlog("bluray-transcode.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(20)

    WCycles = 20
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 1
           time.sleep(1)
           if (WCycles >= 50):
               if (__verbose__ == "true"):
                   OSlog("Timeout 50 secounds reached for pid-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array bluray

    parameters = len(__exec_bluray__)

    for index in range((parameters - 1),0):
        del  __exec_bluray__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSGetProgressVal                          #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0-100       Progress current process                  #
# 101         No value for process to watch             #
# -1          File for processsing could not be opened  #
#                                                       #
#########################################################
def OSGetProgressVal():

    global __configLinux__
    global __verbose__
    global __stage_percent__

    if (os.path.exists(__configLinux__[31])):
        ProgressFile = open(__configLinux__[31],'r')
        line =  ProgressFile.readline()
        ProgressFile.close
        line = line.strip()
        rvalue = int(line)
        __stage_percent__ = rvalue
        return rvalue
    else:
        return -1

#########################################################





#########################################################
# Function  : OSGetStagesCounter                        #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1-X         Current stage in progress                 #
# -1          File could not be opened                  #
#                                                       #
#########################################################
def OSGetStagesCounter():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[35])):
        ProgressFile = open(__configLinux__[35],'r')
        line =  ProgressFile.readline()
        ProgressFile.close
        line = line.strip()
        rvalue = int(line)
        return rvalue
    else:
        return -1

#########################################################





#########################################################
# Function  : OSGetpids                                 #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# pidList     contains a list with all PID's from the   #
#             current process or "none"                 #
#                                                       #
#########################################################
def OSGetpids():

    global __configLinux__
    global __verbose__

    pidList = []

    if (os.path.exists(__configLinux__[32])):
            PidFile = open(__configLinux__[32],'r')
            for line in PidFile.readlines():
                line = int(line.strip())
                pidList.append(line)
            PidFile.close
            return pidList
    else:
         pidList.append("none")
         return pidList

#########################################################





#########################################################
# Function  : OSCheckContainerID                        #
#########################################################
# Parameter :                                           #
#                                                       #
# index       index to list with data-containers        #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           Directory is not writeable or existing    #
# 0           Directory exists and is writeable         #
#                                                       #
#########################################################
def OSCheckContainerID(index):

    global __data_container__
    global __verbose__

    if (os.path.exists(__data_container__[index])):
        if (os.access(__data_container__[index],os.W_OK) == False):
           if (__verbose__ == "true"):
               OSlog("Container path [" + __data_container__[index] + "] is not writeable !")
           return 1
        else:
           if (__verbose__ == "true"):
               OSlog("Container path [" + __data_container__[index] + "] is checked succesfull for writeable attribut")
           return 0
    else:
        if (__verbose__ == "true"):
            OSlog("Container path [" + __data_container__[index] + "] is not found !")
        return 1

#########################################################






#########################################################
# Function  : OSCheckLock                               #
#########################################################
# Parameter :                                           #
#                                                       #
# Lockcheck   device or file to test for a lock         #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           Lock is set on device or file             #
# 0           Lock is free                              #
#                                                       #
#########################################################
def OSCheckLock(Lockcheck):

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[45])):
        Lockfile  = open(__configLinux__[45],'r')
        Lock = Lockfile.readline()
        Lockfile.close
        Lock = Lock.strip()
        if (Lock == Lockcheck):
            return 1
        else:
            return 0
    else:
        return 0

#########################################################






#########################################################
# Function  : OSKillProc                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           Error                                     #
# 0           successfull                               #
#                                                       #
#########################################################
def OSKillProc():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[45])):
        OSRun("kill-job.sh ",True,False)                          
        OSCleanTemp()
        return (0) 
    else:
        return (1)

#########################################################






#########################################################
# Function  : OSGetJobState                             #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           A job is running in background            #
# 0           no job found                              #
#                                                       #
#########################################################
def OSGetJobState():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[45])):
        return 1
    else:
        return 0

#########################################################





#########################################################
# Function  : OSChapterDVD                              #
#########################################################
# Parameter : Boolean                                   #
#                                                       #
# True 	      Shell script is using makemkvcon          #
# False       Shell script is using Handbrakecli	#
#                                                       #
# Returns   :                                           #
#                                                       #
# tracklist   contains all tracks from the dvd          #
#             If tracklist could not be read the list   #
#             only contains "none"                      #
#                                                       #
#########################################################
def OSChapterDVD(UsingMKV_Tracks):

    global __configLinux__
    global __verbose__

    tracklist = []

    # Because we need a mkv tracklist we call a other function  

    if (UsingMKV_Tracks == True):     
        tracklist =  OSChapterMKV()
        return tracklist   

    # Execution of shell-script br1.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd-chapter.sh command ready to start")

    OSRun("dvd1.sh " +  __configLinux__[1] + " 1 ",True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-chapter.sh command executed")

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We must wait until the file with the track-information could be read
    # Without the list of track we can not select inside the list .....
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(3)

    WCycles = 3
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[46])):
               if (__verbose__ == "true"):
                   OSlog("track-files exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 1
               time.sleep(1)
           if (WCycles >= __configLinux__[24]):
               if (__verbose__ == "true"):
                   OSlog("Timeout t2 reached for chapter-file")
                   OSlog("increase timeout value for timeout t2") 
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               tracklist.append('none')
               return tracklist

    xbmc.executebuiltin("Dialog.Close(busydialog)")

    if (__verbose__ == "true"):
        OSlog("track-files exist . Create list for GUI")

    # We should have the file with the state

    if (os.path.exists(__configLinux__[46])):
        trackfile = open(__configLinux__[46],'r')
        for line in trackfile.readlines():
                line = line.strip()

                #######################################################################
                # Warning : In the case we use makemkv it is not allowed to add       #
                # a track that is shorter than 120 secounds or all indexes are wrong  #
                #######################################################################

                ## if (UsingMKV_Tracks == True):

                ##    tcounter = line.count("[00:00")
                ##    if (tcounter == 0): 
                ##        tracklist.append(line)
                ## else:
                ##    tracklist.append(line)
 
                tracklist.append(line)

        trackfile.close
        return tracklist
    else:
        tracklist.append('none')
        return tracklist

#########################################################







#########################################################
# Function  : OSDVDTranscode                            #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           Transcode-process not startet             #
# 1           Transcode-process startet                 #
#                                                       #
#########################################################
def OSDVDTranscode():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd2.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd-handbrake.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    x = 0
    for number in __exec_dvd__:
        dvd_command = dvd_command + " " + __exec_dvd__[x]
        if (__verbose__ == "true"):
            OSlog("dvd-handbrake.sh Transcode para: [" + str(x) +  "]  " + __exec_dvd__[x])
        x = x + 1

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd2.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-handbrake.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(15)

    WCycles = 15
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached for dvd-pid-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSDVDExecuteList                          #
#########################################################
# Parameter :                                           #
#                                                       #
# auto_mode   Boolean : if true do set the parameters   #
#             for the execution                         #
#                                                       #
# Returns   :                                           #
#                                                       #
# GUIList     List with all parameters prior to the     #
#             execution from the GUI                    #
#                                                       #
#########################################################
def OSDVDExecuteList(auto_mode):

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    GUIList = []
    tmp = []


    xbmc.executebuiltin("ActivateWindow(busydialog)")

    if (os.path.exists(__configLinux__[47])):

       GUIFile = open(__configLinux__[47],'r')
       for line in GUIFile.readlines():
           line = line.strip()
           tmp.append(line)
       GUIFile.close

       if (auto_mode == True):

           # We prepare the arguments for dvd-handbrake.sh

           # Device
           __exec_dvd__.append(tmp[0])
          
           # DVD transcode directory
           __exec_dvd__.append(__configLinux__[4])
                     
           # name
           __exec_dvd__.append(tmp[1])    
            
           # track
           __exec_dvd__.append(tmp[2])
      
           # default language
           __exec_dvd__.append(tmp[3])
   

           if (tmp[4] != 'none'):
               if (__verbose__ == "true"):
                   OSlog("dvd-handbrake.sh Transcode parameter add : " + "-a " + tmp[4])
                   __exec_dvd__.append("-a " + tmp[4])

           if (tmp[5] != 'none'):
               if (__verbose__ == "true"):
                   OSlog("dvd-handbrake.sh Transcode parameter add : " + "-s " + tmp[5])
                   __exec_dvd__.append("-s " + tmp[5])

       x = 0
       parameters = 0
       for number in __exec_dvd__:
           x = x + 1
           parameters = parameters + 1

       # Add device
       GUIList.append(__language__(32151) + tmp[0])

       # Add track
       GUIList.append(__language__(32152) + tmp[2])
       # Add audio
       GUIList.append(__language__(32158) + __configLinux__[7] + ' ' + __configLinux__[8] + ' ' +  __configLinux__[18])

       # Add name including extension mkv
       GUIList.append(__language__(32155) + tmp[1] + ".mkv")

       # Add accept and cancel button
       GUIList.append(__language__(32156))
       GUIList.append(__language__(32157))

       time.sleep(1)
       xbmc.executebuiltin("Dialog.Close(busydialog)")
       return GUIList

    else:

       time.sleep(1)
       xbmc.executebuiltin("Dialog.Close(busydialog)")
       GUIList.append("none")
       return GUIList

#########################################################






#########################################################
# Function  : OSDVDcopyToIso                            #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           ISO-Copy-process not startet              #
# 1           ISO-Copy-process startet                  #
#                                                       #
#########################################################
def OSDVDcopyToIso():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd3.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd3.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    dvd_command = dvd_command + " " + __exec_dvd__[0] + " " + __exec_dvd__[1] + " " + __exec_dvd__[2]

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd3.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-handbrake.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached for dvd-iso-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSRemoveLock                              #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           Lock was removed                          #
# 0           Lock was not set and therefor not deleted #
#                                                       #
#########################################################
def OSRemoveLock():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[45])):
        os.remove(__configLinux__[45])
        if (__verbose__ == "true"):
            OSlog("lock-file delete : " + __configLinux__[45])
        return 1
    else:
        return 0

#########################################################




#########################################################
# Function  : OSGetStageCurrentIndex                    #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1-X         Current stage in progress                 #
# -1          File could not be opened                  #
#                                                       #
#########################################################
def OSGetStageCurrentIndex():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[37])):
        ProgressFile = open(__configLinux__[37],'r')
        line =  ProgressFile.readline()
        ProgressFile.close
        line = line.strip()
        rvalue = int(line)
        return rvalue
    else:
        return -1

#########################################################







#########################################################
# Function  : OSGetStageText                            #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# msg         Text that will be shwon inside the        #
#             progress-windows                          #
#                                                       #
#########################################################
def OSGetStageText():

    global __configLinux__
    global __verbose__
    global __stage_percent__
    global __stage_last__

    msg = ""

    # get Stages counter .....

    if (os.path.exists(__configLinux__[35])):
        StageCounter = open(__configLinux__[35],'r')
        line = StageCounter.readline()
        line.strip()
        Stages = int(line)
        StageCounter.close

        # Get Stages-Descirption

        stagesdescription = []
        if (os.path.exists(__configLinux__[36])):

            DescFileID = open(__configLinux__[36],'r')
            for line in DescFileID.readlines():
                line = line.strip()
                stagesdescription.append(line)
            DescFileID.close

            # Get Current-Stage

            if (os.path.exists(__configLinux__[37])):
                StageCurrent = open(__configLinux__[37],'r')
                line = StageCurrent.readline()
                line.strip()
                StageCurrent.close
                StageCurr = int (line)

                index = int(stagesdescription[(StageCurr -1)])

                progress_message = __language__(index)

                # we should have all info for the text inside the progress-bar windows
                # and we dont have to edit the shell-scripts to update the messages (strings.xml)

                msg = __language__(32174) + str(StageCurr) + " / " + str(Stages) + " " + progress_message


                if (StageCurr == Stages):
                    __lock__.acquire(1) 
                    __stage_last__ = True
                    __lock__.release() 
                else:
                    __lock__.acquire(1)  
                    __stage_last__ = False
                    __lock__.release() 

                return msg
            else:
                return msg
        else:
            return msg
    else:
        return msg

#########################################################





#########################################################
# Function  : OSCheckSSH                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           Test failed                               #
# 0           Test successfull                          #
#                                                       #
#########################################################
def OSCheckSSH():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[39])):

        # Before we try to delete a existing file we should be certain to have 
        # full write accesss to this file but inside the main-code we did allready 
        # this test, therefore we can skip this test .-) 

        os.remove(__configLinux__[39])

    OSRun( "check-ssh.sh ",True,False)

    # We wait for at least 6 secounds ... after this timeout we leave 
    # the function 

    index = 0 
    retcode = 1
    Waitexit = True
    while (Waitexit):
          if (os.path.exists(__configLinux__[39])):
              Waitexit = False  
              retcode = 0
          index = index + 1
          if (index == 10):
             Waitexit = False   
          time.sleep(1) 

    return retcode 

#########################################################







#########################################################
# Function  : OSCheckAccess                             #
#########################################################
# Parameter :                                           #
#                                                       #
# dir         directory to check for read / write       #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           Directory is not writeable                #
# 0           Directory exists and is writeable         #
#                                                       #
#########################################################
def OSCheckAccess(dir):

    global __verbose__

    if (os.path.exists(dir)):
        if (os.access(dir,os.W_OK) == False):
           return 1
        else:
           return 0
    else:
        return 1

#########################################################





#########################################################
# Function  : OSBlurayVolume                            #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# Volname     Volname of the inserted bluray            #
#                                                       #
#########################################################
def OSBlurayVolume():

    global __configLinux__
    global __exec_bluray__
    global __verbose__

    if (os.path.exists(__configLinux__[41])):
        BluRayVOl  = open(__configLinux__[41],'r')
        name = BluRayVOl.readline()
        name.strip()
        BluRayVOl.close
        return (name)
    else:
        return("unknown")

#########################################################





#########################################################
# Function  : OSBluAdd                                  #
#########################################################
# Parameter :                                           #
#                                                       #
# list        list with all parameters for execution    #
#                                                       #
# Returns   : none                                      #
#                                                       #
#########################################################
def OSBluAdd(list):

    global __exec_bluray__

    __exec_bluray__ = list

    return 0

#########################################################





#########################################################
# Function  : OSDVDAudioTrack                           #
#########################################################
# Parameter :                                           #
#                                                       #
# track	      track-number to get audio (1-X)           #
#                                                       #
# Returns   :                                           #
#                                                       #
# audio       list with tracks or none                  #
#                                                       #
#########################################################
def OSDVDAudioTrack(track):

    global __configLinux__
    global __verbose__

    audio = []

    if (__verbose__ == "true"):
       OSlog("dvd4.sh command ready to start")
       OSlog("dvd4.sh para1=[" + __configLinux__[1] + "] para2=[" + str(track) + "]")

    OSRun("dvd4.sh " +  __configLinux__[1]  + " " + str(track),True,True)
    time.sleep(4)
    if (os.path.exists(__configLinux__[48])):
        ListF = open(__configLinux__[48],'r')
        for line in ListF.readlines():
            line = line.strip()
            audio.append(line)
            if (__verbose__ == "true"): 
               OSlog("OSReadList data to add :" + line)
        if (__verbose__ == "true"): 
           OSlog("OSReadList file-close")
        ListF.close

        index = len(audio)
        if (index == 0):
            if (__verbose__ == "true"): 
               OSlog("audio list is empty !!!!!!")
            audio.append('none')
            return (audio)
        else:
            return (audio)
    else:
        if (__verbose__ == "true"):
           OSlog("dvd-audio tracks could not be read !! :" + __configLinux__[48])
        audio.append('none')
        return (audio)

#########################################################





#########################################################
# Function  : OSDVDSubTrack                             #
#########################################################
# Parameter :                                           #
#                                                       #
# track	      track-number to get audio (1-X)           #
#                                                       #
# Returns   :                                           #
#                                                       #
# sub         list with tracks or none                  #
#                                                       #
#########################################################
def OSDVDSubTrack(track):

    global __configLinux__
    global __verbose__

    sub = []

    if (os.path.exists(__configLinux__[49])):
        SubFile = open(__configLinux__[49],'r')
        for line in SubFile.readlines():
            line = line.strip()
            sub.append(line)
            OSlog("OSReadList data to add :" + line)
        OSlog("OSReadList file-close")
        SubFile.close

        index = len(sub)
        if (index == 0):
            OSlog("subtitle list is empty !!!!!!")
            sub.append('none')
            return (sub)
        else:
            return (sub)
    else:
        sub.append('none')
        return subs

#########################################################





#########################################################
# Function  : OSDVDVolume                               #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# Volname     Volname of the inserted bluray            #
#                                                       #
#########################################################
def OSDVDVolume():

    global __configLinux__
    global __exec_bluray__
    global __verbose__

    if (os.path.exists(__configLinux__[44])):
        DVDVOl  = open(__configLinux__[44],'r')
        name = DVDVOl.readline()
        name.strip()
        DVDVOl.close
        return (name)
    else:
        return("unknown")

#########################################################





#########################################################
# Function  : OSDVDAdd                                  #
#########################################################
# Parameter :                                           #
#                                                       #
# list        list with all parameters for execution    #
#                                                       #
# Returns   : none                                      #
#                                                       #
#########################################################
def OSDVDAdd(list):

    global __exec_dvd__

    __exec_dvd__ = list

    return 0

#########################################################





#########################################################
# Function  : OSDetectLastStage                         #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# Bool 	      State of current stage true or false      #
#                                                       #
#########################################################
def OSDetectLastStage():

    global __stage_last__

    __lock__.acquire(1)  
    stage = __stage_last__
    __lock__.release() 
 
    return (stage)

#########################################################




#########################################################
# Function  : OSSetupDone                               #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           setup.done was executed                   #
# 0           setup.sh was not executed                 #
#                                                       #
#########################################################
def OSSetupDone():

    global __configLinux__ 
    global __verbose__

    if (os.path.exists(__configLinux__[29])):
        return 1
    else:
        return 0

#########################################################






#########################################################
# Function  : OSCheckLicence                            #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           makemkv use a valid licence               #
# 0           makemkv use a expired licence             #
#                                                       #
#########################################################
def OSCheckLicence():

    global __configLinux__
    global __verbose__

    if (os.path.exists(__configLinux__[27])):
        os.remove(__configLinux__[27])

    OSRun("check-mkv.sh ",False,False)
  
    if (os.path.exists(__configLinux__[27])):
        return 1
    else:
        return 0

#########################################################




#########################################################
# Function  : OSDVDcopyToIsoRescque                     #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           ISO-Copy-process not startet              #
# 1           ISO-Copy-process startet                  #
#                                                       #
#########################################################
def OSDVDcopyToIsoResque():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd5.sh inside shell-linux

    if (__verbose__ == 'true'):
        OSlog("dvd5.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    dvd_command = dvd_command + " " + __exec_dvd__[0] + " " + __exec_dvd__[1] + " " + __exec_dvd__[2]

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd5.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-resque.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached 20 secounds for dvd-iso-file  ...")
                   OSlog("change value on line 1818 for dvd-iso-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################




#########################################################
# Function  : OSCheckUser                               #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 1           username valid                            #
# 0           usrname invalid or current username       #
#             could not be read from the addon-dir      #
#                                                       #
#########################################################
def OSCheckUser():

    global __configLinux__
    global __verbose__

    # if we would send a ssh-command with the wrong 
    # user-name our xbmc would became a little hickup and crashing ....

    name = __configLinux__[6]

    sys.platform.startswith('linux')
    command = "whoami >" +  __configLinux__[26]
    status = os.system("%s" % (command))

    if (os.path.exists(__configLinux__[26])):
        UsernameFile = open(__configLinux__[26],'r')
        CurrentUser = str(UsernameFile.readline())
        CurrentUser = CurrentUser.strip()   
        UsernameFile.close()
        if (__verbose__ == "true"):
            OSlog("Current-user      : [" + CurrentUser + "]")
            OSlog("SSH-user expected : [" + name + "]")
        index = name.find(CurrentUser)
        if (index == -1):
            if (__verbose__ == "true"): 
               OSlog("Warning current user and ssh-command mismatch !!!!!")
            return 0
        else:  
            if (__verbose__ == "true"): 
               OSlog("current user is listed inside the ssh-command")
            return 1  
    else:
        return 0

#########################################################






#########################################################
# Function  : OSDVDMount                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           dvd is not mounted                        #
# 1           dvd is correctly mounted into the fs      #
#                                                       #
#########################################################
def OSDVDMount():

    global __configLinux__
    global __exec_bluray__
    global __verbose__
 
    command = "mount | grep " + __configLinux__[1] + " | awk '{print $3}' >" +  __configLinux__[30]
    OSRun(command,True,False) 
    time.sleep(1)

    if (os.path.exists(__configLinux__[30])):
        MountFile = open(__configLinux__[30],'r')
        MountState = str(MountFile.readline())
        MountState = MountState.strip()   
        MountFile.close()
        Len = MountState.len()
        if (Len > 1):
            return 1
        else:
            return 0
    else:
         return 0
#########################################################




#########################################################
# Function  : OSDVDvcopy                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           Vcopy-Copy-process not startet            #
# 1           Vcopy-Copy-process startet                #
#                                                       #
#########################################################
def OSDVDvcopy():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd6.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd6.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    dvd_command = dvd_command + " " + __exec_dvd__[0] + " " + __exec_dvd__[1]

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd6.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-vcopy.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached 20 secounds for vobcopy-file  ...")
                   OSlog("change timeout on line 1980 for vobcopy-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSDVDtoMKV                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           MKV-process not startet                   #
# 1           MKV-process startet                       #
#                                                       #
#########################################################
def OSDVDtoMKV():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    if (__verbose__ == "true"):
        OSlog("mkv parameters : " + str(parameters))      

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd9.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd9.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    dvd_command = dvd_command + " " + __exec_dvd__[0] + " " + __exec_dvd__[1] + " " + __exec_dvd__[2] + " " + __exec_dvd__[3]

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd9.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-mkv.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 30):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached 30 secounds for mkv-file  ...")
                   OSlog("change timeout on line 2124 for mkv-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################




#########################################################
# Function  : OSDVDtoLOW                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           handbrake-process not startet             #
# 1           handbrake-process startet                 #
#                                                       #
#########################################################
def OSDVDtoLOW():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd10.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd10.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    x = 0
    for number in __exec_dvd__:
        dvd_command = dvd_command + " " + __exec_dvd__[x]
        if (__verbose__ == "true"):
            OSlog("dvd-iphone.sh Transcode para: [" + str(x) +  "]  " + __exec_dvd__[x])
        x = x + 1

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd10.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-low.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 30):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached 30 secounds for low-file  ...")
                   OSlog("change timeout on line 2213 for low-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSDVDtoIphone                             #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           handbrake-process not startet             #
# 1           handbrake-process startet                 #
#                                                       #
#########################################################
def OSDVDtoIphone():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd10.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd11.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    x = 0
    for number in __exec_dvd__:
        dvd_command = dvd_command + " " + __exec_dvd__[x]
        if (__verbose__ == "true"):
            OSlog("dvd-iphone.sh Transcode para: [" + str(x) +  "]  " + __exec_dvd__[x])
        x = x + 1

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd11.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-iphone.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 30):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached 30 secounds for iphone-file  ...")
                   OSlog("change timeout on line 2287 for iphone-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSDVDtoPSP                                #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           handbrake-process not startet             #
# 1           handbrake-process startet                 #
#                                                       #
#########################################################
def OSDVDtoPSP():

    global __configLinux__
    global __exec_dvd__
    global __verbose__

    parameters = len(__exec_dvd__)

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # Execution of shell-script dvd10.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd12.sh command ready to start")

    # Prepare command string

    dvd_command = ""
    x = 0
    for number in __exec_dvd__:
        dvd_command = dvd_command + " " + __exec_dvd__[x]
        if (__verbose__ == "true"):
            OSlog("dvd-iphone.sh Transcode para: [" + str(x) +  "]  " + __exec_dvd__[x])
        x = x + 1

    if (__verbose__ == "true"):
        OSlog("final :" + dvd_command)

    OSRun("dvd12.sh " + dvd_command,True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-psp.sh command executed")

    # Now we do loop until the PID-file exists

    time.sleep(8)

    WCycles = 5
    Waitexit = True
    while (Waitexit):
           if (os.path.exists(__configLinux__[32])):
               if (__verbose__ == "true"):
                   OSlog("pid-file exist ...")
               Waitexit = False
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 30):
               if (__verbose__ == "true"):
                   OSlog("Timeout reached 30 secounds for psp-file  ...")
                   OSlog("change timeout on line 2376 for psp-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0

    # Clean exec-array dvd

    for index in range((parameters - 1),0):
        del  __exec_dvd__[index]

    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1

#########################################################





#########################################################
# Function  : OSGetUserDesc                             #
#########################################################
# Parameter :                                           #
#                                                       #
# index	     index to get description (1-9)             #
#                                                       #
# Returns   :                                           #
#                                                       #
# usertext   User-Description or ""                     #
#                                                       #
#########################################################
def OSGetUserDesc(index):

    global __configLinux__
    global __verbose__

    desc = []

    UserScript = os.getenv("HOME") + '/swiss.army.knife/' + 'user' + str(index) + '.sh' 
    UserDescription = os.getenv("HOME") + '/swiss.army.knife/' + 'user' + str(index) + '.desc'

    if (__verbose__ == "true"):
        OSlog("Try to load user-function description : " + UserDescription)

    if (os.path.exists(UserDescription)):

        # We need both a description file and a shell-script

        if (os.path.exists(UserScript)):
            UserDescF = open(UserDescription,'r')
            for line in UserDescF.readlines():
                line = line.strip()
                desc.append(line)
            UserDescF.close
            return desc[0]
        else:
            return " "    
    else:
        return " "
#########################################################





#########################################################
# Function  : OSDVDTranscodeDefault                     #
#########################################################
# Parameter : Paramlist                                 #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           default transcode-process not startet     #
# 1           default transcode-process startet         #
#                                                       #
#########################################################
def OSDVDTranscodeDefault(Paramlist):

    global __configLinux__
    global __exec_dvd__
    global __verbose__
    
    index = 0 
    para = [] 

    for word in Paramlist.split(' '):
        para.append(word)
        index = index + 1 

    # The para string contains all info for the default transcode-selection 
    # The secound parameter is the most importand one ...

    if (para[1] == '5'):

       # We can pass the arguments 1:1 
   
       if (__verbose__ == "true"): 
          x = 0 
          dvd_command = ""
          for number in __exec_dvd__:
              dvd_command = dvd_command + " " + __exec_dvd__[x]
              x = x + 1  
          OSlog("__exec_dvd__ filds andvanced [" + dvd_command + "]")  

       if (__verbose__ == "true"):
          OSlog("advanced transcoding selected")   
       if (para[0] == 'h264-high'):
          state_tr = OSDVDTranscode() 
       if (para[0] == 'h264-low'):
          state_tr = OSDVDtoLOW()
       if (para[0] == 'iphone'):
          state_tr = OSDVDtoIphone()
       if (para[0] == 'psp'):
          state_tr = OSDVDtoPSP()
  
    if (para[1] == '4'):

       new_exec = []
       export_track = 0 
   
       export_name = __exec_dvd__[2]
       export_dir = para[4]
       export_device = __exec_dvd__[0]
       export_track = int (__exec_dvd__[4])
     
       new_exec.append(export_device)
       new_exec.append(export_dir) 
       new_exec.append(export_name)
       new_exec.append(str(export_track))

       __exec_dvd__ = new_exec

       if (__verbose__ == "true"): 
          x = 0 
          dvd_command = ""
          for number in __exec_dvd__:
              dvd_command = dvd_command + " " + __exec_dvd__[x]
              x = x + 1  
          OSlog("__exec_dvd__ filds simple [" + dvd_command + "]")  
          state_tr = OSDVDtoMKV() 

    # we need only device directory and a single name 

    if (para[1] == '3'):

       new_exec = []  
       export_name = __exec_dvd__[2]
       export_dir = para[4]
       export_device = para[3] 

       new_exec.append(export_device)
       new_exec.append(export_dir) 
       new_exec.append(export_name)
 
       __exec_dvd__ = new_exec
 
       if (__verbose__ == "true"): 
          x = 0 
          dvd_command = ""
          for number in __exec_dvd__:
              dvd_command = dvd_command + " " + __exec_dvd__[x]
              x = x + 1  
          OSlog("__exec_dvd__ filds simple [" + dvd_command + "]")  

       if (__verbose__ == "true"): 
          OSlog("simple transcoding selected")
       if (para[0] == 'iso'):
          state_tr = OSDVDcopyToIso()  
       if (para[0] == 'vobcopy'):
          state_tr = OSDVDvcopy() 
 
    return state_tr
#########################################################




#########################################################
# Function  : OSCheckMainProcess                        #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# 0           default main-process is running           #
# 1           default main-process is not running       #
# 2           pid for main-process is not set           #
#             (the pid-file could not be readed)        #
#########################################################
def OSCheckMainProcess():

    global __configLinux__
    global __verbose__

    pid = []

    if (os.path.exists(__configLinux__[53])):
        WatchF = open(__configLinux__[53],'r')
        for line in WatchF.readlines():
                line = line.strip()
                pid.append(line)
        WatchF.close()
         
        # We have the main pid of the important transcode or copy process
        # As long this pid is running properly we give back -> 0 

        try: 
            os.kill(int(pid[0]), 0)
            return 0
        except OSError, err:
            
            # We send back the signal to stop all polling ....
            # and to terminate the scripts immediately

            return 1  
    else:
        if (__verbose__ == "true"): 
            OSlog("default transcode-pid file could not be read") 
        return 2
#########################################################





#########################################################
# Function  : OSChapterMKV                              #
#########################################################
# Parameter : none                                      #
#                                                       #
# Returns   :                                           #
#                                                       #
# tracklist   contains tracks or only "none"            #
#                                                       #
#########################################################
def OSChapterMKV():

    global __configLinux__
    global __verbose__

    tracklist = []

    # Execution of shell-script dvd7.sh inside shell-linux

    if (__verbose__ == "true"):
        OSlog("dvd-chapter-mkv.sh command ready to start")

    OSRun("dvd7.sh " +  __configLinux__[1],True,False)

    if (__verbose__ == "true"):
        OSlog("dvd-chapter-mkv.sh command executed")

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We must wait until the file with the track-information could be read
    # Without the list of tracks we can not select inside the list .....
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(30)

    WCycles = 30
    Waitexit = True
    OSlog("Waiting until track-files exist ... WCycles:=" + str(WCycles))
    while (Waitexit):
           if (os.path.exists(__configLinux__[42])):
               if (__verbose__ == "true"):
                   OSlog("track-files exist ... WCycles:=" + str(WCycles))
               Waitexit = False
           else:
               WCycles = WCycles + 1
               time.sleep(1)
           time.sleep(1)

           # The generation of track-list with makemkv needs a lot of time 
           # in the case we have a copy protected dvd inserted. 
           # In most cases it only needs a few scounds to parse the dvd...
               
           if (WCycles >= 600):
               if (__verbose__ == "true"):
                  OSlog("Timeout mkv 600 secounds reached ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               tracklist.append('none')
               return tracklist

    xbmc.executebuiltin("Dialog.Close(busydialog)")

    if (__verbose__ ==  "true"):
        OSlog("track-files exist . Create list for GUI")

    # We should have the file with the state

    if (os.path.exists(__configLinux__[42])):
        trackfile = open(__configLinux__[42],'r')
        for line in trackfile.readlines():
                line = line.strip()
                tracklist.append(line)
        trackfile.close
        return tracklist
    else:
        tracklist.append('none')
        return tracklist

#########################################################
