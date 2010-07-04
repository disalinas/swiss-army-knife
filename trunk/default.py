#!/usr/bin/python
# -*- coding: utf-8 -*-
#########################################################
# SCRIPT  : default.py                                  #
#########################################################
# AUTHOR  : Hans Weber                                  #
# EMAIL   : linuxluemmel.ch@gmail.com                   #
# XBMC    : Version 10.5  or higher                     #
# PYTHON  : internal xbmc python 2.4.X                  #
# OS      : Linux                                       #
# TASKS   : - copy a dvd 1:1 as a iso file to a disk    #
#           - transcode bluray to matroska container    #
#           - transcode dvd to multiple formats         #
#           - Integration of user-functions             #
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




################## CONTANTS #############################

__script__ 		= "Swiss-Army-Knife"
__scriptID__ 		= "script-video-ripper"
__author__ 		= "linuxluemmel.ch@gmail.com"
__url__ 		= "http://code.google.com/p/swiss-army-knife/"
__svn_url__ 		= "https://swiss-army-knife.googlecode.com/svn/trunk"
__platform__ 		= "xbmc media center, [LINUX]"
__date__ 		= "27-06-2010"
__version__ 		= "0.6C"
__XBMC_Revision__ 	= "31504"
__index_config__        = 50 

xbmc.output(__script__ + " Version: " + __version__  + "\n")

#########################################################





####################### IMPORTS #########################

import xbmc, xbmcgui,xbmcaddon
import os, sys, thread, stat, time, string, re
import urllib, urlparse, urllib2, xml.dom.minidom

#########################################################



####################### GLOBAL DATA #####################

configuration = []  

__settings__ = xbmcaddon.Addon(id=__scriptID__)
__language__ = __settings__.getLocalizedString

enable_bluray = 'false'
enable_network = 'false'
enable_burning = 'false'
enable_customer = 'false'


CWD = os.getcwd().rstrip(";")
sys.path.append(xbmc.translatePath(os.path.join(CWD,'resources','lib')))


##########################################################
# Every Operating-System get a own import section        #
##########################################################            

system = os.uname()
if system[0] == 'Linux': 
   from Linux import OSConfiguration
   from Linux import OSRun
   from Linux import OSCheckMedia
   from Linux import OSChapterBluray
   from Linux import OSCleanTemp
   from Linux import OSBlurayExecuteList 
   from Linux import OSBlurayTranscode
   from Linux import OSGetProgressVal 
   from Linux import OSGetStagesCounter
   from Linux import OSGetpids
else:
   sys.exit

#########################################################




#########################################################
# Function : GUIlog                                     #
#########################################################
# Parameter                                             #
# msg          String to be shown                       # 
#                                                       # 
# Returns      none 0                                   #
#########################################################
def GUIlog(msg):
    xbmc.output("[%s]: [GUIlog] %s\n" % ("swiss-army-knife",str(msg))) 
    return (0)
#########################################################






#########################################################
# Function : GUIProgressbar                             #
#########################################################
# Parameter                                             #
# InfoText       Text for select-box                    #
#                                                       # 
# Returns        none                                   #
#########################################################
def GUIProgressbar(InfoText):

    dp = xbmcgui.DialogProgress()
    dp.create(InfoText)

    exit = True 
    while (exit):
           progress = OSGetProgressVal()
           if (progress == 100):
               dp.close() 
               exit = False 
           dp.update(progress,"")
           if dp.iscanceled():
              dp.close() 
              exit = False 
           time.sleep(3)
    return  

#########################################################







#########################################################
# Function : GUISelectList                              #
#########################################################
# Parameter                                             #
# InfoText       Text for select-box                    #
# SelectList     List with multpiple entrys to select   # 
#                                                       # 
# Returns        Index of list witch was selected       #
#########################################################
def GUISelectList(InfoText,SelectList):
    dialog = xbmcgui.Dialog()
    choice  = dialog.select(InfoText,SelectList)
    return choice
#########################################################





