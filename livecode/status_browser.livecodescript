######################################################################################
## STACK SCRIPT: "Status_Browser"  (LIB_DEV, 11 14 2026; the owner's layout)
## Keeps the owner up with the files the AI makes.
##   LEFT   the files waiting for review, newest first (from LIB_LLMOUT/FOR_REVIEW.txt,
##          which the AI fills with LIB_DEV/tools/for_review.py). Refresh reloads it.
##          Click a name: its details show on the right (no file access: the owner, 14 Nov 13:05,
##          Explorer over the Windows-WSL bridge spins about 30 s). Right-click a name:
##          Reviewed / Not Reviewed / Open in Explorer / Copy Path (the only way Explorer opens).
##          Each file keeps its own unsent feedback draft: switching files shows that file's text.
##          The right-click menu ends with LIB_MENU's lines: "Leave comment..." (a line in
##          LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt, board STATUS BROWSER, target = the file's path) and
##          "Explore here..." (Explorer at the file). LIB_MENU is loaded from <projects>/LIB_MENU/livecode;
##          without it the menu is the plain one (no ending), and nothing else changes.
##          o = waiting, + = reviewed, * = has feedback
##   RIGHT  top: what the AI says about the file (LIB, work done, warnings, caveats, path)
##          bottom: the owner's feedback; Submit saves it for the AI to read
## The owner's states and feedback go to the AI's inbox: LIB_LLMIN/LIB_DEV/
##   REVIEW_STATE.txt     <full path> TAB reviewed|waiting TAB date time
##   REVIEW_FEEDBACK.txt  date time TAB <full path> TAB feedback (one line)
##   TELL_CLAUDE.txt      date time TAB "tell" TAB counts: the "Tell Claude" button. The AI watches
##                        this file while a session is open and reads your reviews when it changes.
######################################################################################

local sEntries     -- [n][date|lib|path|done|warn|caveat]; list line n = entry n
local sCount, sCurrent, sState, sNotes, sNoteText   -- sNoteText[path] = your stamped comments
local sLastSent      -- the feedback text last submitted (Tell Claude submits unsent text first)
local sDraft         -- [path] the Feedback field's text for that file (kept while you switch files)
local sAskAnswer     -- checks only: the next comment's text instead of asking

on openStack
   SB.Refresh
end openStack

