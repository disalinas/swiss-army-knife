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
# VERSION : 0.6C-A8                                     #
# DATE    : 07-13-10                                    #
# STATE   : Alpha 8                                     #
# LICENCE : GPL 3.0                                     #
#########################################################
#                                                       #
# Project-Homepage :                                    #
# http://code.google.com/p/swiss-army-knife/            #
#                                                       #
#########################################################






####################### CONSTANTS #######################

__script__ 		= "Swiss-Army-Knife"
__scriptID__ 		= "script-video-ripper"
__authorEmail__  	= "linuxluemmel.ch@gmail.com"
__author__ 		= "Hans Weber"
__url__ 		= "http://code.google.com/p/swiss-army-knife/"
__svn_url__ 		= "https://swiss-army-knife.googlecode.com/svn/trunk"
__platform__ 		= "xbmc media center, [LINUX]"
__date__ 		= "07-12-2010"
__version__ 		= "0.6C-ALPHA-8"
__code_name__           = "Bill and Teds bogus journey"
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

__configuration__ = []  

__settings__ = xbmcaddon.Addon(id=__scriptID__)
__language__ = __settings__.getLocalizedString

__enable_bluray__ = 'false'
__enable_network__ = 'false'
__enable_burning__ = 'false'
__enable_customer__ = 'false'
__enable_pw_mode__ = 'false'
__pw__ = ''
__jobs__ = False


CWD = os.getcwd().rstrip(";")
sys.path.append(xbmc.translatePath(os.path.join(CWD,'resources','lib')))


##########################################################
# Every Operating-System get a own import section        #
# Feel free to send patches for Windows and MacOS x      #
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
   from Linux import OSCheckContainerID
   from Linux import OSCheckLock 
   from Linux import OSKillProc
   from Linux import OSGetJobState
   from Linux import OSChapterDVD
   from Linux import OSDVDExecuteList     
   from Linux import OSDVDTranscode
   from Linux import OSDVDcopyToIso
   from Linux import OSRemoveLock
   from Linux import OSGetStageText
else:

   # only Linux is supported by now ...

   sys.exit 

#########################################################





#########################################################
# Function  : GUIlog                                    #
#########################################################
# Parameter :                                           #
#                                                       #
# msg         String to be shown inside GUI             # 
#                                                       # 
# Returns   : none                                      #
#########################################################
def GUIlog(msg):
    xbmc.output("[%s]: [GUIlog] %s\n" % ("swiss-army-knife",str(msg))) 
    return (0)

#########################################################





#########################################################
# Function  : GUIProgressbar                            #
#########################################################
# Parameter :                                           #
#                                                       #
# InfoText    Text for progress-bar box                 #
#                                                       # 
# Returns   : none                                      #
#########################################################
def GUIProgressbar(InfoText):

    progress = OSGetProgressVal()
    dp = xbmcgui.DialogProgress()
    dp.create(InfoText)

    exit = True 
    while (exit):
           progress = OSGetProgressVal()
           if (progress == 100):
               dp.close() 
               exit = False 
           dp.update(progress,OSGetStageText())
           if dp.iscanceled():
              dp.close() 
              exit = False 
           time.sleep(1)
    return  

#########################################################





#########################################################
# Function  : GUISelectList                             #
#########################################################
# Parameter :                                           #
#                                                       #
# InfoText    Text for select-box                       #
# SelectList  Python List with entrys to select         # 
#                                                       # 
# Returns   : Index of List witch was selected (int)    #
#########################################################
def GUISelectList(InfoText,SelectList):

    dialog = xbmcgui.Dialog()
    choice  = dialog.select(InfoText,SelectList)
    return choice

#########################################################





#########################################################
# Function  : GUIInfo                                   #
#########################################################
# Parameter :                                           #
#                                                       #
# Selector    integer                                   # 
#                                                       #
# 0           Info                                      #
# 1           Warning                                   #
# 2           Error                                     #
# 3           No text                                   #
#                                                       #
# Info        String to be shown inside Dialog-Box      #
#                                                       # 
# Returns   : none                                      #
#########################################################
def GUIInfo(Selector,Info):
    dialog = xbmcgui.Dialog()

    title = __language__(33214 + Selector)
    selected = dialog.ok(title,Info)
    return 0

