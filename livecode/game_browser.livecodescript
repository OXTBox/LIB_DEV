######################################################################################
## STACK SCRIPT: "GAME_Browser"  (LIB_DEV, 11 14 2026; the owner's layout)
## A list of the games; each game starts as a program of its own. Built by
## tools/build_game_browser.lc from the owner's layout (GAME_Browser_gui_For_edits.livecode).
##   LEFT   every game in LIB_GAMES/Vibecode3D_Games. Refresh reloads the list.
##          Click (or arrow up/down): its details on the right.
##          Double-click or Return: play it on the engines ticked at the top
##          (Vibecode3d / xt3d / both; none ticked = Vibecode3D).
##          Right-click: pick the engine (Vibecode3D / xt3d games bench),
##          Open script in Explorer, Copy script path.
##   RIGHT  top: what the game's script says (levels, keys, rules, paths)
##          bottom: your note about the game; Submit adds it to LIB_LLMIN/LIB_GAMES/GAME_NOTES.txt,
##          the same inbox as the in-game notes (` or F2), marked BROWSER.
##   Tell Claude: a line in LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt, which the AI watches.
## Engines (the browser never opens a game window itself)
##   Vibecode3D   starts the Game_Player app (LIB_DEV/Game_Player/Game_Player.exe <Game>): a window
##                "Play <Game>" on the Vibecode3D engine library; its ... menu: Pause, Reset,
##                Levels, Quit. Closing the window quits that program.
##   xt3d         starts the xt3d games bench if it is not running and asks it (LIB_MCP, port
##                8770) to play the game.
######################################################################################

constant kGamesRel = "LIB_GAMES/Vibecode3D_Games"
constant kBenchRel = "xt3D_Raylib_Livecode_Bridge/standalone/xt3d_Bench_LibMCP/xt3d_Bench_LibMCP.exe"
constant kBenchPort = 8770

local sGames, sCount, sCurrent, sLastSent, sInfo
local sDraft   -- [game] the Feedback field's text for that game (kept while you switch games)

on openStack
   GB.Refresh
end openStack

-- run from a launcher standalone: closing the browser quits the app
on closeStack
   global gGameBrowserLauncher
   if gGameBrowserLauncher is true and the environment is "standalone application" then quit
   pass closeStack
end closeStack

-- every entry point: our own controls, whatever window was used last
command GB.UseMe
   set the defaultStack to "GAME_Browser"
end GB.UseMe

-------------------------------------------------------------------- files

-- the projects folder: the nearest folder above this stack that holds LIB_LLMOUT
function GB.Projects
   local tPath
   put the effective filename of stack "GAME_Browser" into tPath
   set the itemDel to "/"
   repeat while the number of items of tPath > 1
      delete item -1 of tPath
      if there is a folder (tPath & "/LIB_LLMOUT") then return tPath
   end repeat
   return "//wsl$/Ubuntu/home/igame3d/projects"
end GB.Projects

function GB.GameFile pName
   return GB.Projects() & "/" & kGamesRel & "/Vibecode3D_Play_" & pName & ".livecodescript"
end GB.GameFile

function GB.ReadText pPath
   local tText
   if there is not a file pPath then return empty
   put textDecode(URL ("binfile:" & pPath), "UTF-8") into tText
   replace numToChar(13) & numToChar(10) with return in tText
   replace numToChar(13) with return in tText
   return tText
end GB.ReadText

command GB.AppendLine pPath, pLine
   local tText
   put GB.ReadText(pPath) into tText
   if tText is not empty and the last char of tText is not return then put return after tText
   put pLine & return after tText
   put textEncode(tText, "UTF-8") into URL ("binfile:" & pPath)
end GB.AppendLine

function GB.Inbox pLib, pName
   local tDir
   put GB.Projects() & "/LIB_LLMIN/" & pLib into tDir
   if there is not a folder tDir then create folder tDir
   return tDir & "/" & pName
end GB.Inbox

-- //wsl$/... -> \\wsl$\... for Windows
function GB.Win pPath
   replace "/" with "\" in pPath
   return pPath
end GB.Win