-- run from the launcher standalone: closing the browser quits the app (no hidden leftovers).
-- Only when the launcher is there, so other engines (the AI's test standalone) never quit.
on closeStack
   global gStatusBrowserLauncher      -- set only by the launcher standalone when it opens the browser
   if gStatusBrowserLauncher is true and the environment is "standalone application" then quit
   pass closeStack
end closeStack

-------------------------------------------------------------------- files

-- the projects folder: the nearest folder above this stack (or standalone) that holds LIB_LLMOUT,
-- so a build anywhere under projects works (e.g. LIB_LLMIN/LIB_DEV/Status_Browser/Status_Browser.exe)
function SB.Projects
   local tPath
   put the effective filename of this stack into tPath
   set the itemDel to "/"
   repeat while the number of items of tPath > 1
      delete item -1 of tPath
      if there is a folder (tPath & "/LIB_LLMOUT") then return tPath
   end repeat
   return "//wsl$/Ubuntu/home/igame3d/projects"
end SB.Projects

function SB.ListFile
   return SB.Projects() & "/LIB_LLMOUT/FOR_REVIEW.txt"
end SB.ListFile

function SB.InboxFile pName
   local tDir
   put SB.Projects() & "/LIB_LLMIN/LIB_DEV" into tDir
   if there is not a folder tDir then create folder tDir
   return tDir & "/" & pName
end SB.InboxFile

function SB.ReadText pPath
   local tText
   if there is not a file pPath then return empty
   put textDecode(URL ("binfile:" & pPath), "UTF-8") into tText
   replace numToChar(13) & numToChar(10) with return in tText
   return tText
end SB.ReadText

command SB.AppendLine pPath, pLine
   local tText
   put SB.ReadText(pPath) into tText
   if tText is not empty and the last char of tText is not return then put return after tText
   put pLine & return after tText
   put textEncode(tText, "UTF-8") into URL ("binfile:" & pPath)
end SB.AppendLine

-------------------------------------------------------------------- the list

on SB.Refresh
   local tText, tLine, tN, tOut, tLines, i, tPath, tName
   SB.UseMenu
   put SB.ReadText(SB.ListFile()) into tText
   -- review states: the last line for a path wins
   put empty into sState
   set the itemDel to tab
   repeat for each line tLine in SB.ReadText(SB.InboxFile("REVIEW_STATE.txt"))
      if tLine is not empty then put item 2 of tLine into sState[item 1 of tLine]
   end repeat
   put empty into sNotes
   put empty into sNoteText
   repeat for each line tLine in SB.ReadText(SB.InboxFile("REVIEW_FEEDBACK.txt"))
      if tLine is empty then next repeat
      put true into sNotes[item 2 of tLine]
      put "  " & item 1 of tLine & ":  " & item 3 to -1 of tLine & return after sNoteText[item 2 of tLine]
   end repeat
   -- entries, newest (last in the file) first
   put empty into tLines
   repeat for each line tLine in tText
      if tLine is empty or char 1 of tLine is "#" then next repeat
      put tLine & return before tLines
   end repeat
   put empty into sEntries
   put 0 into tN
   put empty into tOut
   repeat for each line tLine in tLines
      if tLine is empty then next repeat
      add 1 to tN
      put item 1 of tLine into sEntries[tN]["date"]
      put item 2 of tLine into sEntries[tN]["lib"]
      put item 3 of tLine into sEntries[tN]["path"]
      put item 4 of tLine into sEntries[tN]["done"]
      put item 5 of tLine into sEntries[tN]["warn"]
      put item 6 of tLine into sEntries[tN]["caveat"]
      put SB.Mark(sEntries[tN]["path"]) && SB.ShortName(sEntries[tN]["path"]) & "   " & sEntries[tN]["lib"] & return after tOut
   end repeat
   delete the last char of tOut
   put tN into sCount
   put tOut into field "Scrolling List Field"
   put "LLM Details here:" & return & tN && "files for review." & return & return & \
         "Click a name: details here." & return & \
         "Right-click a name: Reviewed / Not Reviewed / Open in Explorer / Copy Path." & return & \
         "o waiting   + reviewed   * has feedback" into field "LLMNote"
   put empty into sCurrent
end SB.Refresh

function SB.Mark pPath
   if sNotes[pPath] is true then return "*"
   if sState[pPath] is "reviewed" then return "+"
   return "o"
end SB.Mark

function SB.ShortName pPath
   set the itemDel to "\"
   if "\" is not in pPath then set the itemDel to "/"
   return item -1 of pPath
end SB.ShortName

-- a click: show the AI's details. Never opens Explorer (that is the right-click menu's job); pOpen is
-- kept so older builds of the list's script still compile.
on SB.Clicked pLine, pOpen
   if pLine < 1 or pLine > sCount then exit SB.Clicked
   if pLine is not sCurrent then
      SB.SwapDraft pLine
      put "Feedback" into field "Label Field"
   end if
   put pLine into sCurrent
   put "LLM Details here:" & return & \
         "LIB: " & sEntries[pLine]["lib"] & "   (" & sEntries[pLine]["date"] & ")" & return & \
         "Work done: " & sEntries[pLine]["done"] & return & \
         "Warnings: " & sEntries[pLine]["warn"] & return & \
         "Caveats: " & sEntries[pLine]["caveat"] & return & \
         "Full File Path: " & sEntries[pLine]["path"] & return & \
         "State: " & SB.StateWord(sEntries[pLine]["path"]) & SB.YourNotes(sEntries[pLine]["path"]) into field "LLMNote"
end SB.Clicked

-- the Feedback field follows the selected file: keep the text written for the old one, show the new one's
on SB.SwapDraft pNewLine
   if sCurrent is not empty then put field "Feedback" into sDraft[sEntries[sCurrent]["path"]]
   put sDraft[sEntries[pNewLine]["path"]] into field "Feedback"
end SB.SwapDraft

-- your earlier comments on this file, with their date and time
function SB.YourNotes pPath
   if sNoteText[pPath] is empty then return empty
   return return & return & "Your feedback:" & return & char 1 to -2 of sNoteText[pPath]
end SB.YourNotes

function SB.StateWord pPath
   if sState[pPath] is "reviewed" then return "reviewed"
   return "waiting for review"
end SB.StateWord

