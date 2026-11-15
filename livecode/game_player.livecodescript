######################################################################################
## STACK SCRIPT: "GamePlayer"  (LIB_DEV, 11 14 2026)
## One game in its own window, made by the Game_Player app (GameLaunch GL.Open), which the
## GAME_Browser starts as its own program for each game. Each window is a new
## stack "Play <Game>" whose card is "Play.<Game>" holding the game's card script, exactly as
## on a Vibecode3D Play card. The engine is the Vibecode3D engine as a library
## (xt3D_Raylib_Livecode_Bridge/testbench/vibe_engine_xt3d.livecodescript: the owner's whole
## engine with its drawing handed to the host); this script owns the timer and draws the
## frame with LiveCode line graphics, one graphic per colour.
##
## In the window
##   ... (top right)   Pause / Resume, Reset, Levels > 1..n, Quit
##   Escape            pause / resume (the engine never closes the window)
##   ` or F2           game notes (LIB_GAMES/tools/GameNotes), as in Vibecode3D
## Status and message lines are made when first needed (Player.Status, Player.Message),
## never left on the card as fixed objects.
## One game per Game_Player app (the engine keeps its state in globals); closing the window
## quits that app.
## Custom properties set by GL.Open: uGame (name), uScriptFile, uPrefix (for
## <Prefix>.StartLevel), uLevels (count, 0 = no level menu), uQuitOnClose.
######################################################################################

global gSceneObjects, bPaused, bPlaying

constant kTickMS = 33          -- draw once per engine step (the game only changes every 33 ms)
constant kPausedMS = 100       -- paused: no drawing, just look for the resume ten times a second
constant kMenuH = 22

local sTickMsg, sRunning, sGfx, sGfxCount, sBG, sFrames, sFPSTick, sFPS, sMsgEnd, sEnded
local sLevel

-------------------------------------------------------------------- start / stop

-- the engine library is in every message path and its preOpenStack starts the whole
-- Vibecode3D app (APP.init, a first game.update before Game.OnStart): stop it here
on preOpenStack
end preOpenStack

on Player.Start
   local tErr
   Player.StopTimer
   Player.UseMe
   put empty into sEnded
   try
      Vibe.Begin Player.ViewRect()
      dispatch "Game.OnStart" to card 1 of me
      Vibe.Go
   catch tErr
      Player.Failed tErr, "starting"
      exit Player.Start
   end try
   put 1 into sLevel
   put true into sRunning
   put 0 into sFrames
   put the milliseconds into sFPSTick
   Player.BuildMenu
   Player.Message the uGame of me, 1500
   Player.Tick
end Player.Start

on Player.Reset
   Player.Start
end Player.Reset

-- a level from the ... menu: restart the game, then the game's own <Prefix>.StartLevel n
on Player.GoLevel pLevel
   local tErr
   Player.Start
   if the uPrefix of me is empty then exit Player.GoLevel
   try
      dispatch (the uPrefix of me & ".StartLevel") to card 1 of me with pLevel
   catch tErr
      Player.Failed tErr, "going to level" && pLevel
      exit Player.GoLevel
   end try
   put pLevel into sLevel
   Player.Message "LEVEL" && pLevel, 1500
end Player.GoLevel

on Player.TogglePause
   if sRunning is not true then exit Player.TogglePause
   Player.UseMe
   if bPaused is true then
      put false into bPaused
      dispatch "Game.OnResume" to card 1 of me
      Player.Message empty
   else
      put true into bPaused
      dispatch "Game.OnPause" to card 1 of me
      Player.Message "PAUSED   (Escape to go on,  ... for Reset / Levels / Quit)", 0
   end if
   Player.BuildMenu
end Player.TogglePause

on Player.Quit
   close me
end Player.Quit

on closeStack
   local tErr
   Player.StopTimer
   if sRunning is true then
      put false into sRunning
      Player.UseMe
      try
         if Vibe.Playing() then Game.Exit
      catch tErr
      end try
   end if
   -- the Game_Player app: this window was its only job, so end the program now (a message
   -- sent to this window would never arrive: destroyStack removes it as it closes)
   if the uQuitOnClose of me is true and the environment is "standalone application" then quit
   pass closeStack
end closeStack

-- LIB_ALPHA 12b: closing frees the window (and, in the Game_Player app, ends it)
on closeStackRequest
   set the destroyStack of me to true
   pass closeStackRequest
end closeStackRequest

command Player.StopTimer
   if sTickMsg is not empty then cancel sTickMsg
   put empty into sTickMsg
end Player.StopTimer

-- the engine sends to "this card": make this window the default stack while it works
command Player.UseMe
   set the defaultStack to the short name of me
end Player.UseMe

function Player.ViewRect
   return 0, 0, the width of me, the height of me
end Player.ViewRect

-------------------------------------------------------------------- the loop

