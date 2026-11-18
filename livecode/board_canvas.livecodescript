script "board_canvas"
-- The board canvas: cards and strings on a black, zoomable canvas. ONE script for every board stack
-- (applied as the stack script of LIB_DEV/ProjectMap/ProjectMap.oxtstack and
-- LIB_DEV/OnGitOrNot/OnGitOrNot.oxtstack); what differs comes in the data's B rows.
-- Project Map: where we are (NOW), where we are going (GOAL), what stops each part (red, strings to YOU).
-- On Git or Not: every folder of the project on one side, ON GIT or NOT ON GIT.
-- Data: map_data.txt next to the stack (made by the board's tool, tools/make_map.py by default).
--   B key value   board settings: title, bar, help, tool, panel, bkinds, legend (fill|ink|text, one a row)
--   L chipId      the right panel's lines in this order (else: the red chips, YOU's first)
-- Comments: right-click anything (a box, a chip, a column title, a string, a panel line, the black)
-- opens a big comment box; a saved comment is a yellow note on the board tied to what it is about.
-- All boards share LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt; the order of comments is NOT their priority.
-- Moved boxes are kept in positions.txt next to the stack.
--
-- Mouse: wheel zooms at the pointer; drag the black to pan; drag a part's header to move it with its
-- cards; click a box to focus it (its strings and neighbours stay lit), click the black to clear.
-- Keys: F fit all, B blockers only (red and pink), R rebuild (runs make_map.py), 0 zoom 100%.
-- The right panel lists what is stopping us; click a line to fly there.
-- Menus: every menu (a box's click menu, a chip's files, a red blocker, a note) ends with the same
-- lines, made by ONE handler (pmMenuEnd): "Leave comment..." and "Explore here...". Explorer is only
-- touched when the owner picks a line (the WSL bridge is slow). Rules: LIB_DEV/LIB_MENU_PLAN.md.
-- Decisions (On Git or Not): a loose file's lines (F rows flagged "decide") offer Commit / Ignore /
-- Delete / Leave; a pick appends a line to LIB_LLMIN/LIB_DEV/GIT_DECISIONS.txt for Claude to carry
-- out (the board runs no git and deletes nothing); decided files are marked on their chip and line.

local sRect      -- world rect of each box: left,top,width,height (by control name)
local sOff       -- chip offset from its part: dx,dy
local sPartOf    -- chip name -> part name
local sChips     -- part name -> chip names, one a line
local sKind      -- box name -> core/part/has/demo/done/next/block/review
local sLinks     -- part name -> linked box names (both ways), one a line
local sEdges     -- one line each: line name, from box, to box
local sZoom, sPanX, sPanY
local sDrag, sDragFrom, sDragStart
local sFocus, sBlockersOnly
local sBlockList -- control names in the panel's order
local sMenuMap   -- popup item -> Windows path & tab & 1 when a folder (for the open popup)
local sMenuChip  -- the box (part, chip or note) whose popup is open
local sFolder    -- part name -> its folder as a Windows path (P rows, item 10), for "Explore here..."
local sDecided   -- Windows path -> the owner's last decision on it (GIT_DECISIONS.txt)
local sConf      -- board settings from the B rows (legend: one line each)
local sPanelOrder -- chip names from the L rows, one a line
local sCmt       -- the comment being written: target, words, id, where, text
local sNotes     -- note name -> its comment line (id, date, board, target, words, state, where, text)

constant kTop = 44
constant kPanelW = 330
constant kMinZoom = 0.08
constant kMaxZoom = 3

---------------------------------------------------------------- opening and closing
on preOpenStack
   set the resizable of this stack to true
   set the backgroundColor of this stack to "10,10,14"
   set the minWidth of this stack to 640
   set the minHeight of this stack to 420
   pmBuild
end preOpenStack

on closeStackRequest
   set the destroyStack of this stack to true
   close stack (the mainStack of this stack)
end closeStackRequest

on resizeStack
   pmLayoutHud
   pmDraw
end resizeStack

function pmFolder
   local tPath
   put the effective fileName of this stack into tPath
   set the itemDelimiter to "/"
   return item 1 to -2 of tPath
end pmFolder

function pmReadText pFile
   local tPath
   put pmFolder() & "/" & pFile into tPath
   if there is not a file tPath then return empty
   return textDecode(URL ("binfile:" & tPath), "UTF-8")
end pmReadText

---------------------------------------------------------------- building
command pmBuild pKeepView
   local tData, tLine, tName, tPos, tFiles, tDecide
   put pmReadText("map_data.txt") into tData
   lock screen
   lock messages
   pmClear
   put empty into sRect
   put empty into sOff
   put empty into sPartOf
   put empty into sChips
   put empty into sKind
   put empty into sLinks
   put empty into sEdges
   put empty into sFocus
   put false into sBlockersOnly
   put empty into sConf
   put empty into sPanelOrder
   put empty into sFolder
   put empty into sDecided
   put pmReadPositions() into tPos
   set the itemDelimiter to tab
   repeat for each line tLine in tData
      switch item 1 of tLine
         case "B"
            if item 2 of tLine is "legend" then
               put item 3 of tLine & return after sConf["legend"]
            else
               put item 3 of tLine into sConf[item 2 of tLine]
            end if
            break
         case "L"
            put "C:" & item 2 of tLine & return after sPanelOrder
            break
         case "Z"
            pmMakeZone tLine
            break
         case "P"
            pmMakePart tLine, tPos
            break
         case "C"
            pmMakeChip tLine
            break
         case "F"
            put item 3 to 7 of tLine & return after tFiles["C:" & item 2 of tLine]
            if item 7 of tLine is "decide" then put true into tDecide
            break
      end switch
   end repeat
   repeat for each line tLine in tData
      if item 1 of tLine is "E" then pmMakeEdge tLine
   end repeat
   put empty into sNotes
   pmMakeNotes
   set the title of this stack to pmConf("title", "FOR OWNER | Project Map")
   -- each chip keeps its own files (group, label, Windows path, folder flag), so a click never searches the disk
   repeat for each key tName in tFiles
      if there is a field tName then set the cFiles of field tName to tFiles[tName]
   end repeat
   -- only a board with loose files to decide reads the decisions file
   if tDecide is true then
      pmReadDecisions
      repeat for each key tName in tFiles
         if there is a field tName then pmMarkDecided tName
      end repeat
   end if
   pmMakeHud
   unlock messages
   if tData is empty then put "No map_data.txt beside the stack: press R to rebuild." into field "HUD_Help"
   pmFillBlockers
   if pKeepView is true and sZoom is a number then
      pmFocus empty
      pmDraw
   else
      pmFit
   end if
   unlock screen
end pmBuild

-- a line in the help bar, when it is there (a rebuild may be under way)
command pmSay pText
   if there is a field "HUD_Help" then put pText into field "HUD_Help"
end pmSay

-- a board setting from the data's B rows, or pDefault
function pmConf pKey, pDefault
   if sConf[pKey] is empty then return pDefault
   return sConf[pKey]
end pmConf

command pmClear
   local i, tName
   repeat with i = the number of controls of this card down to 1
      put the short name of control i of this card into tName
      -- the popup button stays (it cannot be deleted while its menu is in use)
      if tName is "HUD_Popup" then next repeat
      if char 1 to 2 of tName is among the items of "P:,C:,E:,Z:,N:,HU" then delete control i of this card
   end repeat
end pmClear

function pmReadPositions
   local tText, tLine, tPos
   put pmReadText("positions.txt") into tText
   set the itemDelimiter to tab
   repeat for each line tLine in tText
      if the number of items of tLine >= 3 then put item 2 of tLine & "," & item 3 of tLine into tPos[item 1 of tLine]
   end repeat
   return tPos
end pmReadPositions

command pmMakeZone pLine
   local tName
   set the itemDelimiter to tab
   put "Z:" & item 2 of pLine into tName
   create field tName
   pmStyleField tName, "10,10,14", "10,10,14", "110,110,125", 0
   set the textStyle of field tName to "bold"
   set the dontWrap of field tName to true
   put item 3 of pLine into field tName
   put item 4 of pLine & "," & item 5 of pLine & "," & item 6 of pLine & ",60" into sRect[tName]
   put "zone" into sKind[tName]
end pmMakeZone

