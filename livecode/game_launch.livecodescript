script "GameLaunch"
######################################################################################
## GAME LAUNCH  (LIB_DEV, 11 14 2026)
## Shared by the GAME_Browser and the Game_Player app:
##   GL.Info(name)        what a game's script says (title, keys, rules, level prefix, levels)
##   GL.Open name         (Game_Player app) the game in its own window: a new stack
##                        "Play <Game>" with game_player.livecodescript as its script and the
##                        game's card script on card "Play.<Game>", on the Vibecode3D engine library
## The browser never opens a game window itself: it starts the Game_Player app
## (Game_Player.exe <Game>), one program per game.
######################################################################################

constant kGamesRel = "LIB_GAMES/Vibecode3D_Games"
constant kEngineRel = "xt3D_Raylib_Livecode_Bridge/testbench/vibe_engine_xt3d.livecodescript"
constant kPlayerRel = "LIB_DEV/livecode/game_player.livecodescript"

-- the projects folder: the nearest folder above pFrom (a file path) that holds LIB_LLMOUT
function GL.Projects pFrom
   local tPath
   put pFrom into tPath
   if tPath is empty then put the effective filename of stack "GameLaunch" into tPath
   replace "\" with "/" in tPath
   set the itemDel to "/"
   repeat while the number of items of tPath > 1
      delete item -1 of tPath
      if there is a folder (tPath & "/LIB_LLMOUT") then return tPath
   end repeat
   return "//wsl$/Ubuntu/home/igame3d/projects"
end GL.Projects

function GL.GameFile pProjects, pName
   return pProjects & "/" & kGamesRel & "/Vibecode3D_Play_" & pName & ".livecodescript"
end GL.GameFile

function GL.ReadText pPath
   local tText
   if there is not a file pPath then return empty
   put textDecode(URL ("binfile:" & pPath), "UTF-8") into tText
   replace numToChar(13) & numToChar(10) with return in tText
   replace numToChar(13) with return in tText
   return tText
end GL.ReadText

-- what the script's header and handlers say about a game
function GL.Info pProjects, pName
   local tScript, tInfo, tLine, tText, tMode, tAt
   put GL.ReadText(GL.GameFile(pProjects, pName)) into tScript
   put pName into tInfo["name"]
   repeat for each line tLine in line 1 to 30 of tScript
      if not (tLine begins with "##") then
         if tLine is not empty then exit repeat
         next repeat
      end if
      if char 3 to 5 of tLine is "###" or tLine is "##" then next repeat
      put char 4 to -1 of tLine into tText
      if word 1 of tText is "CARD" and word 2 of tText is "SCRIPT:" then
         put word 4 to -1 of tText into tInfo["title"]
         next repeat
      end if
      if word 1 of tText is "CONTROLS" then
         put "keys" into tMode
         delete word 1 of tText
      else if word 1 of tText is "RULES" then
         put "rules" into tMode
         delete word 1 of tText
      end if
      if tMode is empty then put "about" into tMode
      put "  " & word 1 to -1 of tText & return after tInfo[tMode]
   end repeat
   -- <Prefix>.StartLevel n: the level menu
   repeat for each line tLine in tScript
      if word 1 of tLine is "on" and word 2 of tLine ends with ".StartLevel" then
         put char 1 to -12 of word 2 of tLine into tInfo["prefix"]
         exit repeat
      end if
   end repeat
   put 0 into tInfo["levels"]
   if tInfo["prefix"] is not empty then
      put 5 into tInfo["levels"]                 -- the arcade games' rule
      if matchText(line 1 to 30 of tScript, "(?i)\b([0-9]+) levels", tAt) then
         if tAt is an integer and tAt > 0 and tAt < 100 then put tAt into tInfo["levels"]
      end if
   end if
   put ("SetMouseLook true" is in tScript) into tInfo["mouselook"]
   return tInfo
end GL.Info