-- Explorer with the file selected (a folder opens itself)
on SB.Explore pWinPath
   if the platform is not "Win32" then exit SB.Explore
   set the hideConsoleWindows to true
   if there is a folder (SB.Slashes(pWinPath)) then
      get shell("explorer.exe " & quote & pWinPath & quote)
   else
      get shell("explorer.exe /select," & quote & pWinPath & quote)
   end if
end SB.Explore

-- \\wsl$\Ubuntu\... -> //wsl$/Ubuntu/... (how LiveCode names the same file)
function SB.Slashes pPath
   replace "\" with "/" in pPath
   return pPath
end SB.Slashes

-------------------------------------------------------------------- right-click and feedback

on SB.RightClicked pLine
   if pLine < 1 or pLine > sCount then exit SB.RightClicked
   SB.MenuSet pLine
   popup button "ReviewMenu"
end SB.RightClicked

-- select the file and fill the menu (headless checks stop here); nothing on the disk is touched
on SB.MenuSet pLine
   if pLine < 1 or pLine > sCount then exit SB.MenuSet
   SB.Clicked pLine, false
   set the hilitedLine of field "Scrolling List Field" to pLine
   set the text of button "ReviewMenu" to SB.MenuText()
end SB.MenuSet

-- the file menu; with LIB_MENU, its ending after it (LIB_MENU/PLAN.md rule 1)
function SB.MenuText
   local tMenu
   put "Reviewed" & return & "Not Reviewed" & return & "-" & return & "Open in Explorer" & return & "Copy Path" into tMenu
   if SB.MenuOn() then return Menu.WithEnd(tMenu)
   return tMenu
end SB.MenuText

on SB.MenuPicked pItem
   if sCurrent is empty then exit SB.MenuPicked
   -- a guard in its own if: OpenXTalk evaluates both sides of "and"
   if SB.MenuOn() then
      if Menu.IsEnd(pItem) then
         -- LIB_MENU sends it back as menuLeaveComment / menuExploreHere
         Menu.EndPick pItem, sEntries[sCurrent]["path"], the long id of this stack
         exit SB.MenuPicked
      end if
   end if
   switch pItem
      case "Reviewed"
         SB.SetState "reviewed"
         break
      case "Not Reviewed"
         SB.SetState "waiting"
         break
      case "Open in Explorer"
         SB.Explore sEntries[sCurrent]["path"]
         break
      case "Copy Path"
         set the clipboardData["text"] to sEntries[sCurrent]["path"]
         break
   end switch
end SB.MenuPicked

-- the selected file's state: reviewed or waiting
on SB.SetState pState
   local tLine, tPath
   if sCurrent is empty then exit SB.SetState
   put sEntries[sCurrent]["path"] into tPath
   SB.AppendLine SB.InboxFile("REVIEW_STATE.txt"), tPath & tab & pState & tab & the short date && the long time
   put pState into sState[tPath]
   put sCurrent into tLine
   put SB.Mark(tPath) && SB.ShortName(tPath) & "   " & sEntries[tLine]["lib"] into line tLine of field "Scrolling List Field"
   set the hilitedLine of field "Scrolling List Field" to tLine
   SB.Clicked tLine, false
end SB.SetState

on SB.Submit
   local tText, tPath, tStamp
   put field "Feedback" into tText
   if tText is empty or tText begins with "Whatever feedback" then exit SB.Submit
   if sCurrent is empty then
      put "(general)" into tPath
   else
      put sEntries[sCurrent]["path"] into tPath
   end if
   put field "Feedback" into sLastSent
   replace return with " / " in tText
   replace tab with " " in tText
   put the short date && the long time into tStamp
   SB.AppendLine SB.InboxFile("REVIEW_FEEDBACK.txt"), tStamp & tab & tPath & tab & tText
   -- the text stays in the field (the owner: Submit is also a save while you keep writing)
   put "Saved" && the short time into field "Label Field"
   put true into sNotes[tPath]
   put "  " & tStamp & ":  " & tText & return after sNoteText[tPath]
   if sCurrent is not empty then
      put SB.Mark(tPath) && SB.ShortName(tPath) & "   " & sEntries[sCurrent]["lib"] into line sCurrent of field "Scrolling List Field"
      set the hilitedLine of field "Scrolling List Field" to sCurrent
      SB.Clicked sCurrent, false
   end if
end SB.Submit

