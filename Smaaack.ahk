; Stop the stupid SM9 inactive timeout by clicking the "refresh the whole tree" icon at top
; right of SM9 every 10 minutes

; Still to test if SM9 is running, if not, do nothing

Program := "Smaaack!"
Version := "v1.1"
Minutes = 14
SM9Title := "Wolseley Service Manager"
SM9RefreshControl := "ToolbarWindow327"
Debug = 0
Smacked = 0

if %0% >= 1
{
   Minutes = %1%
   if Minutes is integer
   {
	   Interval := Minutes * 60 * 1000
   }  ; end if it is numeric
   else
   {
      GoSub HelpSmack
      ExitApp
   }  ; end if it is not numeric
}  ; end if we received a parameter
else
{
   Interval := 14 * 60 * 1000  ; 14 minutes should be good - SetTimer works in milliseconds, so 14 * 60 * 1000
}  ; end if we did not receive any parameters

MsgBox ,,,Interval is set to %Interval% (%Minutes% minutes) `nRight click the tray icon for menu options,3
SetTitleMatchMode, 2   ; set for partial window title matching

#Persistent
Menu, tray, add, &About, AboutSmack ; Creates an about menu item
Menu, tray, add, &Help, HelpSmack  ; Creates a help menu item.
Menu, tray, add, &Exit, ExitSmack  ; Creates an exit app menu item.
Menu, tray, add  ; Creates a separator line.
Menu, tray, NoStandard  ; this removes the tray icon menu items
Menu, tray, Standard  ; this restores the tray icon menu items at the end of the menu

SetTimer, SmackSM9, %Interval%
return

; ------------------------------------
SmackSM9:
{
   IfWinExist, %SM9Title%
   {
      ; Get ID of active window
      WinGet, ActiveWin, ID, A

      ; make SM window active
      ; WinActivate, Wolseley Service Manager  ; This is not actually necessary as the ControlClick takes acre of it

      ; click refresh on SM9
      ControlClick %SM9RefreshControl%, %SM9Title%,, LEFT

      ; make original window active again
      WinActivate, ahk_id %ActiveWin%
      
      Smacked++
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
AboutSmack:
{
   AboutMessage =
   (
%Program%, %Version% has smacked SM9 %Smacked% times so far!

Current setting is to smack SM9 every %Minutes% minutes to stop it from
timing you out.

If you want to change the timeout interval, just run
%Program% again with a new integer parameter. This will cause it to
prompt if you want to reload, and will apply the new settings.

The default interval is 14 minutes which should subdue the obnoxious beast
known as the SM9 inactivity timeout. If this doesn't work for you for
some reason, try making the delay a bit shorter.

e.g. Smaaack 10

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
   Gui, 1: Add, Picture, xp+0 y+10 w250 h250 gAboutEggClick Icon hwndPicExe, Smaaack.exe
   Gui, 1: Add, Picture, w3 h3 gAboutBigAl Icon, Smaaack.exe
   hIcon := ExtractIcon("Smaaack.exe", 1)
   SendMessage, 0x170, hIcon,,, ahk_id %PicExe%  ; STM_SETICON

   Gui, Add, Text, x266 y6 w390 h320 , %AboutMessage%
   Gui, Add, Button, default, CloseAbout
   Gui, Show,, About: %Program%, %Version%
   Return

   AboutEggClick:
   MsgBox, 0, %Program% Easter egg, What? Now you think you're smart or something?`n`nYou really want to know who wrote this?`nNice try! At least you found the Easter egg.
   return
   
   AboutBigAl:
   MsgBox, 0, %Program% Easter egg, Now you're onto something!`n`nDoes 'Big Al' mean anything to you? `nNo? ... too bad!
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
HelpSmack:
{
   HelpMessage =
   (
This program accepts one numeric parameter only, the number of minutes to
delay between smacking SM9. If you don't give a valid integer parameter
the default is 14, which should help with the inactivity timeout.

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

This even works when your screensaver kicks in and the screen is locked.

%Program% is brought to you by a former
"I hate the SM9 inactivity timeout" disgruntled user. Have fun!

Did you *really* expect to find out who wrote this? Not likely ... :-)
Maybe there's an egg.
   )
   
   ; -------------------------------------------
   ; Make a GUI help window
   Gui, 2: Add, Picture, xp+0 y+10 w250 h250 gAboutEggClick Icon hwndPicExe, Smaaack.exe
   Gui, 2: Add, Picture, w3 h3 gHelpBigAl Icon, Smaaack.exe
   hIcon := ExtractIcon("Smaaack.exe", 1)
   SendMessage, 0x170, hIcon,,, ahk_id %PicExe%  ; STM_SETICON

   Gui, 2: Add, Text, x266 y6 w390 h360 , %HelpMessage%
   Gui, 2: Add, Button, default, CloseHelp
   Gui, 2: Show,, Help: %Program%, %Version%
   Return

   HelpEggClick:
   MsgBox, 0, %Program% Easter egg, What? Now you think you're smart or something?`n`nYou really want to know who wrote this?`nNice try! At least you found the Easter egg.
   return
   
   HelpBigAl:
   MsgBox, 0, %Program% Easter egg, Now you're onto something!`n`nDoes 'Big Al' mean anything to you? `nNo? ... too bad!
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
ExitSmack:
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