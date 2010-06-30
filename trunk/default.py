#!/usr/bin/python
# -*- coding: utf-8 -*-
#########################################################
# SCRIPT  : default.py                                  #
#########################################################
# AUTHOR  : Hans Weber                                  #
# EMAIL   : linuxluemmel.ch@gmail.com                   #
# XBMC    : Version 10.5  or higher                     #
# OS      : Linux                                       #
# TASKS   : - copy a dvd 1:1 as a iso file to a disk    #
#           - transcode bluray to matroska container    #
#           - transcode dvd to multiple formats         #
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
__author__ 		= "linuxluemmel"
__url__ 		= "http://code.google.com/p/swiss-army-knife/"
__svn_url__ 		= "https://swiss-army-knife.googlecode.com/svn/trunk"
__platform__ 		= "xbmc media center, [LINUX]"
__date__ 		= "27-06-2010"
__version__ 		= "0.6C"
__XBMC_Revision__ 	= "20000"

xbmc.output(__script__ + " Version: " + __version__  + "\n")

#########################################################



####################### IMPORTS #########################

import xbmc, xbmcgui,xbmcaddon
import os, sys, thread, stat, time, string, re
import urllib, urlparse, urllib2, xml.dom.minidom

#########################################################






####################### LANGUAGE FUNCTIONS ##############

__settings__ = xbmcaddon.Addon(id='script-video-ripper')
__language__ = __settings__.getLocalizedString

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

       exit_script = True 

       while (exit_script): 
             dialog = xbmcgui.Dialog()
             choice  = dialog.select(__language__(32000) , [__language__(32100), __language__(32101), __language__(32102),__language__(32103),__language__(32104) ])
             if (choice == 0): 
                 print 'menu-1'
                 dvd_info = xbmc.getDVDState()
                 if (dvd_info == 4):
                     OS_transcode_blueray()
                 else:
                      xbmc.executebuiltin("ActivateWindow(busydialog)")
                      time.sleep 1
                      xbmc.executebuiltin("Dialog.Close(busydialog)")
             if (choice == 1): 
                 print 'menu-2'
             if (choice == 2): 
                 print 'menu-3' 
             if (choice == 3): 
                 print 'menu-4'
                 menu02 = GUIMain02Class() 
             if (choice == 4): 
                 print 'menu-5'
                 exit_script = False
       self.close()
#########################################################


#########################################################
####################### MAIN ############################
#########################################################
if __name__ == '__main__':
   menu01 = GUIMain01Class() 
#########################################################
#########################################################
#########################################################