-- the shared script (GL.Info), also used by the Game_Player app
command GB.UseLaunch
   local tFile
   if "GameLaunch" is among the lines of the stacksInUse then exit GB.UseLaunch
   put GB.Projects() & "/LIB_DEV/livecode/game_launch.livecodescript" into tFile
   if there is a file tFile then start using stack tFile
end GB.UseLaunch

-------------------------------------------------------------------- the list

on GB.Refresh
   local tFolder, tWas, tFiles, tLine, tName, tOut, tN
   GB.UseMe
   GB.UseLaunch
   put GB.Projects() & "/" & kGamesRel into tFolder
   put empty into sGames
   put 0 into tN
   if there is a folder tFolder then
      put the defaultFolder into tWas
      set the defaultFolder to tFolder
      put the detailed files into tFiles
      set the defaultFolder to tWas
      sort lines of tFiles ascending by urlDecode(item 1 of each)
      repeat for each line tLine in tFiles
         put urlDecode(item 1 of tLine) into tName
         if not (tName begins with "Vibecode3D_Play_") then next repeat
         if not (tName ends with ".livecodescript") then next repeat
         put char 17 to -16 of tName into tName
         add 1 to tN
         put tName into sGames[tN]["name"]
         put item 5 of tLine into sGames[tN]["modified"]
         put tName & return after tOut
      end repeat
   end if
   delete the last char of tOut
   put tN into sCount
   put tOut into field "Games_List"
   put empty into sCurrent
   put empty into sInfo
   put tN && "games in" && kGamesRel & return & return & \
         "Click a game: its details here." & return & \
         "Double-click or Return: play it on the engine(s) ticked above (none = Vibecode3D)." & return & \
         "Right-click: pick the engine (Vibecode3D or xt3d games bench)." & return & \
         "In the game window: ... (top right) for Pause, Reset, Levels, Quit; Escape pauses." into field "LLMNote"
end GB.Refresh

-------------------------------------------------------------------- one game's details

on GB.Clicked pLine
   local tName, tI, tWhen
   GB.UseMe
   if pLine is empty or pLine < 1 or pLine > sCount then exit GB.Clicked
   if pLine is not sCurrent then
      -- the Feedback field follows the selected game (the owner: it stayed stuck on one item)
      if sCurrent is not empty then put field "Feedback" into sDraft[sGames[sCurrent]["name"]]
      put sDraft[sGames[pLine]["name"]] into field "Feedback"
      put "Feedback" into field "FeedbackLabel"
   end if
   put pLine into sCurrent
   put sGames[pLine]["name"] into tName
   GB.UseLaunch
   put GL.Info(GB.Projects(), tName) into sInfo
   put sGames[pLine]["modified"] into tWhen
   if tWhen is a number then convert tWhen from seconds to short date and short time
   put sInfo into tI
   put tName & "   " & tI["title"] & return & \
         "Last Change: " & tWhen & return & \
         "Genre: " & return & \
         "# Levels: " & GB.LevelWord(tI) & return & \
         "Win State / Lose State / Rewards / Enemies: see RULES" & return & \
         "MouseLook: " & tI["mouselook"] & return & \
         "KEYS:" & return & tI["keys"] & \
         "RULES:" & return & tI["rules"] & \
         "ABOUT:" & return & tI["about"] & return & \
         "Paths:" & return & "  " & GB.Win(GB.GameFile(tName)) into field "LLMNote"
   set the vScroll of field "LLMNote" to 0
end GB.Clicked

function GB.LevelWord pInfo
   if pInfo["levels"] > 0 then return pInfo["levels"] && "(... > Levels in the game window)"
   return "one (no level menu)"
end GB.LevelWord

on GB.RightClicked pLine
   GB.UseMe
   if pLine is empty or pLine < 1 or pLine > sCount then exit GB.RightClicked
   set the hilitedLine of field "Games_List" to pLine
   GB.Clicked pLine
   set the text of button "ReviewMenu" to "Play in Vibecode3D" & return & \
         "Play in xt3d (games bench)" & return & "-" & return & \
         "Open script in Explorer" & return & "Copy script path"
   popup button "ReviewMenu"
