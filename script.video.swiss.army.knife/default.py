#!/usr/bin/python
# -*- coding: utf-8 -*-
#########################################################
# SCRIPT  : default.py                                  #
#########################################################
# AUTHOR  : Hans Weber                                  #
# EMAIL   : linuxluemmel.ch@gmail.com                   #
# XBMC    : Version 10.0 or higher                      #
# PYTHON  : internal xbmc python 2.4.X                  #
# OS      : Linux                                       #
# TASKS   : - copy a dvd 1:1 as a iso file to a disk    #
#           - transcode bluray to matroska container    #
#           - transcode dvd to multiple formats         #
#             including Appple Iphone and Sony PSP      # 
#           - Integration of user-functions 1-9         #
# VERSION : 0.6.19                                      #
# DATE    : 01-03-11                                    #
# STATE   : Beta 4                                      #
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
__date__ 		= "01-03-2011"
__version__ 		= "0.6.19"
__code_name__           = "Avatar"
__XBMC_Revision__ 	= "35648"
__index_config__        = 65
__credits__             = "a bunch of gpl-devs"
 

xbmc.output(__script__ + " Version: " + __version__  + "\n")

#########################################################





####################### IMPORTS #########################

import xbmc, xbmcgui,xbmcaddon
import os, sys, threading, stat, time, string, re
import urllib, urlparse, urllib2, xml.dom.minidom

#########################################################





####################### GLOBAL DATA #####################

__configuration__ = []  
__dvd_values__ = []

__settings__ = xbmcaddon.Addon(id=__scriptID__)
__language__ = __settings__.getLocalizedString

__default_dvd_tr__  = 0
__enable_bluray__   = 'false'
__enable_network__  = 'false'
__enable_burning__  = 'false'
__enable_customer__ = 'false'
__enable_pw_mode__  = 'false'
__verbose__         = 'false'
__disable_cp_trancode__ = 'false'
__notifications__ = 'false'
__allways_default__ = 'false'
__ProgressView__ = False
__default_tr_mkv__ = False
__pw__ = ''
__jobs__ = False
__linebreak__ = 0
__exitFlag__ = False

CWD = os.getcwd().rstrip(";")
sys.path.append(xbmc.translatePath(os.path.join(CWD,'resources','lib')))


##########################################################
# Every Operating-System get a own import section        #
# Feel free to send patches for Windows and MacOS x      #
##########################################################

system = os.uname()
if system[0] == 'Linux':
   
   from Linux import *
 
else:

   # only Linux is supported by now ...
   # help is welcome .. 

   sys.exit 

#########################################################





#########################################################
# Function  : GUINotification                           #
#########################################################
# Parameter :                                           #
#                                                       #
# Info        Text to be shown inside Notification-Box  #
#                                                       # 
# Returns   : none                                      #
#########################################################
def GUINotification(Info):

    if (__verbose__ == "true"):
        GUIlog('notification : [' + Info + "]")

    Command = '"xbmc.Notification((Swiss-Army-Knife),' + Info + ',10)"'
    xbmc.executebuiltin( "xbmc.Notification((Swiss-Army-Knife)," + Info + ",1000) ")
 
    if (__verbose__ == "true"):
       GUIlog('notification-command : [' + Command + "]") 

    return 
     
#########################################################




#########################################################
# Function  : GUIYesNo                                  #
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
# Returns   : OK or Yes                                 #
#########################################################
def GUIYesNo(Selector,Info):

    global __linebreak__

    # Is the text that should be displayed shorter than __linebreak__ ?

    LenInfo = len(Info)

    if (LenInfo <= (__linebreak__ - 1)):

        # The text fit into a single line 

        dialog = xbmcgui.Dialog()
        title = __language__(33214 + Selector)
        selected = dialog.yesno(title,Info)

    else:

        # we need to split the single string into 2 lines ...

        line1 = ''
        line2 = ''

        for word in Info.split(' '):
            l1 = len(line1)
            l2 = len(word)
            if ((l1 + l2) <= (__linebreak__ - 1)):
                line1 = line1 + word + ' '
            else:     
                line2 = line2 + word + ' '

        dialog = xbmcgui.Dialog()
        title = __language__(33214 + Selector)
        selected = dialog.yesno(title,line1,line2)
  
    return selected

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
     
    if (__verbose__ == "true"):     
       xbmc.output("[%s]: [GUIlog] %s\n" % ("swiss-army-knife",str(msg)))

    return

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

    global __ProgressView__   

    __ProgressView__ = True
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
                      if (__verbose__ == "true"):
                          GUIlog('active job finished')
                      dp.close() 
                      exit = False
                      retval = 1
                      time.sleep(3)

           dp.update(progress,OSGetStageText())
           if dp.iscanceled():
              dp.close() 
              exit = False
              retval = 0
           time.sleep(1)

    __ProgressView__ = False
    return (retval)             