-- SKINS (A-86, Opus 15 Nov 2026): the editor's Edit > Replace With Model... saves skins as
--   LIB_GAMES/Vibecode3D_Games/Skins/<Game>/<skin>.skin.txt   mesh name TAB model file (relative to projects)
--   LIB_GAMES/Vibecode3D_Games/Skins/<Game>/ACTIVE.txt         the skin in use (empty or missing: placeholders)
-- Before a game starts its active skin goes into the global gV3DSkin[mesh name] = model file, and the
-- engine's Mesh.Define (xt3d overrides) uses that model instead of the game's placeholder mesh.
command GL.LoadSkin pProjects, pName
   global gV3DSkin
   local tDir, tSkin, tLine
   put empty into gV3DSkin
   put pProjects & "/LIB_GAMES/Vibecode3D_Games/Skins/" & pName into tDir
   put word 1 to -1 of line 1 of GL.ReadText(tDir & "/ACTIVE.txt") into tSkin
   if tSkin is empty then exit GL.LoadSkin
   set the itemDelimiter to tab
   repeat for each line tLine in GL.ReadText(tDir & "/" & tSkin & ".skin.txt")
      if tLine is empty or char 1 of tLine is "#" then next repeat
      if item 2 of tLine is not empty then put pProjects & "/" & item 2 of tLine into gV3DSkin[item 1 of tLine]
   end repeat
end GL.LoadSkin

-- the game in its own window. Returns empty, or why it could not.
-- pQuitOnClose: closing the window quits the app (the Game_Player app sets it)
function GL.Open pProjects, pName, pQuitOnClose
   local tFile, tScript, tStack, tPlayer, tEngine, tInfo, tErr
   put GL.GameFile(pProjects, pName) into tFile
   put GL.ReadText(tFile) into tScript
   if tScript is empty then return "No game script:" && tFile
   put pProjects & "/" & kEngineRel into tEngine
   if there is not a file tEngine then return "No engine library:" && tEngine
   put GL.ReadText(pProjects & "/" & kPlayerRel) into tPlayer
   if tPlayer is empty then return "No player script:" && kPlayerRel
   try
      if not ("VibeEngineXt3d" is among the lines of the stacksInUse) then start using stack tEngine
   catch tErr
      return "The engine library did not load:" && tErr
   end try
   GL.GameNotes pProjects
   GL.LoadSkin pProjects, pName
   put GL.Info(pProjects, pName) into tInfo
   put "Play" && pName into tStack
   if there is a stack tStack then close stack tStack
   lock messages
   create invisible stack tStack
   unlock messages
   set the defaultStack to tStack
   set the script of stack tStack to tPlayer
   if the result is not empty then
      put the result into tErr
      delete stack tStack
      return "The player script does not compile:" && tErr
   end if
   set the name of card 1 of stack tStack to "Play." & pName
   set the script of card 1 of stack tStack to tScript
   if the result is not empty then
      put the result into tErr
      delete stack tStack
      return pName && "does not compile:" && tErr
   end if
   set the uGame of stack tStack to pName
   set the uScriptFile of stack tStack to tFile
   set the uPrefix of stack tStack to tInfo["prefix"]
   set the uLevels of stack tStack to tInfo["levels"]
   set the uQuitOnClose of stack tStack to (pQuitOnClose is true)
   set the backgroundColor of stack tStack to "0,0,0"
   set the resizable of stack tStack to false
   set the destroyStack of stack tStack to true
   set the title of stack tStack to "FOR OWNER |" && pName && "| Escape pauses, ... top right: Reset, Levels, Quit"
   dispatch "Users.TitleStack" with tStack, pName && "| Escape pauses, ... top right: Reset, Levels, Quit"   -- LIB_USERS words it, when in use
   set the rect of stack tStack to GL.WindowRect()
   try
      show stack tStack
      go stack tStack
   catch tErr
      return "The window did not open:" && line 1 of tErr
   end try
   send "Player.Start" to stack tStack in 50 milliseconds
   return empty
end GL.Open

-- 900 x 600, centred on the main screen
function GL.WindowRect
   local tL, tT
   put max(0, (item 3 of the screenRect - 900) div 2) into tL
   put max(30, (item 4 of the screenRect - 600) div 2) into tT
   return tL, tT, tL + 900, tT + 600
end GL.WindowRect

-- the in-game notes box (` or F2), as in Vibecode3D and the bench
command GL.GameNotes pProjects
   local tFile, tErr
   if there is a stack "GameNotes" and "GameNotes" is among the lines of the frontScripts then exit GL.GameNotes
   put pProjects & "/LIB_GAMES/tools/GameNotes.livecodescript" into tFile
   if there is not a file tFile then exit GL.GameNotes
   try
      start using stack tFile
      insert script of stack "GameNotes" into front
   catch tErr
   end try
end GL.GameNotes
