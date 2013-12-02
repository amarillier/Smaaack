; Stop the stupid SM9 inactive timeout by clicking the "refresh the whole tree" icon at top
; right of SM9 every 14 minutes


Program := "SM-AAACK!"
Version := "v1.1.2"
Minutes = 14
NewMinutes = 0
Interval = 0
; SM9Title := "Wolseley Service Manager"
SM9Title := "Service Manager"
SM9RefreshControl := "ToolbarWindow327"
SM9AWOLMsg = `n`nNOTE: %SM9Title% does not appear to be running right now.`n %Program% will simply run quietly in the system tray and do nothing`nuntil it detects that %Program% is running.`nAt that time it will automatically begin smacking SM9 to prevent inactivity timeout
Debug = 0
Smacked = 0
FormatTime, Startup,, hh:mm:ss tt
SmackTime = None yet (start time: %Startup%)

SetTitleMatchMode, 2   ; set for partial window title matching

if %0% >= 1
{
   Minutes = %1%
   SecondParam = %2%
   if Minutes is integer
   {
      if (Minutes < 5) or (Minutes > 15)
      {
         MsgBox ,,%Program% %Version%, You entered a parameter %Minutes% which is < 5 or > 15.`nThe default is 14 because the SM9 timeout is 15 minutes.`n`n5 or less is ok for testing, but not necessary.`nMore than 14 will very likely cause the inactivity timeout to activate.`n`nYou can leave %Program% running like this, or exit and restart, or just`nrun %Program% again with a new, more suitable parameter`nand it will reload.
      }  ; end if the number seems too low or too high
	   Interval := Minutes * 60 * 1000
   }  ; end if it is numeric
   else
   {
      MsgBox ,,%Program% command line help,%Program%: %Version% only accepts one parameter, an integer number.`n`nThis program is for people who hate the SM9 inactivity timer.`nThe parameter is the number of minutes to delay between `n'smacking' SM9 into shape.The default is 14 minutes.`n`nRun this program, then right click the tray icon for menu options, help etc.
      ExitApp
   }  ; end if it is not numeric
   
   if SecondParam in d,D,debug,DEBUG
   {
      Debug = 1
      MsgBox ,,,Turning debug mode on,3
   }  ; end if debug mode turned on
}  ; end if we received a parameter
else
{
   Interval := 14 * 60 * 1000  ; 14 minutes should be good - SetTimer works in milliseconds, so 14 * 60 * 1000
}  ; end if we did not receive any parameters

if Debug = 1
{
   Version = %Version% . (DEBUG active)
   MsgBox ,,%Program% %Version% command line help,%Program%: %Version% Debug mode is turned on, 3
}

Intro = Interval is set to %Interval% (%Minutes% minutes) `nRight click the tray icon for menu options
IfWinNotExist %SM9Title%
{
   Intro = %Intro% . %SM9AWOLMsg%
}  ; end if SM9 is not currently open

MsgBox ,,,%Intro%,10
DetectHiddenWindows, On

#Persistent
Menu, tray, Icon, SM-AAACK.exe,, 1
Menu, tray, add, &About, AboutSmackL ; Creates an about menu item
Menu, tray, add, &Help, HelpSmackL  ; Creates a help menu item.
Menu, tray, add, &Change Timeout, ChangeSmackL
Menu, tray, add, &Disable SM-AAACK, DisableSmackL
Menu, tray, add, &SM-AAACK now, SmackSM9L
Menu, tray, add, &Exit, ExitSmackL  ; Creates an exit app menu item.
Menu, tray, NoStandard  ; this removes the standard tray icon menu items
;Menu, tray, add  ; Creates a separator line.
;Menu, tray, Standard  ; this restores the tray icon menu items at the end of the menu

SetTimer, SmackSM9L, %Interval%
return

AboutSmackL:
AboutSmack()
return

HelpSmackL:
HelpSmack()
return

ChangeSmackL:
ChangeSmack()
return

DisableSmackL:
menu, tray, ToggleCheck, &Disable SM-AAACK
Pause, toggle
return

ExitSmackL:
ExitSmack()
return

SmackSM9L:
SmackSM9()
return