end GB.RightClicked

on GB.MenuPicked pItem
   GB.UseMe
   if sCurrent is empty then exit GB.MenuPicked
   switch pItem
      case "Play in Vibecode3D"
         GB.PlayVibe sGames[sCurrent]["name"]
         break
      case "Play in xt3d (games bench)"
         GB.PlayXt3d sGames[sCurrent]["name"]
         break
      case "Open script in Explorer"
         GB.Explore GB.GameFile(sGames[sCurrent]["name"])
         break
      case "Copy script path"
         set the clipboardData["text"] to GB.Win(GB.GameFile(sGames[sCurrent]["name"]))
         break
   end switch
end GB.MenuPicked

-- double-click, Return: the engines ticked at the top (Vibecode3d, xt3d; both = both;
-- none = Vibecode3D)
on GB.PlayCurrent
   local tVibe, tXt
   GB.UseMe
   get the hilitedLine of field "Games_List"
   if it is a number and it is not sCurrent then GB.Clicked it
   if sCurrent is empty then exit GB.PlayCurrent
   put (there is a button "VibeCheck" and the hilite of button "VibeCheck") into tVibe
   put (there is a button "xt3dCheck" and the hilite of button "xt3dCheck") into tXt
   if tVibe or not tXt then GB.PlayVibe sGames[sCurrent]["name"]
   if tXt then GB.PlayXt3d sGames[sCurrent]["name"]
end GB.PlayCurrent

on GB.Explore pPath
   if the platform is not "Win32" then exit GB.Explore
   set the hideConsoleWindows to true
   get shell("explorer.exe /select," & quote & GB.Win(pPath) & quote)
end GB.Explore

-------------------------------------------------------------------- Vibecode3D: its own program

-- Game_Player.exe <Game> (LIB_DEV/livecode/launcher_game_player.livecodescript, built once
-- as a standalone); the name also goes in a request file in case the command line loses it
on GB.PlayVibe pName
   local tExe
   GB.UseMe
   put GB.PlayerExe() into tExe
   if tExe is empty then
      GB.Say "The Game_Player app is not built yet (once only, see LIB_DEV/README.md):" & return & \
            "open LIB_DEV/Game_Player_Launcher.livecode, File > Save as Standalone Application," & return & \
            "into LIB_DEV/Game_Player. Then pick the game again."
      exit GB.PlayVibe
   end if
   put textEncode(pName, "UTF-8") into URL ("binfile:" & specialFolderPath("temporary") & "/game_player_request.txt")
   -- Windows' start: a new program every time (LiveCode's launch refuses a second copy of an
   -- app it started), and the browser does not wait for it
   if the platform is not "Win32" then
      GB.Say "Game_Player runs on Windows only."
      exit GB.PlayVibe
   end if
   GB.Start tExe, pName
   GB.Say "Starting" && pName && "in its own Game_Player window."
end GB.PlayVibe

