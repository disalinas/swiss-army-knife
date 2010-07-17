#!/usr/bin/python
# -*- coding: utf-8 -*-
#########################################################
# SCRIPT  : Linux.py                                    #
#########################################################
# AUTHOR  : Hans Weber                                  #
# EMAIL   : linuxluemmel.ch@gmail.com                   #
# XBMC    : Version 10.5  or higher                     #
# PYTHON  : internal xbmc python 2.4.X                  #
# OS      : Linux                                       #
# TASKS   : This python code contains only os-dependet  #
#           functions and must be rewritten for every   #
#           os that should exexcute this addon.         #
# VERSION : 0.6C                                        #
# DATE    : 07-14-10                                    #
# STATE   : Alpha 10                                    #
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

__settings__       = xbmcaddon.Addon(id='script-video-ripper')
__language__       = __settings__.getLocalizedString

__configLinux__    = [] 
__temp_files__     = []
__data_container__ = []
__exec_bluray__    = []
__exec_dvd__       = []
__verbose__        = 'false'

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
    xbmc.output("[%s]: [OSlog]  %s\n" % ("swiss-army-knife",str(msg))) 
    return (0)
#########################################################





#########################################################
# Function  : OSConfiguration                           #
#########################################################
# Parameter :                                           #
#                                                       #
# index       index howmay config-entrys are used       # 
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
    
    # config [13] reserved for future use    
 
    config[14] = __settings__.getSetting("id-customer") 
    config[15] = __settings__.getSetting("id-burn") 
    config[16] = __settings__.getSetting("id-netcat")
    config[17] = __settings__.getSetting("id-verbose")
    config[18] = __settings__.getSetting("id-dvd-subt")
    config[19] = __settings__.getSetting("id-expert")
    config[20] = __settings__.getSetting("id-password")
 

    # Modul-global variable to detect if debug-log is active
 
    __verbose__ = config[17]

    # On startup we need to check that all data-containers are writeable

    __data_container__.append(config[3])
    __data_container__.append(config[4])
    __data_container__.append(config[5])

    # We need to write a few files on startup inside the addon-dirctory
 
    # DVD_LANG1
    # DVD_LANG2
    # DVD_SUB
 
    # Over these files we know inside the shell-scripts witch languages and 
    # subtitles we would like to transcode 

    if (config[7] != 'none'):
        sys.platform.startswith('linux')
        command ="echo -n " + config[7] + " > $HOME/.xbmc/userdata/addon_data/script-video-ripper/DVD_LANG1" 
        status = os.system("%s" % (command))
        
    if (config[8] != 'none'):
        sys.platform.startswith('linux')
        command = "echo -n " + config[8] + " > $HOME/.xbmc/userdata/addon_data/script-video-ripper/DVD_LANG2" 
        status = os.system("%s" % (command))
    else: 
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script-video-ripper/DVD_LANG2 > /dev/null 2>&1" 
        status = os.system("%s" % (command))
         
    if (config[18] != 'none'):
        sys.platform.startswith('linux')
        command = "echo -n " + config[18] + " > $HOME/.xbmc/userdata/addon_data/script-video-ripper/DVD_SUB" 
        status = os.system("%s" % (command))
    else:
        command = "rm " + "$HOME/.xbmc/userdata/addon_data/script-video-ripper/DVD_SUB > /dev/null 2>&1" 
        status = os.system("%s" % (command)) 

    # All used internal files are stored inside after here ...

    config[30] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/media/state' 
    config[31] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/progress' 
    config[32] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-pid' 
    config[33] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-files'   
    config[34] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/progress-done'   
    config[35] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-counter'
    config[36] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-descriptions'
    config[37] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/progress/stages-current'
    config[38] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/log/ssh-log'
    config[39] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/log/ssh-test'
    config[40] = os.getenv("HOME") + '/.xbmc/addons/swiss-army-knife/shell-linux/' 
    config[41] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/bluray/BR_VOLUME' 
    config[42] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/bluray/BR_TRACKS' 
    config[43] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/media/BR_GUI'
    config[44] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/dvd/DVD_VOLUME'
    config[45] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/JOB'
    config[46] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/dvd/DVD_TRACKS'
    config[47] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/media/DVD_GUI' 
  
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


    # Do log all settings inside xbmc.log 

    if (__verbose__ == 'true'):
        OSlog("Configuration 00 reading : " + config[0])
        OSlog("Configuration 01 reading : " + config[1])
        OSlog("Configuration 02 reading : " + config[2]) 
        OSlog("Configuration 03 reading : " + config[3])
        OSlog("Configuration 04 reading : " + config[4])
        OSlog("Configuration 05 reading : " + config[5])
        OSlog("Configuration 06 reading : " + config[6]) 
        OSlog("Configuration 07 reading : " + config[7])
        OSlog("Configuration 08 reading : " + config[8])
        OSlog("Configuration 09 reading : " + config[9])
        OSlog("Configuration 10 reading : " + config[10])
        OSlog("Configuration 11 reading : " + config[11])
        OSlog("Configuration 12 reading : " + config[12])
        OSlog("Configuration 13 reading : " + config[13])
        OSlog("Configuration 14 reading : " + config[14])
        OSlog("Configuration 15 reading : " + config[15])
        OSlog("Configuration 16 reading : " + config[16])
        OSlog("Configuration 17 reading : " + config[17])
        OSlog("Configuration 18 reading : " + config[18])       

        OSlog("Configuration 30 reading : " + config[30])
        OSlog("Configuration 31 reading : " + config[31])
        OSlog("Configuration 32 reading : " + config[32])
        OSlog("Configuration 33 reading : " + config[33])
        OSlog("Configuration 34 reading : " + config[34])
        OSlog("Configuration 35 reading : " + config[35])
        OSlog("Configuration 36 reading : " + config[36])
        OSlog("Configuration 37 reading : " + config[37])
        OSlog("Configuration 38 reading : " + config[38])
        OSlog("Configuration 40 reading : " + config[40])
        OSlog("Configuration 41 reading : " + config[41])
        OSlog("Configuration 42 reading : " + config[42])
        OSlog("Configuration 43 reading : " + config[43]) 
        OSlog("Configuration 44 reading : " + config[44])
        OSlog("Configuration 45 reading : " + config[45])
        OSlog("Configuration 46 reading : " + config[46])
        OSlog("Configuration 47 reading : " + config[47])    

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
#             - false command is not startet in         #
#               background (very dangerous .... )       #
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


    sshlog ="echo \"" + command + "\" >> " + __configLinux__[38]
    tatus = os.system("%s" % (sshlog))
    if (__verbose__ == 'true'):
        OSlog("Command to log inside ssh:" + sshlog)
        OSlog ("OSRun start")


    commandssh = "ssh " + __configLinux__[6] + " " + __configLinux__[40] + command + " "

    if (backg):
        commandssh = commandssh + " > /dev/null 2>&1 &"
 
    status = os.system("%s" % (command))
 
    if (__verbose__ == 'true'):
        OSlog("Command to run :" + commandssh)

    # No we execute the command  ...
    # over ssh

    status = os.system("%s" % (commandssh))

    if (busys):
        xbmc.executebuiltin("Dialog.Close(busydialog)")

    if (__verbose__ == 'true'):
        OSlog ("OSRun end")   

    return status
