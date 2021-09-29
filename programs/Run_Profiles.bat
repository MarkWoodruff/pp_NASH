rem Run BOS-580-201 Patient Profiles, and then checks log via checklogs.sas
rem To execute this program, double-click the file name in Windows Explorer.
rem Modification History
rem 2021-09-29 Mark Woodruff created program

@set sasexepath=C:\Program Files\SASHome\SASFoundation\9.4\Sas.exe
@set sascfgpath=C:\Program Files\SASHome\SASFoundation\9.4\nls\en\SASV9.CFG
@set pgmdir=C:\Users\markw.consultant\_projects\BOS-580-201\profiles\programs

"%sasexepath%" -config "%sascfgpath%" -sysin %pgmdir%\RunProfiles.sas -log %pgmdir%\RunProfiles.log -print %pgmdir%\RunProfiles.lst -nosplash 
"%sasexepath%" -config "%sascfgpath%" -sysin %pgmdir%\checklogs.sas   -log %pgmdir%\checklogs.log   -print %pgmdir%\checklogs.lst -nosplash