command pmMakePart pLine, pPos
   local tName, tId, tXY
   set the itemDelimiter to tab
   put item 2 of pLine into tId
   put "P:" & tId into tName
   put item 4 of pLine & "," & item 5 of pLine into tXY
   if pPos[tId] is not empty then put pPos[tId] into tXY
   create field tName
   put item 3 of pLine into sKind[tName]
   if sKind[tName] is "core" then
      pmStyleField tName, "88,40,140", "175,115,235", "255,222,60", 2
   else
      pmStyleField tName, "38,38,46", "120,120,132", "255,255,255", 1
   end if
   set the htmlText of field tName to "<p><b>" & pmHtml(item 8 of pLine) & "</b></p><p>" & pmHtml(item 9 of pLine) & "</p>"
   put tXY & "," & item 6 of pLine & "," & item 7 of pLine into sRect[tName]
   put item 10 of pLine into sFolder[tName]
end pmMakePart

command pmMakeChip pLine
   local tName, tPart, tKind, tText
   set the itemDelimiter to tab
   put "C:" & item 2 of pLine into tName
   put "P:" & item 3 of pLine into tPart
   put item 4 of pLine into tKind
   put item 9 of pLine into tText
   replace "\n" with return in tText
   create field tName
   put tKind into sKind[tName]
   put tPart into sPartOf[tName]
   put tName & return after sChips[tPart]
   put item 5 of pLine & "," & item 6 of pLine into sOff[tName]
   put "0,0," & item 7 of pLine & "," & item 8 of pLine into sRect[tName]
   switch tKind
      case "has"
         pmStyleField tName, "26,110,52", "70,200,105", "255,255,255", 1
         break
      case "demo"
         pmStyleField tName, "128,100,180", "200,175,240", "255,255,255", 1
         break
      case "done"
         pmStyleField tName, "36,30,6", "232,190,40", "242,202,64", 2
         break
      case "next"
         pmStyleField tName, "16,16,20", "235,235,235", "255,255,255", 1
         break
      case "block"
         pmStyleField tName, "190,22,22", "255,90,90", "255,255,255", 2
         break
      case "review"
         pmStyleField tName, "215,35,140", "255,120,200", "255,255,255", 1
         break
      case "ignored"
         pmStyleField tName, "70,70,80", "130,130,142", "225,225,230", 1
         break
      case "private"
         pmStyleField tName, "20,20,24", "70,70,82", "150,150,165", 1
         break
      default
         pmStyleField tName, "38,38,46", "120,120,132", "255,255,255", 1
   end switch
   if tKind is "next" then put "NEXT: " & tText into tText
   put tText into field tName
   pmPlaceChip tName
end pmMakeChip

command pmPlaceChip pChip
   local tPartR, tOffXY, tChipR
   put sRect[sPartOf[pChip]] into tPartR
   put sOff[pChip] into tOffXY
   put sRect[pChip] into tChipR
   put (item 1 of tPartR + item 1 of tOffXY) into item 1 of tChipR
   put (item 2 of tPartR + item 2 of tOffXY) into item 2 of tChipR
   put tChipR into sRect[pChip]
end pmPlaceChip

command pmMakeEdge pLine
   local tFrom, tTo, tName
   set the itemDelimiter to tab
   put pmBoxName(item 2 of pLine) into tFrom
   put pmBoxName(item 3 of pLine) into tTo
   if sRect[tFrom] is empty or sRect[tTo] is empty then exit pmMakeEdge
   put "E:" & (the number of lines of sEdges + 1) into tName
   create graphic tName
   set the style of graphic tName to "line"
   set the antialiased of graphic tName to true
   if item 4 of pLine is "red" then
      set the foregroundColor of graphic tName to "235,45,45"
      set the cWidth of graphic tName to 3
   else
      set the foregroundColor of graphic tName to "95,95,110"
      set the cWidth of graphic tName to 1
   end if
   set the layer of graphic tName to 1
   put tName & tab & tFrom & tab & tTo & return after sEdges
   put tFrom & return after sLinks[pmPartOfBox(tTo)]
   put tTo & return after sLinks[pmPartOfBox(tFrom)]
end pmMakeEdge

function pmBoxName pRef
   if pRef contains "#" then return "C:" & pRef
   return "P:" & pRef
end pmBoxName

function pmPartOfBox pBox
   if char 1 to 2 of pBox is "C:" then return sPartOf[pBox]
   return pBox
end pmPartOfBox

command pmStyleField pName, pFill, pBorder, pInk, pBorderW
   set the opaque of field pName to true
   set the backgroundColor of field pName to pFill
   set the borderColor of field pName to pBorder
   set the textColor of field pName to pInk
   set the borderWidth of field pName to pBorderW
   set the showBorder of field pName to (pBorderW > 0)
   set the threeD of field pName to false
   set the lockText of field pName to true
   set the traversalOn of field pName to false
   set the dontWrap of field pName to false
   set the vScrollbar of field pName to false
   set the showFocusBorder of field pName to false
   set the margins of field pName to 4
   set the cInk of field pName to pInk
   set the cFill of field pName to pFill
end pmStyleField

function pmHtml pText
   replace "&" with "&amp;" in pText
   replace "<" with "&lt;" in pText
   replace ">" with "&gt;" in pText
   return pText
end pmHtml

---------------------------------------------------------------- the HUD (fixed on screen)
command pmMakeHud
   create field "HUD_Bar"
   pmStyleField "HUD_Bar", "22,22,28", "22,22,28", "235,235,235", 0
   set the textStyle of field "HUD_Bar" to "bold"
   set the textSize of field "HUD_Bar" to 15
   put pmConf("bar", "PROJECT MAP") into field "HUD_Bar"
   create field "HUD_Help"
   pmStyleField "HUD_Help", "22,22,28", "22,22,28", "160,160,175", 0
   set the textSize of field "HUD_Help" to 11
   pmSay pmConf("help", "wheel zoom | drag black to pan | drag a header to move | click a box for its menu | right-click anything to comment | F fit  B blockers  R rebuild  T tell Claude  0 100%")
   create field "HUD_Legend"
   pmStyleField "HUD_Legend", "22,22,28", "60,60,70", "235,235,235", 1
   set the textSize of field "HUD_Legend" to 11
   pmFillLegend
   create field "HUD_Blockers"
   pmStyleField "HUD_Blockers", "18,18,24", "90,30,30", "255,255,255", 1
   set the textSize of field "HUD_Blockers" to 12
   set the margins of field "HUD_Blockers" to 10
   set the vScrollbar of field "HUD_Blockers" to true
   if there is not a button "HUD_Popup" then create button "HUD_Popup"
   set the style of button "HUD_Popup" to "menu"
   set the menuMode of button "HUD_Popup" to "popup"
   set the visible of button "HUD_Popup" to false
   pmLayoutHud
end pmMakeHud

command pmFillLegend
   local tH, tLine
   put "<p>" into tH
   if sConf["legend"] is not empty then
      set the itemDelimiter to "|"
      repeat for each line tLine in sConf["legend"]
         put pmSwatch(item 1 of tLine, item 2 of tLine, item 3 of tLine) after tH
      end repeat
      put pmSwatch("255,236,140", "30,30,30", "comment (order is not priority)") after tH
      set the htmlText of field "HUD_Legend" to tH & "</p>"
      exit pmFillLegend
   end if
   put pmSwatch("88,40,140", "255,222,60", "core") after tH
   put pmSwatch("38,38,46", "255,255,255", "part") after tH
   put pmSwatch("26,110,52", "255,255,255", "works") after tH
   put pmSwatch("128,100,180", "255,255,255", "demo / in production") after tH
   put pmSwatch("36,30,6", "242,202,64", "done") after tH
   put pmSwatch("16,16,20", "255,255,255", "next") after tH
   put pmSwatch("215,35,140", "255,255,255", "waits review") after tH
   put pmSwatch("190,22,22", "255,255,255", "blocked") after tH
   put pmSwatch("255,236,140", "30,30,30", "comment (order is not priority)") after tH
   put "</p>" after tH
   set the htmlText of field "HUD_Legend" to tH
end pmFillLegend

function pmSwatch pFill, pInk, pText
   return "<font bgcolor=" & quote & pmHex(pFill) & quote && "color=" & quote & pmHex(pInk) & quote & ">&nbsp;" & pText & "&nbsp;</font>&nbsp;&nbsp;"
end pmSwatch

function pmHex pRGB
   return "#" & format("%02X%02X%02X", item 1 of pRGB, item 2 of pRGB, item 3 of pRGB)
end pmHex

