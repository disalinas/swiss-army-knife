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


###################### CONTANTS #########################




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
    xbmc.output("[%s]: [OSlog] %s\n" % ("swiss-army-knife",str(msg))) 
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

    for i in range(0,index):
	config.append(" ")

    # Default settings addon 

    config[0] = __settings__.getAddonInfo("profile")
    config[1] = __settings__.getSetting("id-dvd") 
    config[2] = __settings__.getSetting("id-bluray")
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


    # config[17] until config[29] are reserved for future configurations-settings

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

    configLinux = config 

    OSRun("state.sh",False,True) 

    return config
#########################################################






#########################################################
# Function : OSRun                                      #
#########################################################
# Parameter                                             #
# command       command to execute over ssh             # 
# waitc         Boolean : If true the command is not    #
#               put into background.                    # 
# busys         Boolean : Show Busy-Dialog during the   # 
#               execution of the command                #
# Returns                                               #
# State of os.system call                               #
#########################################################
def OSRun(command,waitc,busys):    

    global configLinux

    OSlog ("OSRun start")
    if (busys):
        xbmc.executebuiltin("ActivateWindow(busydialog)")  
    sys.platform.startswith('linux')
    commandssh = configLinux[6] + " " + configLinux[40] + command + " "  
    if (waitc):
        commandssh = commandssh + "&"
    commandssh = commandssh + " > " + configLinux[38]
    OSlog("command to run :" + commandssh)
    status = os.system("%s" % (commandssh))
    time.sleep(1)
    if (busys):
        xbmc.executebuiltin("Dialog.Close(busydialog)")
    OSlog ("OSRun end")   
    return status
#########################################################