; ------------------------------------
SmackSM9()
{
   global Program
   global Version
   global Minutes
   global SM9Title
   global SM9RefreshControl
   global Smacked
   global SmackTime
   global Debug
   
   IfWinExist, %SM9Title%
   {
      ; Get ID of active window
      WinGet, ActiveWin, ID, A

      ; Check if the window is minimized. If it is, maximize it qucikly, then minimize again after
      WinGet Minimized, MinMax, %SM9Title%
      IfEqual Minimized,-1, WinRestore, %SM9Title%

      ; click refresh on SM9
      SetControlDelay -1
      ;ControlClick ,%SM9RefreshControl%, %SM9Title%,,LEFT,1,x215 y80 NA
      ;ControlClick ,,%SM9Title%,,,,x215 y80 NA
      ControlClick %SM9RefreshControl%, %SM9Title%,, LEFT

      IfEqual Minimized,-1, WinMinimize, %SM9Title%
      
      ; make original window active again
      WinActivate, ahk_id ActiveWin
      
      Smacked++
      FormatTime, SmackTime,, dddd MMMM d, yyyy hh:mm:ss tt
      if Debug > 0
      {
         MsgBox ,,TEST,Smacked is %Smacked%,5
      }  ; end if debug mode
      
   }  ; end if SM9 is active
   else
   {
      if Debug > 0
      {
         MsgBox ,,,%SM9Title% is not active!,2
      }  ; end if debug mode
   }  ; end if SM9 is not active
   return
}  ; end of SmackSM9