on Player.Tick
   local tErr, tWas, tWait
   put empty into sTickMsg
   if sRunning is not true then exit Player.Tick
   put kTickMS into tWait
   if bPaused is true then
      -- paused (Escape, the ... menu, or the notes box): the picture does not change, so
      -- nothing is stepped or drawn; the window costs next to no CPU
      put kPausedMS into tWait
   else
      put the defaultStack into tWas
      Player.UseMe
      try
         Vibe.Step
         if Vibe.Playing() then
            Player.Draw
         else
            Player.Ended
         end if
      catch tErr
         Player.Failed tErr, "playing"
      end try
      if tWas is not empty and there is a stack tWas then set the defaultStack to tWas
      add 1 to sFrames
   end if
   if sRunning is true then
      send "Player.Tick" to me in tWait milliseconds
      put the result into sTickMsg
   end if
   if the milliseconds - sFPSTick >= 1000 then
      put round(sFrames * 1000 / (the milliseconds - sFPSTick)) into sFPS
      put 0 into sFrames
      put the milliseconds into sFPSTick
      if bPaused is not true then Player.Status the uGame of me && "|" && sFPS && "fps" & Player.LevelText()
   end if
   if sMsgEnd > 0 and the milliseconds > sMsgEnd then Player.Message empty
end Player.Tick

function Player.LevelText
   if the uLevels of me > 0 then return " | level" && sLevel
   return empty
end Player.LevelText

-- the game stopped itself (Game.Exit, game over that exits): keep the window, offer a restart
command Player.Ended
   if sEnded is true then exit Player.Ended
   put true into sEnded
   put false into sRunning
   Player.Message "GAME OVER   (... > Reset to play again)", 0
end Player.Ended

command Player.Failed pErr, pWhen
   local tText
   put false into sRunning
   Player.StopTimer
   set the uLastError of me to pErr
   put "STOPPED: an error while" && pWhen && "(line" && item 2 of line 1 of pErr & ")." && \
         "... > Reset to try again" into tText
   Player.Message tText, 0
   Player.LogError pErr, pWhen
end Player.Failed

-- the full error for the AI: LIB_LLMIN/LIB_DEV/GAME_PLAYER_ERRORS.txt
command Player.LogError pErr, pWhen
   local tFile, tText, tLine, tErr
   try
      put GL.Projects() & "/LIB_LLMIN/LIB_DEV/GAME_PLAYER_ERRORS.txt" into tFile
      put the short date && the long time & tab & the uGame of me & tab & pWhen & tab into tLine
      replace return with " / " in pErr
      put pErr after tLine
      if there is a file tFile then put textDecode(URL ("binfile:" & tFile), "UTF-8") into tText
      put tLine & return after tText
      put textEncode(tText, "UTF-8") into URL ("binfile:" & tFile)
   catch tErr
   end try
end Player.LogError

-------------------------------------------------------------------- drawing

-- every scene object's edges, then the particles, weapon lines and HUD, batched by colour
command Player.Draw
   local tBuf, tLine, tKey, tG, tCol, tOut, tName, tUsed, i
   Render.BeginFrame
   set the itemDel to comma
   repeat for each line tLine in gSceneObjects
      put word 2 of tLine into tKey
      put word 3 of tLine into tG
      if tG is empty then put tKey into tG
      put item 1 to 3 of Vibe.Color(tG) into tCol
      RenderMeshInto word 1 of tLine, tKey, tCol, tBuf, true
   end repeat
   put empty into tOut
   Particles.Render tOut
   Weapon.Render tOut
   HUD.Render tOut
   repeat for each key tName in tOut
      if tOut[tName] is empty then next repeat
      put item 1 to 3 of Vibe.Color(tName) into tCol
      put tOut[tName] after tBuf[tCol]
   end repeat
   if sFrames mod 30 is 0 then Player.Background
   lock screen
   put 0 into tUsed
   repeat for each key tCol in tBuf
      add 1 to tUsed
      put Player.Graphic(tUsed) into tG
      if the foregroundColor of graphic tG is not tCol then set the foregroundColor of graphic tG to tCol
      set the points of graphic tG to tBuf[tCol]
   end repeat
   repeat with i = tUsed + 1 to sGfxCount
      if the points of graphic ("VB_" & i) is not empty then set the points of graphic ("VB_" & i) to empty
   end repeat
   unlock screen
end Player.Draw

-- graphic n of the pool (made once, reused every frame)
function Player.Graphic pN
   local tName
   put "VB_" & pN into tName
   if there is not a graphic tName then
      lock messages
      reset the templateGraphic
      create graphic tName
      set the style of graphic tName to "line"
      set the lineSize of graphic tName to 1
      set the opaque of graphic tName to false
      set the traversalOn of graphic tName to false
      set the rect of graphic tName to Player.ViewRect()
      set the layer of graphic tName to 1
      unlock messages
      put max(sGfxCount, pN) into sGfxCount
   end if
   return tName
