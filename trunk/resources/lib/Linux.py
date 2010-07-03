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




####################### LANGUAGE #######################

__settings__ = xbmcaddon.Addon(id='script-video-ripper')
__language__ = __settings__.getLocalizedString

#########################################################




####################### GLOBAL DATA #####################

configLinux = [] 
verbose = False

#########################################################



#########################################################
# Function : OSlog                                      #
#########################################################
# Parameter                                             #
# msg          String to be shown                       # 
#                                                       # 
# Returns      none 0                                   #
#########################################################
def OSlog(msg):
    xbmc.output("[%s]: [OSlog]  %s\n" % ("swiss-army-knife",str(msg))) 
    return (0)
#########################################################



#########################################################
# Function : OSConfiguration                            #
#########################################################
# Parameter                                             #
# index           Configurations-settings to load       # 
#                                                       # 
# Returns                                               #
# List with all configurations-settings                 #
#########################################################
def OSConfiguration(index):

    config = []
    __settings__
    global configLinux
    global verbose 

    for i in range(0,index):
	config.append("empty")

    # Default settings addon 

    config[0] = __settings__.getAddonInfo("profile")
    config[1] = __settings__.getSetting("id-device-dvd") 
    config[2] = __settings__.getSetting("id-device-bluray")
    config[3] = __settings__.getSetting("id-iso")
    config[4] = __settings__.getSetting("id-dvd")
    config[5] = __settings__.getSetting("id-bluray")
    config[6] = __settings__.getSetting("id-command")  
    config[7] = __settings__.getSetting("id-lang1")
    config[8] = __settings__.getSetting("id-lang2")
    config[9] = __settings__.getSetting("id-def_dvd")
    config[10] = __settings__.getSetting("id-show-bluray") 
    config[11] = __settings__.getSetting("id-show-network") 
    config[12] = __settings__.getSetting("id-show-burning") 
    config[13] = __settings__.getSetting("id-show-customer") 
    config[14] = __settings__.getSetting("id-customer1") 
    config[15] = __settings__.getSetting("id-burn") 
    config[16] = __settings__.getSetting("id-netcat")
    config[17] = __settings__.getSetting("id-verbose")


    verbose = config[17]

    # config[18] until config[29] are reserved for future configurations-settings

    # All used file are stored inside after here ...

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

    # By now we have a modul global list with all the settings ;-)

    if (verbose == True):
        OSlog("Configuration 0 reading : " + config[0])
        OSlog("Configuration 1 reading : " + config[1])
        OSlog("Configuration 2 reading : " + config[2]) 
        OSlog("Configuration 3 reading : " + config[3])
        OSlog("Configuration 4 reading : " + config[4])
        OSlog("Configuration 5 reading : " + config[5])
        OSlog("Configuration 6 reading : " + config[6]) 
        OSlog("Configuration 7 reading : " + config[7])
        OSlog("Configuration 8 reading : " + config[8])
        OSlog("Configuration 9 reading : " + config[9])
        OSlog("Configuration 10 reading : " + config[10])
        OSlog("Configuration 11 reading : " + config[11])
        OSlog("Configuration 12 reading : " + config[12])
        OSlog("Configuration 13 reading : " + config[13])
        OSlog("Configuration 14 reading : " + config[14])
        OSlog("Configuration 15 reading : " + config[15])
        OSlog("Configuration 16 reading : " + config[16])
        OSlog("Configuration 17 reading : " + config[17])

    configLinux = config 

    return config
#########################################################






#########################################################
# Function : OSRun                                      #
#########################################################
# Parameter                                             #
# command       command to execute over ssh             # 
# waitc         Boolean : If true the command is        #
#               put into background.                    # 
# busys         Boolean : Show busy-dialog during the   # 
#               execution of the command                #
# Returns                                               #
# State of os.system call                               #
#########################################################
def OSRun(command,waitc,busys):    

    global configLinux
    global verbose 

    if (verbose):
        OSlog ("OSRun start")
    if (busys):
        xbmc.executebuiltin("ActivateWindow(busydialog)")  
    sys.platform.startswith('linux')
    commandssh = "ssh " + configLinux[6] + " " + configLinux[40] + command + " "  
    if (waitc):
        commandssh = commandssh + "&"
    commandssh = commandssh + " > " + configLinux[38]
    if (verbose):
        OSlog("Command to run :" + commandssh)
    status = os.system("%s" % (commandssh))
    if (busys):
        xbmc.executebuiltin("Dialog.Close(busydialog)")
    if (verbose):
        OSlog ("OSRun end")   
    return status
#########################################################





#########################################################
# Function : OSCheckBlu                                 #
#########################################################
# Parameter                                             #
# none                                                  #
# Returns                                               #
# 0             bluray-disc inserted inside device      #
# 1             No bluray-disc found inside device      #
# 2             state file not exist                    #
#########################################################
def OSCheckBlu():

    global configLinux
    global verbose 

    # Execution of shell-script state.sh inside shell-linux 

    OSRun("state.sh " +  configLinux[2],False,False)     
    
    # We shoud now have the fiel with the state 
 
    if (os.path.exists(configLinux[2])):   
        f = open(configLinux[2],'r')
        media = f.readline()
        f.close       
        if (media == 'BLURAY'):
            return 0 
        else:
            return 1
    else:
        return 2         
#########################################################