; ------------------------------------
AboutSmack()
{
   global Program
   global Version
   global Minutes
   global SM9Title
   global Smacked
   global SmackTime
   global SM9AWOLMsg
   global Debug
  
   Stuff := ""
   IfWinNotExist %SM9Title%
   {
      Stuff = %SM9AWOLMsg%`n
   }  ; end if SM9 is active
   
   AboutMessage =
   (
%Program%, %Version% has smacked SM9 %Smacked% times so far!

Current setting is to smack SM9 every %Minutes% minutes to stop it from
timing you out. The most recent smack: %SmackTime%
%Stuff%
The default interval is 14 minutes which should subdue the obnoxious beast
known as the SM9 inactivity timeout. If this doesn't work for you for
some reason, try making the delay a bit shorter.

There are two ways to change the timeout. The easiest is to right click
%Program%'s icon in the system tray and select 'Change Timeout', then
use the slider control. The other way is by re-running the program with
a new integer parameter which will prompt if you want to reload the program.

e.g. SM-AAACK 10

%Program% is brought to you by a former
"I hate the SM9 inactivity timeout" disgruntled user. Have fun!

Did you *really* expect to find out who wrote this? Not likely ... :-)
Maybe there's an egg.

Please use %Program% responsibly.
You can talk %Program%. You can %Program% your lips.
Don't %Program% and drive. Don't %Program% your spouse or kids.
   )

   ; -------------------------------------------
   ; Make a GUI about window
   Gui, 1: Add, Picture, xp+0 y+10 w250 h250 gAboutEggClick Icon hwndPicExe, SM-AAACK.exe
   Gui, 1: Add, Picture, w3 h3 gAboutBigAl Icon, SM-AAACK.exe
   hIcon := ExtractIcon("SM-AAACK.exe", 1)
   SendMessage, 0x170, hIcon,,, ahk_id %PicExe%  ; STM_SETICON

   Gui, Add, Text, x266 y6, %AboutMessage%
   Gui, Add, Button, default, CloseAbout
   Gui, 1: Add, Picture, w1 h2 gAboutEgg3 Icon, SM-AAACK.exe
   Gui, Show,, About: %Program% %Version%
   Return

   AboutEggClick:
   MsgBox, 0, %Program% Easter egg, What? Now you think you're smart or something?`n`nYou really want to know who wrote this?`nNice try! At least you found the Easter egg.`nMaybe there are more.
   return
   
   AboutBigAl:
   MsgBox, 0, %Program% Easter egg, Now you're onto something!`n`nDoes 'Big Al' mean anything to you? `n`nNo? ... too bad!`nKeep looking for eggs, you might find more ...
   return
   
   AboutEgg3:
   MsgBox, 0, %Program% Another Easter egg!, Whoo-hooo! You found another Easter egg.`n`nYou're good. Do you really want to know?`n`nTry sending an email to hsapions@gmail.com and see if Homer Sapions responds!
   return
   
   GuiEscape:
   AboutGuiClose:
   ButtonCloseAbout:
   Gui, Submit
   Gui, Destroy
   ; -------------------------------------------
   ; Alternately, just make a text display
   ; MsgBox, 0, %Program% %Version%, %AboutMessage%, 20
   
   return
}  ; end of AboutSmackGUI

; ------------------------------------
HelpSmack()
{
   global Program
   global Version
   global Minutes
   global Smacked
   global Debug
   
   HelpMessage =
   (
This program accepts one numeric parameter only, the number of minutes to
delay between smacking SM9. If you don't give a valid integer parameter
the default is 14, which should circumvent the SM9 inactivity timeout.

The point of this program is to save the current window and cursor position,
hop over to SM9 and click the green 'Refresh the whole tree' icon at the
top left of SM9. This causes SM9 to see activity and not time you out for
inactivity. After this, it hops right back to where you were, hopefully all
fast enough that you will not even notice that anything happened.

If you have two monitors with SM9 on the other monitor than where you are 
currently working, you probably won't even see it. If you're on a single
monitor, or SM9 minimized, or on the same monitor as you're working on
you may see a really quick flash. Then again, you probably won't.

The way you can see that it is working is to click the [+] next to any of the
activities in the SM9 'System Navigator' to expand those activities. Carry
on working as normal, and you should see them collapse as the refresh button
is clicked.

This should also work when your screensaver kicks in and the screen is locked.

Three menu items avaiable by right clicking the system tray icon may be worth
a mention.
- Change Timeout pops up a slider conrol allowing you to change the timeout value
  from anything between 1 and 60. 60 will not bypass the current SM9 inactivity
  timeout which appears to be 15 minutes. You can achive the same thing by stopping
  and restarting %Program%, or by simply re-running %Program% with a different
  integer parameter.
- Disable %Program%: simply pauses the program, so that you can stop it running
  for a while, then resume again later. When disabled, a check mark appears next
  to the menu item.
- %Program% now: sends a smack to SM9 immediately. The only real use for this is
  for you to test, to see that the program will work. You can do this with the SM9
  window minimized or open and active. To see that it works, try expanding a few 
  items with the [+] under the System Navigator panel on the left side of SM9.
  After SM9 is smacked, all items in the System Navigator panel should be collapsed.


%Program% is brought to you by a former
"I hate the SM9 inactivity timeout" disgruntled user. Have fun!

Did you *really* expect to find out who wrote this? Not likely ... :-)
Maybe there's an egg.
   )
   
   ; -------------------------------------------
   ; Make a GUI help window
   Gui, 2: Add, Picture, xp+0 y+10 w250 h250 gAboutEggClick Icon hwndPicExe, SM-AAACK.exe
   Gui, 2: Add, Picture, w3 h3 gHelpBigAl Icon, SM-AAACK.exe
   hIcon := ExtractIcon("SM-AAACK.exe", 1)
   SendMessage, 0x170, hIcon,,, ahk_id %PicExe%  ; STM_SETICON

   Gui, 2: Add, Text, x266 y6, %HelpMessage%
   Gui, 2: Add, Button, default, CloseHelp
   Gui, 2: Add, Picture, w1 h2 gHelpEgg3 Icon, SM-AAACK.exe
   Gui, 2: Show,, Help: %Program% %Version%
   Return

   HelpEggClick:
   MsgBox, 0, %Program% Easter egg, What? Now you think you're smart or something?`n`nYou really want to know who wrote this?`nNice try! At least you found the Easter egg.
   return
   
   HelpBigAl:
   MsgBox, 0, %Program% Easter egg, Now you're onto something!`n`nDoes 'Big Al' mean anything to you? `nNo? ... too bad!
   return
   
   HelpEgg3:
   MsgBox, 0, %Program% Another Easter egg!, Whoo-hooo! You found another Easter egg.`n`nYou're good. Do you really want to know?`n`nTry sending an email to hsapions@gmail.com and see if Homer Sapions responds!
   return
   
   2GuiEscape:
   HelpGuiClose:
   2ButtonCloseHelp:
   Gui, 2: Submit
   Gui, 2: Destroy
   ; -------------------------------------------   
   ; Alternately, just make a text display
   ; MsgBox, 0, %Program% %Version%, %HelpMessage%, 20
   
   return
}  ; end of HelpSmack

