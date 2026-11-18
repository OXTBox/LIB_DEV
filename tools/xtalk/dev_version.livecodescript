script "dev_version"
-- dev_version: one step of the owner's stack workflow (15 Nov 2026; memory xtalk-dev-stack-workflow).
-- Every iteration starts from a brand-new empty stack: the previous version's cards are copied in,
-- with what cards do not carry (the stack's properties, custom property sets, script), saved as
-- <folder>/<concept>_dev_<yyyymmdd_hhmmss>.oxtstack, and the previous version is closed.
--
--   start using stack "//wsl$/Ubuntu/home/igame3d/projects/LIB_DEV/tools/xtalk/dev_version.livecodescript"
--   put Dev.NewVersion("TTRPG_Client", "TTRPG_Client", "<folder>", "<folder>/livecode/client_main.livecodescript", "Opus")
--
-- pScriptFile: the stack script's source file (empty = keep the old stack's script).
-- pTitleWho: the title prefix (the AI driving it, or "FOR OWNER"); kept for old callers: with LIB_USERS in use, Users.TitleStack words it; the title becomes pTitleWho && the new name.
-- Not carried: substacks (none yet in our apps). Run it from the sandbox or Message Box, never from a
-- handler of the old stack (it is deleted from memory). Returns the new file's path, or "error: ...".
-- Dev.Stamp(): yyyymmdd_hhmmss from the system clock.

constant kStackProps = "width,height,resizable,minWidth,minHeight,backgroundColor,foregroundColor,textFont,textSize,textStyle"

function Dev.Stamp
   local tD
   put the seconds into tD
   convert tD to dateItems
   return format("%04d%02d%02d_%02d%02d%02d", item 1 of tD, item 2 of tD, item 3 of tD, item 4 of tD, item 5 of tD, item 6 of tD)
end Dev.Stamp

-- puts stack pStack at the top left of pRect when that rect lies on the screen (below the title bar),
-- else in the middle of the screen
command Dev.PlaceOnScreen pStack, pRect
   local tScreen
   put the screenRect into tScreen
   if item 1 of pRect >= item 1 of tScreen and item 2 of pRect >= item 2 of tScreen + 24 \
         and item 3 of pRect <= item 3 of tScreen and item 4 of pRect <= item 4 of tScreen then
      set the topLeft of stack pStack to item 1 to 2 of pRect
   else
      set the loc of stack pStack to the screenLoc
   end if
end Dev.PlaceOnScreen

function Dev.NewVersion pOld, pConcept, pFolder, pScriptFile, pTitleWho
   local tName, tPath, tProp, tSet, tSets, tProps, i, tScript, tFirst
   if there is not a stack pOld then return "error: no stack " & pOld
   put pConcept & "_dev_" & Dev.Stamp() into tName
   if there is a stack tName then return "error: " & tName & " already open (one version a second)"
   if pFolder ends with "/" then delete char -1 of pFolder
   put pFolder & "/" & tName & ".oxtstack" into tPath
   if there is a file tPath then return "error: file exists " & tPath
   if pScriptFile is not empty then
      if there is not a file pScriptFile then return "error: no script file " & pScriptFile
      put textDecode(url ("binfile:" & pScriptFile), "UTF-8") into tScript
   else
      put the script of stack pOld into tScript
   end if
   lock screen
   lock messages
   create invisible stack tName
   put the long id of card 1 of stack tName into tFirst
   -- the stack's own properties
   repeat for each item tProp in kStackProps
      set the tProp of stack tName to the tProp of stack pOld
   end repeat
   -- where the window opens: where the old one was, or centred when that was off the screen
   -- (owner, 15 Nov: the first dev version opened at -288,-81)
   Dev.PlaceOnScreen tName, the rect of stack pOld
   -- custom property sets: the default (empty name) and each named set
   put the customPropertySets of stack pOld into tSets
   put the customProperties of stack pOld into tProps
   set the customProperties of stack tName to tProps
   repeat for each line tSet in tSets
      put the customProperties[tSet] of stack pOld into tProps
      set the customProperties[tSet] of stack tName to tProps
   end repeat
   -- the cards, in order, then the blank first card goes
   repeat with i = 1 to the number of cards of stack pOld
      copy card i of stack pOld to stack tName
   end repeat
   delete tFirst
   set the script of stack tName to tScript
   if the result is not empty then
      delete stack tName
      unlock messages
      unlock screen
      return "error: script does not compile: " & the result
   end if
   if pTitleWho is not empty then set the title of stack tName to pTitleWho && tName
   dispatch "Users.TitleStack" with tName   -- LIB_USERS words it, when in use
   set the visible of stack tName to true   -- created invisible so it builds unseen; saved and shown visible
   save stack tName as tPath
   if the result is not empty then
      unlock messages
      unlock screen
      return "error: save failed: " & the result
   end if
   -- close the previous version (messages locked: its closeStackRequest does not run)
   delete stack pOld
   unlock messages
   unlock screen
   return tPath
end Dev.NewVersion
