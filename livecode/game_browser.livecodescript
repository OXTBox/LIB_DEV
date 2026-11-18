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
constant kBenchPort = 8770     -- LIB_PORTS/ports.tsv: xt3d-bench-mcp
constant kPingMs = 1500        -- is the bench there? (LIB_PORTS rule 3: a health check waits at most 2 s)
constant kRunMs = 15000        -- a request to the bench

local sGames, sCount, sCurrent, sLastSent, sInfo
local sHttp    -- [socket] ["state"] empty / done / error, ["data"]: GB.Http's requests in flight
local sBusy    -- what the browser is waiting for (one bench request at a time)
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
   set the cursor to busy
   open process ("explorer.exe /select," & quote & GB.Win(pPath) & quote) for neither
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
            "open LIB_DEV/livecode/Game_Player_Launcher.livecode, File > Save as Standalone Application," & return & \
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
   if the result is "process is already open" then
      GB.Say pName && "is already open in a Game_Player window."
   else if the result is not empty then
      GB.Say "Game_Player did not start:" && the result
   else
      GB.Say "Starting" && pName && "in its own Game_Player window."
   end if
end GB.PlayVibe

-- start a program without waiting for it. No shell: on 18 Nov every shell() took 20-50 s to start
-- (antivirus scanning cmd.exe), so "start" froze the browser; open process took 15 ms.
-- LiveCode refuses the same command line twice while it runs: the result is "process is already open".
command GB.Start pExe, pArg
   local tCmd
   set the cursor to busy
   put quote & GB.Win(pExe) & quote into tCmd
   if pArg is not empty then put " " & quote & pArg & quote after tCmd
   open process tCmd for neither
   return the result
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
   local tExe, tCode, tReply, tStart
   GB.UseMe
   if sBusy is not empty then
      GB.Say "Still waiting for the bench (" & sBusy & "); try again in a moment."
      exit GB.PlayXt3d
   end if
   put "checking the xt3d games bench" into sBusy
   GB.Say "Checking the xt3d games bench..."
   if not GB.BenchAlive() then
      put GB.Projects() & "/" & kBenchRel into tExe
      if there is not a file tExe then
         put empty into sBusy
         GB.Say "No xt3d games bench at" && GB.Win(tExe) & return & "(build it: xt3D_Raylib_Livecode_Bridge/standalone/README.md)"
         exit GB.PlayXt3d
      end if
      put "starting the xt3d games bench" into sBusy
      GB.Say "Starting the xt3d games bench..."
      GB.Start tExe, empty
      put the milliseconds into tStart
      repeat until GB.BenchAlive() or the milliseconds - tStart > 30000
         set the cursor to busy
         wait 500 milliseconds with messages
      end repeat
      if not GB.BenchAlive() then
         put empty into sBusy
         GB.Say "The xt3d games bench did not answer on port" && kBenchPort && "within 30 seconds."
         exit GB.PlayXt3d
      end if
      wait 4 seconds with messages            -- it opens its window and raylib after the server
   end if
   put "asking the bench to play" && pName into sBusy
   put "xbListGames" & return & "xbPlayGame" && quote & pName & quote into tCode
   put GB.Bench("POST", "/run", tCode, kRunMs) into tReply
   put empty into sBusy
   GB.Say "xt3d games bench:" && pName && tReply
end GB.PlayXt3d

function GB.BenchToken
   set the cursor to busy
   return line 1 of GB.ReadText("C:/LIB_MCP/devtoken_" & kBenchPort & ".txt")
end GB.BenchToken

function GB.BenchAlive
   if GB.BenchToken() is empty then return false
   return GB.Bench("GET", "/ping", empty, kPingMs) begins with "OK"
end GB.BenchAlive

function GB.Bench pMethod, pRoute, pBody, pTimeoutMs
   return GB.Http(pMethod, kBenchPort, pRoute, pBody, GB.BenchToken(), pTimeoutMs)
end GB.Bench

-------------------------------------------------------------------- HTTP without curl