#########################################################







#########################################################
# Function  : GUISelectDVDTranscode                     #
#########################################################
# Parameter : none                                      #
#                                                       # 
#                                                       # 
# Returns   : list of all default values                #
#########################################################
def GUISelectDVDTranscode():

    # We define the default parameters for the dvd-transcoding 

    # 1 -> 264-high 	/dev/sr0   	/dvdrip/dvd 		
    # 2 -> iso 		/dev/sr0  	/dvdrip/iso	
    # 3 -> h264-low	/dev/sr0 	/dvdrip/transcode 
    # 4 -> mkv 		/dev/sr0 	/dvdrip/transcode 
    # 5 -> vobcopy	/dev/sr0 	/dvdrip/vobcopy      
    # 6 -> iphone  	/dev/sr0	/dvdrip/portable/ip
    # 7 -> psp		/dev/sr0	/dvdrip/portable/psp

    dvd_parameters = []

    dvd_parameters.append("h264-high " +  "5 2 " + __configuration__[1] + " " + __configuration__[4] + " " + "var1" + " " + "var2" + " " + "var3" + " " + "var4")
    dvd_parameters.append("iso " +  "3 0 " + __configuration__[1] + " " + __configuration__[3] + " " + "var1")
    dvd_parameters.append("h264-low " + "5 2 " +  __configuration__[1] + " " + __configuration__[13] + " " + "var1" + " " + "var2" + " " + "var3" + " " + "var4")
    dvd_parameters.append("mkv " + "3 0 " +  __configuration__[1] + " " + __configuration__[13] + " " + "var1")
    dvd_parameters.append("vobcopy " + "3 0 " +  __configuration__[1] + " " + __configuration__[21] + " " + "var1")
    dvd_parameters.append("iphone " + "5 2 " +  __configuration__[1] + " " + __configuration__[50] + " " + "var1" + " " + "var2" + " " + "var3" + " " + "var4")
    dvd_parameters.append("psp " + "5 2 " +  __configuration__[1] + " " + __configuration__[51] + " " + "var1" + " " + "var2" + " " + "var3" + " " + "var4")
      
    return dvd_parameters    
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

    global __linebreak__

    # Is the text that should be displayed shorter than __linebreak__ ?

    LenInfo = len(Info)

    if (LenInfo <= (__linebreak__ - 1)):

        # The text fit into a single line 

        dialog = xbmcgui.Dialog()
        title = __language__(33214 + Selector)
        selected = dialog.ok(title,Info)

    else:

        # we need to split the single string into 2 lines ...

        line1 = ''
        line2 = ''

        for word in Info.split(' '):
            l1 = len(line1)
            l2 = len(word)
            if ((l1 + l2) <= (__linebreak__ - 1)):
                line1 = line1 + word + ' '
            else:     
                line2 = line2 + word + ' '

        dialog = xbmcgui.Dialog()
        title = __language__(33214 + Selector)
        selected = dialog.ok(title,line1,line2)
  
    return 0

#########################################################




#########################################################
# Class     : GUIExpertUserfunctionsClass               #
#########################################################
# Parameter : XBMC-Window Class                         #
#                                                       #
# xbmcgui.Window                                        # 
#                                                       # 
# Returns   : none                                      #
#########################################################
class GUIExpertUserfunctionsClass(xbmcgui.Window):

      def __init__(self):

          global __jobs__ 
          exit = True

          menu = []
          index = 1 
          found = 0 
     
          # We generate the menu-list over a loop ,-)

          for i in range(32190,32200):
              userdescription = OSGetUserDesc(index)
              if (userdescription == " "):
 	          menu.append(__language__(i))
              else:
                  menu.append(userdescription)
                  found = found + 1
              index = index + 1

          # If there are no user-functions found 
          # we will exit ... 

          if (found == 0):  
            GUIInfo(0,__language__(33236)) 
            if (__verbose__ == "true"):                
               GUIlog ("no user-functions found.Read the documenation how to use them")     
            self.close()
          else:

              # We stay inside menu until exit ....

              while (exit): 
                     dialog = xbmcgui.Dialog()
                     choice  = dialog.select(__language__(32094) ,menu)
                     if (choice == 0):
                         if (menu[0] != " "):
                            OSRun("user1.sh",True,False) 
                            GUINotification("user1.sh executed")   
                     if (choice == 1):
                         if (menu[1] != " "):
                            OSRun("user2.sh",True,False)   
                            GUINotification("user2.sh executed")   
                     if (choice == 2):
                         if (menu[2] != " "):
                            OSRun("user3.sh",True,False)  
                            GUINotification("user3.sh executed")   
                     if (choice == 3):
                         if (menu[3] != " "):
                            OSRun("user4.sh",True,False)  
                            GUINotification("user4.sh executed")    
                     if (choice == 4):
                         if (menu[4] != " "): 
                            OSRun("user5.sh",True,False)  
                            GUINotification("user5.sh executed")   
                     if (choice == 5):
                         if (menu[5] != " "):
                            OSRun("user6.sh",True,False) 
                            GUINotification("user6.sh executed")   
                     if (choice == 6):
                        if (menu[6] != " "): 
                           OSRun("user7.sh",True,False) 
                           GUINotification("user7.sh executed")   
                     if (choice == 7):
                         if (menu[7] != " "): 
                            OSRun("user8.sh",True,False) 
                            GUINotification("user8.sh executed")   
                     if (choice == 8):
                         if (menu[8] != " "): 
                            OSRun("user9.sh",True,False) 
                            GUINotification("user9.sh executed")     
                     if (choice == 9): 
                        exit = False
                        time.sleep(1) 
          self.close()

