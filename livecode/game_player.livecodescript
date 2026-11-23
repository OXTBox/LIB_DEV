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
##   ... (top right)   Pause / Resume, Reset, Levels > 1..n, Controls... (a game with an
##                     actions file: LIB_INPUT), Quit
##   Escape            pause / resume (the engine never closes the window)
##   ` or F2           game notes (LIB_GAMES/tools/GameNotes), as in Vibecode3D
##   F4 or ... > Console   the console (22 Nov 2026, LIB_ig3d lib_console, as in iGame3D XT and the
##                     xt3d bench): lower left, typing fills in engine names, Tab = a menu of what fits,
##                     Return runs the line in this window, Up/Down the lines before. While the line has
##                     the keyboard the game waits; Escape or a click on the game gives the keys back.
##   Tab               the console's only while its line has the keyboard (or no game plays): a game
##                     that plays keeps Tab (ISSUES 0015)
## The loading screen (LIB_LOADING_SCREEN lib_loading, 22 Nov 2026): the first level, Reset and the
## Levels menu go through it (burn, green text, reveal); a game that calls Loading.Go does too.
## While it is up the game is not stepped (no Game.OnUpdate); it is still drawn. No library: as before.
## Status and message lines are made when first needed (Player.Status, Player.Message),
## never left on the card as fixed objects.
## One game per Game_Player app (the engine keeps its state in globals); closing the window
## quits that app.
## Custom properties set by GL.Open: uGame (name), uScriptFile, uPrefix (for
## <Prefix>.StartLevel), uLevels (count, 0 = no level menu), uQuitOnClose.
######################################################################################

global gSceneObjects, bPaused, bPlaying, bStill, gV3DTickMS   -- gV3DTickMS: a game's own frame time (ms), else kTickMS

constant kTickMS = 33          -- draw once per engine step (the game only changes every 33 ms)
constant kPausedMS = 100       -- paused: no drawing, just look for the resume ten times a second
constant kStillMS = 50         -- still (bStill, set by the game): no step, no drawing until a key or the mouse
constant kMenuH = 22

local sAway        -- true while the program is in the background and this player paused it
local sMovingFPS   -- the frame rate the last time it moved (shown while at rest)
local sTickMsg, sRunning, sGfx, sGfxCount, sBG, sFrames, sFPSTick, sFPS, sMsgEnd, sEnded
local sLevel
local sInput      -- true when the game has an actions file and LIB_INPUT read it (Player.LoadInput)
local sConLoaded  -- true once lib_console was looked for (Player.ConsoleLoad); sConWhy: why there is none
local sConWhy
local sLoad       -- true when lib_loading is in use (Player.LoadLoading)

-------------------------------------------------------------------- start / stop

-- the engine library is in every message path and its preOpenStack starts the whole
-- Vibecode3D app (APP.init, a first game.update before Game.OnStart): stop it here
on preOpenStack
end preOpenStack

-- pNoScreen true: the caller puts up the loading screen itself (Player.GoLevel)
on Player.Start pNoScreen
   local tErr
   Player.StopTimer
   Player.UseMe
   put false into bStill
   put empty into sEnded
   Player.LoadInput
   Player.LoadLoading
   if sLoad then
      -- a game still open (Reset): its last level goes into the play record as left
      Loading.Host the long id of card 1 of me, the uPrefix of me, Player.ViewRect(), the uGame of me
      if pNoScreen is not true then Loading.Begin 1, "start", false
   end if
   -- the engine contract: Engine.Info("edition") and Engine.Has() answer from these
   global gV3DEdition, gV3DHas
   put "XT" into gV3DEdition
   put empty into gV3DHas
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
-- (with the loading screen: the picture is taken first, the level is built behind the screen)
on Player.GoLevel pLevel
   local tErr
   if sLoad and the uPrefix of me is not empty then
      Loading.Begin pLevel, "level", true
      Player.Start true
      exit Player.GoLevel
   end if
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

-- end the game but keep the window (LIB_HOWTO: picking another step must not make the
-- window vanish); pText is shown in it. Player.Start plays the card script again.
command Player.Halt pText
   local tErr
   Player.StopTimer
   Player.LoadingEnd "quit"
   if sRunning is true then
      put false into sRunning
      Player.UseMe
      try
         if Vibe.Playing() then Game.Exit
      catch tErr
      end try
   end if
   put true into sEnded
   Player.Message pText, 0
