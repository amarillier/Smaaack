; Stop the stupid SM inactive timeout by clicking the "refresh the whole tree" icon at top
; right of SM every 14 minutes

; To-do
; - Switch to not smack when screen is locked - default to keep on smacking
; - Use Loop %0% to cycle through command line params to detect integer timeout, debug, nodisable, random etc.

;Loop, %0%  ; For each parameter:
;{
;    param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
;    MsgBox, 4,, Parameter number %A_Index% is %param%.  Continue?
;    IfMsgBox, No
;        break
;}

; Changes
; 1.1.4
; - Added hyperlink to google code home page in About and Help windows
; - Added a randomize capability to change the smack time delay between Minutes and half
;   of Minutes so we are not always smacking at the same interval
;
; 1.1.3
; - Added overnight disable, between 6pm and 7am. This can be over-ridden with a second parameter nodisable/nodis.
;   This means the timeout MUST be the first parameter
; 

Program := "Smaaack!"
Version := "v1.1.4"
HomePage = http://code.google.com/p/Smaaack/
Minutes = 14
NewMinutes = 0
Interval = 0
SMTitle := "Service Manager"
SMRefreshControl := "ToolbarWindow327"
SMAWOLMsg = `n`nNOTE: %SMTitle% does not appear to be running right now.`n %Program% will simply run quietly in the system tray and do nothing`nuntil it detects that %Program% is running.`nAt that time it will automatically begin smacking SM to prevent inactivity timeout
SMDisableOvernight = 1
SMRandomize = 0
RandomMinutes = 0
RandomMinutesMax = Minutes
RandomMinutesMin := RandomMinutesMax // 2
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
         MsgBox ,,%Program% %Version%, You entered a parameter %Minutes% which is < 5 or > 15.`nThe default timeout is 14 minutes.`n`n5 or less is ok for testing, but not necessary.`nMore than 14 will very likely cause the inactivity timeout not to activate.`n`nYou can leave %Program% running like this, or exit and restart, or just`nrun %Program% again with a new, more suitable parameter`nand it will reload.
      }  ; end if the number seems too low or too high
	   Interval := Minutes * 60 * 1000
   }  ; end if it is numeric
   else
   {
      MsgBox ,,%Program% command line help,%Program%: %Version% only accepts one parameter, an integer number.`n`nThis program is for people who hate the SM inactivity timer.`nThe parameter is the number of minutes to delay between `n'smacking' SM into shape.The default is 14 minutes.`n`nRun this program, then right click the tray icon for menu options, help etc.
      ExitApp
   }  ; end if it is not numeric
   
   if SecondParam in d,D,debug,DEBUG
   {
      Debug = 1
      MsgBox ,,,Turning debug mode on,3
   }  ; end if debug mode turned on
   if SecondParam in nodis,nodisable,NODISABLE
   {
      SMDisableOvernight = 0
      MsgBox ,,,SM will not be disabled overnight,3
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
IfWinNotExist %SMTitle%
{
   Intro = %Intro% . %SMAWOLMsg%
}  ; end if SM is not currently open

MsgBox ,,,%Intro%,10
DetectHiddenWindows, On

#Persistent
Menu, tray, Icon, Smaaack.exe,, 1
Menu, tray, add, &About, AboutSmackL ; Creates an about menu item
Menu, tray, add, &Help, HelpSmackL  ; Creates a help menu item.
Menu, tray, add, &Change Timeout, ChangeSmackL
Menu, tray, add, &Disable Smaaack, DisableSmackL
Menu, tray, add, &Randomize Smaaack, RandomizeSmackL
Menu, tray, add, &Smaaack now, SmackSML
Menu, tray, add, &Exit, ExitSmackL  ; Creates an exit app menu item.
Menu, tray, NoStandard  ; this removes the standard tray icon menu items
;Menu, tray, add  ; Creates a separator line.
;Menu, tray, Standard  ; this restores the tray icon menu items at the end of the menu

SetTimer, SmackSML, %Interval%
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
menu, tray, ToggleCheck, &Disable Smaaack
Pause, toggle
return

SmackSML:
SmackSM()
return

RandomizeSmackL:
menu, tray, ToggleCheck, &Randomize Smaaack
if SMRandomize = 0
{
   SMRandomize = 1
   RandomMinutesMax = %Minutes%
   RandomMinutesMin := RandomMinutesMax // 2
   Random, RandomMinutes, RandomMinutesMin, RandomMinutesMax
   if Debug = 1
   {
      MsgBox ,,%Program%: Randomize, Randomize is now set to %SMRandomize%`nMinutes = %Minutes%`nRandomMinutes = %RandomMinutes%`nMin = %RandomMinutesMin% Max = %RandomMinutesMax%,
   }  ; end if debug mode
   SetTimer, SmackSML, off,0
   SetTimer, SmackSML, %RandomMinutes%,0
}  ; end if randomize is not yet on
else
{
   SMRandomize = 0
   SetTimer, SmackSML, off,0
   SetTimer, SmackSML, %Interval%,0
}  ; end if randomize is already on
return