-- start a program without waiting for it; the folder is a local one (cmd can't start in \\wsl$)
command GB.Start pExe, pArg
   local tWas, tCmd
   put the defaultFolder into tWas
   set the defaultFolder to specialFolderPath("temporary")
   put "start " & quote & quote & " " & quote & GB.Win(pExe) & quote into tCmd
   if pArg is not empty then put " " & quote & pArg & quote after tCmd
   set the hideConsoleWindows to true
   get shell(tCmd)
   set the defaultFolder to tWas
end GB.Start

-- Game_Player.exe as LiveCode builds it, in LIB_DEV/Game_Player (or the inbox)
function GB.PlayerExe
   local tRoot, tTry
   put GB.Projects() into tRoot
   repeat for each item tTry in "LIB_DEV/Game_Player,LIB_DEV/Game_Player/Game_Player,LIB_DEV/Game_Player/Windows x86-64,LIB_LLMIN/LIB_DEV/Game_Player"
      if there is a file (tRoot & "/" & tTry & "/Game_Player.exe") then return tRoot & "/" & tTry & "/Game_Player.exe"
   end repeat
   return empty
end GB.PlayerExe

-------------------------------------------------------------------- xt3d: the games bench

on GB.PlayXt3d pName
   local tExe, tCode, tReply
   GB.UseMe
   if not GB.BenchAlive() then
      put GB.Projects() & "/" & kBenchRel into tExe
      if there is not a file tExe then
         GB.Say "No xt3d games bench at" && GB.Win(tExe) & return & "(build it: xt3D_Raylib_Livecode_Bridge/standalone/README.md)"
         exit GB.PlayXt3d
      end if
      GB.Say "Starting the xt3d games bench..."
      GB.Start tExe, empty
      repeat 60 times
         wait 500 milliseconds with messages
         if GB.BenchAlive() then exit repeat
      end repeat
      if not GB.BenchAlive() then
         GB.Say "The xt3d games bench did not answer on port" && kBenchPort & "."
         exit GB.PlayXt3d
      end if
      wait 4 seconds with messages            -- it opens its window and raylib after the server
   end if
   put "xbListGames" & return & "xbPlayGame" && quote & pName & quote into tCode
   put GB.Bench("POST", "/run", tCode) into tReply
   GB.Say "xt3d games bench:" && pName && tReply
end GB.PlayXt3d

function GB.BenchToken
   return line 1 of GB.ReadText("C:/LIB_MCP/devtoken_" & kBenchPort & ".txt")
end GB.BenchToken

function GB.BenchAlive
   if GB.BenchToken() is empty then return false
   return GB.Bench("GET", "/ping", empty) begins with "OK"
end GB.BenchAlive

-- through Windows' curl.exe (as LIB_MCP's lcmcp does), with a time limit: never hangs the browser
function GB.Bench pMethod, pRoute, pBody
   local tUrl, tCmd, tBody, tOut
   if the platform is not "Win32" then return "not on Windows"
   put "http://127.0.0.1:" & kBenchPort & pRoute into tUrl
   put "curl.exe -sS -m 15 -H " & quote & "X-Token: " & GB.BenchToken() & quote into tCmd
   if pMethod is "POST" then
      put specialFolderPath("temporary") & "/game_browser_post.txt" into tBody
      put textEncode(pBody, "UTF-8") into URL ("binfile:" & tBody)
      put " -X POST -H " & quote & "Expect:" & quote & " -H " & quote & "Content-Type: text/plain; charset=utf-8" & quote & \
            " --data-binary " & quote & "@" & GB.Win(tBody) & quote after tCmd
   end if
   put " " & tUrl after tCmd
   set the hideConsoleWindows to true
   put shell(tCmd) into tOut
   return textDecode(tOut, "UTF-8")
end GB.Bench

-------------------------------------------------------------------- feedback

-- a message at the top of the details panel
command GB.Say pText
   GB.UseMe
   put pText & return & "------" & return before field "LLMNote"
   set the vScroll of field "LLMNote" to 0
end GB.Say

-- your note about the selected game goes to the game notes inbox, marked BROWSER
on GB.Submit
   local tText, tGame
   GB.UseMe
   put field "Feedback" into tText
   if tText is empty then exit GB.Submit
   put field "Feedback" into sLastSent
   replace return with " / " in tText
   replace "|" with "/" in tText
   if sCurrent is empty then
      put "(general)" into tGame
   else
      put sGames[sCurrent]["name"] into tGame
   end if
   GB.AppendLine GB.Inbox("LIB_GAMES", "GAME_NOTES.txt"), the short date && the long time && "|" && tGame && "| BROWSER |" && tText
   put "Saved" && the short time into field "FeedbackLabel"
end GB.Submit

on GB.TellClaude
   local tText
   GB.UseMe
   put field "Feedback" into tText
   if tText is not empty and tText is not sLastSent then GB.Submit
   GB.AppendLine GB.Inbox("LIB_DEV", "TELL_CLAUDE.txt"), the short date && the long time & tab & "tell" & tab & "GAME_Browser: game notes"
   put "Told Claude" && the short time into field "FeedbackLabel"
end GB.TellClaude

-- tests: one line
function GB.State
   return sCount & " games|current " & sCurrent & "|" & sInfo["prefix"] & "|" & sInfo["levels"]
end GB.State