#########################################################




#########################################################
# Class     : GUIExpertTranscodeClass                   #
#########################################################
# Parameter : XBMC-Window Class                         #
#                                                       #
# xbmcgui.Window                                        # 
#                                                       # 
# Returns   : none                                      #
#########################################################
class GUIExpertTranscodeClass(xbmcgui.Window):

      def __init__(self):

          global __jobs__ 
          exit = True

          menu = []

          # We generate the menu-list over a loop ,-)
       
          for i in range(32180,32186):
	      menu.append(__language__(i))

          # We stay inside menu until exit ....

          while (exit): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32095) ,menu)
             if (choice == 0):
                 GUIInfo(1,__language__(33205))  
                 exit = True    
             if (choice == 1):
 
                 ############################################## 
                 # Transcoding dvd to mkv selected            # 
                 ############################################## 
                               
                 Lock = OSCheckLock(__configuration__[1])
                 if (__enable_bluray__ == 'true'):
                     if (Lock == 0):
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             DVDState = OSCheckMedia("DVD-ROM")
                             if (DVDState == 3):
                                 GUIlog('dvd-copy protection detected !!')  
                                 selection = GUIYesNo(1,__language__(33334))
                                 if (selection):
                                     DVDState = 0
                             if (DVDState == 2):
                                 GUIInfo(0,__language__(33302)) 
                             if (DVDState == 1):
                                 GUIInfo(0,__language__(33311))
                             if (DVDState == 0):
                                 tracklist = []

                                 tracklist = OSChapterDVD()
                                 track = GUISelectList(__language__(33207),tracklist)            
                     
                                 # makemkv is not starting with index 1

                                 if (tracklist[0] != 'none'):
                                      execlist = []

                                      if ( __allways_default__ == 'true'):
                                         savedir = __configuration__[13]
                                      else:
                                         savedir = GUISelectDir()

                                      volname = OSDVDVolume()
                                      volname = GUIEditExportName(volname) 
 
                                      # Update parameters for the OS-Part DVD

                                      execlist.append(__configuration__[1])
                                      execlist.append(savedir)
                                      execlist.append(volname)
                                      execlist.append(track)
                                      OSDVDAdd(execlist)
       
                                      execstate =  OSDVDtoMKV()
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
                 else:
                     GUIInfo(0,__language__(33328)) 

             if (choice == 2):


                 ############################################## 
                 # Transcoding dvd-low selected               # 
                 ##############################################

                 selected_done = False
                 append_pars = []
 
                 Lock = OSCheckLock(__configuration__[1])
                 if (Lock == 0):
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         DVDState = OSCheckMedia("DVD-ROM")
                         if (DVDState == 3):
                             GUIlog('dvd-copy protection detected !!') 
                             selection = GUIYesNo(1,__language__(33334))
                             if (selection):
                                 DVDState = 0
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
                                  
                                 if (__verbose__ == "true"):    
                                    GUIlog("Ready to start dvd4.sh")

                                 audio1 = OSDVDAudioTrack(track)

                                 if (__verbose__ == "true"):    
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

                     if ( __allways_default__ == 'true'):
                        savedir = __configuration__[13]
                     else:
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
                     
                     if (__verbose__ == "true"):   
                        for item in execlist:
                            GUIlog('dvd-parmater corrections :' + str(item))                                      

                     OSDVDAdd(execlist)       

                     execstate = OSDVDtoLOW() 
                     if (execstate == 0):
                         GUIInfo(2,__language__(33209))
                     if (execstate == 1):
                         GUIInfo(0,__language__(33208))
                         __jobs__ = True

             if (choice == 3):

                 ############################################## 
                 # Transcoding dvd-iphone selected            # 
                 ##############################################

                 selected_done = False
                 append_pars = []
 
                 Lock = OSCheckLock(__configuration__[1])
                 if (Lock == 0):
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         DVDState = OSCheckMedia("DVD-ROM")
                         if (DVDState == 3):
                             GUIlog('dvd-copy protection detected !!') 
                             selection = GUIYesNo(1,__language__(33334))
                             if (selection):
                                 DVDState = 0
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

                     if ( __allways_default__ == 'true'):
                        savedir = __configuration__[50]
                     else:
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
                     
                     if (__verbose__ == "true"):   
                        for item in execlist:
                            GUIlog('dvd-parmater corrections :' + str(item))                                      

                     OSDVDAdd(execlist)       

                     execstate =  OSDVDtoIphone() 
                     if (execstate == 0):
                         GUIInfo(2,__language__(33209))
                     if (execstate == 1):
                         GUIInfo(0,__language__(33208))
                         __jobs__ = True

             if (choice == 4):

                 ############################################## 
                 # Transcoding dvd-psp selected               # 
                 ##############################################

                 selected_done = False
                 append_pars = []
 
                 Lock = OSCheckLock(__configuration__[1])
                 if (Lock == 0):
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         DVDState = OSCheckMedia("DVD-ROM")
                         if (DVDState == 3):
                             GUIlog('dvd-copy protection detected !!') 
                             selection = GUIYesNo(1,__language__(33334))
                             if (selection):
                                 DVDState = 0
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

                     if ( __allways_default__ == 'true'):
                        savedir = __configuration__[51]
                     else:
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
                     
                     if (__verbose__ == "true"):   
                        for item in execlist:
                            GUIlog('dvd-parmater corrections :' + str(item))                                      

                     OSDVDAdd(execlist)       

                     execstate =  OSDVDtoPSP() 
                     if (execstate == 0):
                         GUIInfo(2,__language__(33209))
                     if (execstate == 1):
                         GUIInfo(0,__language__(33208))
                         __jobs__ = True


             if (choice == 5): 
                 exit = False
                 time.sleep(1) 

          self.close()

