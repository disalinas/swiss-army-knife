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
# VERSION : 0.6.11                                      #
# DATE    : 07-21-10                                    #
# STATE   : Alpha 10                                    #
# LICENCE : GPL 3.0                                     #
#########################################################
#                                                       #
# Project-Homepage :                                    #
# http://code.google.com/p/swiss-army-knife/            #
#                                                       #
#########################################################






####################### CONSTANTS #######################

__script__ 		= "Swiss-Army-Knife"
__scriptID__ 		= "script.video.swiss.army.knife"
__authorEmail__  	= "linuxluemmel.ch@gmail.com"
__author__ 		= "Hans Weber"
__url__ 		= "http://code.google.com/p/swiss-army-knife/"
__svn_url__ 		= "https://swiss-army-knife.googlecode.com/svn/trunk"
__platform__ 		= "xbmc media center, [LINUX]"
__date__ 		= "07-21-2010"
__version__ 		= "0.6.11"
__code_name__           = "300"
__XBMC_Revision__ 	= "31953"
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
__verbose__        = 'false'
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
   
   from linux import *
 
else:

   # only Linux is supported by now ...
   # help is welcome .. 

   sys.exit 

#########################################################




#########################################################
# Function  : GUIEditExportName                         #
#########################################################
# Parameter :                                           #
#                                                       #
# name        sugested name for export                  #
#                                                       # 
# Returns   :                                           #
#                                                       #
# name        name of export excluding any extension    #
#                                                       #
#########################################################
def GUIEditExportName(name):

    exit = True 
    while (exit):
          kb = xbmc.Keyboard('default', 'heading', True)
          kb.setDefault(name)
          kb.setHeading(__language__(33223))
          kb.setHiddenInput(False)
          kb.doModal()
          if (kb.isConfirmed()):
              name_confirmed  = kb.getText()
              name_correct = name_confirmed.count(' ')
              if (name_correct):
                 GUIInfo(2,__language__(33224)) 
              else: 
                   name = name_confirmed
                   exit = False
          else:
              GUIInfo(2,__language__(33225)) 
    return(name)
   
#########################################################