end Player.Halt

on closeStack
   local tErr
   Player.StopTimer
   Player.LoadingEnd "quit"
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
   local tErr, tWas, tWait, tTickStart, tWasLoading
   put the milliseconds into tTickStart
   put empty into sTickMsg
   if sRunning is not true then exit Player.Tick
   put kTickMS into tWait
   if gV3DTickMS is a number and gV3DTickMS >= 8 and gV3DTickMS <= 200 then put gV3DTickMS into tWait
   if bPaused is true then
      -- paused (Escape, the ... menu, or the notes box): the picture does not change, so
      -- nothing is stepped or drawn; the window costs next to no CPU
      put kPausedMS into tWait
   else if bStill is true and the keysDown is empty and the mouse is up then
      -- still: the game said nothing moves (an editor at rest), so the picture stays as it is
      -- until a key or the mouse is pressed, or the game puts false into bStill
      put kStillMS into tWait
   else
      put false into bStill
      put the defaultStack into tWas
      Player.UseMe
      try
         -- while the console line has the keyboard the game waits (games read the keysDown
         -- themselves, they would see the typing); it is still drawn, so a line's change shows
         -- the loading screen: stepped every frame; while it is up the game waits (still drawn)
         if sLoad then
            put Loading.Busy() into tWasLoading
            Loading.Tick
            -- the screen just went: a fresh clock, or the engine would catch up the seconds it
            -- waited (up to 8 game steps in one frame)
            if tWasLoading and not Loading.Busy() then Vibe.Go
         end if
         if not Player.ConsoleTyping() and not Player.Loading() then
            if sInput is true then Input.Poll
            Vibe.Step
         end if
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
      -- the next frame is due one step after this one STARTED: the time spent stepping and drawing
      -- comes off the wait (it used to come on top, so a frame of 15 ms gave 21 fps, not 30)
      put max(1, tWait - (the milliseconds - tTickStart)) into tWait
   end if
   if sRunning is true then
      send "Player.Tick" to me in tWait milliseconds
      put the result into sTickMsg
   end if
   if the milliseconds - sFPSTick >= 1000 then
      put round(sFrames * 1000 / (the milliseconds - sFPSTick)) into sFPS
      put 0 into sFrames
      put the milliseconds into sFPSTick
      if bPaused is not true and bStill is true then
         Player.Status the uGame of me && "| at rest: 0 fps (nothing moves, nothing drawn; moving it was" && sMovingFPS && "fps)" & Player.LevelText()
      else if bPaused is not true then
         if sFPS > 0 then put sFPS into sMovingFPS
         Player.Status the uGame of me && "|" && sFPS && "fps" & Player.LevelText()
      end if
   end if
   if sMsgEnd > 0 and the milliseconds > sMsgEnd then Player.Message empty
end Player.Tick

function Player.LevelText
   if sLoad and Loading.Level() is a number then put Loading.Level() into sLevel
   if the uLevels of me > 0 then return " | level" && sLevel
   return empty
end Player.LevelText

-- true while the loading screen is up
function Player.Loading
   if sLoad then return Loading.Busy()
   return false
end Player.Loading

-- the game ended or the window goes: one line in the play record, the screen down
command Player.LoadingEnd pEvent
   local tErr
   if not sLoad then exit Player.LoadingEnd
   try
      Loading.Record pEvent
      Loading.Stop
   catch tErr
   end try
end Player.LoadingEnd

-- LIB_LOADING_SCREEN beside the game (looked for upward from its script, like LIB_INPUT)
command Player.LoadLoading
   local tLib, tErr
   if sLoad is true and "LIB_LOADING" is among the lines of the stacksInUse then exit Player.LoadLoading
   put false into sLoad
   put Player.FindLib("LIB_LOADING_SCREEN/livecode/lib_loading.livecodescript") into tLib
   if tLib is empty then exit Player.LoadLoading
   try
      start using stack tLib
      put true into sLoad
   catch tErr
      put false into sLoad
   end try
end Player.LoadLoading

