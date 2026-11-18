script "project_map"
-- Project Map: the whole project as a board of cards and strings on a black, zoomable canvas.
-- Where we are (NOW), where we are going (GOAL), what stops each part (red, strings to YOU).
-- Data: map_data.txt next to the stack (made by tools/make_map.py from board.txt + counted facts).
-- Moved boxes are kept in positions.txt next to the stack.
--
-- Mouse: wheel zooms at the pointer; drag the black to pan; drag a part's header to move it with its
-- cards; click a box to focus it (its strings and neighbours stay lit), click the black to clear.
-- Keys: F fit all, B blockers only (red and pink), R rebuild (runs make_map.py), 0 zoom 100%.
-- The right panel lists what is stopping us; click a line to fly there.

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
local sMenuChip  -- the chip whose popup is open

constant kTop = 44
constant kPanelW = 330
constant kMinZoom = 0.08
constant kMaxZoom = 3

---------------------------------------------------------------- opening and closing
on preOpenStack
   set the title of this stack to "FOR OWNER | Project Map"
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
   local tData, tLine, tName, tPos, tFiles
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
   put pmReadPositions() into tPos
   set the itemDelimiter to tab
   repeat for each line tLine in tData
      switch item 1 of tLine
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
            break
      end switch
   end repeat
   repeat for each line tLine in tData
      if item 1 of tLine is "E" then pmMakeEdge tLine
   end repeat
   -- each chip keeps its own files (group, label, Windows path, folder flag), so a click never searches the disk
   repeat for each key tName in tFiles
      if there is a field tName then set the cFiles of field tName to tFiles[tName]
   end repeat
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

command pmClear
   local i, tName
   repeat with i = the number of controls of this card down to 1
      put the short name of control i of this card into tName
      if char 1 to 2 of tName is among the items of "P:,C:,E:,Z:,HU" then delete control i of this card
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
   put "PROJECT MAP" into field "HUD_Bar"
   create field "HUD_Help"
   pmStyleField "HUD_Help", "22,22,28", "22,22,28", "160,160,175", 0
   set the textSize of field "HUD_Help" to 11
   put "wheel zoom | drag black to pan | drag a header to move | click to focus | F fit  B blockers  R rebuild  T tell Claude  0 100%" into field "HUD_Help"
   create field "HUD_Legend"
   pmStyleField "HUD_Legend", "22,22,28", "60,60,70", "235,235,235", 1
   set the textSize of field "HUD_Legend" to 11
   pmFillLegend
   create field "HUD_Blockers"
   pmStyleField "HUD_Blockers", "18,18,24", "90,30,30", "255,255,255", 1
   set the textSize of field "HUD_Blockers" to 12
   set the margins of field "HUD_Blockers" to 10
   set the vScrollbar of field "HUD_Blockers" to true
   create button "HUD_Popup"
   set the style of button "HUD_Popup" to "menu"
   set the menuMode of button "HUD_Popup" to "popup"
   set the visible of button "HUD_Popup" to false
   pmLayoutHud
end pmMakeHud

command pmFillLegend
   local tH
   put "<p>" into tH
   put pmSwatch("88,40,140", "255,222,60", "core") after tH
   put pmSwatch("38,38,46", "255,255,255", "part") after tH
   put pmSwatch("26,110,52", "255,255,255", "works") after tH
   put pmSwatch("128,100,180", "255,255,255", "demo / in production") after tH
   put pmSwatch("36,30,6", "242,202,64", "done") after tH
   put pmSwatch("16,16,20", "255,255,255", "next") after tH
   put pmSwatch("215,35,140", "255,255,255", "waits review") after tH
   put pmSwatch("190,22,22", "255,255,255", "blocked") after tH
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
   set the rect of field "HUD_Bar" to 0, 0, 150, kTop
   set the rect of field "HUD_Help" to 150, 0, tW, kTop
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
   put "<p></p><p><font color=" & quote & "#8888A0" & quote & ">Click a line to fly there. B shows only red and pink.</font></p>" after tH
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
         put not sBlockersOnly or sKind[tName] is among the items of "block,review" into tOn
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
   put pmFolder() & "/tools/make_map.py" into tPath
   if tPath begins with "//wsl$/Ubuntu" or tPath begins with "//wsl.localhost/Ubuntu" then
      set the itemDelimiter to "/"
      put "/" & item 5 to -1 of tPath into tPath
      put "wsl.exe python3 -I " & quote & tPath & quote into tCmd
   else
      put "python3 -I " & quote & tPath & quote into tCmd
   end if
   put "Rebuilding..." into field "HUD_Help"
   put shell(tCmd) into tOut
   pmBuild true
   put "Rebuilt:" && line 1 of tOut into field "HUD_Help"
end pmRebuild

---------------------------------------------------------------- the mouse and keys
on mouseDown pButton
   local tName
   put the short name of the target into tName
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
   end if
end mouseMove

on mouseUp pButton
   local tWas, tMoved
   put sDrag into tWas
   put empty into sDrag
   if tWas is empty then pass mouseUp
   put abs(item 1 of the mouseLoc - item 1 of sDragStart) + abs(item 2 of the mouseLoc - item 2 of sDragStart) > 4 into tMoved
   if tMoved then
      if char 1 to 2 of tWas is "P:" then pmSavePositions
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
      end if
   else
      pmFocus tWas
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
   if char 1 to 2 of tName is "C:" then pmFlyTo tName