#########################################################
# Function  : GUISelectDir                              #
#########################################################
# Parameter : none                                      #
#                                                       # 
# Returns   :                                           #
#                                                       #
# Selected directory / without spaces / writeable       #
#                                                       #
#########################################################
def GUISelectDir():

    exit = True 
    while (exit):
          dialog = xbmcgui.Dialog()
          directory_1 = dialog.browse(0,__language__(33220), 'files', '', True, False, '//')
          if (directory_1 != '//'):               
              directory_2 =  directory_1[1:-1]
              path_correct = directory_2.count(' ')
              if (path_correct):
                  GUIInfo(2,__language__(33221)) 
              else: 
                  state = OSCheckAccess(directory_2)
                  if (state == 0):
                      exit = False
                  else:
                      GUIInfo(2,__language__(33222)) 
    return(directory_2)
   
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
# Returns   :                                           #
#                                                       #
# 0           Progress-bar canceld / Job running        #
# 1           Job finished                              #
#                                                       #                    
#########################################################
def GUIProgressbar(InfoText):

    progress = OSGetProgressVal()
    dp = xbmcgui.DialogProgress()
    dp.create(InfoText)

    exit = True 
    while (exit):
           progress = OSGetProgressVal()
           if (progress == 100):

               # We could have multiple passes and therefore 
               # only in the last pass we do close and send back 
               # Job is finished ...
                
               if (OSDetectLastStage() == True):
                   dp.close() 
                   exit = False
                   retval = 1

           dp.update(progress,OSGetStageText())
           if dp.iscanceled():
              dp.close() 
              exit = False
              retval = 0 
           time.sleep(1)
    return (retval)             

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

             if (choice == 0):
                 Lock = OSCheckLock(__configuration__[2])
                 if (__enable_bluray__ == 'true'):
                     if (Lock == 0):
                         GUIlog('menu bluray to mkv activated')
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             BluState = OSCheckMedia("BLURAY")
                             if (BluState == 2):
                                     GUIInfo(0,__language__(33302)) 
                             if (BluState == 1):
                                     GUIInfo(0,__language__(33301))
                             if (BluState == 0):
                                 tracklist = []
                                 tracklist = OSChapterBluray() 
                                 if (tracklist[0] != 'none'):
                                     executeList = []      

                                     executeList = OSBlurayExecuteList(False)
                                     track = GUISelectList(__language__(33202),tracklist)
                                     savedir = GUISelectDir() 
                                     volname = OSBlurayVolume()
                                     volname = GUIEditExportName(volname)

                                     blurayparameters = [__configuration__[2],savedir,volname,str(track)]
                                     OSBluAdd(blurayparameters)
                   
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

                 selected_done = False
                 append_pars = []
 
                 Lock = OSCheckLock(__configuration__[1])
                 if (Lock == 0):
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         DVDState = OSCheckMedia("DVD-ROM")
                         if (DVDState == 2):
                             GUIInfo(0,__language__(33302)) 
                         if (DVDState == 1):
                             GUIInfo(0,__language__(33311))
                         if (DVDState == 0):
                             tracklist = []
                             tracklist = OSChapterDVD()
                             if (tracklist[0] != 'none'):
                                 executeList = []
                                 audio1 = []
                                 audio2 = []
                                 sub = []   
                                 executeList = OSDVDExecuteList(False)
                                    
                                 track = GUISelectList(__language__(33207),tracklist)
                                 track = track + 1

                                 # We have a video-track 

                                 append_pars.append(" " + str(track) + " ") 

                                 GUIlog("Ready to start dvd4.sh")
                                 audio1 = OSDVDAudioTrack(track)
                                 GUIlog("dvd4.sh executed")

                                 if (audio1[0] != 'none'):
                                     aselect1 = GUISelectList(__language__(33226),audio1)
                                    
                                     # We have primary-audio language 

                                     append_pars.append(" " + str(aselect1) + " ") 
 
                                     dialog = xbmcgui.Dialog()
                                     title = __language__(33217)
                                     question = __language__(33227)
                                     selected = dialog.yesno(title, question)
                                     if (selected):
                                         audio2 = audio1  
                                         aselect2 = GUISelectList(__language__(33229),audio2)
                                       
                                         # a secoundary language was added
                               
                                         append_pars.append(" -a " + str(aselect2) + " ")
  
                                     dialog = xbmcgui.Dialog()
                                     title = __language__(33217)
                                     question = __language__(33228)
                                     selected = dialog.yesno(title, question)
                                     if (selected):
                                         sub = OSDVDSubTrack(track)   
                                         if (sub[0] != 'none'):
                                             sselect1 = GUISelectList(__language__(33230),sub)

                                             # subtitle was added 

                                             append_pars.append(" -s " + str(sselect1) + " ")
                                             selected_done = True 
                                         else:
                                             GUIInfo(2,__language__(33314)) 
                                     else: 
                                          selected_done = True 
                                     selected_done = True  
                                 else:
                                     GUIInfo(2,__language__(33313)) 
                             else:
                                 GUIInfo(0,__language__(33312)) 
                     else:
                         GUIInfo(0,__language__(33309))
                 else:
                     GUIInfo(0,__language__(33308))    

                 # We have all parameters execpt the filename and the directory to store 

                 if (selected_done == True):

                     execlist = []

                     savedir = GUISelectDir() 
                     volname = OSDVDVolume()
                     volname = GUIEditExportName(volname)                      
 
                     # Update parameters for the OS-Part DVD

                     execlist.append(__configuration__[1])
                     execlist.append(savedir)
                     execlist.append(volname)
                                
                     attach_index = len(append_pars)
                     for item in range(0,attach_index):
                          execlist.append(append_pars[item]) 
                     
                     if (__verbose__):   
                        for item in execlist:
                            GUIlog('dvd-parmater corrections :' + str(item))                                      

                     OSDVDAdd(execlist)       

                     execstate =  OSDVDTranscode() 
                     if (execstate == 0):
                         GUIInfo(2,__language__(33209))
                     if (execstate == 1):
                         GUIInfo(0,__language__(33208))
                         __jobs__ = True


             if (choice == 2):
                 Lock = OSCheckLock(__configuration__[1])
                 if (Lock == 0):
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         DVDState = OSCheckMedia("DVD-ROM")
                         if (DVDState == 2):
                             GUIInfo(0,__language__(33302)) 
                         if (DVDState == 1):
                             GUIInfo(0,__language__(33311))
                         if (DVDState == 0):
                             tracklist = []
                             tracklist = OSChapterDVD()
                             if (tracklist[0] != 'none'):
                                 executeList = []
                                 executeList = OSDVDExecuteList(False)   

                                 execlist = []

                                 savedir = GUISelectDir() 
                                 volname = OSDVDVolume()
                                 volname = GUIEditExportName(volname)                      
 
                                 # Update parameters for the OS-Part DVD

                                 execlist.append(__configuration__[1])
                                 execlist.append(savedir)
                                 execlist.append(volname)

                                 OSDVDAdd(execlist)      
 
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
                 GUIInfo(1,__language__(33205)) 

             if (choice == 4):
                 GUIInfo(1,__language__(33205)) 

             if (choice == 5):
                 GUIInfo(1,__language__(33205)) 

             if (choice == 6):
                 GUIInfo(1,__language__(33205)) 

             if (choice == 7):
                 state_ssh = OSCheckSSH()
                 if (state_ssh == 0):
                     GUIInfo(0,__language__(33218))   
                 else:
                     GUIInfo(2,__language__(33219)) 

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
                 if (__jobs__ == False):
                     state = GUIInfo(0,__language__(32177))
                 else:
                     state =  GUIProgressbar("Progress current process") 
                     if (state == 1):
                         __jobs__ = False
             if (choice == 1): 
                 if (__jobs__ == False):
                     GUIInfo(0,__language__(32177))
                 else:
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
                                     GUIInfo(0,__language__(33302)) 
                                 if (BluState == 1):
                                     GUIInfo(0,__language__(33301))
                                 if (BluState == 0):
                                     tracklist = []
                                     tracklist = OSChapterBluray() 
                                     if (tracklist[0] != 'none'):
                                         executeList = []      
                                         executeList = OSBlurayExecuteList(True)
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
                     Lock = OSCheckLock(__configuration__[1])
                     if (Lock == 0):
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             DVDState = OSCheckMedia("DVD-ROM")
                             if (DVDState == 2):
                                 GUIInfo(0,__language__(33302)) 
                             if (DVDState == 1):
                                 GUIInfo(0,__language__(33311))
                             if (DVDState == 0):
                                 tracklist = []
                                 tracklist = OSChapterDVD()
                                 if (tracklist[0] != 'none'):
                                     executeList = []
                                     executeList = OSDVDExecuteList(True)   
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
                     Lock = OSCheckLock(__configuration__[1])
                     if (Lock == 0):
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             DVDState = OSCheckMedia("DVD-ROM")
                             if (DVDState == 2):
                                 GUIInfo(0,__language__(33302)) 
                             if (DVDState == 1):
                                 GUIInfo(0,__language__(33311))
                             if (DVDState == 0):
                                 tracklist = []
                                 tracklist = OSChapterDVD()
                                 if (tracklist[0] != 'none'):
                                     executeList = []
                                     executeList = OSDVDExecuteList(True)   
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
                     JobWindow = GUIJobWinClass()
                     del JobWindow        
                 if (choice == 5): 
                     if (__verbose__):
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
   __verbose__         = __configuration__[17]
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