command pmLayoutHud
   local tW, tH
   if there is not a field "HUD_Bar" then exit pmLayoutHud
   put the width of this card into tW
   put the height of this card into tH
   set the rect of field "HUD_Bar" to 0, 0, 170, kTop
   set the rect of field "HUD_Help" to 170, 0, tW, kTop
   set the rect of field "HUD_Legend" to 0, tH - 26, tW - kPanelW, tH
   set the rect of field "HUD_Blockers" to tW - kPanelW, kTop, tW, tH
   set the layer of field "HUD_Bar" to top
   set the layer of field "HUD_Help" to top
   set the layer of field "HUD_Legend" to top
   set the layer of field "HUD_Blockers" to top
end pmLayoutHud

-- the panel: everything red, the ones only YOU can unblock first, then the pink counts
command pmFillBlockers
   local tName, tOwner, tOther, tH, tLine
   put empty into sBlockList
   if sPanelOrder is not empty then
      -- the board gave its own list (L rows), in its own order
      put "<p><font size=16><b>" & pmHtml(pmConf("panel", "THE LIST")) & "</b></font></p><p></p>" into tH
      put "-" & return & "-" & return after sBlockList
      repeat for each line tName in sPanelOrder
         if there is not a field tName then next repeat
         put pmShort(tName) & tab & tName & return after tLine
      end repeat
      pmAddPanelLines tLine, tH
      pmPanelComments tH
      put "<p></p><p><font color=" & quote & "#8888A0" & quote & ">Click a line to fly there. Right-click one to comment on it.</font></p>" after tH
      set the htmlText of field "HUD_Blockers" to tH
      set the dontWrap of field "HUD_Blockers" to false
      exit pmFillBlockers
   end if
   repeat for each key tName in sKind
      if sKind[tName] is "block" then
         put pmShort(tName) & tab & tName into tLine
         if field tName begins with "owner:" then
            put tLine & return after tOwner
         else
            put tLine & return after tOther
         end if
      end if
   end repeat
   sort lines of tOwner
   sort lines of tOther
   put "<p><font size=16><b>WHAT IS STOPPING US</b></font></p><p></p>" into tH
   put "-" & return & "-" & return after sBlockList
   put "<p><font color=" & quote & "#FF6060" & quote & "><b>Only you can unblock (" & the number of lines of tOwner & ")</b></font></p>" after tH
   put "-" & return after sBlockList
   pmAddPanelLines tOwner, tH
   put "<p></p><p><font color=" & quote & "#FF9A9A" & quote & "><b>Other blocks (" & the number of lines of tOther & ")</b></font></p>" after tH
   put "-" & return & "-" & return after sBlockList
   pmAddPanelLines tOther, tH
   pmPanelComments tH
   put "<p></p><p><font color=" & quote & "#8888A0" & quote & ">Click a line to fly there. B shows only red and pink. Right-click anything to comment.</font></p>" after tH
   set the htmlText of field "HUD_Blockers" to tH
   set the dontWrap of field "HUD_Blockers" to false
end pmFillBlockers

command pmAddPanelLines pLines, @xHtml
   local tLine
   set the itemDelimiter to tab
   repeat for each line tLine in pLines
      put "<p>- " & pmHtml(item 1 of tLine) & "</p>" after xHtml
      put item 2 of tLine & return after sBlockList
   end repeat
end pmAddPanelLines

function pmShort pChip
   local tText
   put line 1 of field pChip into tText
   if tText begins with "owner:" then delete char 1 to 7 of tText
   if tText ends with " - click to list them" then delete char -21 to -1 of tText
   return char 3 to -1 of sPartOf[pChip] & ": " & tText
end pmShort

---------------------------------------------------------------- drawing
command pmDraw
   local tName, tR, tSize, tLine
   lock screen
   repeat for each key tName in sRect
      if there is not a field tName then next repeat
      put sRect[tName] into tR
      set the rect of field tName to pmScreenRect(tR)
      switch sKind[tName]
         case "zone"
            put 40 into tSize
            break
         case "core"
         case "part"
            put 13 into tSize
            break
         default
            put 12 into tSize
      end switch
      pmSetTextSize tName, tSize
   end repeat
   set the itemDelimiter to tab
   repeat for each line tLine in sEdges
      pmDrawEdge item 1 of tLine, item 2 of tLine, item 3 of tLine
   end repeat
   unlock screen
end pmDraw

command pmSetTextSize pName, pSize
   local tSize
   put round(pSize * sZoom) into tSize
   if tSize < 5 then
      -- too small to read: ink the text in the fill colour, the box still shows
      set the textColor of field pName to the cFill of field pName
      set the textSize of field pName to 5
   else
      set the textColor of field pName to the cInk of field pName
      set the textSize of field pName to tSize
   end if
   set the margins of field pName to max(1, round(4 * sZoom))
end pmSetTextSize

function pmScreenRect pR
   local tL, tT
   put round((item 1 of pR - sPanX) * sZoom) into tL
   put round((item 2 of pR - sPanY) * sZoom) + kTop into tT
   return tL & "," & tT & "," & (tL + max(2, round(item 3 of pR * sZoom))) & "," & (tT + max(2, round(item 4 of pR * sZoom)))
end pmScreenRect

command pmDrawEdge pLine, pFrom, pTo
   local tA, tB
   put pmScreenRect(sRect[pFrom]) into tA
   put pmScreenRect(sRect[pTo]) into tB
   set the points of graphic pLine to pmEdgePoint(tA, tB) & return & pmEdgePoint(tB, tA)
   set the lineSize of graphic pLine to max(1, round(the cWidth of graphic pLine * min(1, sZoom * 1.5)))
end pmDrawEdge

-- where a string leaves box pA heading for box pB: the middle of the nearest side
function pmEdgePoint pA, pB
   local tAX, tAY, tBX, tBY
   put (item 1 of pA + item 3 of pA) div 2 into tAX
   put (item 2 of pA + item 4 of pA) div 2 into tAY
   put (item 1 of pB + item 3 of pB) div 2 into tBX
   put (item 2 of pB + item 4 of pB) div 2 into tBY
   if abs(tBX - tAX) > abs(tBY - tAY) then
      if tBX > tAX then return item 3 of pA & "," & tAY
      return item 1 of pA & "," & tAY
   end if
   if tBY > tAY then return tAX & "," & item 4 of pA
   return tAX & "," & item 2 of pA
end pmEdgePoint

---------------------------------------------------------------- views
command pmFit
   local tName, tR, tL, tT, tRi, tB, tW, tH
   put 999999 into tL
   put 999999 into tT
   put -999999 into tRi
   put -999999 into tB
   repeat for each key tName in sRect
      put sRect[tName] into tR
      put min(tL, item 1 of tR) into tL
      put min(tT, item 2 of tR) into tT
      put max(tRi, item 1 of tR + item 3 of tR) into tRi
      put max(tB, item 2 of tR + item 4 of tR) into tB
   end repeat
   if tL > tRi then
      put 1 into sZoom
      put 0 into sPanX
      put 0 into sPanY
   else
      put the width of this card - kPanelW - 40 into tW
      put the height of this card - kTop - 26 - 40 into tH
      put max(kMinZoom, min(1, min(tW / (tRi - tL), tH / (tB - tT)))) into sZoom
      put tL - 20 / sZoom into sPanX
      put tT - 20 / sZoom into sPanY
   end if
   pmDraw
end pmFit

-- zoom by pFactor keeping the world point under screen point pX,pY still
command pmZoomAt pFactor, pX, pY
   local tWX, tWY, tNew
   put max(kMinZoom, min(kMaxZoom, sZoom * pFactor)) into tNew
   put sPanX + pX / sZoom into tWX
   put sPanY + (pY - kTop) / sZoom into tWY
   put tNew into sZoom
   put tWX - pX / sZoom into sPanX
   put tWY - (pY - kTop) / sZoom into sPanY
   pmDraw
end pmZoomAt

-- fly to a box: zoom 1, the box in the middle of the canvas, focused
command pmFlyTo pName
   local tR
   if sRect[pName] is empty then exit pmFlyTo
   put sRect[pName] into tR
   put 1 into sZoom
   put item 1 of tR + item 3 of tR / 2 - (the width of this card - kPanelW) / 2 into sPanX
   put item 2 of tR + item 4 of tR / 2 - (the height of this card - kTop) / 2 into sPanY
   pmFocus pName
   pmDraw
end pmFlyTo