end pmPanelClick

on rawKeyDown pKey
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
   put pChip into sMenuChip
   set the text of button "HUD_Popup" to pmFilesMenu(pChip)
   popup button "HUD_Popup" at the mouseLoc
end pmPopupFiles

-- the popup's text for a chip's files; fills sMenuMap for menuPick
function pmFilesMenu pChip
   local tFiles, tLine, tGroups, tGroup, tMenu, tLabel, tCount
   put the cFiles of field pChip into tFiles
   put empty into sMenuMap
   set the itemDelimiter to tab
   repeat for each line tLine in tFiles
      if item 1 of tLine is not among the lines of tGroups then put item 1 of tLine & return after tGroups
   end repeat
   put "(" & the number of lines of tFiles && "files: open one, or mark it Reviewed / give Feedback" & return & "-" & return into tMenu
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
-- (Open in Explorer / Reviewed / Feedback...); a loose file opens at once. pIndent = the tabs before it.
function pmMenuItem pParent, pLine, pIndent
   local tLabel, tN, tOut, tAction
   set the itemDelimiter to tab
   put pmMenuSafe(item 2 of pLine) into tLabel
   if item 4 of pLine is 1 then put tLabel && "[folder]" into tLabel
   put 1 into tN
   repeat while sMenuMap[pParent & tLabel] is not empty
      add 1 to tN
      put pmMenuSafe(item 2 of pLine) && "#" & tN into tLabel
   end repeat
   put item 3 of pLine & tab & item 4 of pLine & tab & item 5 of pLine into sMenuMap[pParent & tLabel]
   put pIndent & tLabel & return into tOut
   if item 5 of pLine is 1 then
      repeat for each line tAction in ("Open in Explorer" & return & "Reviewed" & return & "Feedback...")
         put pIndent & tab & tAction & return after tOut
      end repeat
   end if
   return tOut
end pmMenuItem

-- menu text treats ( ! - / & and | as commands: keep them out of labels
function pmMenuSafe pText
   replace "&" with "+" in pText
   replace "/" with "-" in pText
   replace "|" with "-" in pText
   replace tab with " " in pText
   if char 1 of pText is among the items of "(,!,-" then put " " before pText
   return pText
end pmMenuSafe

on menuPick pItem
   local tHit, tAction, tKey
   if the short name of the target is not "HUD_Popup" then pass menuPick
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
   put "Reviewed:" && pmLastPart(pWinPath) & "   (T tells Claude)" into field "HUD_Help"
end pmMarkReviewed

command pmFeedback pWinPath
   local tText
   ask "Feedback on" && pmLastPart(pWinPath) & ":"
   if the result is "Cancel" or it is empty then exit pmFeedback
   put it into tText
   replace return with " " in tText
   replace tab with " " in tText
   pmAppendLine "REVIEW_FEEDBACK.txt", the short date && the long time & tab & pWinPath & tab & tText
   put "Feedback saved:" && pmLastPart(pWinPath) & "   (T tells Claude)" into field "HUD_Help"
end pmFeedback

command pmTellClaude
   pmAppendLine "TELL_CLAUDE.txt", the short date && the long time & tab & "tell" & tab & "from the Project Map"
   put "Told Claude" && the short time into field "HUD_Help"
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
      put "Path:" && pWinPath into field "HUD_Help"
      exit pmExplore
   end if
   set the hideConsoleWindows to true
   if pIsFolder is 1 then
      put "start " & quote & quote & " explorer.exe " & quote & pWinPath & quote into tCmd
   else
      put "start " & quote & quote & " explorer.exe /select," & quote & pWinPath & quote into tCmd
   end if
   get shell(tCmd)
   put "Explorer:" && pWinPath into field "HUD_Help"
end pmExplore

---------------------------------------------------------------- red chips: feedback and files on a blocker
-- LIB_LLMIN/LIB_DEV/MAP_NOTES.txt, one line each:
--   date time TAB part TAB the blocker's words TAB feedback|file TAB the text, or a file's Windows path
-- for_review.py feedback prints it at every session start.
command pmPopupBlock pChip
   local tMenu
   put empty into sMenuMap
   put pChip into sMenuChip
   put "(About this blocker" & return & "Feedback on this blocker..." & return & "Select file(s) for Claude..." & return into tMenu
   if the cFiles of field pChip is not empty then put "-" & return & pmFilesMenu(pChip) after tMenu
   set the text of button "HUD_Popup" to tMenu
   popup button "HUD_Popup" at the mouseLoc
end pmPopupBlock

command pmBlockFeedback pChip
   local tText
   ask "Feedback on:" && pmBlockWords(pChip)
   if the result is "Cancel" or it is empty then exit pmBlockFeedback
   put it into tText
   replace return with " " in tText
   replace tab with " " in tText
   pmBlockNote pChip, "feedback", tText
   put "Feedback saved on the blocker   (T tells Claude)" into field "HUD_Help"
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
   put tN && "file path(s) passed to Claude for this blocker   (T tells Claude)" into field "HUD_Help"
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
