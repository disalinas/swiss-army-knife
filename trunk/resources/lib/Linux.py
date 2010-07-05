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
# DATE    : 06-27-10                                    #
# STATE   : Alpha 1                                     #
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

__settings__ = xbmcaddon.Addon(id='script-video-ripper')
__language__ = __settings__.getLocalizedString

configLinux = [] 
temp_files = []
data_container = []
exec_bluray = []
exec_dvd = []
verbose = 'false'

#########################################################



#########################################################
# Function : OSlog                                      #
#########################################################
# Parameter                                             #
#                                                       #
# msg        String to be shown                         # 
#                                                       # 
# Returns    0                                          #
#########################################################
def OSlog(msg):
    xbmc.output("[%s]: [OSlog]  %s\n" % ("swiss-army-knife",str(msg))) 
    return (0)
#########################################################






#########################################################
# Function : OSConfiguration                            #
#########################################################
# Parameter                                             #
#                                                       #
# index      Howmany index the configurations should    #
#            have                                       #
#                                                       # 
# Returns    List with all configurations-settings      #
#########################################################
def OSConfiguration(index):

    config = []
    __settings__
    global data_container
    global configLinux
    global verbose 
    global temp_files 

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
    config[13] = __settings__.getSetting("id-show-customer") 
    config[14] = __settings__.getSetting("id-customer1") 
    config[15] = __settings__.getSetting("id-burn") 
    config[16] = __settings__.getSetting("id-netcat")
    config[17] = __settings__.getSetting("id-verbose")
    config[18] = __settings__.getSetting("id-dvd-subt")
 
    verbose = config[17]

    # On startup we need to check that all data-containers are writeable
 
    data_container.append(config[3])
    data_container.append(config[4])
    data_container.append(config[5])


    # config[19] until config[29] are reserved for future configurations-settings

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

    config[40] = os.getenv("HOME") + '/.xbmc/addons/swiss-army-knife/shell-linux/' 
    config[41] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/bluray/BR_VOLUME' 
    config[42] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/bluray/BR_TRACKS' 
    config[43] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/media/BR_GUI'
    config[44] = os.getenv("HOME") + '/.xbmc/userdata/addon_data/script-video-ripper/dvd/DVD_VOLUME'
  

    # With a list the delete of multiple files is very easy ;-) 

    temp_files.append(config[30])
    temp_files.append(config[31]) 
    temp_files.append(config[32])
    temp_files.append(config[33])
    temp_files.append(config[34])
    temp_files.append(config[35])
    temp_files.append(config[36])
    temp_files.append(config[37])
    temp_files.append(config[41])
    temp_files.append(config[42]) 
    temp_files.append(config[43]) 
    temp_files.append(config[44])


    # By now we have a modul global list with all the settings ;-)

    if (verbose == 'true'):
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


    configLinux = config 

    return config
#########################################################






#########################################################
# Function : OSRun                                      #
#########################################################
# Parameter                                             #
# command       command to execute over ssh             # 
# backg         Boolean : If true the command is        #
#               put into background.                    # 
#               Warning :                               #
#               DO ONLY SET THIS VALUE TO FALSE IF YOU  #
#               DO ONLY A JOB WIHTOUT ANY HEAVY IO      #
#               THE ADDON WILL WAIT UNTIL COMMAND IS    #
#               FINISHED.DO SET TO FALSE ON OWN RISK    #      
# busys         Boolean : Show busy-dialog during the   # 
#               execution of the command                #
# Returns                                               #
# State of os.system call                               #
#########################################################
def OSRun(command,backg,busys):    

    global configLinux
    global verbose 

    if (verbose == 'true'):
        OSlog ("OSRun start")
    if (busys):
        xbmc.executebuiltin("ActivateWindow(busydialog)")  
    sys.platform.startswith('linux')
    commandssh = "ssh " + configLinux[6] + " " + configLinux[40] + command + " "  
    if (backg):
        commandssh = commandssh + " > /dev/null 2>&1 &"

    # We do send a copy of the command to ssh-log  configLinux[38] 

    if (verbose == 'true'):
        OSlog("Command to run :" + commandssh)
    status = os.system("%s" % (commandssh))
    if (busys):
        xbmc.executebuiltin("Dialog.Close(busydialog)")
    if (verbose == 'true'):
        OSlog ("OSRun end")   
    return status
#########################################################