-- focus: the box's part, its cards, the parts its strings reach, and those strings stay lit
command pmFocus pName
   local tPart, tLit, tName, tLine, tOn
   put pName into sFocus
   put pmPartOfBox(pName) into tPart
   if tPart is not empty then
      put tPart & return & sChips[tPart] & sLinks[tPart] into tLit
      repeat for each line tName in sLinks[tPart]
         if char 1 to 2 of tName is "C:" then put sPartOf[tName] & return after tLit
      end repeat
   end if
   lock screen
   repeat for each key tName in sKind
      if sKind[tName] is "zone" then next repeat
      if pName is empty then
         put not sBlockersOnly or sKind[tName] is among the items of (pmConf("bkinds", "block,review") & ",note") into tOn
      else
         put tName is among the lines of tLit into tOn
      end if
      set the blendLevel of field tName to pmDim(tOn)
   end repeat
   set the itemDelimiter to tab
   repeat for each line tLine in sEdges
      if pName is empty then
         put not sBlockersOnly or the cWidth of graphic (item 1 of tLine) > 1 into tOn
      else
         put pmPartOfBox(item 2 of tLine) is tPart or pmPartOfBox(item 3 of tLine) is tPart into tOn
      end if
      set the blendLevel of graphic (item 1 of tLine) to pmDim(tOn)
   end repeat
   unlock screen
end pmFocus

function pmDim pOn
   if pOn then return 0
   return 80
end pmDim

command pmToggleBlockers
   put not sBlockersOnly into sBlockersOnly
   pmFocus empty
end pmToggleBlockers

command pmRebuild
   local tCmd, tOut, tPath
   put pmFolder() & "/" & pmConf("tool", "tools/make_map.py") into tPath
   if tPath begins with "//wsl$/Ubuntu" or tPath begins with "//wsl.localhost/Ubuntu" then
      set the itemDelimiter to "/"
      put "/" & item 5 to -1 of tPath into tPath
      put "wsl.exe python3 -I " & quote & tPath & quote into tCmd
   else
      put "python3 -I " & quote & tPath & quote into tCmd
   end if
   pmSay "Rebuilding..."
   put shell(tCmd) into tOut
   pmBuild true
   pmSay "Rebuilt:" && line 1 of tOut
end pmRebuild

---------------------------------------------------------------- the mouse and keys
on mouseDown pButton
   local tName
   put the short name of the target into tName
   if pButton is 3 then
      pmRightClick tName
      exit mouseDown
   end if
   if pButton is not 1 then pass mouseDown
   if tName is "HUD_Blockers" then
      pmPanelClick
      exit mouseDown
   end if
   if char 1 to 3 of tName is "HUD" then exit mouseDown
   put the mouseLoc into sDragFrom
   put sDragFrom into sDragStart
   if char 1 to 2 of tName is "P:" then
      put tName into sDrag
   else if char 1 to 2 of tName is "N:" then
      put "note" && tName into sDrag
   else if char 1 to 2 of tName is "C:" then
      put "click" && tName into sDrag
   else
      put "pan" into sDrag
   end if
end mouseDown

on mouseMove pX, pY
   local tDX, tDY
   if sDrag is empty then pass mouseMove
   if the mouse is up then
      put empty into sDrag
      exit mouseMove
   end if
   put pX - item 1 of sDragFrom into tDX
   put pY - item 2 of sDragFrom into tDY
   put pX & "," & pY into sDragFrom
   if sDrag is "pan" then
      subtract tDX / sZoom from sPanX
      subtract tDY / sZoom from sPanY
      pmDraw
   else if char 1 to 2 of sDrag is "P:" then
      pmMovePart sDrag, tDX / sZoom, tDY / sZoom
   else if word 1 of sDrag is "note" then
      pmMoveNote word 2 to -1 of sDrag, tDX / sZoom, tDY / sZoom
   end if
end mouseMove

on mouseUp pButton
   local tWas, tMoved
   switch the short name of the target
      case "HUD_CmtSave"
         pmCommentSave
         exit mouseUp
      case "HUD_CmtCancel"
         pmCommentClose
         exit mouseUp
   end switch
   put sDrag into tWas
   put empty into sDrag
   if tWas is empty then pass mouseUp
   put abs(item 1 of the mouseLoc - item 1 of sDragStart) + abs(item 2 of the mouseLoc - item 2 of sDragStart) > 4 into tMoved
   if tMoved then
      if char 1 to 2 of tWas is "P:" then pmSavePositions
      if word 1 of tWas is "note" then pmNoteMoved word 2 to -1 of tWas
      exit mouseUp
   end if
   if word 1 of tWas is "note" then
      pmPopupNote word 2 to -1 of tWas
      exit mouseUp
   end if
   if tWas is "pan" then
      pmFocus empty
   else if word 1 of tWas is "click" then
      pmFocus word 2 to -1 of tWas
      if sKind[word 2 to -1 of tWas] is "block" then
         pmPopupBlock word 2 to -1 of tWas
      else if the cFiles of field (word 2 to -1 of tWas) is not empty then
         pmPopupFiles word 2 to -1 of tWas
      else
         pmPopupBox word 2 to -1 of tWas
      end if
   else
      pmFocus tWas
      pmPopupBox tWas
   end if
end mouseUp

on mouseRelease
   put empty into sDrag
end mouseRelease

command pmMovePart pPart, pDX, pDY
   local tR, tChip
   put sRect[pPart] into tR
   put item 1 of tR + pDX into item 1 of tR
   put item 2 of tR + pDY into item 2 of tR
   put tR into sRect[pPart]
   repeat for each line tChip in sChips[pPart]
      pmPlaceChip tChip
   end repeat
   pmDraw
end pmMovePart

command pmSavePositions
   local tName, tOut, tPath
   repeat for each key tName in sKind
      if sKind[tName] is among the items of "core,part" then
         put char 3 to -1 of tName & tab & round(item 1 of sRect[tName]) & tab & round(item 2 of sRect[tName]) & return after tOut
      end if
   end repeat
   sort lines of tOut
   put pmFolder() & "/positions.txt" into tPath
   put textEncode(tOut, "UTF-8") into URL ("binfile:" & tPath)
end pmSavePositions

command pmPanelClick
   local tLine, tName
   put word 2 of the clickLine into tLine
   if tLine is not a number then exit pmPanelClick
   put line tLine of sBlockList into tName
   if char 1 to 2 of tName is among the items of "C:,N:" then pmFlyTo tName
end pmPanelClick

on rawKeyDown pKey
   if the short name of the target is "HUD_CmtBox" then pass rawKeyDown
   -- the wheel: 65308 down (out), 65309 up (in)
   if pKey is 65309 then
      pmZoomAt 1.15, item 1 of the mouseLoc, item 2 of the mouseLoc
   else if pKey is 65308 then
      pmZoomAt 1 / 1.15, item 1 of the mouseLoc, item 2 of the mouseLoc
   else
      pass rawKeyDown
   end if
end rawKeyDown

on keyDown pChar
   if the short name of the target is "HUD_CmtBox" then pass keyDown
   switch pChar
      case "f"
         pmFit
         break
      case "b"
         pmToggleBlockers
         break
      case "r"
         pmRebuild
         break
      case "t"
         pmTellClaude
         break
      case "0"
         pmZoomAt 1 / sZoom, (the width of this card - kPanelW) / 2, (the height of this card) / 2
         break
      default
         pass keyDown
   end switch
end keyDown

---------------------------------------------------------------- the files of a pink (or red) chip
-- a popup of the chip's files (by LIB when they come from more than one); a pick shows it in Explorer
command pmPopupFiles pChip
   pmPopupMenu pChip, pmFilesMenu(pChip)
end pmPopupFiles

-- the popup's text for a chip's files; fills sMenuMap for menuPick
function pmFilesMenu pChip
   local tFiles, tLine, tGroups, tGroup, tMenu, tLabel, tCount, tReview
   put the cFiles of field pChip into tFiles
   put empty into sMenuMap
   set the itemDelimiter to tab
   repeat for each line tLine in tFiles
      if item 1 of tLine is not among the lines of tGroups then put item 1 of tLine & return after tGroups
   end repeat
   put false into tReview
   repeat for each line tLine in tFiles
      if item 5 of tLine is 1 then put true into tReview
      if item 5 of tLine is "decide" then put "decide" into tReview
   end repeat
   if tReview is "decide" then
      put "(" & the number of lines of tFiles && "loose: Commit, Ignore, Delete or Leave each (for Claude), or see it in Explorer" & return & "-" & return into tMenu
   else if tReview then
      put "(" & the number of lines of tFiles && "files: open one, or mark it Reviewed / give Feedback" & return & "-" & return into tMenu
   else
      put "(" & the number of lines of tFiles && "lines: pick one to see it in Explorer" & return & "-" & return into tMenu
   end if
   if the number of lines of tGroups > 1 then
      repeat for each line tGroup in tGroups
         put empty into tCount
         repeat for each line tLine in tFiles
            if item 1 of tLine is tGroup then add 1 to tCount
         end repeat
         put pmMenuSafe(tGroup) && "[" & tCount & "]" into tLabel
         put tLabel & return after tMenu
         repeat for each line tLine in tFiles
            if item 1 of tLine is tGroup then put pmMenuItem(tLabel & "|", tLine, tab) after tMenu
         end repeat
      end repeat
   else
      repeat for each line tLine in tFiles
         put pmMenuItem(empty, tLine, empty) after tMenu
      end repeat
   end if
   return tMenu