#########################################################





#########################################################
# Class     : GUIExpertNetworkClass                     #
#########################################################
# Parameter : XBMC-Window Class                         #
#                                                       #
# xbmcgui.Window                                        # 
#                                                       # 
# Returns   : none                                      #
#########################################################
class GUIExpertNetworkClass(xbmcgui.Window):

      def __init__(self):

          global __jobs__ 
          exit = True

          menu = []

          # We generate the menu-list over a loop ,-)
       
          for i in range(32140,32145):
	      menu.append(__language__(i))

          # We stay inside menu until exit ....

          while (exit): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32093) ,menu)
             if (choice == 0):
                 GUIInfo(1,__language__(33205)) 
                 exit = True
             if (choice == 1):
                 GUIInfo(1,__language__(33205))  
                 exit = True    
             if (choice == 2):
                 GUIInfo(1,__language__(33205)) 
                 exit = True
             if (choice == 3):
                 GUIInfo(1,__language__(33205)) 
                 exit = True 
             if (choice == 4): 
                 exit = False 
                 time.sleep(1)                 
          self.close()

#########################################################





#########################################################
# Class     : GUIExpertWinClass                         #
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

          # We generate the menu-list over a loop ,-)
      
          for i in range(32120,32131):
	      menu.append(__language__(i))

          # We stay inside menu until exit ....

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

                                     if ( __allways_default__ == 'true'):
                                        savedir = __configuration__[5]
                                     else:
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
                         if (DVDState == 3):
                             GUIlog('dvd-copy protection detected !!')  
                             selection = GUIYesNo(1,__language__(33334))
                             if (selection):
                                 DVDState = 0
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

                     if ( __allways_default__ == 'true'):
                        savedir = __configuration__[4] 
                     else:
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
                     
                     if (__verbose__ == "true"):   
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
                         if (DVDState == 3):
                             GUIlog('dvd-copy protection detected !!') 
                             selection = GUIYesNo(1,__language__(33334))
                             if (selection):
                                 DVDState = 0
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

                                 if ( __allways_default__ == 'true'):
                                    savedir = __configuration__[3] 
                                 else:
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

                                 if ( __allways_default__ == 'true'):
                                    savedir = __configuration__[3] 
                                 else:
                                    savedir = GUISelectDir()

                                 volname = OSDVDVolume()
                                 volname = GUIEditExportName(volname)                      
 
                                 # Update parameters for the OS-Part DVD

                                 execlist.append(__configuration__[1])
                                 execlist.append(savedir)
                                 execlist.append(volname)

                                 OSDVDAdd(execlist)      
 
                                 execstate = OSDVDcopyToIsoResque() 
  
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

             if (choice == 4):
                 Lock = OSCheckLock(__configuration__[1])
                 if (Lock == 0):
                     dvd_info = xbmc.getDVDState()
                     if (dvd_info == 4):
                         DVDState = OSCheckMedia("DVD-ROM")
                         if (DVDState == 3):
                             GUIlog('dvd-copy protection detected !!') 
                             selection = GUIYesNo(1,__language__(33334))
                             if (selection):
                                 DVDState = 0
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

                                 if ( __allways_default__ == 'true'):
                                     savedir = __configuration__[21]
                                 else:
                                     savedir = GUISelectDir()
     
                                 # Update parameters for the OS-Part DVD

                                 execlist.append(__configuration__[1])
                                 execlist.append(savedir)

                                 OSDVDAdd(execlist)      
 
                                 execstate = OSDVDvcopy() 
  
                                 if (execstate == 0):
                                     GUIInfo(2,__language__(33232))
                                 if (execstate == 1):
                                     GUIInfo(0,__language__(33231))
                                     __jobs__ = True                                
                             else:
                                 GUIInfo(0,__language__(33312)) 
                     else:
                         GUIInfo(0,__language__(33309))
                 else:
                     GUIInfo(0,__language__(33308))

             if (choice == 5):
                 if (__enable_burning__ == 'true'):                
                     TranscodeWindow = GUIExpertTranscodeClass()
                     del TranscodeWindow
                 else:
                     GUIInfo(0,__language__(33325))   

             if (choice == 6):
                 if (__enable_network__ == 'true'):                
                     NetworkWindow = GUIExpertNetworkClass()
                     del NetworkWindow
                 else:
                     GUIInfo(0,__language__(33320))                            
                  
             if (choice == 7):
                 if (__enable_customer__ == 'true'):                
                     UserfunctionsWindow = GUIExpertUserfunctionsClass()
                     del UserfunctionsWindow
                 else:
                     GUIInfo(0,__language__(33322)) 

             if (choice == 8):
                 state_ssh = OSCheckSSH()
                 if (state_ssh == 0):
                     GUIInfo(0,__language__(33218))   
                 else:
                     GUIInfo(2,__language__(33219)) 

             if (choice == 9): 
                 message = "Author  :  " + __author__ + "\nVersion :  " + __version__ 
                 GUIInfo(3,message)   
             if (choice == 10):   
                 exit = False
                 time.sleep(1) 
          self.close()