end Player.Graphic

command Player.Background
   local tF
   put Vibe.Frame() into tF
   if tF["background"] is not sBG then
      put tF["background"] into sBG
      set the backgroundColor of me to sBG
   end if
end Player.Background

-------------------------------------------------------------------- status and message lines
-- made when first needed, removed when not

-- bottom-left status line (game, fps, level); empty removes it
command Player.Status pText
   if pText is empty then
      if there is a field "PlayerStatus" of me then delete field "PlayerStatus" of me
      exit Player.Status
   end if
   if there is not a field "PlayerStatus" of me then
      Player.MakeLabel "PlayerStatus", 10, the height of me - 22, 420, 18, "65,200,120"
   end if
   put pText into field "PlayerStatus" of me
end Player.Status

-- a centred message; pMS 0 = until replaced, empty pText removes it
command Player.Message pText, pMS
   if pText is empty then
      put 0 into sMsgEnd
      if there is a field "PlayerMessage" of me then delete field "PlayerMessage" of me
      exit Player.Message
   end if
   if there is not a field "PlayerMessage" of me then
      Player.MakeLabel "PlayerMessage", 20, the height of me div 2 - 16, the width of me - 40, 30, "255,255,140"
      set the textAlign of field "PlayerMessage" of me to "center"
      set the textSize of field "PlayerMessage" of me to 16
   end if
   put pText into field "PlayerMessage" of me
   if pMS > 0 then
      put the milliseconds + pMS into sMsgEnd
   else
      put 0 into sMsgEnd
   end if
end Player.Message

command Player.MakeLabel pName, pL, pT, pW, pH, pColor
   lock messages
   reset the templateField
   create field pName in card 1 of me
   set the rect of field pName of me to pL, pT, pL + pW, pT + pH
   set the opaque of field pName of me to false
   set the showBorder of field pName of me to false
   set the lockText of field pName of me to true
   set the traversalOn of field pName of me to false
   set the dontWrap of field pName of me to true
   set the textFont of field pName of me to "Courier New"
   set the textSize of field pName of me to 12
   set the foregroundColor of field pName of me to pColor
   unlock messages
end Player.MakeLabel

-------------------------------------------------------------------- the ... menu

command Player.BuildMenu
   local tText, i
   if there is not a button "PlayerMenu" of me then
      lock messages
      reset the templateButton
      create button "PlayerMenu" in card 1 of me
      set the style of button "PlayerMenu" of me to "menu"
      set the menuMode of button "PlayerMenu" of me to "pulldown"
      set the label of button "PlayerMenu" of me to "..."
      set the showBorder of button "PlayerMenu" of me to false
      set the opaque of button "PlayerMenu" of me to false
      set the traversalOn of button "PlayerMenu" of me to false
      set the textSize of button "PlayerMenu" of me to 16
      set the textStyle of button "PlayerMenu" of me to "bold"
      set the foregroundColor of button "PlayerMenu" of me to "200,200,200"
      set the rect of button "PlayerMenu" of me to the width of me - 44, 2, the width of me - 4, 2 + kMenuH
      set the script of button "PlayerMenu" of me to "on menuPick pItem" & return & "  Player.MenuPick pItem" & return & "end menuPick"
      unlock messages
   end if
   if bPaused is true and sRunning is true then
      put "Resume" into tText
   else
      put "Pause" into tText
   end if
   put return & "Reset" after tText
   if the uLevels of me > 0 then
      put return & "Levels" after tText
      repeat with i = 1 to the uLevels of me
         put return & tab & "Level" && i after tText
      end repeat
   end if
   put return & "-" & return & "Quit" after tText
   set the text of button "PlayerMenu" of me to tText
end Player.BuildMenu

on Player.MenuPick pItem
   set the itemDel to "|"
   switch item 1 of pItem
      case "Pause"
      case "Resume"
         Player.TogglePause
         break
      case "Reset"
         Player.Reset
         break
      case "Levels"
         Player.GoLevel word 2 of item 2 of pItem
         break
      case "Quit"
         Player.Quit
         break
   end switch
end Player.MenuPick

-------------------------------------------------------------------- input

-- Escape pauses and resumes here; it never reaches the engine (which would stop the game).
-- GameNotes (a front script) sees keys first, so ` and F2 still open the note box.
on rawKeyDown pKey
   if pKey is 65307 then
      Player.TogglePause
      exit rawKeyDown
   end if
   pass rawKeyDown
end rawKeyDown

on escapeKey
end escapeKey

on mouseUp pButton
   if the short name of the target is "PlayerMenu" then pass mouseUp
   if sRunning is not true or bPaused is true then exit mouseUp
   Player.UseMe
   dispatch "Game.OnClick" to card 1 of me with the mouseH, the mouseV, pButton
end mouseUp