end pmFilesMenu

-- one file's menu lines (each ends in return). A file on the review list gets a submenu
-- (Open in Explorer / Reviewed / Feedback...), a loose file to decide another (Open in Explorer /
-- Commit / Ignore / Delete / Leave, its decision shown after its name); others open at once.
-- pIndent = the tabs before it.
function pmMenuItem pParent, pLine, pIndent
   local tLabel, tN, tOut, tAction, tMark, tActions
   set the itemDelimiter to tab
   put empty into tMark
   if item 4 of pLine is 1 then put " [folder]" into tMark
   if item 5 of pLine is "decide" and sDecided[item 3 of pLine] is not empty then
      put tMark && "=" && toUpper(sDecided[item 3 of pLine]) into tMark
   end if
   put pmMenuSafe(item 2 of pLine) & tMark into tLabel
   put 1 into tN
   repeat while sMenuMap[pParent & tLabel] is not empty
      add 1 to tN
      put pmMenuSafe(item 2 of pLine) && "#" & tN & tMark into tLabel
   end repeat
   put item 3 of pLine & tab & item 4 of pLine & tab & item 5 of pLine into sMenuMap[pParent & tLabel]
   put pIndent & tLabel & return into tOut
   put empty into tActions
   if item 5 of pLine is 1 then put "Open in Explorer" & return & "Reviewed" & return & "Feedback..." into tActions
   if item 5 of pLine is "decide" then put "Open in Explorer" & return & "-" & return & "Commit" & return & "Ignore" & return & "Delete" & return & "Leave" into tActions
   repeat for each line tAction in tActions
      put pIndent & tab & tAction & return after tOut
   end repeat
   return tOut
end pmMenuItem