#########################################################





#########################################################
# Class     : GUIJobWinClass                            #
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

          # We generate the menu-list over a loop ,-)
  
          for i in range(32170,32174):
	      menu.append(__language__(i))
          
          # We stay inside menu until exit ....

          while (exit): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32091) ,menu)
             if (choice == 0):  
                 if (__jobs__ == False):
                     state = GUIInfo(0,__language__(32177))
                 else:
                     state =  GUIProgressbar(__language__(32170)) 
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
                 time.sleep(1) 
          self.close()

#########################################################





#########################################################
# Class     : GUIMain01Class                            #
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
 
          ############################################## 
          # Get current jobstate for addon             # 
          ##############################################

          job_state = OSGetJobState()
          if (job_state == 1):

              # The real-job files do exist. Prior to set the job-state to active we have 
              # to be sure that the main-process of every shell-script is running ....
 
              mainprocess = OSCheckMainProcess()
              if (mainprocess == 0): 
                  __jobs__ = True
                  if (__notifications__ == "true"):
                      GUINotification(__language__(33240))
                      time.sleep(1)
              else:

                  # There must be something wrong ....
                  # The main-process is not running ...
                   
                  removal = OSRemoveLock()
                  state = OSKillProc()
                  __jobs__ = False 

        
                  # Inform that we clean-up 
                            
                  if (__notifications__ == "true"):
                     GUINotification(__language__(33244))
                     time.sleep(1)


          if (job_state == 0):
              __jobs__ = False
              if (__notifications__ == "true"):
                  GUINotification(__language__(33239))


          # We generate the menu-list over a loop ,-)

          menu = []      
          for i in range(32100,32105):
	      menu.append(__language__(i))

          # We stay inside menu until exit ....
          # after this loop the addon wil be closed.

          exit_script = True 
          while (exit_script): 
                 dialog = xbmcgui.Dialog()
                 choice  = dialog.select(__language__(32090) ,menu)
                 if (choice == 0):

                     ############################################## 
                     # Convert Bluray                             # 
                     ##############################################

                     if (__verbose__ == "true"):      
                        GUIlog('menu bluray-transcode activated')
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

                     ############################################## 
                     # Default DVD-Transcode                      # 
                     ##############################################

                     if (__verbose__ == "true"):      
                        GUIlog('menu dvd-transcode activated')
                     Lock = OSCheckLock(__configuration__[1])
                     if (Lock == 0):
                         dvd_info = xbmc.getDVDState()
                         if (dvd_info == 4):
                             DVDState = OSCheckMedia("DVD-ROM")
                             if (DVDState == 3):
                                 
                                 ######################################################
                                 # There is a copy protected dvd inside the the drive #
                                 # Depending on the settings we do continue now or we #
                                 # pepare to exit this menu-point.                    #
                                 ######################################################

                                 if (__disable_cp_trancode__ == 'true'):

                                     # Show Info that copy protected dvd's can not be transcoded 
                                     # because the settings prevent this ...

                                     GUIInfo(0,__language__(33237))
   
                                 else:

                                     GUIlog('dvd-copy protection detected !!') 

                                     #############################################################
                                     # Ask to continue operation even if a copy protected dvd is #
                                     # detectec inside the drive                                 #
                                     #############################################################

                                     selection = GUIYesNo(1,__language__(33334))
                                     if (selection):
                                         DVDState = 0
              
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
                                     execstate = OSDVDTranscodeDefault(__dvd_values__[__default_dvd_tr__])    
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

                    ############################################## 
                    # Expert-Window                              # 
                    ##############################################


                     if (__verbose__ == "true"):      
                        GUIlog('menu expert-mode activated')

                     # In the case the expert-mode is password protected 
                     # we ask for the passsword and compare it.
                   
                     if ( __enable_pw_mode__ == 'true'):
                         kb = xbmc.Keyboard('default', 'heading', True)
                         kb.setDefault()
                         kb.setHeading(__language__(33212))
                         kb.setHiddenInput(True)
                         kb.doModal()
                         if (kb.isConfirmed()):
                             password = kb.getText()
                             if (password == __pw__ ):
                                 if (__verbose__ == "true"):
                                     GUIlog('menu expert-mode starting -> password correct')
                                 ExpertWindow = GUIExpertWinClass()
                                 del ExpertWindow
                             else: 
                                 if (__verbose__ == "true"):
                                     GUIlog('menu expert-mode disabled -> password not correct')
                                 GUIInfo(2,__language__(33213))    
                     else:
                          ExpertWindow = GUIExpertWinClass()
                          del ExpertWindow                          

                 if (choice == 3):

                    ############################################## 
                    # Job-Window                                 # 
                    ##############################################

                     if (__verbose__ == "true"):      
                        GUIlog('menu jobs activated')
                     JobWindow = GUIJobWinClass()  
                     time.sleep(1)
                     del JobWindow    
                     
                 if (choice == 4): 

                    ############################################## 
                    # Exit Addon                                 # 
                    ##############################################

                     if (__verbose__ == "true"):
                         GUIlog('menu exit activated')
                     exit_script = False   

          self.close()
          