ExitSmackL:
ExitSmack()
return


; ------------------------------------
SmackSM()
{
   global Program
   global Version
   global HomePage
   global Minutes
   global Interval
   global NewMinutes
   global Message
   global SMTitle
   global HomePage
   global Smacked
   global SmackTime
   global SMAWOLMsg
   global SMRefreshControl
   global SMDisableOvernight
   global SMRandomize
   global RandomMinutes
   global RandomMinutesMax
   global RandomMinutesMin
   global Debug
   
   FormatTime, HourNow,, H
   FormatTime, MinNow,, m
   
   if ( SMDisableOvernight = 0 ) or ( HourNow >= 7 ) and ( HourNow <= 18 )
   {
      IfWinExist, %SMTitle%
      {
         ; Get ID of active window
         WinGet, ActiveWin, ID, A

         ; Check if the window is minimized. If it is, maximize it quickly, then minimize again after
         WinGet Minimized, MinMax, %SMTitle%
         IfEqual Minimized,-1, WinRestore, %SMTitle%

         ; click refresh on SM
         SetControlDelay -1
         ;ControlClick ,%SMRefreshControl%, %SMTitle%,,LEFT,1,x215 y80 NA
         ;ControlClick ,,%SMTitle%,,,,x215 y80 NA
         ControlClick %SMRefreshControl%, %SMTitle%,, LEFT

         IfEqual Minimized,-1, WinMinimize, %SMTitle%
      
         ; make original window active again
         WinActivate, ahk_id ActiveWin
      
         Smacked++
         FormatTime, SmackTime,, dddd MMMM d, yyyy hh:mm:ss tt
         if Debug > 0
         {
            MsgBox ,,TEST,Smacked is %Smacked%,5
         }  ; end if debug mode
         if (SMRandomize = 1) and (Minutes > 4)
         {
            Random, RandonMinutes, RandomMinutesMin, RandomMinutesMax  ; Random, OutputVar [, Min, Max]
            SetTimer, SmackSML, off,0
            RandomInterval = RandomMinutes * 60 * 1000
            SetTimer, SmackSML, %RandomInterval%,0
         }  ; end if SMRandomize is 1
      }  ; end if SM is active
      else
      {
         if Debug > 0
         {
           MsgBox ,,,%SMTitle% is not active!,2
         }  ; end if debug mode
      }  ; end if SM is not active
   }  ; end if time is between 7am and 6pm
   else
   {
      if Debug > 0
      {
         MsgBox ,,,%Program% is not active after hours!,3
      }  ; end if debug mode
   }  ; end if not in daytime
   return
}  ; end of SmackSM

; ------------------------------------
AboutSmack()
{
   global Program
   global Version
   global HomePage
   global Minutes
   global Interval
   global NewMinutes
   global Message
   global SMTitle
   global HomePage
   global Smacked
   global SmackTime
   global SMAWOLMsg
   global SMRefreshControl
   global SMDisableOvernight
   global SMRandomize
   global RandomMinutes
   global RandomMinutesMax
   global RandomMinutesMin
   global Debug
  
   Stuff := ""
   IfWinNotExist %SMTitle%
   {
      Stuff = %SMAWOLMsg%
   }  ; end if SM is active
   
   RandomMessage := ""
   if SMRandomize = 1
   {
      RandomMessage := "`nRandom timing is enabled at " . RandomMinutes . " minutes (from " . RandomMinutesMin . " to " . RandomMinutesMax . ")`n"
   }  ; end if randomize is on
   
   AboutMessage =
   (
%Program%, %Version% has smacked SM %Smacked% times so far!
The most recent smack: %SmackTime%

%RandomMessage%
Standard setting is to smack SM every %Minutes% minutes to stop it from timing you out. 
%Stuff%
The default interval is 14 minutes which should subdue the obnoxious beast
known as the SM inactivity timeout. If this doesn't work for you for some
reason, try making the delay a bit shorter.

There are two ways to change the timeout. The easiest is to right click
%Program%'s icon in the system tray and select 'Change Timeout', then
use the slider control. The other way is by re-running the program with
a new integer parameter which will prompt if you want to reload the program.

e.g. Smaaack 10

%Program% is brought to you by Homer Sapions, a former
"I hate the SM inactivity timeout" disgruntled user. Have fun!

Please use %Program% responsibly.
You can talk %Program%. You can %Program% your lips.
Don't %Program% and drive. Don't %Program% your spouse or kids.
   )

   ; -------------------------------------------
   ; Make a GUI about window
   Gui, 1: Add, Picture, xp+0 y+10 w250 h250 gAboutHomePage Icon hwndPicExe, Smaaack.exe
   hIcon := ExtractIcon("Smaaack.exe", 1)
   SendMessage, 0x170, hIcon,,, ahk_id %PicExe%  ; STM_SETICON

   Gui, Add, Text,x266 y6, %AboutMessage%
   Gui, Font, underline
   Gui, Add, Text, cBlue gAboutHomePage, Click here to visit %Program%'s home page
   Gui, Font, norm

   Gui, Add, Button, default, CloseAbout
   Gui, Show,, About: %Program% %Version%
   Return

   AboutHomePage:
   Run %HomePage%
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
}  ; end of AboutSmack