#########################################################
# Function : OSCheckMedia                               #
#########################################################
# Parameter                                             #
# Media         Contains BLURAY or DVD-ROM              #
#                                                       #
# Returns                                               #
# 0             Checkedi Media is inside device         #
# 1             No Media found inside device            #
# 2             state file not exist                    #
#########################################################
def OSCheckMedia(Media):

    global configLinux
    global verbose 

    # Erase  all temporary files 
 
    OSCleanTemp()      

    # Execution of shell-script br0.sh inside shell-linux  

    if (verbose == 'true'):
        OSlog("state.sh command ready to start")

    if (Media == 'BLURAY'):
        OSRun("br0.sh " +  configLinux[2],True,False)
    if (Media == 'DVD-ROM'):     
        OSRun("br0.sh " +  configLinux[1],True,False)

    if (verbose == 'true'):
        OSlog("state.sh command executed")


    xbmc.executebuiltin("ActivateWindow(busydialog)")   

    # We must wait until the file with the state-information could be read 
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(3) 
   
    WCycles = 3 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(configLinux[30])):  
               if (verbose == 'true'):
                   OSlog("state-files exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 1
               time.sleep(1)
           if (WCycles >= 10):
               if (verbose == 'true'):
                   OSlog("Timeout 10 secounds reached for track-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)") 
               return 2   

    xbmc.executebuiltin("Dialog.Close(busydialog)")

    # We shoud now have the file with the state 
 
    if (os.path.exists(configLinux[30])):   
        f = open(configLinux[30],'r')
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
# Function : OSChapterBluray                            #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               #
# list of tracks or list 'none' 0                       #
#########################################################
def OSChapterBluray():

    global configLinux
    global verbose 

    tracklist = []

    # Execution of shell-script br1.sh inside shell-linux 

    if (verbose == 'true'):
        OSlog("bluray-chapter.sh command ready to start")

    OSRun("br1.sh " +  configLinux[2],True,False)

    if (verbose == 'true'): 
        OSlog("bluray-chapter.sh command executed") 

    xbmc.executebuiltin("ActivateWindow(busydialog)")

    # We must wait until the file with the track-information could be read 
    # Without the list of track we can not select inside the list .....
    # If someone knows a bettey way to get this list faster ... send me pm .-)

    time.sleep(20) 
   
    WCycles = 20 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(configLinux[42])):  
               if (verbose == 'true'):
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
    
    if (verbose == 'true'):
        OSlog("track-files exist . Create list for GUI")
   
    # We should have the file with the state 
 
    if (os.path.exists(configLinux[42])):   
        trackfile = open(configLinux[42],'r')
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
# Function : OSCleanTemp                                #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               #
# none                                                  #
#########################################################
def OSCleanTemp():

    global temp_files 

    xbmc.executebuiltin("ActivateWindow(busydialog)")    

    # We have global list that contains all temp. files
    # as it looks easy do delete all file inside the list

    for item in temp_files:
         if (os.path.exists(item)):
             os.remove(item)

    time.sleep(1)
    xbmc.executebuiltin("Dialog.Close(busydialog)")
  
    return  

#########################################################







#########################################################
# Function : OSBlurayExecuteList                        #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               #
# list of blueray summary prio to execution             #
#########################################################
def OSBlurayExecuteList():

    global temp_files 
    global exec_bluray
    global configLinux
 
    GUIList = [] 
    tmp = []


    xbmc.executebuiltin("ActivateWindow(busydialog)")    

    if (os.path.exists(configLinux[43])): 

       GUIFile = open(configLinux[43],'r')
       for line in GUIFile.readlines():
           line = line.strip()
           tmp.append(line)
       GUIFile.close

       # We prepare the arguments for bluray-transcode.sh 

       exec_bluray.append(tmp[0])
       exec_bluray.append(configLinux[5])
       exec_bluray.append(tmp[3])
       exec_bluray.append(tmp[1])


       # Add device 
       GUIList.append(__language__(32151) + tmp[0])


       # Add track
       GUIList.append(__language__(32152) + tmp[1])

       # Add audio 
       GUIList.append(__language__(32153))

       # Add length
       GUIList.append(__language__(32154) + tmp[2])
 
       # Add name including extension mkv
       GUIList.append(__language__(32155) + tmp[3] + ".mkv")
    
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
# Function : OSBlurayTranscode                          #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               #
# 0               Transcode-process not startet         #
# 1               Transcode-process startet             #
#########################################################
def OSBlurayTranscode():

    global exec_bluray

    xbmc.executebuiltin("ActivateWindow(busydialog)")    

    # Execution of shell-script br2.sh inside shell-linux 

    if (verbose == 'true'):
        OSlog("bluray-transcode.sh command ready to start")

    OSRun("br2.sh " +  exec_bluray[0] + " " + exec_bluray[1] + " " + exec_bluray[2] + " " + exec_bluray[3],True,False)

    if (verbose == 'true'): 
        OSlog("bluray-transcode.sh command executed")     
 
    # Now we do loop until the PID-file exists

    time.sleep(30) 
   
    WCycles = 20 
    Waitexit = True 
    while (Waitexit):  
           if (os.path.exists(configLinux[32])):  
               if (verbose == 'true'):
                   OSlog("pid-file exist ...")
               Waitexit = False 
           else:
               WCycles = WCycles + 3
               time.sleep(3)
           if (WCycles >= 50):
               if (verbose == 'true'):
                   OSlog("Timeout 50 secounds reached for pid-file  ...")
               xbmc.executebuiltin("Dialog.Close(busydialog)")
               return 0       
        
    # Clean exec-array 
 
    del exec_bluray[3]
    del exec_bluray[2]
    del exec_bluray[1]
    del exec_bluray[0]
    
    xbmc.executebuiltin("Dialog.Close(busydialog)")
    return 1
#########################################################





#########################################################
# Function : OSGetProgressVal                           #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               # 
# 0-100         Current progress                        #
# 101           No value for progess to watch           #
# -1            File could not be opened                # 
#########################################################
def OSGetProgressVal():

    global configLinux

    if (os.path.exists(configLinux[31])):
        ProgressFile = open(configLinux[31],'r')
        line =  ProgressFile.readline()
        ProgressFile.close
        line = line.strip() 
        rvalue = int(line)
        return rvalue 
    else: 
        return -1 
#########################################################





#########################################################
# Function : OSGetStagesCounter                         #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               # 
# 1-X           Current progress-counter                #
# -1            File could not be opened                # 
#########################################################
def OSGetStagesCounter():

    global configLinux

    if (os.path.exists(configLinux[35])):
        ProgressFile = open(configLinux[35],'r')
        line =  ProgressFile.readline()
        ProgressFile.close
        line = line.strip() 
        rvalue = int(line)
        return rvalue 
    else: 
        return -1 
#########################################################




#########################################################
# Function : OSGetpids                                  #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               # 
# List          List with all process-pid for killing   #
# none          File could not be opened                # 
#########################################################
def OSGetpids():
    print   
    return 
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
def OSCheckContainerID(index)

    global data_container

    if (os.path.exists(data_container[index]):
        print  
        return 0        
    else 
        return 1
#########################################################