-- one request to 127.0.0.1:pPort over a socket of our own. No shell (curl.exe could take 50 s
-- just to start), and the window keeps working while it waits: the busy cursor turns, clicks and
-- keys are handled. Returns the body, or "(no answer in N ms)" / "(error: ...)".
function GB.Http pMethod, pPort, pRoute, pBody, pToken, pTimeoutMs
   local tSock, tReq, tBytes, tStart, tState, tData, tAt
   put "127.0.0.1:" & pPort & "|gb" & the milliseconds into tSock
   put textEncode(pBody, "UTF-8") into tBytes
   put pMethod && pRoute && "HTTP/1.1" & crlf & "Host: 127.0.0.1:" & pPort & crlf & \
         "X-Token: " & pToken & crlf & "Connection: close" & crlf into tReq
   if pMethod is "POST" then
      put "Content-Type: text/plain; charset=utf-8" & crlf & \
            "Content-Length: " & the number of bytes of tBytes & crlf after tReq
   end if
   put crlf after tReq
   put empty into sHttp[tSock]["state"]
   put empty into sHttp[tSock]["data"]
   put textEncode(tReq, "UTF-8") & tBytes into sHttp[tSock]["send"]
   put the milliseconds into tStart
   set the cursor to busy
   open socket to tSock with message "GB.HttpOpen"
   if the result is not empty then
      delete variable sHttp[tSock]
      return "(error:" && the result & ")"
   end if
   repeat until sHttp[tSock]["state"] is not empty or the milliseconds - tStart > pTimeoutMs
      set the cursor to busy
      wait 20 milliseconds with messages
   end repeat
   put sHttp[tSock]["state"] into tState
   put sHttp[tSock]["data"] into tData
   if tState is empty then
      -- still connecting: closing it now lets its late error land on the next socket (18 Nov,
      -- error 10038 on the request after a timeout). It is closed when it answers or fails.
      put "abandoned" into sHttp[tSock]["state"]
      return "(no answer in" && pTimeoutMs && "ms)"
   end if
   delete variable sHttp[tSock]
   close socket tSock
   if tState begins with "error" then return "(" & tState & ")"
   put offset(crlf & crlf, tData) into tAt
   if tAt > 0 then delete char 1 to tAt + 3 of tData
   return textDecode(tData, "UTF-8")
end GB.Http

on GB.HttpOpen pSock
   if pSock is not among the lines of the keys of sHttp then exit GB.HttpOpen
   if sHttp[pSock]["state"] is "abandoned" then
      delete variable sHttp[pSock]
      close socket pSock
      exit GB.HttpOpen
   end if
   write sHttp[pSock]["send"] to socket pSock
   read from socket pSock with message "GB.HttpRead"
end GB.HttpOpen

on GB.HttpRead pSock, pData
   if pSock is not among the lines of the keys of sHttp then exit GB.HttpRead
   if sHttp[pSock]["state"] is "abandoned" then exit GB.HttpRead
   put pData after sHttp[pSock]["data"]
   if GB.HttpComplete(sHttp[pSock]["data"]) then
      put "done" into sHttp[pSock]["state"]
   else
      read from socket pSock with message "GB.HttpRead"
   end if
end GB.HttpRead

-- the whole reply is in: the head, and as many body bytes as its Content-Length
function GB.HttpComplete pData
   local tAt, tHead, tLen, tLine
   put offset(crlf & crlf, pData) into tAt
   if tAt is 0 then return false
   put char 1 to tAt of pData into tHead
   replace numToChar(13) with empty in tHead
   put empty into tLen
   repeat for each line tLine in tHead
      if tLine begins with "Content-Length:" then put word 2 of tLine into tLen
   end repeat
   if tLen is not an integer then return false      -- no length: wait for the server to close
   return the number of bytes of pData - (tAt + 3) >= tLen
end GB.HttpComplete

on socketClosed pSock
   if pSock is among the lines of the keys of sHttp then
      if sHttp[pSock]["state"] is "abandoned" then
         delete variable sHttp[pSock]
      else
         put "done" into sHttp[pSock]["state"]
      end if
   else
      pass socketClosed
   end if
end socketClosed

on socketError pSock, pErr
   if pSock is among the lines of the keys of sHttp then
      if sHttp[pSock]["state"] is "abandoned" then
         delete variable sHttp[pSock]
      else
         put "error:" && pErr into sHttp[pSock]["state"]
      end if
   else
      pass socketError
   end if
end socketError

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