; ------------------------------------
HelpSmack()
{
   global Program
   global Version
   global HomePage
   global Minutes
   global Interval
   global NewMinutes
   global Message
   global SMTitle
   global HomePage
   global Smacked
   global SmackTime
   global SMAWOLMsg
   global SMRefreshControl
   global SMDisableOvernight
   global SMRandomize
   global RandomMinutes
   global RandomMinutesMax
   global RandomMinutesMin
   global Debug
   
   HelpMessage =
   (
This program accepts one numeric parameter only, the number of minutes to
delay between smacking SM. If you don't give a valid integer parameter
the default is 14.

The point of this program is to save the current window and cursor position,
hop over to SM and click the green 'Refresh the whole tree' icon at the
top left of SM. This causes SM to see activity and not time you out for
inactivity. After this, it hops right back to where you were, hopefully all
fast enough that you will not even notice that anything happened.

If you have two monitors with SM on the other monitor than where you are 
currently working, you probably won't even see it. If you're on a single
monitor, or have SM minimized on the same monitor as you're working on
you may see a really quick flash. Then again, you may not.

The way you can see that it is working is to click the [+] next to any of the
activities in the SM 'System Navigator' to expand those activities. Carry
on working as normal, and you should see them collapse as the refresh button
is clicked.

This should also work when your screensaver kicks in and the screen is locked.

Three menu items available by right clicking the system tray icon may be worth
a mention.
  - 'Change Timeout': pops up a slider control allowing you to change the timeout value
    to anything between 1 and 60. 60 may not bypass the current SM inactivity
    timeout depending how your SM server has been configured.
    You can achieve the same thing by stopping and restarting %Program%,
    or by simply re-running %Program% with a different integer parameter.
  - 'Disable %Program%': simply pauses the program, so that you can stop it running
    for a while, then resume again later. When disabled, a check mark appears next
    to the menu item.
  - '%Program% now': sends a smack to SM immediately. The only real use for this is
    for you to test, to see that the program will work. You can do this with the SM
    window minimized or open and active. To see that it works, try expanding a few 
    items with the [+] under the System Navigator panel on the left side of SM.
    After SM is smacked, all items in the System Navigator panel should be collapsed.


%Program% is brought to you by Homer Sapions, a former
"I hate the SM inactivity timeout" disgruntled user. Have fun!
   )
   
   ; -------------------------------------------
   ; Make a GUI help window
   Gui, 2: Add, Picture, xp+0 y+10 w250 h250 gHelpHomePage Icon hwndPicExe, Smaaack.exe
   hIcon := ExtractIcon("Smaaack.exe", 1)
   SendMessage, 0x170, hIcon,,, ahk_id %PicExe%  ; STM_SETICON

   Gui, 2: Add, Text, x266 y6, %HelpMessage%
   Gui, 2: Font, underline
   Gui, 2: Add, Text, cBlue gHelpHomePage, Click here to visit %Program%'s home page
   Gui, 2: Font, norm
   Gui, 2: Add, Button, default, CloseHelp
   Gui, 2: Show,, Help: %Program% %Version%
   Return
   
   HelpHomePage:
   Run %HomePage%
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
   global Program
   global Version
   global HomePage
   global Minutes
   global Interval
   global NewMinutes
   global Message
   global SMTitle
   global HomePage
   global Smacked
   global SmackTime
   global SMAWOLMsg
   global SMRefreshControl
   global SMDisableOvernight
   global SMRandomize
   global RandomMinutes
   global RandomMinutesMax
   global RandomMinutesMin
   global Debug
   
   NewMinutes := Minutes
   
   Message = Pick a new timeout prevention Smaaack value (currently %Minutes%)
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
   SetTimer, SmackSML, off,0
   SetTimer, SmackSML, %Interval%,0
   return
   
   Slide:
   NewMessage = Pick a new timeout prevention Smaaack value (currently %Minutes% will change to %NewMinutes%)
   GuiControl,,Message, %NewMessage%
   Return
   
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