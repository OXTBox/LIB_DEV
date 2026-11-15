######################################################################################
## STACK SCRIPT: "Game_Player_Launcher"  (LIB_DEV, 11 14 2026)
## Build THIS stack as a standalone ONCE, named Game_Player (steps in LIB_DEV/README.md).
## The GAME_Browser starts it as   Game_Player.exe <GameName>   : one program per game, so a
## game never runs inside the browser and closing the browser leaves the game running.
## At each start it loads LIB_DEV/livecode/game_launch.livecodescript from disk (GL.Open) and
## opens the game in its own window; closing that window quits this program. Everything it
## loads comes from disk, so the AI's updates need no rebuild.
## The game's name: the first command-line argument, else the request file the browser writes
## (<temporary folder>/game_player_request.txt).
## In the IDE it does nothing but show itself (so it can be built).
## Every start is logged to LIB_LLMIN/LIB_DEV/launcher_log.txt.
######################################################################################

on openStack
   if the environment is not "standalone application" then exit openStack   -- in the IDE: just show
   send "Launcher.Go" to me in 10 milliseconds
end openStack

command Launcher.Go
   local tProjects, tLaunch, tGame, tErr, tWhy
   hide stack "Game_Player_Launcher"
   put Launcher.Projects() into tProjects
   put Launcher.GameName() into tGame
   put tProjects & "/LIB_DEV/livecode/game_launch.livecodescript" into tLaunch
   Launcher.Log tProjects, "Game_Player start: " & tGame & " | " & the effective filename of this stack
   if tGame is empty then
      answer "Game_Player: no game named. Start it from the GAME_Browser."
      quit
   end if
   if there is not a file tLaunch then
      answer "Game_Player: not found:" & return & tLaunch
      quit
   end if
   try
      start using stack tLaunch
      put GL.Open(tProjects, tGame, true) into tWhy
   catch tErr
      put "error: " & line 1 of tErr into tWhy
   end try
   if tWhy is not empty then
      Launcher.Log tProjects, "Game_Player FAILED " & tGame & ": " & tWhy
      answer "Game_Player could not start" && tGame & ":" & return & tWhy
      quit
   end if
   Launcher.Log tProjects, "Game_Player playing " & tGame
end Launcher.Go

-- the game: the command line first, else the browser's request file
function Launcher.GameName
   local tName, tFile, tErr
   try
      put $1 into tName
   catch tErr
      put empty into tName
   end try
   if tName is empty then
      put specialFolderPath("temporary") & "/game_player_request.txt" into tFile
      if there is a file tFile then put line 1 of textDecode(URL ("binfile:" & tFile), "UTF-8") into tName
   end if
   replace quote with empty in tName
   -- Windows may hand the name over as a path (launch <name> with <app>): keep the last part
   replace "\" with "/" in tName
   set the itemDel to "/"
   put item -1 of tName into tName
   return word 1 to -1 of tName
end Launcher.GameName

-- the nearest folder above this program that holds LIB_LLMOUT; else the WSL path
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