#########################################################





#########################################################
# Class     : GUIWorkerThread                           #
#########################################################
# Parameter : threading.Thread                          #
#                                                       #
# Returns   : none                                      #
#########################################################
class GUIWorkerThread(threading.Thread):
  
        def __init__(self):
            threading.Thread.__init__(self)
        
        def run(self):

            ############################################## 
            # Inside this thread we need a few vars      # 
            ##############################################

            global __ProgressView__ 
            global __jobs__ 
            global __exitFlag__


            exit = True

            ############################################## 
            # This loop remains until addon do exit      # 
            ##############################################

            while (exit):  
                   time.sleep(1)

                   ############################################## 
                   # Should we exit the main-loop ?             # 
                   ##############################################
 
                   if (__exitFlag__ == True): 
                       exit = False
                                    
                   if (__jobs__ == True):

                       mainprocess = OSCheckMainProcess()
                       progress = OSGetProgressVal() 
                       modula = progress % 5                 
                 
                       ####################################################################
                       # Process is dead ... may a copy-protection of the inserted dvd ?  #
                       ####################################################################

                       if (mainprocess == 1 ):
                          if (progress <= 97):  
                             removal = OSRemoveLock()
                             state = OSKillProc()
                             __jobs__ = False 
                             if (__notifications__ == "true"):
                                GUINotification(__language__(33243))

                       # Process is running like expected ...

                       if (mainprocess == 0):
                          if (__notifications__ == "true"):
                             if (modula == 0): 
                                GUINotification(str(progress) + " % " + str(OSGetStageCurrentIndex())  + "/" +  str(OSGetStagesCounter()))
   
                          if (progress == 100):
                             if (OSDetectLastStage() == True):
                                __jobs__ == False
                                if (__notifications__ == "true"):
                                   GUINotification(__language__(33238))
                     

            ############################################## 
            # Exit this worker-thread                    # 
            ##############################################
 
            thread.exit() 
        
                     
#########################################################





#########################################################
####################### MAIN ############################
#########################################################

