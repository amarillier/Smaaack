; Smaaack
; Stop the stupid SM inactive timeout by clicking the "refresh the whole tree" icon at top
; right of SM every 14 minutes
; Brought to you by Homer Sapions, April 2013

; NOTE: Compile this with AutoHotkey Classic so that the icon file can be properly 
; embedded into the executable to be displayed in About, Help, Changelog etc. 
; If AutoHotkey-L is used the image does not work, we have to use different tricks
; where the image can be embedded, but then to be used must be unpacked into the
; same directory as the executable program is located. The image can be auto deleted
; at program termination, but may be left behind if the program aborts unexpectdely 
; or is killed using task manager or any other process management utilities.

; To-do
; - Add code to test if Sounds directory exists and contains wavs to be played as alternates
; - Convert to using FileInstall and FileDelete to work with AutoHotkey-L
; FileInstall, TicketMonkey.jpg, TicketMonkey.jpg, 1
; FileDelete, %A_Temp%\FiveLittleMonkeys.mp3

; Change record
SMAAACK_Changes =
(
Changes with v 1.2.4
   - Removed built in icon mechanism that accessed the icon without extracting it. This
     bound us to AutoHotkey Classic because it did not work under AutoHotkey_L
     
Changes with v 1.2.3
   - Changed home page from Google Code to Sourceforge.net since Google is 
     abandoning all their users and dumping Google Code
     
Changes with v 1.2.2
   - Added a check for a directory named Sounds in the same directory where Smaaack is
     installed. If one is found, and it contains .wav files, then these will be read,
     and one picked at random to be played each time SM is smacked.

Changes with v 1.2.1
   - Bug fix for reactivating the window that was active right before a smack
   - Added a little bit of silly fun, a smack sound can be turned on now when SM is smacked
     enable or disable sound effects via tray menu, or command line:
        s=y | snd=y | sound=y or s=n | snd=n | sound=n
   - Minor tray menu changes to rearrange menu items a bit more logically

   
Changes with v 1.2.0
  - Added a hyperlink to google code home page in About and Help windows.
  - Added a Randomize capability to change the smack time delay between defined smack interval and one
       third of smack interval so we are not always smacking at the same interval. Randomize is now
       default at startup.
       When randomize is passed as a command line parameter, turn on the check mark in the tray menu to
       show it is randomized.
    When the smack interval is changed usng the tray menu slider, update the random intervals if
       randomize is enabled.
  - Added a Disable when PC Locked menu item. Default is to NOT disable when the screensaver kicks in.
       This means %Program% will continue to smack even when the PC is locked and the screensaver active.
       When PC lock disable is passed as a command line parameter, turn on the check mark in the tray menu to
       show it is disabled.
  - Added a Disable Overnight menu item. Default is to disable between 6pm and 7am (local PC time).
       This means %Program% will not continue to smack between 6pm and 7am when a typical user will not 
       be active. This is pointless, wastes SM server resources, and is likely to attract unawanted attention.
       This can also be activated at startup as a command line parameter.
       When no disable overnight is passed as a command line parameter, turn off the check mark
       in the tray menu to show it is active and not disabled.
  - Use Loop %0% for flexible cycle through command line parameters in any sequence:
       integer number for non default smack interval
       disableovernight:
          dn=y | dnight=y | disnight=y | disablenight=y or dn=n | dnight=n | disnight=n | disablenight=n
       disable when locked:
          dl=y | dlock=y | dislock=y | disablelock=y or dl=n | dlock=n | dislock=n | disablelock=n
       randomize smack interval:
          r=y | rand=y | random=y | randomize=y or r=n | rand=n | random=n | randomize=n
  - Added a change record menu item with a list of all changes

    
Changes with v 1.1.3
  1.1.3
  - Added overnight disable, between 6pm and 7am. This can be over-ridden with a second parameter nodisable/nodis.
       This means the timeout MUST be the first parameter.
)  ; end of change record

