######################################################################################
## STACK SCRIPT: "Status_Browser_Launcher"  (LIB_DEV, 11 14 2026)
## Build THIS stack as a standalone (once; steps in LIB_DEV/README.md). As a standalone it opens
## the CURRENT LIB_DEV/Status_Browser.livecode from disk at every start, so the AI's updates need
## no rebuild, and the browser keeps running when the LiveCode IDE quits. Closing the browser
## quits it. In the IDE it does nothing but show itself (so it can be built).
## Every start is logged to LIB_LLMIN/LIB_DEV/launcher_log.txt (what it found, what failed).
######################################################################################

on openStack
   if the environment is not "standalone application" then exit openStack   -- in the IDE: just show
   Launcher.Go
end openStack

command Launcher.Go
   local tProjects, tBrowser, tErr
   put Launcher.Projects() into tProjects
   put tProjects & "/LIB_DEV/Status_Browser.livecode" into tBrowser
   Launcher.Log tProjects, "start: " & the effective filename of this stack & " | browser: " & tBrowser & " | exists: " & (there is a file tBrowser)
   if there is not a file tBrowser then
      answer "Status_Browser not found:" & return & tBrowser
      quit
   end if
   global gStatusBrowserLauncher
   put true into gStatusBrowserLauncher       -- closing the browser now quits this app
   try
      go stack tBrowser
   catch tErr
      Launcher.Log tProjects, "ERROR opening the browser: " & line 1 of tErr
      answer "Could not open Status_Browser:" & return & line 1 of tErr
      quit
   end try
   Launcher.Log tProjects, "opened: " & the short name of the topStack
   if the environment is "standalone application" then hide stack "Status_Browser_Launcher"
end Launcher.Go

-- the nearest folder above this launcher (or its .exe) that holds LIB_LLMOUT; else the WSL path
function Launcher.Projects
   local tPath
   put the effective filename of this stack into tPath
   replace "\" with "/" in tPath
   set the itemDel to "/"
   repeat while the number of items of tPath > 1
      delete item -1 of tPath
      if there is a folder (tPath & "/LIB_LLMOUT") then return tPath
   end repeat
   return "//wsl$/Ubuntu/home/igame3d/projects"
end Launcher.Projects

command Launcher.Log pProjects, pText
   local tFile
   put pProjects & "/LIB_LLMIN/LIB_DEV/launcher_log.txt" into tFile
   if there is not a folder (pProjects & "/LIB_LLMIN/LIB_DEV") then exit Launcher.Log
   put the short date && the long time & tab & pText & return after URL ("file:" & tFile)
end Launcher.Log