#########################################################





#########################################################
# Function  : OSCheckMedia                              #
#########################################################
# Parameter :                                           #
#                                                       #
# Media       String with "BLURAY" or "DVD-ROM          #     
#                                                       # 
# Returns   :                                           #
#                                                       #
# 0           Checked media is inside drive             #
# 1           No media found inside drive               #
# 2           State file do not exist                   #
#                                                       #
#########################################################
def OSCheckMedia(Media):

    global __configLinux__ 
    global __verbose__

    # Erase  all temporary files stored inside list but only if 
    # there is no active job 

    if (os.path.exists(__configLinux__[45])):
        if (os.path.exists(__configLinux__[30])):
            os.remove(__configLinux__[30])
    else:  
        OSCleanTemp()      

    # Execution of shell-script br0.sh inside shell-linux  

    if (__verbose__ == 'true'):
        OSlog("state.sh command ready to start")

    if (Media == 'BLURAY'):
        OSRun("br0.sh " +  __configLinux__[2],True,False)
    if (Media == 'DVD-ROM'):     
        OSRun("dvd0.sh " +  __configLinux__[1],True,False)

    if (__verbose__ == 'true'):
        OSlog("state.sh command executed")

    xbmc.executebuiltin("ActivateWindow(busydialog)")   

    # We must wait until the file with the state-information could be read 
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(3) 
   
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
           if (WCycles >= 15):
               if (__verbose__ == 'true'):
                   OSlog("Timeout 15 secounds reached for track-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)") 
               return 2   

    xbmc.executebuiltin("Dialog.Close(busydialog)")

    # We shoud now have the file with the state 
 
    if (os.path.exists(__configLinux__[30])):   
        f = open(__configLinux__[30],'r')
        media = f.readline()
        media = media.strip()
        OSlog("Media detected")  
        f.close
       
        if (media == Media):
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

    if (__verbose__ == 'true'):
        OSlog("bluray-chapter.sh command ready to start")

    OSRun("br1.sh " +  __configLinux__[2],True,False)

    if (__verbose__ == 'true'): 
        OSlog("bluray-chapter.sh command executed") 

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We must wait until the file with the track-information could be read 
    # Without the list of track we can not select inside the list .....
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(20) 
   
    WCycles = 20 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(__configLinux__[42])):  
               if (__verbose__ == 'true'):
                   OSlog("track-files exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 90):
               if (verbose == 'true'):
                   OSlog("Timeout 90 secounds reached for track-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               tracklist.append('none') 
               return tracklist       
 
    xbmc.executebuiltin("Dialog.Close(busydialog)")
    
    if (__verbose__ == 'true'):
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

    # We have global list that contains all temp. files
    # as it looks easy do delete all file inside the list

    for item in __temp_files__:
         if (os.path.exists(item)):
             os.remove(item)
             if (__verbose__):
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

    if (__verbose__ == 'true'):
        OSlog("bluray-transcode.sh command ready to start")
        OSlog ("Bluray-paramter [0] : " + __exec_bluray__[0])  
        OSlog ("Bluray-paramter [1] : " + __exec_bluray__[1]) 
        OSlog ("Bluray-paramter [2] : " + __exec_bluray__[2])
        OSlog ("Bluray-paramter [3] : " + str(__exec_bluray__[3]))      

    OSRun("br2.sh " +  __exec_bluray__[0] + " " + __exec_bluray__[1] + " " + __exec_bluray__[2] + " " +  __exec_bluray__[3],True,False)


    if (__verbose__ == 'true'): 
        OSlog("bluray-transcode.sh command executed")     
 
    # Now we do loop until the PID-file exists

    time.sleep(30) 
   
    WCycles = 20 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(__configLinux__[32])):  
               if (__verbose__ == 'true'):
                   OSlog("pid-file exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 50):
               if (__verbose__ == 'true'):
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

    if (os.path.exists(__configLinux__[31])):
        ProgressFile = open(__configLinux__[31],'r')
        line =  ProgressFile.readline()
        ProgressFile.close
        line = line.strip() 
        rvalue = int(line)
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
            PidFile.close()
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
           return 1 
        else: 
           return 0        
    else: 
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
        if (os.path.exists(__configLinux__[32])):

            pid_list = []
            file_list = []

            PidFile = open(__configLinux__[32],'r')

            for line in PidFile.readlines():
                line = int(line.strip())
                pid_list.append(line)
            PidFile.close()

            # Reverse order because we kill from botton to the top

            pid_list.reverse()
            
            # Kill the processes 

            for pid in pid_list: 
                try:
                   if (__verbose__):
                        OSlog("send signal 9 to pid : " + str(pid))
                   os.kill(pid,9)
                except OSError, err:
                  return (1)

            # remove files from job
 
            if (os.path.exists(__configLinux__[35])):
                ProcessFile = open(__configLinux__[35],'r')
                for line in ProcessFile.readlines():
                    line = line.strip()
                    if (__verbose__):
                        OSlog("file added to delete-command : " + line)
                    file_list.append(line)
                PidFile.close()

                for FileDel in file_list:
                    if (os.path.exists(FileDel)):
                        os.remove(FileDel) 
       
            # Clean-up

            OSCleanTemp()

            return (0) 
        else:
            return (1) 
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
# Parameter : none                                      #
#                                                       #
# Returns   :                                           # 
#                                                       #
# tracklist   contains all tracks from the dvd          # 
#             If tracklist could not be read the list   #
#             only contains "none"                      #
#                                                       # 
#########################################################
def OSChapterDVD():

    global __configLinux__ 
    global __verbose__

    tracklist = []

    # Execution of shell-script br1.sh inside shell-linux 

    if (__verbose__ == 'true'):
        OSlog("dvd-chapter.sh command ready to start")

    OSRun("dvd1.sh " +  __configLinux__[1] + " 1 ",True,False)

    if (__verbose__ == 'true'): 
        OSlog("dvd-chapter.sh command executed") 

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We must wait until the file with the track-information could be read 
    # Without the list of track we can not select inside the list .....
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(20) 
   
    WCycles = 10 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(__configLinux__[46])):  
               if (__verbose__ == 'true'):
                   OSlog("track-files exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (verbose == 'true'):
                   OSlog("Timeout 90 secounds reached for track-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               tracklist.append('none') 
               return tracklist       
 
    xbmc.executebuiltin("Dialog.Close(busydialog)")
    
    if (__verbose__ == 'true'):
        OSlog("track-files exist . Create list for GUI")
   
    # We should have the file with the state 
 
    if (os.path.exists(__configLinux__[46])):   
        trackfile = open(__configLinux__[46],'r')
        for line in trackfile.readlines():
                line = line.strip()
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

    if (__verbose__ == 'true'):
        OSlog("dvd-handbrake.sh command ready to start")

    # Prepare command string 
 
    dvd_command = ""
    x = 0
    for number in __exec_dvd__: 
        dvd_command = dvd_command + " " + __exec_dvd__[x]
        if (__verbose__ == 'true'):
            OSlog("dvd-handbrake.sh Transcode para: [" + str(x) +  "]  " + __exec_dvd__[x])
        x = x + 1 

    if (__verbose__ == 'true'):
        OSlog("final :" + dvd_command)   

    OSRun("dvd2.sh " + dvd_command,True,False)

    if (__verbose__ == 'true'): 
        OSlog("dvd-handbrake.sh command executed")     
 
    # Now we do loop until the PID-file exists

    time.sleep(35) 
   
    WCycles = 15 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(__configLinux__[32])):  
               if (__verbose__ == 'true'):
                   OSlog("pid-file exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (__verbose__ == 'true'):
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
# Parameter : none                                      #
#                                                       #
# Returns   :                                           # 
#                                                       #
# GUIList     List with all parameters prior to the     #
#             execution from the GUI                    #   
#                                                       # 
#########################################################
def OSDVDExecuteList():

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
          if (__verbose__ == 'true'):
             OSlog("dvd-handbrake.sh Transcode parameter add : " + "-a " + tmp[4])
          __exec_dvd__.append("-a " + tmp[4])

       if (tmp[5] != 'none'):
          if (__verbose__ == 'true'):
             OSlog("dvd-handbrake.sh Transcode parameter add : " + "-s " + tmp[5])
          __exec_dvd__.append("-s " + tmp[5])


       # If there is someone who knows a better trick to
       # get the indexes, please give me a pm 

       x = 0 
       parameters = 0 
       for number in __exec_dvd__:
           if (__verbose__ == 'true'):
               OSlog("dvd-handbrake.sh para: [" + str(x) +  "]  " + __exec_dvd__[x])
               x = x + 1      
           parameters = parameters + 1
           

       if (__verbose__ == 'true'): 
           OSlog("dvd-handbrake.sh is using : " + str(parameters) + " parameters")      

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

    if (__verbose__ == 'true'):
        OSlog("dvd3.sh command ready to start")

    # Prepare command string 
 
    dvd_command = ""
    dvd_command = dvd_command + " " + __exec_dvd__[0] + " " + __exec_dvd__[1] + " " + __exec_dvd__[2] 

    if (__verbose__ == 'true'):
        OSlog("final :" + dvd_command)   

    OSRun("dvd3.sh " + dvd_command,True,False)

    if (__verbose__ == 'true'): 
        OSlog("dvd-handbrake.sh command executed")     
 
    # Now we do loop until the PID-file exists

    time.sleep(8) 
   
    WCycles = 5 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(__configLinux__[32])):  
               if (__verbose__ == 'true'):
                   OSlog("pid-file exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 20):
               if (__verbose__ == 'true'):
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

    # In the case the provided pid over the file process-ids
    # are running we should display a BIG-Warning or even not 
    # kill the lock-file.

    PidList = []
 
    PidList = OSGetpids()

    # The Lock-file should only removed in the case
    # a process died unexpected ...

    if (PidList != 'none' ):
        x = 0 
        for item in PidList:
            OSlog("PID-list:" + str(item)) 
            try: 
                pid = int(item)
                os.kill(pid,0)
                running = True
            except OSError, err:
                running = False    
            if (running):
                return 0

    if (os.path.exists(__configLinux__[45])):
        os.remove(__configLinux__[45])
        if (__verbose__):
            OSlog("lock-file delete : " + __configLinux__[45])
        return 1
    else:
        return 0

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

    msg = ""

    # get Stages counter .....

    if (os.path.exists(__configLinux__[35])):
        StageCounter = open(__configLinux__[35],'r')
        line = StageCounter.readline()
        line.strip()
        Stages = int(line)
        StageCounter.close()

        # Get Stages-Descirption  

        stagesdescription = []
        if (os.path.exists(__configLinux__[36])):

            if (Stages == 1):
                StageDesc = open(__configLinux__[36],'r')
                line = StageDesc.readline()
                line.strip()
                stagesdescription.append(line)
                StageDesc.close()

            # Until version 0.6C A8 we had read direct the text from 
            # the shell-scripts but this behavior has one little failure.
            # The submitted strings from the scripts are not translated if
            # you plan to run this addon with other language than english.
            # Now the strings reside in strings.xml and can be translated.

            if (Stages >= 2):
                StageDesc = open(__configLinux__[36],'r') 
                for index in range(0,(Stages - 1)):
                    line = StageDesc.readline()
                    Translation_Index = int(line) 
                    stagesdescription.append(TranslationIndex)
                StageDesc.close()

            # Get Current-Stage 

            if (os.path.exists(__configLinux__[37])):
                StageCurrent = open(__configLinux__[37],'r')
                line = StageCurrent.readline()
                line.strip()
                StageCurrent.close()
                StageCurr = int (line)

                index = int(stagesdescription[(StageCurr - 1)])
                progress_message = __language__(index)

                # we should have all info for the text inside the progress-bar windows
                # and we dont have to edit the shell-scripts to update the messages (strings.xml)   
             
                msg = __language__(32174) + str(StageCurr) + " / " + str(Stages) + " " + progress_message
                
                if (__verbose__):
                    OSlog("Progress-bar text : " + msg)
 
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
# 1           Test failed    l                          # 
# 0           Test successfull                          #
#                                                       # 
#########################################################
def OSCheckSSH():

    global __configLinux__
    global __verbose__

    OSRun( "echo 1 > " + __configLinux__[39],False,False) 

    if (os.path.exists(__configLinux__[39])): 
        return 0
    else:
        return 1 

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
        BluRayVOl.close()       
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