-- the game stopped itself (Game.Exit, game over that exits): keep the window, offer a restart
command Player.Ended
   if sEnded is true then exit Player.Ended
   put true into sEnded
   put false into sRunning
   Player.LoadingEnd "end"
   Player.Message "GAME OVER   (... > Reset to play again)", 0
end Player.Ended

command Player.Failed pErr, pWhen
   local tText
   put false into sRunning
   Player.StopTimer
   if sLoad then Loading.Stop
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
      Player.MakeLabel "PlayerStatus", 10, Player.StatusTop(), 420, 18, "65,200,120"
   end if
   put pText into field "PlayerStatus" of me
   -- above anything the game made on the card (the editor's panels)
   if the layer of field "PlayerStatus" of me < the number of controls of me then set the layer of field "PlayerStatus" of me to top
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
   if sInput is true then put return & "Controls..." after tText
   put return & "Console" after tText
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
      case "Controls..."
         Player.Controls
         break
      case "Console"
         Player.Console
         break
      case "Quit"
         Player.Quit
         break
   end switch
end Player.MenuPick

-------------------------------------------------------------------- LIB_INPUT (rebindable controls)

-- A game with an actions file beside its script (<script name>.input.txt) gets LIB_INPUT: the
-- player reads the file, polls once a step, and the ... menu offers "Controls...". The game asks
-- Input.Down("jump") instead of key codes. No file, or no LIB_INPUT: everything is as before.
command Player.LoadInput
   local tFile, tLib, tData, tErr
   put false into sInput
   put the uScriptFile of me into tFile
   if tFile is empty then exit Player.LoadInput
   set the itemDelimiter to "."
   put item 1 to -2 of tFile & ".input.txt" into tFile
   if there is no file tFile then exit Player.LoadInput
   put Player.FindLib("LIB_INPUT/livecode/lib_input.livecodescript") into tLib
   if tLib is empty then exit Player.LoadInput
   try
      if "LIB_DATA" is not among the lines of the stacksInUse then
         put Player.FindLib("LIB_DATA/livecode/lib_data.livecodescript") into tData
         if tData is not empty then start using stack tData      -- where the bindings are saved
      end if
      start using stack tLib
      Input.Load the uGame of me, tFile
      put (the result is empty) into sInput
   catch tErr
      put false into sInput
   end try
end Player.LoadInput

-- a library beside the game: looked for in each folder from the game's script upward
function Player.FindLib pRelative
   local tFolder
   put the uScriptFile of me into tFolder
   set the itemDelimiter to "/"
   repeat while the number of items of tFolder > 1
      delete the last item of tFolder
      if there is a file (tFolder & "/" & pRelative) then return tFolder & "/" & pRelative
   end repeat
   return empty
end Player.FindLib

-- the ... menu's "Controls...": the game waits (paused) while its controls are changed
command Player.Controls
   local tErr
   if sInput is not true then exit Player.Controls
   if bPaused is not true and sRunning is true then Player.TogglePause
   try
      Input.ShowSettings
      if the result is not empty then Player.Message the result, 3000
   catch tErr
      Player.Message "Controls: could not open the window", 3000
   end try
end Player.Controls

-------------------------------------------------------------------- input

-- in the background: paused, so keys typed in other programs never reach the game (the engine
-- reads the keyboard itself, the keysDown, which sees every key on the PC) and it costs no CPU;
-- back in front: it goes on, unless it was paused before (Escape)
on suspend
   if sRunning is true and bPaused is not true then
      Player.TogglePause
      put true into sAway
      Player.Message "PAUSED: IN THE BACKGROUND (click here to go on)", 0
   end if
   pass suspend
end suspend

on resume
   if sAway is true then
      put false into sAway
      if bPaused is true then Player.TogglePause
   end if
   pass resume
end resume

-- Escape pauses and resumes here; it never reaches the engine (which would stop the game).
-- GameNotes (a front script) sees keys first, so ` and F2 still open the note box.
on rawKeyDown pKey
   if pKey is 65307 and Player.ConsoleTyping() then
      focus on nothing                    -- Escape in the console line: the keys go back to the game
      exit rawKeyDown
   end if
   if pKey is 65473 then
      Player.Console                      -- F4: the console, shown / hidden
      exit rawKeyDown
   end if
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
   if the short name of the target begins with "PlayerCon" then exit mouseUp   -- the console's own
   if Player.ConsoleTyping() then focus on nothing      -- a click on the game: the keys back to it
   if sRunning is not true or bPaused is true or Player.Loading() then exit mouseUp
   Player.UseMe
   dispatch "Game.OnClick" to card 1 of me with the mouseH, the mouseV, pButton
end mouseUp

-------------------------------------------------------------------- the console (22 Nov 2026)
-- LIB_ig3d's lib_console (the same thinking as iGame3D XT's Window > Console and the xt3d Games
-- bench): F4 or ... > Console shows it in the lower left, the answers above, one line below. Hidden
-- until asked for: the game needs the whole window and its keys. Lines run here (Con.DoHere): the
-- engine's calls and the player's own Player... handlers.

on Player.Console pShow
   local tErr
   if pShow is empty then put not Player.ConsoleShown() into pShow
   if pShow then Player.ConsoleBuild
   if there is not a field "PlayerConIn" of me then exit Player.Console
   lock screen
   set the visible of field "PlayerConOut" of me to pShow
   set the visible of field "PlayerConIn" of me to pShow
   set the visible of button "PlayerConClose" of me to pShow
   Player.PlaceConsole
   unlock screen
   try
      if pShow then
         focus on field "PlayerConIn" of me
         select after char (the number of chars of the text of field "PlayerConIn" of me) of field "PlayerConIn" of me
      else
         focus on nothing
      end if
   catch tErr
   end try
end Player.Console

function Player.ConsoleShown
   if there is not a field "PlayerConIn" of me then return false
   return the visible of field "PlayerConIn" of me
end Player.ConsoleShown

-- true while the console line has the keyboard (the game then waits)
function Player.ConsoleTyping
   local tErr
   if sConLoaded is not true or sConWhy is not empty then return false
   try
      return Con.Typing()
   catch tErr
      return false
   end try
end Player.ConsoleTyping

-- true while a game plays (not paused, not ended): Tab is then the game's
function Player.GamePlays
   return sRunning is true and bPaused is not true
end Player.GamePlays

-- lib_console (lib_suggest and the words beside it), looked for from the game's folder upward
command Player.ConsoleLoad
   local tLib, tErr
   if sConLoaded is true then exit Player.ConsoleLoad
   put true into sConLoaded
   put empty into sConWhy
   if not ("LibConsole" is among the lines of the stacksInUse) then
      put Player.FindLib("LIB_ig3d/livecode/lib_console.livecodescript") into tLib
      if tLib is empty then
         put "No console here: LIB_ig3d/livecode/lib_console.livecodescript is not above this game." into sConWhy
         exit Player.ConsoleLoad
      end if
      try
         start using stack tLib
      catch tErr
         put "No console:" && line 1 of tErr into sConWhy
         exit Player.ConsoleLoad
      end try
   end if
   try
      Con.Load
      if the result is not empty then put "Console:" && the result into sConWhy
   catch tErr
      put "No console:" && line 1 of tErr into sConWhy
   end try
end Player.ConsoleLoad

-- the three controls, coloured on the templates before they are made (house rule)
command Player.ConsoleBuild
   if there is a field "PlayerConIn" of me then exit Player.ConsoleBuild
   Player.ConsoleLoad
   lock messages
   reset the templateField
   set the opaque of the templateField to true
   set the backgroundColor of the templateField to "8,20,12"
   set the foregroundColor of the templateField to "124,255,124"
   set the borderColor of the templateField to "40,90,55"
   set the showBorder of the templateField to true
   set the textFont of the templateField to "Courier New"
   set the textSize of the templateField to 11
   set the visible of the templateField to false
   create field "PlayerConOut" in card 1 of me
   set the lockText of field "PlayerConOut" of me to true
   set the traversalOn of field "PlayerConOut" of me to false
   set the vScrollbar of field "PlayerConOut" of me to true
   set the backgroundColor of the templateField to "10,26,14"
   set the textSize of the templateField to 12
   create field "PlayerConIn" in card 1 of me
   reset the templateField
   reset the templateButton
   set the backgroundColor of the templateButton to "40,90,55"
   set the foregroundColor of the templateButton to "200,255,200"
   set the visible of the templateButton to false
   create button "PlayerConClose" in card 1 of me
   reset the templateButton
   set the label of button "PlayerConClose" of me to "X"
   set the showBorder of button "PlayerConClose" of me to false
   set the opaque of button "PlayerConClose" of me to true
   set the traversalOn of button "PlayerConClose" of me to false
   set the textStyle of button "PlayerConClose" of me to "bold"
   set the textSize of button "PlayerConClose" of me to 11
   set the tooltip of button "PlayerConClose" of me to "Close the console (F4)"
   set the script of button "PlayerConClose" of me to "on mouseUp" & cr & "   Player.Console false" & cr & "end mouseUp"
   unlock messages
   put "Console (F4 hides it). Type Entity. and press Tab; Return runs the line; help lists the groups." & cr & \
         "While you type here the game waits; Escape or a click on the game gives it the keys back." into field "PlayerConOut" of me
   if sConWhy is not empty then
      put cr & sConWhy after field "PlayerConOut" of me
      set the lockText of field "PlayerConIn" of me to true
   else
      Con.Attach the long id of field "PlayerConIn" of me, the long id of field "PlayerConOut" of me, the long id of me
      set the cConHint of field "PlayerConIn" of me to "the engine library is not loaded (open the game from the Game Player)"
   end if
end Player.ConsoleBuild

-- lower left, up to 520 wide; above the game's graphics; the status line goes above it
on Player.PlaceConsole
   local tL, tR, tB, tT
   if not Player.ConsoleShown() then
      if there is a field "PlayerStatus" of me then set the top of field "PlayerStatus" of me to Player.StatusTop()
      exit Player.PlaceConsole
   end if
   put 10 into tL
   put min(tL + 520, the width of me - 60) into tR
   put the height of me - 6 into tB
   put max(kMenuH + 10, tB - 24 - 132) into tT
   set the rect of field "PlayerConOut" of me to tL, tT, tR, tB - 24
   set the rect of field "PlayerConIn" of me to tL, tB - 22, tR, tB
   set the rect of button "PlayerConClose" of me to tR - 20, tT - 19, tR, tT - 1
   set the layer of field "PlayerConOut" of me to top
   set the layer of field "PlayerConIn" of me to top
   set the layer of button "PlayerConClose" of me to top
   if there is a field "PlayerStatus" of me then set the top of field "PlayerStatus" of me to Player.StatusTop()
end Player.PlaceConsole

-- the status line's top: the bottom left, or above the console while it shows
function Player.StatusTop
   if Player.ConsoleShown() then return the top of field "PlayerConOut" of me - 42
   return the height of me - 22
end Player.StatusTop

-- Tab with the keyboard elsewhere in the window (the line's own Tab never comes here). ISSUES 0015:
-- while a game plays it is the game's (it reads the keysDown; a card's tabKey came first), and
-- nothing is done with it here: passed on, the engine would move the keyboard into the line.
-- Paused, ended or no game: the console's Tab (its menu). No console shown: as before.
on tabKey
   if not Player.ConsoleShown() or sConWhy is not empty then pass tabKey
   if Con.TabIsMine(Player.GamePlays()) then Con.TabFromHost the long id of field "PlayerConIn" of me
end tabKey

-- a console line runs here: "this card" is the game's, the engine's calls and Player... handlers work
on Con.DoHere pGlobals, pCode, pIsValue
   local tAnswer, tWas, tErr
   put the defaultStack into tWas
   Player.UseMe
   -- no try here: an error goes up to lib_console, which says it (a catch and throw again is
   -- lost on the 9.6.3 engine); the default stack then stays this window, which does no harm
   if pIsValue then
      do pGlobals & cr & "put (" & pCode & ") into tAnswer"
   else
      do pGlobals & cr & pCode
      put the result into tAnswer
   end if
   -- paused or still: draw once, so what the line changed shows
   put false into bStill
   if sRunning is true and (bPaused is true or Player.ConsoleTyping()) then
      try
         Player.Draw
      catch tErr
      end try
   end if
   if tWas is not empty and there is a stack tWas then set the defaultStack to tWas
   return tAnswer
end Con.DoHere