#########################################################





#########################################################
# Function  : GUIExpertWinClass                         #
#########################################################
# Parameter : XBMC-Window Class                         #
#                                                       #
# xbmcgui.Window                                        # 
#                                                       # 
# Returns   : none                                      #
#########################################################
class GUIExpertWinClass(xbmcgui.Window):

      def __init__(self):

          global __jobs__ 
          exit = True

          menu = []       
          for i in range(32120,32130):
	      menu.append(__language__(i))
          while (exit): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32092) ,menu)
             if (choice == 8): 
                 message = "Author  :  " + __author__ + "\nVersion :  " + __version__ 
                 GUIInfo(3,message)   
             if (choice == 9):   
                 exit = False
          self.close()

#########################################################





#########################################################
# Function  : GUIJobWinClass                            #
#########################################################
# Parameter : XBMC-Window Class                         #
#                                                       #
# xbmcgui.Window                                        # 
#                                                       # 
# Returns   : none                                      #
#########################################################
class GUIJobWinClass(xbmcgui.Window):

      def __init__(self):

          global __jobs__ 
          exit = True

          menu = []     
          for i in range(32170,32174):
	      menu.append(__language__(i))
          while (exit): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32091) ,menu)
             if (choice == 0):  
                GUIProgressbar("Progress current stage")       
             if (choice == 1):  
                 state = OSKillProc()
                 if (state == 0):
                     GUIInfo(0,__language__(33206))     
                     __jobs__ = False
                     exit = False
                 if (state == 1):
                     GUIInfo(0,__language__(33310))     
             if (choice == 2):  
                 removal = OSRemoveLock()  
             if (choice == 3):   
                 exit = False
          self.close()

#########################################################





