######################################################################################
## STACK SCRIPT: "Status_Browser_Launcher"  (LIB_DEV, 11 14 2026)
## Build THIS stack as a standalone (once). Each start it opens the CURRENT
## LIB_DEV/Status_Browser.livecode from disk, so the AI's updates arrive without a rebuild,
## and the browser keeps running when the LiveCode IDE quits. Closing the browser quits it.
######################################################################################

on openStack
   local tProjects, tBrowser
   put Launcher.Projects() into tProjects
   put tProjects & "/LIB_DEV/Status_Browser.livecode" into tBrowser
   if there is not a file tBrowser then
      answer "Status_Browser not found:" & return & tBrowser
      quit
   end if
   hide this stack
   open stack tBrowser
end openStack

-- the nearest folder above this launcher (or its .exe) that holds LIB_LLMOUT; else the WSL path
function Launcher.Projects
   local tPath
   put the effective filename of this stack into tPath
   set the itemDel to "/"
   repeat while the number of items of tPath > 1
      delete item -1 of tPath
      if there is a folder (tPath & "/LIB_LLMOUT") then return tPath
   end repeat
   return "//wsl$/Ubuntu/home/igame3d/projects"
end Launcher.Projects
