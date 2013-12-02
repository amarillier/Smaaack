This is a small utility written in AutoHotKey for Microsoft Windows, to keep the HP Service Manager client active so that network difficulties and extremely short inactivity timeouts don't keep logging a user out. This should work for any version of the Java client, on any version of Service Manager in any organization.

All this does is run in the system tray, wake up occasionally, and click a control on the Service Manager window to send activity.

If Service Manager is not running, this utility does nothing until Service Manager is discovered.

There is no installation, no registry entries - 100% portable, no configuration .ini files. Run the program and look for the icon in the system tray. Right click and a menu pops up with About, Help and other options.

NOTE! Use of this program may violate IT policies in your organization. Depending on licensing at your site, Service Manager administrators may have limited the Service Manager timeout to prevent licenses from being consumed by people who are not active in the application. This utility should not be used violate IT policies. Use it only if you have a network problem that is causing frequent timeouts and related difficulties.

By downloading and running this program you assume full responsibility for any use or misuse of this program, which comes with absolutely no warranties, express or implied.

In compliance with the GNU GPL v3 licensing, source code is available (by request). 

NOTE: There will always be two versions of the executable available. The first is the default, compressed at compile time with the UPX executable compressor. Because some anti-virus software flags almost any compressed executables as potential malware, the uncompressed version will also always be available.
There is no difference in execution, just that the uncompressed version takes a little more disk space and may take a second or two longer to load into memory.

If you want sound effects each time Service Manager is smacked, you can simply select the enable sounds option in the tray menu. The default sound is a sapping sound. If you would like to have different sound effects, create a sub-directory named Sounds in the same directory where this program is located. There is a zip file named Sounds.zip with some sound effects availble in this downloads directory.