Program := "Smaaack!"
Version := "v1.2.4"
Author := "Homer Sapions"
HomePage = https://sourceforge.net/projects/smaaack/  ; was http://code.google.com/p/Smaaack/
Minutes = 14
NewMinutes = 0
Interval = 0
SMTitle := "Service Manager"
SMRefreshControl := "ToolbarWindow327"
SMAWOLMsg = `n`nNOTE: %SMTitle% does not appear to be running right now.`n %Program% will simply run quietly in the system tray and do nothing`nuntil it detects that %SMTitle% is running.`nAt that time it will automatically begin smacking SM to prevent inactivity timeout
SMDisableOvernight = 1
SMDisableWhenLocked = 1
SMRandomize = 1
RandomMinutes = 0
RandomMinutesMax = Minutes
RandomMinutesMin := RandomMinutesMax // 3
RandomInterval = 0
Debug = 0
Smacked = 0
Startup = 1
FormatTime, StartTime,, hh:mm:ss tt
SmackTime = None yet (start time: %StartTime%)
SmackSound = 0
SmackRandomWav = Smaaack.wav
SmackWavCount = 0

SetTitleMatchMode, 2   ; set for partial window title matching
DetectHiddenWindows, On
SetWorkingDir %A_ScriptDir%

; install the Smaaack wave and icon files at compile time, extract as needed at run time
FileInstall, Smaaack.wav, %A_Temp%\Smaaack.wav, 1
FileInstall, Smaaack.ico, %A_Temp%\Smaaack.ico, 1


if %0% >= 1
{
   ; Use Loop %0% to cycle through command line params to detect integer timeout, debug, nodisable, random etc.
   ; Accepted parameters:
   ; debug mode (additional MsgBox popups) - d,D,debug,DEBUG
   ; integer number for non default smack interval
   ; disableovernight yes/no - dn,dnight,disnight,disablenight
   ; disable when locked yes/no - dl,dlock,dislock,disablelock
   ; randomize yes/no - r,rand,random,randomize
   Loop, %0%  ; For each parameter:
   {
      Param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
      if Param is integer
      {
         Minutes = %Param%
         if (Minutes < 5) or (Minutes > 15)
         {
            MsgBox ,,%Program% %Version%, You entered a parameter %Minutes% which is < 5 or > 15.`nThe default timeout is 14 minutes.`n`n5 or less is ok for testing, but not necessary.`nMore than 14 will very likely cause the inactivity timeout not to activate.`n`nYou can leave %Program% running like this, or exit and restart, or just`nrun %Program% again with a new, more suitable parameter`nand it will reload.
         }  ; end if the number seems too low or too high
	      Interval := Minutes * 60 * 1000
      }  ; end if it is numeric
      else if Param in d,D,debug,DEBUG
      {
         Debug = 1
         MsgBox ,,,Turning debug mode on,3
      }  ; end if debug mode turned on
      else if Param in dn=n,dnight=n,disnight=n,disablenight=n
      {
         SMDisableOvernight = 0
         SMDisableOvernightString = `n%Program% will NOT be disabled overnight
      }  ; end if DisableOvernight mode turned off
      else if Param in dn=y,dnight=y,disnight=y,disablenight=y
      {
         SMDisableOvernight = 1
         SMDisableOvernightString = `n%Program% will be disabled overnight
      }  ; end if DisableOvernight mode turned on
      else if Param in dl=n,dlock=n,dislock=n,disablelock=n
      {
         SMDisableWhenLocked = 0
         SMDisableLockString = `n%Program% will NOT be disabled when the PC is locked
      }  ; end if DisableOvernight mode turned off
      else if Param in dl=y,dlock=y,dislock=y,disablelock=y
      {
         SMDisableWhenLocked = 1
         SMDisableLockString = `n%Program% will be disabled when the PC is locked
      }  ; end if DisableOvernight mode turned on
      else if Param in r=y,rand=y,random=y,randomize=y
      {
         SMRandomize = 1
         SMRandomizeString = `n%Program% will smack at random intervals up to %Minutes% minutes
      }  ; end if random smack mode turned on
      else if Param in r=n,rand=n,random=n,randomize=n
      {
         SMRandomize = 0
         SMRandomizeString = `n%Program% will smack at static, NOT random intervals of %Minutes% minutes
      }  ; end if random smack mode turned off
      else if Param in s=y,sound=y,snd=y
      {
         SmackSound = 1
      }  ; end if smacksound mode turned on
      else if Param in s=n,sound=n,snd=n
      {
         SmackSound = 0
      }  ; end if smacksound mode turned off
   }  ; end looping through all parameters
}  ; end if we received a parameter

if SMRandomize = 1
{
   RandomMinutesMax = %Minutes%
   RandomMinutesMin := RandomMinutesMax // 3
   if RandomMinutesMin = 0
   {
      RandomMinutesMin = 1
   }  ; end if we have a 0 minimum value which causes a death spiral if this becomes the smack time
   Random, RandomMinutes, RandomMinutesMin, RandomMinutesMax
   Interval := RandomMinutes * 60 * 1000
}  ; end if randomize is on
else
{
   Interval := 14 * 60 * 1000  ; 14 minutes should be good - SetTimer works in milliseconds, so 14 * 60 * 1000
}  ; end if randomize is not on


if Debug = 1
{
   Version = %Version% . (DEBUG active)
   MsgBox ,,%Program% %Version% command line help,%Program%: %Version% Debug mode is turned on, 3
}

Intro = Interval is set to %Interval% (%Minutes% minutes)
Intro = %Intro% . %SMDisableOvernightString%
Intro = %Intro% . %SMDisableLockString%
Intro = %Intro% . %SMRandomizeString%
Intro = %Intro% . `n`nRight click the tray icon for menu options

IfWinNotExist %SMTitle%
{
   Intro = %Intro% . %SMAWOLMsg%
}  ; end if SM is not currently open

MsgBox ,,,%Intro%,20

; Check for and read a list of all .wav files in the .\Sounds directory into SmackSounds
IfExist %A_ScriptDir%\Sounds
{
   Loop, %A_ScriptDir%\Sounds\*.wav
   {
      SmackWavCount += 1
      SmackWav%SmackWavCount% := A_LoopFileShortPath
   }  ; end reading all files
}  ; end if directory Sounds exists

#Persistent
Menu, tray, Icon, Smaaack.exe,, 1
Menu, tray, add, &About, AboutSmackL ; Creates an about menu item
Menu, tray, add, &Help, HelpSmackL  ; Creates a help menu item.
Menu, tray, add, Change &Record, ChangeRecordL
Menu, tray, add
Menu, tray, add, &Change Timeout, ChangeSmackL
Menu, tray, add, Disable &Overnight, DisableOvernightL
Menu, tray, add, Disable when &PC Locked, DisablePCLockedL
Menu, tray, add, &Disable Smaaack, DisableSmackL
Menu, tray, add, &Randomize Smaaack, RandomizeSmackL
Menu, tray, add, S&M-AAACK Sound, SmackSoundL
Menu, tray, add
Menu, tray, add, &Smaaack now, SmackSML
Menu, tray, add, &Exit, ExitSmackL  ; Creates an exit app menu item.
Menu, tray, NoStandard  ; this removes the standard tray icon menu items
;Menu, tray, add  ; Creates a separator line.
;Menu, tray, Standard  ; this restores the tray icon menu items at the end of the menu

 ; on the first run after startup, check and toggle menu items if necessary. This will only ever run one time
if Startup = 1
{
   Startup = 0
   ; Check for randomize
   if SMRandomize = 1
   {
      menu, tray, ToggleCheck, &Randomize Smaaack  ; turn on the check mark to show we are randomized
   }  ; end if SMRandomize is set at command line
   if SMDisableOvernight = 1
   {
      menu, tray, ToggleCheck, Disable &Overnight  ; turn on the check mark to show we are disabled overnight
   }  ; end if SMDisableOvernight is set at command line
   if SMDisableWhenLocked = 1
   {
      menu, tray, ToggleCheck, Disable when &PC Locked  ; turn on the check mark to show we are disabled when the PC is locked
   }  ; end if SMDisableWhenLocked is set at command line
   if SmackSound = 1
   {
      menu, tray, ToggleCheck, S&M-AAACK Sound  ; turn on the check mark to show we make smack sounds
   }  ; end if SmackSound is turned on at command line
}  ; end if we are in first pass startup

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


DisablePCLockedL:
if SMDisableWhenLocked = 0
{
   SMDisableWhenLocked = 1
   menu, tray, ToggleCheck, Disable when &PC Locked
}  ; end if we are toggling to disable overnight
else
{
   SMDisableWhenLocked = 0
   menu, tray, ToggleCheck, Disable when &PC Locked
}  ; end if we are toggling to not disable when locked
return


DisableOvernightL:
if SMDisableOvernight = 0
{
   SMDisableOvernight = 1
   menu, tray, ToggleCheck, Disable &Overnight
}  ; end if we are toggling to disable overnight
else
{
   SMDisableOvernight = 0
   menu, tray, ToggleCheck, Disable &Overnight
}  ; end if we are toggling to not disable overnight
return


DisableSmackL:
menu, tray, ToggleCheck, &Disable Smaaack
Pause, toggle
return


SmackSML:
if SmackWavCount >= 1
{
   Random, RandomWav, 1, SmackWavCount
   SmackRandomWav := SmackWav%RandomWav%
}  ; end if there is 1 or more wav files in directory Sounds
SmackSM()
PCLockedNow = 0
return


SmackSoundL:
if SmackSound = 0
{
   SmackSound = 1
   menu, tray, ToggleCheck, S&M-AAACK Sound
}  ; end if we are turning it on
else
{
   SmackSound = 0
   menu, tray, ToggleCheck, S&M-AAACK Sound
}  ; end if we are turning it off
return


RandomizeSmackL:
menu, tray, ToggleCheck, &Randomize Smaaack
if SMRandomize = 0
{
   SMRandomize = 1
   RandomMinutesMax = %Minutes%
   RandomMinutesMin := RandomMinutesMax // 3
   if RandomMinutesMin = 0
   {
      RandomMinutesMin = 1
   }  ; end if we have a 0 minimum value which causes a death spiral if this becomes the smack time
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


ChangeRecordL:
ChangeRecord()
return


ExitSmackL:
ExitSmack()
return


; -------------------------------------------------------------------------------
SmackSM()
{
   global Program
   global Version
   global Author
   global HomePage
   global Minutes
   global Interval
   global NewMinutes
   global Message
   global SMTitle
   global HomePage
   global Smacked
   global SmackTime
   global SmackSound
   global SMAWOLMsg
   global SMRefreshControl
   global SMDisableOvernight
   global SMDisableWhenLocked
   global SMRandomize
   global RandomInterval
   global RandomMinutes
   global RandomMinutesMax
   global RandomMinutesMin
   global Debug
   global SmackRandomWav
   global SmackWavCount
   
   FormatTime, HourNow,, H
   FormatTime, MinNow,, m
   
   
   if !DllCall("User32\OpenInputDesktop","int",0*0,"int",0*0,"int",0x0001L*1)
   {
      PCLockedNow = 1
   }  ; end if the computer is locked right now
   if (SMDisableWhenLocked = 1) and (PCLockedNow = 1)
   {
      ; do nothing if the disable when locked has not been disabled
      return
   }  ; end if the computer is not locked and disable when locked is set

   
   if ( SMDisableOvernight = 0 ) or ( HourNow >= 7 ) and ( HourNow <= 18 )
   {
      IfWinExist, %SMTitle%
      {
         ; Get ID of active window
         WinGet, ActiveWin, ID, A

         ; Check if the SM window is minimized. If it is, maximize it quickly, then minimize again after
         WinGet Minimized, MinMax, %SMTitle%
         IfEqual Minimized,-1, WinRestore, %SMTitle%

         ; click refresh on SM
         SetControlDelay -1
         ;ControlClick ,%SMRefreshControl%, %SMTitle%,,LEFT,1,x215 y80 NA
         ;ControlClick ,,%SMTitle%,,,,x215 y80 NA
         ControlClick %SMRefreshControl%, %SMTitle%,, LEFT
         
         if SmackSound = 1
         {
            if SmackWavCount >= 1
            {
               SoundPlay, %SmackRandomWav%
            }  ; else if there is a Sounds direcotry with 1 or more wav files
            else
            {
               SoundPlay, Smaaack.wav
            }  ; end if there are no extra wav files
         }  ; end if smack sound is enabled

         IfEqual Minimized,-1, WinMinimize, %SMTitle%
      
         ; make original window active again
         WinActivate, ahk_id %ActiveWin%
      
         Smacked++
         if (SMRandomize = 1) and (Minutes > 4)
         {
            Random, RandomMinutes, RandomMinutesMin, RandomMinutesMax  ; Random, OutputVar [, Min, Max]
            SetTimer, SmackSML, off,0
            RandomInterval := RandomMinutes * 60 * 1000
            SetTimer, SmackSML, %RandomInterval%,0
         }  ; end if SMRandomize is 1
         FormatTime, SmackTime,, dddd MMMM d, yyyy hh:mm:ss tt
         if Debug > 0
         {
            MsgBox ,,TEST,Smacked is %Smacked% at %SmackTime%,5
         }  ; end if debug mode
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

; -------------------------------------------------------------------------------
AboutSmack()
{
   global Program
   global Version
   global Author
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
   global SMDisableWhenLocked
   global SMRandomize
   global RandomInterval
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
      RandomMessage := "`nRandom smacking is enabled at " . RandomMinutes . " minutes (from " . RandomMinutesMin . " to " . RandomMinutesMax . ")`n"
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

%Program% is brought to you by %Author%, a former
"I hate the SM inactivity timeout" disgruntled user. Have fun!

Please use %Program% responsibly.
You can talk %Program%. You can %Program% your lips.
Don't %Program% and drive. Don't %Program% your spouse or kids.
   )

   ; -------------------------------------------
   ; Make a GUI about window
   Gui, 1: Add, Picture, xp+0 y+10 w250 h250 gAboutHomePage Icon, %A_Temp%\Smaaack.ico
   Gui, Font, s10, Verdana
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

   return
}  ; end of AboutSmack

; -------------------------------------------------------------------------------
HelpSmack()
{
   global Program
   global Version
   global Author
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
   global SMDisableWhenLocked
   global SMRandomize
   global RandomInterval
   global RandomMinutes
   global RandomMinutesMax
   global RandomMinutesMin
   global Debug
   
   HelpMessage =
   (
%Program% accepts up to four parameters, which if used, can be in any order,
case insensitive.

One numeric parameter is accepted, an integer number of minutes to delay between
smacking SM. If you don't give a valid integer parameter the default is 14 (minutes).

Four additional parameters can also be used, to change behavior, also all accessible
by right clicking the system tray icon. You can use any of the options below, though 
it seems kind of stupid to type a long one when a short one works the same, but maybe
you feel you need need the typing practice!

Sample command line parameter use is below, showing some defaults, some non default:
   Smaaack 14 r=y dn=y dl=n s=y
This will start %Program% with a maximum 14 minute (default) smack interval.
Randomizing will be activated (default) at 1/3 of 14, which will be 4 (rounded integer).
Smacking will not occur between 6pm and 7am (default).
Smacking will continue even when the PC is locked (not default).
Smack sounds will be enabled each time SM is smacked (not default).

All of these can be toggled through a pop up menu by right clicking the tray icon.
   - disable overnight: This toggles %Program% between not smacking between 6pm and 7am
      (default), and smacking continuously. Not disabling overnight is not advised
      because it wastes server resources and licenses, and may also attract unwanted
      attention. dn=n is the default.
   dn=y | dnight=y | disnight=y | disablenight=y or dn=n | dnight=n | disnight=n | disablenight=n
   
   - disable when locked: If you are not at your computer you might want to leave %Program%
      enabled, but consider the need. Once again, you are wasting server resources and licenses
      if you're gone for an extended periof of time. dl=y is the default.
   dl=y | dlock=y | dislock=y | disablelock=y or dl=n | dlock=n | dislock=n | disablelock=n
   
   - randomize smack interval: Just what it says, it randomizes the smack frequency to be less
      obvious about what it is doing. The random interval is based on a pseudo random number
      ranging from the static interval (default 14, or a value you specify), and one third of
      the static interval. Every smack when randomize is enabled, including a manual
      '%Program% Now' smack will re-randomize the smack time. r=y is the default.
   r=y | rand=y | random=y | randomize=y or r=n | rand=n | random=n | randomize=n
   
   - Smaaack Sound: This enables or disables a sound when SM is smacked. Default is to NOT
      make any sound. This one is for fun. If it doesn't make you smile and appreciate this little
      program at least once, there's not much hope for you. You may as well go suck on a lemon
      and see if that cheers you up a bit. s=n is the default.
      If you want to choose your own sound(s), just create a directory named Sounds in the same
      place where you put %Program%, and copy in any .wav files you want. Any .wav files found
      will be read into a list in memory, and one chosen to be played at ramdom if sound is
      enabled. This will over-ride the default sound built into %Program%
   s=y | snd=y | sound=y or s=n | snd=n | sound=n

Three additional tray menu items are worth a mention:
  - 'Change Timeout': pops up a slider control allowing you to change the timeout value
     to anything between 1 and 60. 60 may not bypass the current SM inactivity
     timeout depending how the SM server in your organization has been configured.
     You can achieve the same thing by stopping and restarting %Program%,
     or by simply re-running %Program% with a different integer parameter.
  - 'Disable %Program%': simply pauses the program, so that you can manually stop it
     running for a while, then resume again later. When disabled, a check mark appears
     next to the menu item.
  - '%Program% now': sends a smack to SM immediately. The primary use for this is
     for you to test, to see that the program will work. You can do this with the SM
     window minimized or open and active. To see that it works, try expanding a few 
     items with the [+] under the System Navigator panel on the left side of SM.
     After SM is smacked, all items in the System Navigator panel should be collapsed.
    

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

This should also work when your screensaver kicks in and the screen is locked, unless
you have disabled %Program% from activating when the PC is locked. See the tray menu
option 'Disable when PC Locked'. A check mark next to this option means it will not
smack when the screensaver activates and locks the computer.

%Program% is brought to you by %Author%, a former
"I hate the SM inactivity timeout" disgruntled user. Have fun!
   )
   
   ; -------------------------------------------
   ; Make a GUI help window
   Gui, 2: Add, Picture, xp+0 y+10 w250 h250 gAboutHomePage Icon, %A_Temp%\Smaaack.ico
   Gui, 2: Font, s10, Verdana
   Gui, 2: Add, Edit, -WantCtrlA ReadOnly VScroll x266 y6 h400 w700, %HelpMessage%
   Gui, 2: Font, underline
   Gui, 2: Add, Text, cBlue gHelpHomePage, Click here to visit %Program%'s home page
   Gui, 2: Font, norm
   Gui, 2: Add, Button, default, CloseHelp
   Gui, 2: Show,, Help: %Program% %Version%
   Send ^{Home}
   Return
   
   HelpHomePage:
   Run %HomePage%
   return
   
   2GuiEscape:
   2ButtonCloseHelp:
   Gui, 2: Submit
   Gui, 2: Destroy
   return
}  ; end of HelpSmack

; -------------------------------------------------------------------------------
ChangeSmack()
{
   global Program
   global Version
   global Author
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
   global SMDisableWhenLocked
   global SMRandomize
   global RandomMinutes
   global RandomInterval
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
   if SMRandomize = 1
   {
      RandomMinutesMax = %Minutes%
      RandomMinutesMin := RandomMinutesMax // 3
      if RandomMinutesMin = 0
      {
         RandomMinutesMin = 1
      }  ; end if we have a 0 minimum value which causes a death spiral if this becomes the smack time
      Random, RandomMinutes, RandomMinutesMin, RandomMinutesMax
      Interval := RandomMinutes * 60 * 1000
   }  ; end if randomize is on
   else
   {
      Interval := Minutes * 60 * 1000  ; 14 minutes should be good - SetTimer works in milliseconds, so 14 * 60 * 1000
   }  ; end if randomize is not on
   
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

; -------------------------------------------------------------------------------
ExitSmack()
{
   FileDelete, %A_Temp%\Smaaack.ico
   FileDelete, %A_Temp%\Smaaack.wav
   ExitApp
}  ; end of ExitSmack

; -------------------------------------------------------------------------------
ChangeRecord()
{
   global Program
   global Version
   global Author
   global HomePage
   global SMAAACK_Changes
   
   ; -------------------------------------------
   ; Make a GUI Change Record window
   Gui, 3: Add, Picture, xp+0 y+10 w250 h250 gAboutHomePage Icon, %A_Temp%\Smaaack.ico
   Gui, 3: Font, s10, Verdana
   Gui, 3: Add, Edit, -WantCtrlA ReadOnly VScroll x266 y6 h400, %SMAAACK_Changes%
   Gui, 3: Font, underline
   Gui, 3: Add, Text, cBlue gHelpHomePage, Click here to visit %Program%'s home page
   Gui, 3: Font, norm
   Gui, 3: Add, Button, default, Close
   Gui, 3: Show,, Change Record: %Program% %Version%
   Send ^{Home}
   Return
   
   ChangeHomePage:
   Run %HomePage%
   return
   
   3GuiEscape:
   ChangeGuiClose:
   3ButtonClose:
   Gui, 3: Submit
   Gui, 3: Destroy

   return
}  ; end of ChangeRecord

; -------------------------------------------------------------------------------