#########################################################
# Function  : GUIMain01Class                            #
#########################################################
# Parameter : XBMC-Window Class                         #
#                                                       #
# xbmcgui.Window                                        # 
#                                                       # 
# Returns   : none                                      #
#########################################################
class GUIMain01Class(xbmcgui.Window):

      def __init__(self):
        
          global __jobs__
 
          # Retrive JobsState to act inside the addon ....

          job_state = OSGetJobState()
          if (job_state == 1):
              __jobs__ = True
          if (job_state == 0):
              __jobs__ = False

          menu = []      
          for i in range(32100,32106):
	      menu.append(__language__(i))

          exit_script = True 
          while (exit_script): 
                 dialog = xbmcgui.Dialog()
                 choice  = dialog.select(__language__(32090) ,menu)
                 if (choice == 0):
                     Lock = OSCheckLock(__configuration__[2])
                     if (__enable_bluray__ == 'true'):
                         if (Lock == 0):
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

                                         # execute = GUISelectList(__language__(32150),executeList)
                                         # tracklist = GUISelectList(__language__(33202),trackist)

                                         execstate =  OSBlurayTranscode() 
                                         if (execstate == 0):
                                             GUIInfo(2,__language__(33204))
                                         if (execstate == 1):
                                             GUIInfo(0,__language__(33203))
                                             __jobs__ = True
                                     else:
                                          GUIInfo(0,__language__(33304))
                             else:
                                  GUIInfo(0,__language__(33309))
                         else:        
                             GUIInfo(0,__language__(33308))   
                     else:
                         GUIInfo(0,__language__(33303))    

                 if (choice == 1):  
                     Lock = OSCheckLock(__configuration__[2])
                     if (Lock == 0):
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             DVDState = OSCheckMedia("DVD-ROM")
                             if (DVDState == 2):
                                 GUIInfo(__language__(33302)) 
                             if (DVDState == 1):
                                 GUIInfo(__language__(33311))
                             if (DVDState == 0):
                                 tracklist = []
                                 tracklist = OSChapterDVD()
                                 if (tracklist[0] != 'none'):
                                     executeList = []
                                     executeList = OSDVDExecuteList()   
                                     # execute = GUISelectList(__language__(32150),executeList)
                                     execstate =  OSDVDTranscode() 
                                     if (execstate == 0):
                                         GUIInfo(2,__language__(33209))
                                     if (execstate == 1):
                                         GUIInfo(0,__language__(33208))
                                         __jobs__ = True
                                 else:
                                     GUIInfo(0,__language__(33312)) 
                         else:
                             GUIInfo(0,__language__(33309))
                     else:
                         GUIInfo(0,__language__(33308))    

                 if (choice == 2): 
                     Lock = OSCheckLock(__configuration__[2])
                     if (Lock == 0):
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             DVDState = OSCheckMedia("DVD-ROM")
                             if (DVDState == 2):
                                 GUIInfo(__language__(33302)) 
                             if (DVDState == 1):
                                 GUIInfo(__language__(33311))
                             if (DVDState == 0):
                                 tracklist = []
                                 tracklist = OSChapterDVD()
                                 if (tracklist[0] != 'none'):
                                     executeList = []
                                     executeList = OSDVDExecuteList()   
                                     execstate = OSDVDcopyToIso() 
                                     if (execstate == 0):
                                         GUIInfo(2,__language__(33211))
                                     if (execstate == 1):
                                         GUIInfo(0,__language__(33210))
                                         __jobs__ = True
                                 else:
                                     GUIInfo(0,__language__(33312)) 
                         else:
                             GUIInfo(0,__language__(33309))
                     else:
                         GUIInfo(0,__language__(33308))    


                 if (choice == 3): 
                     if ( __enable_pw_mode__ == 'true'):
                         kb = xbmc.Keyboard('default', 'heading', True)
                         kb.setDefault()
                         kb.setHeading(__language__(33212))
                         kb.setHiddenInput(True)
                         kb.doModal()
                         if (kb.isConfirmed()):
                             password = kb.getText()
                             if (password == __pw__ ):
                                 ExpertWindow = GUIExpertWinClass()
                                 del ExpertWindow
                             else: 
                                 GUIInfo(2,__language__(33213))    
                     else:
                          ExpertWindow = GUIExpertWinClass()
                          del ExpertWindow         
                 if (choice == 4): 
                     if (__jobs__ == False):
                        GUIInfo(0,__language__(32177))
                     else:
                        JobWindow = GUIJobWinClass()
                        del JobWindow        
                 if (choice == 5): 
                     GUIlog('menu exit activated')
                     exit_script = False
          self.close()

#########################################################




#########################################################
####################### MAIN ############################
#########################################################

if __name__ == '__main__':
   
   xbmc.executebuiltin("ActivateWindow(busydialog)")
    
   GUIlog ("addon-startet")

   GUIlog ("loading-configuration")
   __configuration__ = OSConfiguration(__index_config__)
   
   __enable_bluray__   = __configuration__[10]
   __enable_network__  = __configuration__[11]
   __enable_burning__  = __configuration__[15]
   __enable_customer__ = __configuration__[14]
   __enable_pw_mode__  = __configuration__[19]
   __pw__              = __configuration__[20]
 
   # Check that directory exists and could be written 
   # Bluray-directory is only included if the functions are enabled

   if (__enable_bluray__ == "true"):
       if (OSCheckContainerID(2)):
           GUIInfo(1,__language__(33307)) 
     
   if (OSCheckContainerID(1)):
       GUIInfo(1,__language__(33306))

   if (OSCheckContainerID(0)):
       GUIInfo(1,__language__(33305))

   GUIlog ("create main-menu")

   time.sleep(1)
 
   xbmc.executebuiltin("Dialog.Close(busydialog)")

   menu01 = GUIMain01Class()
   del menu01

   GUIlog ("addon-ended")   
   
#########################################################
#########################################################
#########################################################






