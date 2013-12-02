; Stop the stupid SM9 inactive timeout by clicking the "refresh the whole tree" icon at top
; right of SM9 every 10 minutes

; Still to test if SM9 is running, if not, do nothing

Program := "Smaaack!"
Version := "v1.0"
Minutes = 14
SM9Title := "Wolseley Service Manager"
SM9RefreshControl := "ToolbarWindow327"

if %0% >= 1
{
   Minutes = %1%
   if Minutes is integer
   {
	   Interval := Minutes * 60 * 1000
   }  ; end if it is numeric
   else
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

The way you can see that it is working is to click the [+] next to any of the
activities in the SM9 'System Navigator' to expand those activities. Carry
on working as normal, and you should see them collapse as the refresh button
is clicked.

%Program% is brought to you by a former
"I hate the SM9 inactivity timeout" disgruntled user. Have fun!
      )
   MsgBox, 0, %Program% %Version%, %HelpMessage%, 15
   ExitApp
   }  ; end if it is not numeric
}  ; end if we received a parameter
else
{
   Interval := 14 * 60 * 1000  ; 14 minutes should be good - SetTimer works in milliseconds, so 14 * 60 * 1000
}  ; end if we did not receive any parameters

MsgBox ,,,Interval is set to %Interval% (%Minutes% minutes),3
SetTitleMatchMode, 2   ; set for partial window title matching

#Persistent
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Help, Help  ; Creates a help menu item.
SetTimer, WatchSM9, %Interval%
return

; ------------------------------------
WatchSM9:
IfWinExist, SM9Title
{
   ; Get ID of active window
   WinGet, ActiveWin, ID, A

   ; make SM window active
   WinActivate, Wolseley Service Manager

   ; click refresh
   ControlClick %SM9RefreshControl%, %SM9Title%,, LEFT

   ; make original window active again
   WinActivate, ahk_id %ActiveWin%
}  ; end if SM9 is active
else
{
   MsgBox ,,,%SM9Title% is not active!,2
}
return
; ------------------------------------
Help:

return