-- menu text treats ( ! - / & and | as commands: keep them out of labels
function pmMenuSafe pText
   replace "&" with "+" in pText
   replace "/" with numToCodepoint(8725) in pText -- a division slash: looks like / but is no menu command
   replace "|" with "-" in pText
   replace tab with " " in pText
   if char 1 of pText is among the items of "(,!,-" then put " " before pText
   return pText
end pmMenuSafe

on menuPick pItem
   local tHit, tAction, tKey
   if the short name of the target is not "HUD_Popup" then pass menuPick
   if pItem is among the lines of pmMenuEnd() then
      pmMenuEndPick pItem, sMenuChip
      exit menuPick
   end if
   if pItem is "Edit this comment..." then
      pmCommentEdit sMenuChip
      exit menuPick
   end if
   if pItem is "Delete this comment" then
      pmCommentWrite sNotes[sMenuChip], "deleted"
      pmBuild true
      pmSay "Comment deleted   (T tells Claude)"
      exit menuPick
   end if
   if pItem is "Feedback on this blocker..." then
      pmBlockFeedback sMenuChip
      exit menuPick
   end if
   if pItem is "Select file(s) for Claude..." then
      pmBlockFiles sMenuChip
      exit menuPick
   end if
   put sMenuMap[pItem] into tHit
   put "Open in Explorer" into tAction
   if tHit is empty then
      -- a file's submenu: "...|file|Action"
      set the itemDelimiter to "|"
      put item -1 of pItem into tAction
      put item 1 to -2 of pItem into tKey
      put sMenuMap[tKey] into tHit
   end if
   if tHit is empty then exit menuPick
   set the itemDelimiter to tab
   switch tAction
      case "Reviewed"
         pmMarkReviewed item 1 of tHit
         break
      case "Feedback..."
         pmFeedback item 1 of tHit
         break
      case "Commit"
      case "Ignore"
      case "Delete"
      case "Leave"
         pmDecide sMenuChip, item 1 of tHit, tAction
         break
      default
         pmExplore item 1 of tHit, item 2 of tHit
   end switch
end menuPick

---------------------------------------------------------------- reviews (the Status Browser's own files and formats)
-- LIB_LLMIN/LIB_DEV: REVIEW_STATE.txt  <path> TAB reviewed TAB date time
--                    REVIEW_FEEDBACK.txt  date time TAB <path> TAB feedback (one line)
--                    TELL_CLAUDE.txt  date time TAB tell TAB note (wakes the AI)
function pmInboxFile pName
   local tPath
   put pmFolder() into tPath
   set the itemDelimiter to "/"
   return item 1 to -3 of tPath & "/LIB_LLMIN/LIB_DEV/" & pName
end pmInboxFile

command pmAppendLine pFile, pLine
   local tText
   put pmInboxFile(pFile) into pFile
   if there is a file pFile then put textDecode(URL ("binfile:" & pFile), "UTF-8") into tText
   if tText is not empty and the last char of tText is not return then put return after tText
   put pLine & return after tText
   put textEncode(tText, "UTF-8") into URL ("binfile:" & pFile)
end pmAppendLine

command pmMarkReviewed pWinPath
   pmAppendLine "REVIEW_STATE.txt", pWinPath & tab & "reviewed" & tab & the short date && the long time
   pmRebuild
   pmSay "Reviewed:" && pmLastPart(pWinPath) & "   (T tells Claude)"
end pmMarkReviewed

command pmFeedback pWinPath
   local tText
   ask "Feedback on" && pmLastPart(pWinPath) & ":"
   if the result is "Cancel" or it is empty then exit pmFeedback
   put it into tText
   replace return with " " in tText
   replace tab with " " in tText
   pmAppendLine "REVIEW_FEEDBACK.txt", the short date && the long time & tab & pWinPath & tab & tText
   pmSay "Feedback saved:" && pmLastPart(pWinPath) & "   (T tells Claude)"
end pmFeedback

command pmTellClaude
   pmAppendLine "TELL_CLAUDE.txt", the short date && the long time & tab & "tell" & tab & "from the" && pmConf("bar", "PROJECT MAP")
   pmSay "Told Claude" && the short time
end pmTellClaude

function pmLastPart pWinPath
   set the itemDelimiter to "\"
   return item -1 of pWinPath
end pmLastPart

-- Explorer with the file selected (a folder opens itself). "start" returns at once, so the
-- map never waits on the WSL bridge; nothing on the disk is checked here (the folder flag came with the data)
command pmExplore pWinPath, pIsFolder
   local tCmd
   if the platform is not "Win32" then
      pmSay "Path:" && pWinPath
      exit pmExplore
   end if
   set the hideConsoleWindows to true
   if pIsFolder is 1 then
      put "start " & quote & quote & " explorer.exe " & quote & pWinPath & quote into tCmd
   else
      put "start " & quote & quote & " explorer.exe /select," & quote & pWinPath & quote into tCmd
   end if
   get shell(tCmd)
   pmSay "Explorer:" && pWinPath
end pmExplore

---------------------------------------------------------------- red chips: feedback and files on a blocker
-- LIB_LLMIN/LIB_DEV/MAP_NOTES.txt, one line each:
--   date time TAB part TAB the blocker's words TAB feedback|file TAB the text, or a file's Windows path
-- for_review.py feedback prints it at every session start.
command pmPopupBlock pChip
   pmPopupMenu pChip, pmBlockMenu(pChip)
end pmPopupBlock

function pmBlockMenu pChip
   local tMenu
   put empty into sMenuMap
   put "(About this blocker" & return & "Feedback on this blocker..." & return & "Select file(s) for Claude..." & return into tMenu
   if the cFiles of field pChip is not empty then put "-" & return & pmFilesMenu(pChip) after tMenu
   return tMenu
end pmBlockMenu

command pmBlockFeedback pChip
   local tText
   ask "Feedback on:" && pmBlockWords(pChip)
   if the result is "Cancel" or it is empty then exit pmBlockFeedback
   put it into tText
   replace return with " " in tText
   replace tab with " " in tText
   pmBlockNote pChip, "feedback", tText
   pmSay "Feedback saved on the blocker   (T tells Claude)"
end pmBlockFeedback

-- the paths only: Claude reads the files themselves
command pmBlockFiles pChip
   local tFiles, tFile, tN
   answer files "Files for Claude to look at about:" && pmBlockWords(pChip)
   if the result is "Cancel" or it is empty then exit pmBlockFiles
   put it into tFiles
   repeat for each line tFile in tFiles
      if tFile is empty then next repeat
      replace "/" with "\" in tFile
      pmBlockNote pChip, "file", tFile
      add 1 to tN
   end repeat
   pmSay tN && "file path(s) passed to Claude for this blocker   (T tells Claude)"
end pmBlockFiles

command pmBlockNote pChip, pKind, pText
   pmAppendLine "MAP_NOTES.txt", the short date && the long time & tab & char 3 to -1 of sPartOf[pChip] & tab & pmBlockWords(pChip) & tab & pKind & tab & pText
end pmBlockNote

function pmBlockWords pChip
   local tText
   put field pChip into tText
   replace return with " " in tText
   replace tab with " " in tText
   return tText
end pmBlockWords

---------------------------------------------------------------- comments on anything (right-click)
-- LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt, one line each; the last line of an id wins:
--   id TAB date time TAB board TAB target TAB the target's words TAB open|deleted TAB where TAB text
--   target: P:part, C:chip, Z:zone, E:fromBox>toBox (a string), @x,y (the black)
--   where:  dx,dy,x,y = the note's place from its part's corner, and on the board
--   text:   returns kept as \n
-- Comments are in the order written: that is NOT their priority (a priority board comes later).
constant kNoteW = 240
constant kCmtFile = "BOARD_COMMENTS.txt"

on escapeKey
   if there is a field "HUD_CmtBox" then
      pmCommentClose
   else
      pass escapeKey
   end if
end escapeKey

-- in the comment box: Ctrl+Enter saves, Enter alone makes a new line
on returnInField
   if the short name of the target is "HUD_CmtBox" and the controlKey is down then
      pmCommentSave
   else
      pass returnInField
   end if
end returnInField

on enterInField
   if the short name of the target is "HUD_CmtBox" and the controlKey is down then
      pmCommentSave
   else
      pass enterInField
   end if
end enterInField

command pmRightClick pName
   local tLine, tWX, tWY, tFrom, tTo
   if pName is "HUD_Blockers" then
      put word 2 of the clickLine into tLine
      if tLine is not a number then exit pmRightClick
      put line tLine of sBlockList into pName
      if char 1 to 2 of pName is not among the items of "C:,N:" then exit pmRightClick
   end if
   if char 1 to 3 of pName is "HUD" then exit pmRightClick
   switch char 1 to 2 of pName
      case "N:"
         pmCommentEdit pName
         break
      case "P:"
         pmCommentOpen pName, "part" && char 3 to -1 of pName, empty, empty
         break
      case "C:"
      case "Z:"
         pmCommentOpen pName, pmWords(pName), empty, empty
         break
      case "E:"
         set the itemDelimiter to tab
         repeat for each line tLine in sEdges
            if item 1 of tLine is pName then
               put item 2 of tLine into tFrom
               put item 3 of tLine into tTo
            end if
         end repeat
         if tFrom is empty then exit pmRightClick
         pmCommentOpen "E:" & tFrom & ">" & tTo, "the string from" && pmWords(tFrom) && "to" && pmWords(tTo), empty, empty
         break
      default
         put round(sPanX + item 1 of the mouseLoc / sZoom) into tWX
         put round(sPanY + (item 2 of the mouseLoc - kTop) / sZoom) into tWY
         pmCommentOpen "@" & tWX & "," & tWY, "the board here", empty, empty
   end switch
end pmRightClick

-- a box's words for a comment line: its first line, without "owner:" and the click hint
function pmWords pBox
   local tText
   if char 1 to 2 of pBox is "P:" then return char 3 to -1 of pBox
   if there is not a field pBox then return pBox
   put line 1 of field pBox into tText
   if tText begins with "owner:" then delete char 1 to 7 of tText
   if tText ends with " - click to list them" then delete char -21 to -1 of tText
   replace tab with " " in tText
   if the number of chars of tText > 90 then put char 1 to 87 of tText & "..." into tText
   return tText
end pmWords

-- the big comment box (fixed on screen, over the board)
command pmCommentOpen pTarget, pWords, pId, pText
   local tL, tT, tW, tH
   pmCommentClose
   put pTarget into sCmt["target"]
   put pWords into sCmt["words"]
   put pId into sCmt["id"]
   put 560 into tW
   put 350 into tH
   put max(10, (the width of this card - kPanelW - tW) div 2) into tL
   put max(kTop + 10, (the height of this card - tH) div 2) into tT
   create field "HUD_CmtTitle"
   pmStyleField "HUD_CmtTitle", "40,36,12", "232,190,40", "255,236,140", 2
   set the textSize of field "HUD_CmtTitle" to 13
   -- the title says what was clicked, so a comment can be picked up again after a break
   set the htmlText of field "HUD_CmtTitle" to "<p><font color=" & quote & "#C8B878" & quote & ">" & pmHtml(pmCommentWhat(pTarget, pId)) & "</font></p><p><b>" & pmHtml(pWords) & "</b></p><p><font color=" & quote & "#C8B878" & quote & "><i>Comments are kept in the order written: that is not their priority.</i></font></p>"
   set the rect of field "HUD_CmtTitle" to tL, tT, tL + tW, tT + 74
   create field "HUD_CmtBox"
   pmStyleField "HUD_CmtBox", "255,248,210", "232,190,40", "20,20,20", 2
   set the lockText of field "HUD_CmtBox" to false
   set the traversalOn of field "HUD_CmtBox" to true
   set the vScrollbar of field "HUD_CmtBox" to true
   set the textSize of field "HUD_CmtBox" to 15
   set the margins of field "HUD_CmtBox" to 10
   set the rect of field "HUD_CmtBox" to tL, tT + 74, tL + tW, tT + tH - 40
   put pText into field "HUD_CmtBox"
   create button "HUD_CmtSave"
   set the label of button "HUD_CmtSave" to "Save comment (Ctrl+Enter)"
   set the rect of button "HUD_CmtSave" to tL + tW - 330, tT + tH - 34, tL + tW - 130, tT + tH - 6
   create button "HUD_CmtCancel"
   set the label of button "HUD_CmtCancel" to "Cancel (Esc)"
   set the rect of button "HUD_CmtCancel" to tL + tW - 120, tT + tH - 34, tL + tW, tT + tH - 6
   create field "HUD_CmtBack"
   pmStyleField "HUD_CmtBack", "40,36,12", "232,190,40", "255,236,140", 2
   set the rect of field "HUD_CmtBack" to tL, tT + tH - 40, tL + tW, tT + tH
   set the layer of field "HUD_CmtBack" to top
   set the layer of field "HUD_CmtTitle" to top
   set the layer of field "HUD_CmtBox" to top
   set the layer of button "HUD_CmtSave" to top
   set the layer of button "HUD_CmtCancel" to top
   focus on field "HUD_CmtBox"
   select after text of field "HUD_CmtBox"
   pmSay "Writing a comment: Ctrl+Enter (or the button) saves, Esc cancels, Enter makes a new line"
end pmCommentOpen

-- the comment box's first line: which board, and what kind of thing was right-clicked
function pmCommentWhat pTarget, pId
   local tKind, tPart
   switch
      case pId is not empty
         put "editing your comment on" into tKind
         break
      case char 1 to 2 of pTarget is "P:"
         put "you right-clicked the part" into tKind
         break
      case char 1 to 2 of pTarget is among the items of "C:,Z:"
         put char 3 to -1 of pTarget into tPart
         set the itemDelimiter to "#"
         put item 1 of tPart into tPart
         put "you right-clicked a box in" && tPart & ":" into tKind
         break
      case char 1 to 2 of pTarget is "E:"
         put "you right-clicked a string:" into tKind
         break
      default
         put "you right-clicked the board itself (no box), here:" into tKind
   end switch
   return toUpper(pmConf("bar", "PROJECT MAP")) && "-" && tKind
end pmCommentWhat

command pmCommentClose
   local tName
   repeat for each item tName in "HUD_CmtTitle,HUD_CmtBox,HUD_CmtSave,HUD_CmtCancel,HUD_CmtBack"
      if there is a control tName then delete control tName
   end repeat
end pmCommentClose

command pmCommentSave
   local tText, tLine, tWhere
   if there is not a field "HUD_CmtBox" then exit pmCommentSave
   put field "HUD_CmtBox" into tText
   pmCommentClose
   if word 1 to -1 of tText is empty then exit pmCommentSave
   if sCmt["id"] is not empty then
      -- an edit: same id, target and place
      put sNotes["N:" & sCmt["id"]] into tLine
      set the itemDelimiter to tab
      put tText into item 8 of tLine
      pmCommentWrite tLine, "open"
   else
      put pmNewNoteWhere(sCmt["target"]) into tWhere
      put "c" & the milliseconds & tab & the short date && the long time & tab & pmConf("bar", "PROJECT MAP") & tab & sCmt["target"] & tab & sCmt["words"] & tab & "open" & tab & tWhere & tab & tText into tLine
      pmCommentWrite tLine, "open"
   end if
   pmBuild true
   pmSay "Comment saved on" && sCmt["words"] & "   (T tells Claude)"
end pmCommentSave

-- append one comment line (the last line of an id wins) with this state
command pmCommentWrite pLine, pState
   local tText, tFile
   set the itemDelimiter to tab
   put pState into item 6 of pLine
   put the short date && the long time into item 2 of pLine
   put item 8 to -1 of pLine into tText
   replace return with "\n" in tText
   replace tab with " " in tText
   put tText into item 8 of pLine
   put pmInboxFile(kCmtFile) into tFile
   if there is not a file tFile then
      put textEncode("# Comments from the boards (Project Map, On Git or Not), one a line; the last line of an id wins." & return & \
            "# The order of comments is NOT their priority (a priority board comes later)." & return & \
            "# id, date time, board, target, the target's words, open|deleted, where, text (\n = new line)" & return, "UTF-8") into URL ("binfile:" & tFile)
   end if
   pmAppendLine kCmtFile, item 1 to 8 of pLine
end pmCommentWrite

-- where a new note goes: right of what it is about, below the notes already there
function pmNewNoteWhere pTarget
   local tBox, tR, tX, tY, tPart, tPR, tName
   put pmAnchorOf(pTarget, empty) into tBox
   if tBox is empty then
      set the itemDelimiter to ","
      put char 2 to -1 of pTarget into tR
      return "0,0," & item 1 of tR & "," & item 2 of tR
   end if
   put sRect[tBox] into tR
   put item 1 of tR + item 3 of tR + 24 into tX
   put item 2 of tR into tY
   repeat for each key tName in sNotes
      if pmAnchorOf(pmNoteItem(tName, 4), pmNoteItem(tName, 5)) is tBox then add 30 to tY
   end repeat
   put pmPartOfBox(tBox) into tPart
   put sRect[tPart] into tPR
   if char 1 to 2 of tPart is not "P:" then put "0,0,0,0" into tPR
   return (tX - item 1 of tPR) & "," & (tY - item 2 of tPR) & "," & tX & "," & tY
end pmNewNoteWhere

function pmNoteLine pNote
   return sNotes[pNote]
end pmNoteLine

function pmNoteItem pNote, pItem
   set the itemDelimiter to tab
   return item pItem of sNotes[pNote]
end pmNoteItem

-- the box a comment is about, as the board stands now: a chip is found by its words when the
-- numbers changed; a chip that is gone falls back to its part; empty = a free note
function pmAnchorOf pTarget, pWords
   local tName, tPart, tStart
   if char 1 of pTarget is "@" then return empty
   if char 1 to 2 of pTarget is "E:" then
      set the itemDelimiter to ">"
      delete char 1 to 2 of pTarget
      put item 1 of pTarget into pTarget
   end if
   if char 1 to 2 of pTarget is "C:" then
      put char 1 to 30 of pWords into tStart
      if sRect[pTarget] is not empty and (pWords is empty or pmWords(pTarget) begins with tStart) then return pTarget
      set the itemDelimiter to "#"
      put "P:" & char 3 to -1 of item 1 of pTarget into tPart
      repeat for each line tName in sChips[tPart]
         if pmWords(tName) begins with tStart then return tName
      end repeat
      if sRect[tPart] is not empty then return tPart
      return empty
   end if
   if sRect[pTarget] is not empty then return pTarget
   return empty
end pmAnchorOf

-- read BOARD_COMMENTS.txt and put this board's open comments on it as yellow notes
command pmMakeNotes
   local tText, tLine, tLast, tId, tBoard, tName
   put pmInboxFile(kCmtFile) into tName
   if there is not a file tName then exit pmMakeNotes
   put textDecode(URL ("binfile:" & tName), "UTF-8") into tText
   put pmConf("bar", "PROJECT MAP") into tBoard
   set the itemDelimiter to tab
   repeat for each line tLine in tText
      if char 1 of tLine is "#" or item 3 of tLine is not tBoard then next repeat
      put tLine into tLast[item 1 of tLine]
   end repeat
   repeat for each key tId in tLast
      if item 6 of tLast[tId] is "open" then pmMakeNote tLast[tId]
   end repeat
end pmMakeNotes

command pmMakeNote pLine
   local tName, tText, tBox, tPart, tWhere, tPR, tH, tEdge
   set the itemDelimiter to tab
   put "N:" & item 1 of pLine into tName
   put pLine into sNotes[tName]
   put item 8 of pLine into tText
   replace "\n" with return in tText
   put item 7 of pLine into tWhere
   put pmAnchorOf(item 4 of pLine, item 5 of pLine) into tBox
   create field tName
   pmStyleField tName, "255,236,140", "200,165,30", "30,30,30", 1
   set the textSize of field tName to 12
   set the htmlText of field tName to "<p><b>comment " & pmHtml(word 1 of item 2 of pLine) & "</b></p>" & pmHtmlLines(tText)
   set the width of field tName to kNoteW
   put the formattedHeight of field tName + 6 into tH
   put "note" into sKind[tName]
   set the itemDelimiter to ","
   if tBox is not empty and char 1 to 2 of pmPartOfBox(tBox) is "P:" then
      put pmPartOfBox(tBox) into tPart
      put tPart into sPartOf[tName]
      put tName & return after sChips[tPart]
      put item 1 of tWhere & "," & item 2 of tWhere into sOff[tName]
      put "0,0," & kNoteW & "," & tH into sRect[tName]
      pmPlaceChip tName
   else
      put item 3 of tWhere & "," & item 4 of tWhere & "," & kNoteW & "," & tH into sRect[tName]
   end if
   if tBox is not empty then
      put "E:" & (the number of lines of sEdges + 1) into tEdge
      create graphic tEdge
      set the style of graphic tEdge to "line"
      set the antialiased of graphic tEdge to true
      set the foregroundColor of graphic tEdge to "232,200,60"
      set the cWidth of graphic tEdge to 2
      set the layer of graphic tEdge to 1
      put tEdge & tab & tName & tab & tBox & return after sEdges
   end if
end pmMakeNote

function pmHtmlLines pText
   local tLine, tOut
   repeat for each line tLine in pText
      put "<p>" & pmHtml(tLine) & "</p>" after tOut
   end repeat
   return tOut
end pmHtmlLines

command pmMoveNote pNote, pDX, pDY
   local tR
   if sPartOf[pNote] is not empty then
      set the itemDelimiter to ","
      put (item 1 of sOff[pNote] + pDX) & "," & (item 2 of sOff[pNote] + pDY) into sOff[pNote]
      pmPlaceChip pNote
   else
      put sRect[pNote] into tR
      put item 1 of tR + pDX into item 1 of tR
      put item 2 of tR + pDY into item 2 of tR
      put tR into sRect[pNote]
   end if
   pmDraw
end pmMoveNote

-- a dragged note keeps its new place (a new line for its id)
command pmNoteMoved pNote
   local tLine, tR
   put sNotes[pNote] into tLine
   put sRect[pNote] into tR
   set the itemDelimiter to tab
   put round(item 1 of sOff[pNote]) & "," & round(item 2 of sOff[pNote]) & "," & round(item 1 of tR) & "," & round(item 2 of tR) into item 7 of tLine
   if sPartOf[pNote] is empty then put "0,0," & round(item 1 of tR) & "," & round(item 2 of tR) into item 7 of tLine
   pmCommentWrite tLine, "open"
   put tLine into sNotes[pNote]
   set the itemDelimiter to tab
   put "open" into item 6 of sNotes[pNote]
end pmNoteMoved

command pmPopupNote pNote
   pmPopupMenu pNote, pmNoteMenu(pNote)
end pmPopupNote

function pmNoteMenu pNote
   return "(" & pmMenuSafe(pmNoteItem(pNote, 5)) & return & "Edit this comment..." & return & "Delete this comment" & return
end pmNoteMenu

command pmCommentEdit pNote
   local tText
   put pmNoteItem(pNote, 8) into tText
   replace "\n" with return in tText
   pmCommentOpen pmNoteItem(pNote, 4), pmNoteItem(pNote, 5), char 3 to -1 of pNote, tText
end pmCommentEdit

-- the panel's last section: every comment on this board, in the order written (not priority)
command pmPanelComments @xHtml
   local tName, tLines, tLine
   repeat for each key tName in sNotes
      put pmNoteItem(tName, 1) & tab & tName & return after tLines
   end repeat
   if tLines is empty then exit pmPanelComments
   sort lines of tLines
   put "<p></p><p><font color=" & quote & "#FFE88C" & quote & "><b>COMMENTS (" & the number of lines of tLines & ")</b></font></p>" after xHtml
   put "<p><font color=" & quote & "#C8B878" & quote & "><i>in the order written: not their priority</i></font></p>" after xHtml
   put "-" & return & "-" & return & "-" & return after sBlockList
   set the itemDelimiter to tab
   repeat for each line tLine in tLines
      put item 2 of tLine into tName
      put "<p><font color=" & quote & "#FFE88C" & quote & ">- " & pmHtml(pmNoteItem(tName, 5)) & ": " & pmHtml(line 1 of pmTextOf(tName)) & "</font></p>" after xHtml
      put tName & return after sBlockList
   end repeat
end pmPanelComments

function pmTextOf pNote
   local tText
   put pmNoteItem(pNote, 8) into tText
   replace "\n" with return in tText
   return tText
end pmTextOf

---------------------------------------------------------------- menus: one ending for every menu
-- Every menu of every board ends with the same lines (LIB_DEV/LIB_MENU_PLAN.md): a new menu calls
-- pmPopupMenu and gets them; menuPick sends them to pmMenuEndPick. Nothing on the disk is touched
-- until the owner picks a line.
function pmMenuEnd
   return "-" & return & "Leave comment..." & return & "Explore here..."
end pmMenuEnd

-- fill the one popup button with a menu and the ending, for menuPick (headless tests stop here)
command pmMenuSet pTarget, pMenu
   put pTarget into sMenuChip
   if pMenu is not empty and the last char of pMenu is not return then put return after pMenu
   set the text of button "HUD_Popup" to pMenu & pmMenuEnd()
end pmMenuSet

command pmPopupMenu pTarget, pMenu
   pmMenuSet pTarget, pMenu
   popup button "HUD_Popup" at the mouseLoc
end pmPopupMenu

-- a click on a part, or on a chip without files: its name, then the ending
command pmPopupBox pBox
   pmPopupMenu pBox, pmBoxMenu(pBox)
end pmPopupBox

function pmBoxMenu pBox
   if char 1 to 2 of pBox is "P:" then return "(part" && pmMenuSafe(char 3 to -1 of pBox) & return
   return "(" & pmMenuSafe(pmWords(pBox)) & return
end pmBoxMenu

command pmMenuEndPick pItem, pTarget
   switch pItem
      case "Leave comment..."
         pmCommentOn pTarget
         break
      case "Explore here..."
         pmExploreHere pTarget
         break
   end switch
end pmMenuEndPick

-- a new comment on the box (on a note: on what the note is about), as a right-click would
command pmCommentOn pTarget
   if char 1 to 2 of pTarget is "N:" then
      pmCommentOpen pmNoteItem(pTarget, 4), pmNoteItem(pTarget, 5), empty, empty
   else
      pmRightClick pTarget
   end if
end pmCommentOn

-- Explorer at the box's place: a chip of one file selects that file, a part (or a chip of many
-- files) opens the part's folder, a note goes where its box is; anything else: the projects folder
command pmExploreHere pTarget
   local tWhere
   put pmExplorePath(pTarget) into tWhere
   set the itemDelimiter to tab
   pmExplore item 1 of tWhere, item 2 of tWhere
end pmExploreHere

function pmExplorePath pTarget
   local tFiles, tPath
   if char 1 to 2 of pTarget is "N:" then
      put pmAnchorOf(pmNoteItem(pTarget, 4), pmNoteItem(pTarget, 5)) into pTarget
   end if
   if char 1 to 2 of pTarget is "C:" then
      if there is a field pTarget then
         put the cFiles of field pTarget into tFiles
      end if
      if the number of lines of tFiles is 1 then
         set the itemDelimiter to tab
         return item 3 of tFiles & tab & item 4 of tFiles
      end if
      put sPartOf[pTarget] into pTarget
   end if
   if char 1 to 2 of pTarget is "P:" then
      if sFolder[pTarget] is not empty then return sFolder[pTarget] & tab & 1
      -- map data from before the folder column: look for it now (the owner picked this line)
      put pmProjects() & "/" & char 3 to -1 of pTarget into tPath
      if there is a folder tPath then return pmWinPath(tPath) & tab & 1
   end if
   return pmWinPath(pmProjects()) & tab & 1
end pmExplorePath

-- ~/projects as the stack sees it (two folders above the board's stack)
function pmProjects
   local tPath
   put pmFolder() into tPath
   set the itemDelimiter to "/"
   return item 1 to -3 of tPath
end pmProjects

function pmWinPath pPath
   replace "/" with "\" in pPath
   return pPath
end pmWinPath

---------------------------------------------------------------- decisions on loose files (On Git or Not, PLAN.md step 4)
-- LIB_LLMIN/LIB_DEV/GIT_DECISIONS.txt, one line each; the last line of a path wins:
--   date time TAB folder TAB Windows path TAB commit|ignore|delete|leave
-- Claude carries them out (commit it, add a .gitignore rule, delete it, or leave it loose) and
-- rebuilds; the board itself runs no git and deletes nothing.
constant kDecFile = "GIT_DECISIONS.txt"

command pmDecide pChip, pWinPath, pAction
   local tFile
   put toLower(pAction) into pAction
   put pmInboxFile(kDecFile) into tFile
   if there is not a file tFile then
      put textEncode("# Decisions from the On Git or Not board, one a line; the last line of a path wins." & return & \
            "# Claude carries them out (commit, ignore, delete, leave) and rebuilds; the board runs no git." & return & \
            "# date time, folder, Windows path, commit|ignore|delete|leave" & return, "UTF-8") into URL ("binfile:" & tFile)
   end if
   pmAppendLine kDecFile, the short date && the long time & tab & char 3 to -1 of sPartOf[pChip] & tab & pWinPath & tab & pAction
   put pAction into sDecided[pWinPath]
   pmMarkDecided pChip
   pmSay toUpper(char 1 of pAction) & char 2 to -1 of pAction & ":" && pmLastPart(pWinPath) & "   (written for Claude; T tells Claude)"
end pmDecide

command pmReadDecisions
   local tFile, tText, tLine
   put empty into sDecided
   put pmInboxFile(kDecFile) into tFile
   if there is not a file tFile then exit pmReadDecisions
   put textDecode(URL ("binfile:" & tFile), "UTF-8") into tText
   set the itemDelimiter to tab
   repeat for each line tLine in tText
      if char 1 of tLine is "#" or the number of items of tLine < 4 then next repeat
      put item 4 of tLine into sDecided[item 3 of tLine]
   end repeat
end pmReadDecisions

-- a chip of loose files says how many are decided; all of them decided = a white border
command pmMarkDecided pChip
   local tFiles, tLine, tAll, tDone, tText
   put the cFiles of field pChip into tFiles
   put 0 into tAll
   put 0 into tDone
   set the itemDelimiter to tab
   repeat for each line tLine in tFiles
      if item 5 of tLine is not "decide" then next repeat
      add 1 to tAll
      if sDecided[item 3 of tLine] is not empty then add 1 to tDone
   end repeat
   if tAll is 0 then exit pmMarkDecided
   if the cText of field pChip is empty then set the cText of field pChip to field pChip
   put the cText of field pChip into tText
   if tDone > 0 then
      if tText ends with " - click to list them" then delete char -21 to -1 of tText
      put tText & " - " & tDone && "of" && tAll && "decided" into tText
   end if
   put tText into field pChip
   if tDone = tAll then
      set the borderColor of field pChip to "255,255,255"
      set the borderWidth of field pChip to 3
   end if
end pmMarkDecided