; ------------------------------------
ChangeSmack()
{
   global Minutes
   global Interval
   global NewMinutes
   global Message
   global Debug
   
   NewMinutes := Minutes
   
   Message = Pick a new timeout prevention SM-AAACK value (currently %Minutes%)
   Gui, Add, Text, w480 h20 vMessage
   Gui, add, slider, w620 Range1-60 Tickinterval1 ToolTip Page5 vNewMinutes gSlide, %Minutes%
   Gui, Add, Text, h20 x20 y60, 1
   Gui, Add, Text, h20 x60 y60, 5
   Gui, Add, Text, h20 x108 y60, 10
   Gui, Add, Text, h20 x157 y60, 15
   Gui, Add, Text, h20 x208 y60, 20
   Gui, Add, Text, h20 x259 y60, 25
   Gui, Add, Text, h20 x309 y60, 30
   Gui, Add, Text, h20 x360 y60, 35
   Gui, Add, Text, h20 x410 y60, 40
   Gui, Add, Text, h20 x460 y60, 45
   Gui, Add, Text, h20 x511 y60, 50
   Gui, Add, Text, h20 x560 y60, 55
   Gui, Add, Text, h20 x610 y60, 60
   Gui, Add, button, x300, OK
   ;Gui, Add, Picture, w1 h2 gChangeEgg Icon, SM-AAACK.exe
   Gui, Show
   GuiControl,,Message,%Message%
   Return 

   ButtonOK:
   Gui, Submit
   Gui, Destroy
   Minutes := NewMinutes
   Interval := Minutes * 60 * 1000
   if Debug = 1
   {
      MsgBox ,,DEBUG ChangeSmack, Inside ChangeSmack: Minutes = %Minutes%  Interval = %Interval%,2
   }  ; end if Debug mode
   SetTimer, SmackSM9L, off,0
   SetTimer, SmackSM9L, %Interval%,0
   return
   
   Slide:
   NewMessage = Pick a new timeout prevention SM-AAACK value (currently %Minutes% will change to %NewMinutes%)
   GuiControl,,Message, %NewMessage%
   Return
   
   ChangeEgg:
   MsgBox, 0, %Program% Another Easter egg!, Whoo-hooo! You found another Easter egg.`n`nYou're good. Do you really want to know?`n`nTry sending an email to hsapions@gmail.com and see if Homer Sapions responds!
   return
   
}  ; end of ChangeSmack

; ------------------------------------
ExitSmack()
{
   ExitApp
}  ; end of ExitSmack

; ------------------------------------
; this function comes from Lexikos, http://www.autohotkey.com/board/topic/22347-incorrect-loading-of-icos-through-gui-add-picture/#entry145875
ExtractIcon(Filename, IconNumber, IconSize=0)
{
    static SmallIconSize, LargeIconSize
    if (!SmallIconSize) {
        SysGet, SmallIconSize, 49  ; 49, 50  SM_CXSMICON, SM_CYSMICON 
        SysGet, LargeIconSize, 11  ; 11, 12  SM_CXICON, SM_CYICON 
    }


    VarSetCapacity(phicon, 4, 0)
    h_icon = 0

    ; If possible, use PrivateExtractIcons, which supports any size of icon.
    if A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
    {
        VarSetCapacity(piconid, 4, 0)
        
        ; MSDN: "... this function is deprecated ..." (oh well)
        ret := DllCall("PrivateExtractIcons"
            , "str", Filename
            , "int", IconNumber-1   ; zero-based index of the first icon to extract
            , "int", IconSize
            , "int", IconSize
            , "str", phicon         ; pointer to an array of icon handles...
            , "str", piconid        ; piconid - won't be used
            , "uint", 1             ; nIcons - number of icons to extract
            , "uint", 0, "uint")    ; flags
        
        if (ret && ret != 0xFFFFFFFF)
            h_icon := NumGet(phicon)
    }
    else
    {   ; Use ExtractIconEx, which only returns 16x16 or 32x32 icons.
        VarSetCapacity(phiconSmall, 4, 0)
        
        ; Extract the icon from an executable, DLL or icon file.
        if DllCall("shell32.dll\ExtractIconExA"
            , "str", Filename
            , "int", IconNumber-1   ; zero-based index of the first icon to extract
            , "str", phicon         ; pointer to an array of icon handles...
            , "str", phiconSmall
            , "uint", 1)
        {
            ; Use the best-fit size; clean up the other.
            if (IconSize <= SmallIconSize) {
                DllCall("DestroyIcon", "uint", NumGet(phicon))
                h_icon := NumGet(phiconSmall)
            } else {
                DllCall("DestroyIcon", "uint", NumGet(phiconSmall))
                h_icon := NumGet(phicon)
            }
        }
    }

    return h_icon
}

; ------------------------------------