if __name__ == '__main__':


   ############################################## 
   # Initial Addon / Load configuration         # 
   ##############################################

   Enable_Startup_Addon = 0   
   xbmc_version = xbmc.getInfoLabel("System.BuildVersion")
   xbmc.executebuiltin("ActivateWindow(busydialog)")

   if (__verbose__ == "true"):    
      GUIlog ("Release xbmc  : [" +  xbmc_version + "]")     
      GUIlog ("Release Addon : [" + __version__ + "]")
      GUIlog ("Addon url     : [" + __url__ + "]")
      GUIlog ("Author Addon  : [" + __author__  + "]")
        
   reference =  __language__(34000)    
   __linebreak__ = reference.find("Line-2")

   if (__verbose__ == "true"):                  
      GUIlog ("Linebreak     : [" +  str(__linebreak__) + "]")      

   if (__verbose__ == "true"):    
       GUIlog ("loading-configuration")

   __configuration__ = OSConfiguration(__index_config__)
   
  
   __default_dvd_tr__  = int(__configuration__[9]) 
   __enable_bluray__   = __configuration__[10]
   __enable_network__  = __configuration__[11]
   __enable_burning__  = __configuration__[12]
   __enable_customer__ = __configuration__[14]
   __verbose__         = __configuration__[17]
   __enable_pw_mode__  = __configuration__[19]
   __pw__              = __configuration__[20]
   __allways_default__ = __configuration__[58]   
   __disable_cp_trancode__ = __configuration__[59]
   __notifications__ = __configuration__[61]


   #############################################################
   # DVD Tracklists are handled diffrent between handbrake and #
   # makemkvcon.                                               #
   #############################################################
 
   if (__default_dvd_tr__ == 3):
       __default_tr_mkv__ = True
   else:
       __default_tr_mkv__ = False  


   ############################################## 
   # Create values for default dvd-operations   # 
   ##############################################


   if (__verbose__ == "true"):        
       GUIlog ("Transcoding   : [" +  str(__default_dvd_tr__) + "]")      
 
   # bluray mkv                         /dvdrip/bluray        index [5]	     
   # -> 264-high °			/dvdrip/dvd           index [4]		
   # -> iso				/dvdrip/iso           index [3]	
   # -> h264-low                        /dvdrip/transcode     index [13]
   # -> mkv                             /dvdrip/transcode     index [13]
   # -> vobcopy                         /dvdrip/vobcopy       index [21]
   # -> mpeg2                           /dvdrip/transcode     index [13] 
   # -> iphone                          /dvdrip/portable/ip   index [50]
   # -> psp                             /dvdrip/portable/psp  index [51]

   ############################################## 
   # Check that setup.sh was executed           # 
   ##############################################
 
   state = OSSetupDone() 
   if (state == 0):

       # setup.sh was not executed -> exit addon 

       GUIInfo(0,__language__(33300))
       Enable_Startup_Addon = Enable_Startup_Addon + 1
   
   else:

       # We do set all default values for multiple dvd transcoding functions 

       if (__verbose__ == "true"):      
            GUIlog ("Transcoding   : [" +  "read default values tr" + "]")       
       __dvd_values__ = GUISelectDVDTranscode() 
       if (__verbose__ == "true"):                
          GUIlog ("Default DVD   : [" + __dvd_values__[__default_dvd_tr__] + "]")      
       if (__verbose__ == "true"):      
          GUIlog ("Transcoding   : [" +  "read default values done" + "]")           
         
   
   ############################################## 
   # Check user who is running this addon       # 
   ##############################################

   if ( Enable_Startup_Addon == 0):
       Userstate = OSCheckUser()
       if (Userstate == 0):

           # As long the ssh-user inside the settings is not 
           # the same as the current user we do not start ....          

           GUIInfo(0,__language__(33316))
           Enable_Startup_Addon = 1 


   ############################################## 
   # Check ssh comunication for addon           # 
   ##############################################

   if ( Enable_Startup_Addon == 0):   

       # We have a ssh configuration that should work ....
       # But should working and working properly are two diffrent things ,-)
            
       state_ssh = OSCheckSSH()
       if (state_ssh == 1):
               GUIInfo(0,__language__(33321))
               if (__verbose__ == "true"):        
                   GUIlog ("please do configure ssh-server for login without any passwords")
                   GUIlog ("This addon do not start until ssh communication is working properly for the current user") 
                   GUIlog ("Addon do exit now ...")
               Enable_Startup_Addon = Enable_Startup_Addon + 1 
 

   ############################################## 
   # Check Bluray-Part of addon                 # 
   ##############################################
 
   if ( Enable_Startup_Addon == 0):                           
       if (__enable_bluray__ == "true"):

           # The check for a valid mkv licence is a startup-parameter 

           if ( __configuration__[60] == 'false'):
              if ( __verbose__ == "true"):        
                 GUIlog ("checking for expired makemkv licence is executed")
              state = OSCheckLicence()
              if (state == 1):
                 if (OSCheckContainerID(2)):
                    Enable_Startup_Addon = Enable_Startup_Addon + 1  
                    GUIInfo(1,__language__(33307))
              else:
                  __enable_bluray__ = "false"
                  GUIInfo(1,__language__(33315))
           else:
              if (__verbose__ == "true"):        
                 GUIlog ("checking for expired makemkv licence is not executed because addon-configuration")

              ############################################## 
              # Check container bluray-mkv files           # 
              ##############################################

              if (OSCheckContainerID(2)):
                 Enable_Startup_Addon = Enable_Startup_Addon + 1  
                 GUIInfo(1,__language__(33307))   
       else:                     
           if (__default_dvd_tr__ == 3):
              GUIInfo(1,__language__(33333))
              Enable_Startup_Addon = Enable_Startup_Addon + 1   


   ############################################## 
   # Check container dvd-h264 files             # 
   ##############################################     

   if ( Enable_Startup_Addon == 0): 
      if (OSCheckContainerID(1)):
         GUIInfo(1,__language__(33306))
         Enable_Startup_Addon = Enable_Startup_Addon + 1


   ############################################## 
   # Check container dvd-iso files              # 
   ##############################################     

   if ( Enable_Startup_Addon == 0): 
      if (OSCheckContainerID(0)):
         GUIInfo(1,__language__(33305))
         Enable_Startup_Addon = Enable_Startup_Addon + 1


   ############################################## 
   # Check container dvd-iso files              # 
   ##############################################

   if ( Enable_Startup_Addon == 0): 
      if (OSCheckContainerID(3)):
         GUIInfo(1,__language__(33318))
         Enable_Startup_Addon = Enable_Startup_Addon + 1


   ############################################## 
   # Check container network files              # 
   ##############################################

   if ( Enable_Startup_Addon == 0):
      if (__enable_network__ == "true"):         
         if (OSCheckContainerID(4)):
            GUIInfo(1,__language__(33319))
               
            # We do not enable a option in the case the container is not writeable 
      
            Enable_Startup_Addon = Enable_Startup_Addon + 1
            __enable_network__ == "false" 


   ############################################## 
   # Check container dvd-transcode files        # 
   ##############################################

   if ( Enable_Startup_Addon == 0):                   
      if (__enable_burning__ == "true"):        
         if (OSCheckContainerID(5)):
            GUIInfo(1,__language__(33306))
               
             # We do not enable a option in the case the container is not writeable 

            Enable_Startup_Addon = Enable_Startup_Addon + 1
            __enable_burning__ == "false" 


   ############################################## 
   # Check container iphone-transcode files     # 
   ##############################################

   if ( Enable_Startup_Addon == 0):      
      if (OSCheckContainerID(7)):
         GUIInfo(1,__language__(33331))                     
         Enable_Startup_Addon = Enable_Startup_Addon + 1


   ############################################## 
   # Check container psp-transcode files        # 
   ##############################################

   if ( Enable_Startup_Addon == 0):      
      if (OSCheckContainerID(8)):
         GUIInfo(1,__language__(33332))                     
         Enable_Startup_Addon = Enable_Startup_Addon + 1


   ############################################## 
   # Check container ssh-log files              # 
   ##############################################

   if ( Enable_Startup_Addon == 0):      
      if (OSCheckContainerID(6)):
         GUIInfo(1,__language__(33327))                     
         Enable_Startup_Addon = Enable_Startup_Addon + 1


   ############################################## 
   # Start addon only in the case of no errors  # 
   ##############################################

   if ( Enable_Startup_Addon == 0):  

      __ProgressView__ = False
      __jobs__ = False
      __exitFlag__ = False

      xbmc.executebuiltin("Dialog.Close(busydialog)") 
      time.sleep(1)

      ############################################## 
      # Start a worker-thread for operations       # 
      ##############################################

      thread2 = GUIWorkerThread()
      thread2.start()

      ############################################## 
      # Create main-menu for addon                 # 
      ##############################################

      menu01 = GUIMain01Class()
      time.sleep(1) 
      del menu01

      ############################################## 
      # Signal worker-thread to stop and exit      # 
      ##############################################

      if (__verbose__ == "true"):    
         GUIlog ("Signal w-thread to exit from main-thread")  
      __exitFlag__ = True


      ############################################## 
      # Wait until worker-thread is stopped        # 
      ##############################################

      while thread2.isAlive():
            time.sleep(1)  
            if (__verbose__ == "true"):    
               GUIlog ("waiting for termination of thread2")
      if (__verbose__ == "true"):   
         GUIlog ("thread2 has been terminated and was detected to be running inside main-loop")

      time.sleep(1)   
      if ( __jobs__ == True):
          if (__notifications__ == "true"):
             GUINotification(__language__(33241))
             time.sleep(1)  
      else:
          if (__notifications__ == "true"):
             GUINotification(__language__(33242)) 
             time.sleep(1)  
   else:  
       xbmc.executebuiltin("Dialog.Close(busydialog)") 
       GUIlog ("This addon do not start until all errors on startup are resolved.Please read the manual") 

   ############################################## 
   # Exit the addon                             # 
   ##############################################
     
   sys.modules.clear()

       
#########################################################
#########################################################
#########################################################