-- one click: unsent feedback is submitted first, then a line in TELL_CLAUDE.txt wakes the AI
on SB.TellClaude
   local tReviewed, tWaiting, tKey, tText
   put field "Feedback" into tText
   if tText is not empty and tText is not sLastSent and not (tText begins with "Whatever feedback") then SB.Submit
   put 0 into tReviewed
   put 0 into tWaiting
   put 1 into tKey
   repeat while tKey <= sCount
      if sState[sEntries[tKey]["path"]] is "reviewed" then
         add 1 to tReviewed
      else
         add 1 to tWaiting
      end if
      add 1 to tKey
   end repeat
   SB.AppendLine SB.InboxFile("TELL_CLAUDE.txt"), the short date && the long time & tab & "tell" & tab & \
         tReviewed && "reviewed," && tWaiting && "waiting," && the number of lines of SB.ReadText(SB.InboxFile("REVIEW_FEEDBACK.txt")) && "feedback lines"
   put "Told Claude" && the short time into field "Label Field"
end SB.TellClaude

-------------------------------------------------------------------- LIB_MENU: the menus' ending

-- LIB_MENU (the menu rules every stack shares): <projects>/LIB_MENU/livecode/lib_menu.livecodescript; loaded once
on SB.UseMenu
   local tLib
   if SB.MenuOn() then exit SB.UseMenu
   put SB.Projects() & "/LIB_MENU/livecode/lib_menu.livecodescript" into tLib
   if there is a file tLib then
      start using stack tLib
   end if
end SB.UseMenu

-- every call into Menu.* is guarded by this: without the library the menu is the plain one
function SB.MenuOn
   return "LIB_MENU" is among the lines of the stacksInUse
end SB.MenuOn

-- the ending's two lines, sent back by LIB_MENU's Menu.EndPick
on menuLeaveComment pTarget
   SB.CommentAsk pTarget
end menuLeaveComment

on menuExploreHere pTarget
   Menu.Explore SB.Slashes(pTarget), empty
   SB.Say the result
end menuExploreHere

-- a short word under the list, where Saved / Told Claude show
on SB.Say pText
   if there is a field "Label Field" then put pText into field "Label Field"
end SB.Say

-- checks only: the next comment's text, so no dialog opens
on SB.TestAnswer pText
   put pText into sAskAnswer
end SB.TestAnswer

on SB.CommentAsk pPath
   local tText
   if sAskAnswer is not empty then
      put sAskAnswer into tText
      put empty into sAskAnswer
   else
      ask "Comment on" && SB.ShortName(pPath) & ":"
      if the result is "Cancel" then exit SB.CommentAsk
      put it into tText
   end if
   if word 1 to -1 of tText is empty then exit SB.CommentAsk
   SB.CommentWrite pPath, tText
   SB.Say "Comment saved" && the short time
end SB.CommentAsk

-- one line in BOARD_COMMENTS.txt, the boards' format:
--   id TAB date time TAB board TAB target TAB the target's words TAB open TAB where TAB text (\n = new line)
on SB.CommentWrite pPath, pText
   local tLine, tHeader, tFile, tWords
   replace return with "\n" in pText
   replace tab with " " in pText
   put SB.ShortName(pPath) into tWords
   if sCurrent is not empty then
      if sEntries[sCurrent]["path"] is pPath then put tWords & "   " & sEntries[sCurrent]["lib"] into tWords
   end if
   put "c" & the milliseconds & tab & the short date && the long time & tab & "STATUS BROWSER" & tab & pPath & tab & tWords & tab & "open" & tab & "0,0,0,0" & tab & pText into tLine
   put "# Comments from the boards (Project Map, On Git or Not), one a line; the last line of an id wins." & return & \
         "# The order of comments is NOT their priority (a priority board comes later)." & return & \
         "# id, date time, board, target, the target's words, open|deleted, where, text (\n = new line)" into tHeader
   put SB.InboxFile("BOARD_COMMENTS.txt") into tFile
   if SB.MenuOn() then
      Menu.AppendLine tFile, tLine, tHeader
   else
      if there is not a file tFile then SB.AppendLine tFile, tHeader
      SB.AppendLine tFile, tLine
   end if
end SB.CommentWrite

-- tests: one line
function SB.State
   return sCount & " files|current " & sCurrent & "|" & line 1 of field "Scrolling List Field"
end SB.State