#########################################################
# Function : GUIInfo                                    #
#########################################################
# Parameter                                             #
# Info           String to be shown inside Dialog       # 
#                                                       # 
# Returns      none 0                                   #
#########################################################
def GUIInfo(Info):
    dialog = xbmcgui.Dialog()
    title = __language__(33201)
    selected = dialog.ok(title,Info)
    return 0
#########################################################




#########################################################
# Function : GUIMain02Class                             #
#########################################################
# Parameter                                             #
# xbmcgui.Window  Window                                # 
#                                                       # 
# Returns      none 0                                   #
#########################################################
class GUIMain02Class(xbmcgui.Window):
      def __init__(self):

       global enable_bluray
       global enable_network
       global enable_burning
       global enable_customer

       exit_script = True 
       while (exit_script): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32102), [__language__(32120), __language__(32121), __language__(32122),__language__(32123),
                                     __language__(32124),__language__(32125),__language__(32126),__language__(32127) ])
             if (choice == 7): 
                 exit_script = False
       self.close()
#########################################################



#########################################################
# Function : GUIMain01Class                             #
#########################################################
# Parameter                                             #
# xbmcgui.Window  Window                                # 
#                                                       # 
# Returns      none 0                                   #
#########################################################
class GUIMain01Class(xbmcgui.Window):
      def __init__(self):

       global enable_bluray
       global enable_network
       global enable_burning
       global enable_customer

       exit_script = True 
       while (exit_script): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32000) , [__language__(32100), __language__(32101), __language__(32102),__language__(32103),__language__(32104) ])

             if (choice == 0):

                 # Transcode bluray to mkv 
                 # The longest track of the bluray will be converted 
                 # The directory on witch the converted mkv is saved is defined inside settings
                 # The volname of the bluray-disc will be used as mkv-name 
                 # There is nothinhg to do for the user as to press the button ....
                 # Be aware that it could need long time to only start the transcode-process
                 # I need tester now ... 
 
                 if (enable_bluray == 'true'):
                     GUIlog('menu bluray to mkv activated')
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         BluState = OSCheckMedia("BLURAY")
                         if (BluState == 2):
                             GUIInfo(__language__(33302)) 
                         if (BluState == 1):
                             GUIInfo(__language__(33301))
                         if (BluState == 0):
                             tracklist = []
                             tracklist = OSChapterBluray() 
                             if (tracklist[0] != 'none'):
                                  executeList = []      
                                  executeList = OSBlurayExecuteList()
                              
                                  # We could now show the executor-list and a track-list
                                  # but we dont show the lists.


                                  # execute = GUISelectList(__language__(32150),executeList)
                                  # tracklist = GUISelectList(__language__(33202),trackist)

                                  # Allomost ready to transcode
                                  # Here we are ... ready to transcode ....

                                  execstate =  OSBlurayTranscode() 
                                  
                                  if (execstate == 0):
                                      GUIInfo(__language__(33204))
                                  if (execstate == 1):
                          
                                      # Now we should have a nice background job with the inserted 
                                      # bluray .... until we let do it finish or we cancel the job 

                                      GUIInfo(__language__(33203))
                             else:
                                  GUIInfo(__language__(33304))
                     else:        
                         GUIInfo(__language__(33000))
                 else:
                      GUIInfo(__language__(33303))

             if (choice == 1):  
                 GUIInfo(__language__(33205))              
             if (choice == 2): 
                 GUIInfo(__language__(33205))         
             if (choice == 3): 
                 GUIProgressbar("Progress transcoding bluray")        
             if (choice == 4): 
                 GUIlog('menu exit activated')
                 exit_script = False

       self.close()
#########################################################


#########################################################
####################### MAIN ############################
#########################################################
if __name__ == '__main__':
   
   global configuration 
   global enable_bluray
   global enable_network
   global enable_burning
   global enable_customer

   GUIlog ("addon-startet")

   GUIlog ("loading-configuration")
   configuration = OSConfiguration(__index_config__)
   
   enable_bluray = configuration[10]
   enable_network = configuration[11]
   enable_burning = configuration[15]
   enable_customer = configuration[14]
 
   GUIlog ("create main-menu")
   menu01 = GUIMain01Class()

   GUIlog ("addon-ended")   
#########################################################
#########################################################
#########################################################






