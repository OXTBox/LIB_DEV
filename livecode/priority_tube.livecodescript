script "priority_tube"
-- Priority Tube: what to do, as bubbles in a glass tube; the top is done first.
-- Claude's first order: shortest Claude time first, leaning to fun (fun x0.75, utility x0.85).
-- The owner's order wins: drag a bubble anywhere (dragging selects it), or select one and use the
-- up / down arrows (Shift = to the top / the bottom). A moved bubble is "placed by you"; new bubbles
-- slot in by Claude's rule around it.
-- Data: items.txt beside the stack (tools/tube_items.py: board comments + the Project Map's next steps,
-- with Claude's sizes from claude_sizes.txt). The order: LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt.
-- Remove: select a bubble, then Delete (or Backspace, or the panel's "Remove from the tube"): it leaves
-- the tube for good, written to LIB_LLMIN/LIB_DEV/TUBE_REMOVED.txt (Claude does not work on it). U brings
-- back the last one removed.
-- Keys: arrows move the selected bubble, wheel scrolls, Delete removes, U undoes a removal, R reload,
-- T tell Claude, Esc deselect.

local sIds      -- the ids, top first, one a line
local sItem     -- id -> its items.txt line: id source minutes kind score title detail why
local sPlaced   -- id -> owner | claude
local sTopOf    -- id -> its top in the tube (before scrolling)
local sHOf      -- id -> its height
local sSel      -- the selected id
local sDrag, sGrab, sDragFrom
local sScroll   -- how far the tube is scrolled
local sRemoved  -- the ids taken off the tube (TUBE_REMOVED.txt), one a line

constant kTop = 44
constant kPanelW = 380
constant kGap = 8

---------------------------------------------------------------- opening and closing
on preOpenStack
   set the title of this stack to "FOR OWNER | Priority Tube"
   set the resizable of this stack to true
   set the backgroundColor of this stack to "10,10,14"
   set the minWidth of this stack to 760
   set the minHeight of this stack to 480
   ptBuild
end preOpenStack

on closeStackRequest
   set the destroyStack of this stack to true
   close stack (the mainStack of this stack)
end closeStackRequest

on resizeStack
   ptLayout
end resizeStack

function ptFolder
   local tPath
   put the effective fileName of this stack into tPath
   set the itemDelimiter to "/"
   return item 1 to -2 of tPath
end ptFolder

function ptInboxFile pName
   local tPath
   put ptFolder() into tPath
   set the itemDelimiter to "/"
   return item 1 to -3 of tPath & "/LIB_LLMIN/LIB_DEV/" & pName
end ptInboxFile

function ptRead pPath
   if there is not a file pPath then return empty
   return textDecode(URL ("binfile:" & pPath), "UTF-8")
end ptRead

---------------------------------------------------------------- the items and the order
command ptBuild
   local tLine, tId, tOrder, tNew, tItems
   put empty into sItem
   put empty into sPlaced
   put empty into sIds
   put empty into sScroll
   put empty into sRemoved
   set the itemDelimiter to tab
   repeat for each line tLine in ptRead(ptInboxFile("TUBE_REMOVED.txt"))
      if char 1 of tLine is "#" or tLine is empty then next repeat
      put item 2 of tLine & return after sRemoved
   end repeat
   put ptRead(ptFolder() & "/items.txt") into tItems
   repeat for each line tLine in tItems
      if tLine is empty then next repeat
      if item 1 of tLine is among the lines of sRemoved then next repeat
      put tLine into sItem[item 1 of tLine]
      put item 1 of tLine & return after tNew -- in Claude's order (items.txt is sorted)
   end repeat
   -- the saved order first, as it was (the owner's word wins), then new bubbles slotted in
   repeat for each line tLine in ptRead(ptInboxFile("PRIORITY_ORDER.txt"))
      if char 1 of tLine is "#" then next repeat
      put item 2 of tLine into tId
      if sItem[tId] is empty or tId is among the lines of tOrder then next repeat
      put tId & return after tOrder
      put item 3 of tLine into sPlaced[tId]
   end repeat
   repeat for each line tId in tNew
      if tId is among the lines of tOrder then next repeat
      put ptSlotIn(tId, tOrder) into tOrder
      put "claude" into sPlaced[tId]
   end repeat
   put tOrder into sIds
   if sSel is not empty and sItem[sSel] is empty then put empty into sSel
   ptMakeControls
   ptLayout
   ptSaveOrder
end ptBuild

-- a new bubble goes just above the first bubble that Claude would put after it
function ptSlotIn pId, pOrder
   local tScore, i
   put ptItem(pId, 5) into tScore
   repeat with i = 1 to the number of lines of pOrder
      if ptItem(line i of pOrder, 5) > tScore then
         put pId & return before line i of pOrder
         return pOrder
      end if
   end repeat
   return pOrder & pId & return
end ptSlotIn

function ptItem pId, pN
   set the itemDelimiter to tab
   return item pN of sItem[pId]
end ptItem

-- LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt: the whole order, top first
command ptSaveOrder
   local tOut, tId, i
   put "# The owner's priority order for Claude: top first. Claude works from the top." & return into tOut
   put "# Made by the Priority Tube (LIB_DEV/PriorityTube); placed by: owner = the owner moved it, claude = Claude's first order." & return after tOut
   put "# rank, id, placed by, Claude minutes, kind, title" & return after tOut
   repeat for each line tId in sIds
      add 1 to i
      put i & tab & tId & tab & sPlaced[tId] & tab & ptItem(tId, 3) & tab & ptItem(tId, 4) & tab & ptItem(tId, 6) & return after tOut
   end repeat
   put textEncode(tOut, "UTF-8") into URL ("binfile:" & ptInboxFile("PRIORITY_ORDER.txt"))
end ptSaveOrder

---------------------------------------------------------------- controls
command ptMakeControls
   local i, tName, tId
   lock screen
   lock messages
   repeat with i = the number of controls of this card down to 1
      put the short name of control i of this card into tName
      if char 1 to 2 of tName is among the items of "G:,B:" or tName is among the items of "Tube,TubeTop,TubeBottom,Bar,Panel" then delete control i of this card
   end repeat
   create field "Bar"
   ptStyle "Bar", "22,22,28", "235,235,235"
   set the textSize of field "Bar" to 13
   set the htmlText of field "Bar" to "<p><b>PRIORITY TUBE</b>&nbsp;&nbsp;&nbsp;<font color=" & quote & "#A0A0B4" & quote & ">top = done first | drag a bubble to move it (dragging selects) | up / down arrows move the selected one, Shift = to the top / bottom | wheel scrolls  | Delete removes the selected | U brings it back | R reload | T tell Claude</font></p>"
   create graphic "Tube"
   set the style of graphic "Tube" to "roundrect"
   set the roundRadius of graphic "Tube" to 46
   set the opaque of graphic "Tube" to true
   set the backgroundColor of graphic "Tube" to "16,22,30"
   set the foregroundColor of graphic "Tube" to "130,185,215"
   set the lineSize of graphic "Tube" to 3
   set the antialiased of graphic "Tube" to true
   create field "TubeTop"
   ptStyle "TubeTop", "10,10,14", "130,185,215"
   set the textAlign of field "TubeTop" to "center"
   set the htmlText of field "TubeTop" to "<p><b>DO FIRST</b></p>"
   create field "TubeBottom"
   ptStyle "TubeBottom", "10,10,14", "90,110,130"
   set the textAlign of field "TubeBottom" to "center"
   put "later" into field "TubeBottom"
   repeat for each line tId in sIds
      create graphic ("G:" & tId)
      set the style of graphic ("G:" & tId) to "roundrect"
      set the opaque of graphic ("G:" & tId) to true
      set the antialiased of graphic ("G:" & tId) to true
      create field ("B:" & tId)
      ptStyle "B:" & tId, empty, "255,255,255"
      set the opaque of field ("B:" & tId) to false
      set the textSize of field ("B:" & tId) to 13
   end repeat
   create field "Panel"
   ptStyle "Panel", "18,18,24", "235,235,235"
   set the showBorder of field "Panel" to true
   set the borderColor of field "Panel" to "60,60,72"
   set the borderWidth of field "Panel" to 1
   set the margins of field "Panel" to 12
   set the vScrollbar of field "Panel" to true
   set the textSize of field "Panel" to 13
   unlock messages
   ptFillBubbles
   ptFillPanel
   unlock screen
end ptMakeControls

command ptStyle pName, pFill, pInk
   if pFill is not empty then
      set the opaque of field pName to true
      set the backgroundColor of field pName to pFill
   end if
   set the textColor of field pName to pInk
   set the showBorder of field pName to false
   set the threeD of field pName to false
   set the lockText of field pName to true
   set the traversalOn of field pName to false
   set the dontWrap of field pName to false
   set the vScrollbar of field pName to false
   set the showFocusBorder of field pName to false
   set the margins of field pName to 4
end ptStyle

function ptColour pKind
   switch pKind
      case "utility"
         return "28,135,170"
      case "fun"
         return "196,58,166"
      case "fix"
         return "46,150,78"
      case "plan"
         return "116,96,196"
      case "big"
         return "44,62,160"
      case "note"
         return "78,78,90"
   end switch
   return "36,36,44"
end ptColour

-- a bubble's height: a small one is quick work for Claude, a big one long work
function ptHeight pId
   local tMin
   put ptItem(pId, 3) into tMin
   if tMin is not a number then return 50
   return min(140, 46 + round(16 * ln(1 + tMin / 10) / ln(2)))
end ptHeight

command ptFillBubbles
   local tId, tKind, tMin, tInfo, tH
   repeat for each line tId in sIds
      put ptItem(tId, 4) into tKind
      put ptItem(tId, 3) into tMin
      if tMin is a number then
         put "~" & ptMinutes(tMin) && "of Claude, " & tKind into tInfo
      else
         put "not sized by Claude yet" into tInfo
      end if
      if sPlaced[tId] is "owner" then put tInfo & ", placed by you" into tInfo
      set the backgroundColor of graphic ("G:" & tId) to ptColour(tKind)
      set the htmlText of field ("B:" & tId) to "<p><b>" & ptHtml(ptItem(tId, 6)) & "</b></p><p><font size=11 color=" & quote & "#E6E6F0" & quote & ">" & ptHtml(tInfo) & "</font></p>"
      ptMarkSelected tId
   end repeat
end ptFillBubbles

function ptMinutes pMin
   if pMin is not a number then return "not sized by Claude yet"
   if pMin < 60 then return pMin && "min"
   if pMin mod 60 is 0 then return pMin div 60 && "h"
   return pMin div 60 & "h" & format("%02d", pMin mod 60)
end ptMinutes

command ptMarkSelected pId
   if there is not a graphic ("G:" & pId) then exit ptMarkSelected
   if pId is sSel then
      set the foregroundColor of graphic ("G:" & pId) to "255,255,255"
      set the lineSize of graphic ("G:" & pId) to 4
   else
      set the foregroundColor of graphic ("G:" & pId) to "200,220,235"
      set the lineSize of graphic ("G:" & pId) to 1
   end if
end ptMarkSelected

function ptHtml pText
   replace "&" with "&amp;" in pText
   replace "<" with "&lt;" in pText
   replace ">" with "&gt;" in pText
   return pText
end ptHtml

---------------------------------------------------------------- layout
-- the tube's inside, on screen: left, top, right, bottom
function ptTubeRect
   local tW, tH
   put the width of this card into tW
   put the height of this card into tH
   return 30 & "," & (kTop + 34) & "," & min(tW - kPanelW - 30, 30 + 640) & "," & (tH - 34)
end ptTubeRect

command ptLayout
   local tR, tY, tId, tH
   if there is not a field "Bar" then exit ptLayout
   lock screen
   put ptTubeRect() into tR
   set the rect of field "Bar" to 0, 0, the width of this card, kTop
   set the rect of graphic "Tube" to item 1 of tR - 6, item 2 of tR - 6, item 3 of tR + 6, item 4 of tR + 6
   set the rect of field "TubeTop" to item 1 of tR, kTop + 6, item 3 of tR, item 2 of tR - 8
   set the rect of field "TubeBottom" to item 1 of tR, item 4 of tR + 8, item 3 of tR, the height of this card
   set the rect of field "Panel" to the width of this card - kPanelW, kTop, the width of this card, the height of this card
   put item 2 of tR + 14 into tY
   repeat for each line tId in sIds
      put ptHeight(tId) into tH
      put tY into sTopOf[tId]
      put tH into sHOf[tId]
      add tH + kGap to tY
   end repeat
   put max(0, min(sScroll + 0, tY - item 4 of tR)) into sScroll
   repeat for each line tId in sIds
      if tId is not sDrag then ptPlace tId, sTopOf[tId] - sScroll
   end repeat
   unlock screen
end ptLayout

-- one bubble at a screen top; hidden outside the tube
command ptPlace pId, pTop
   local tR, tL, tRi, tH, tTextH
   put ptTubeRect() into tR
   put sHOf[pId] into tH
   put item 1 of tR + 10 into tL
   put item 3 of tR - 10 into tRi
   set the roundRadius of graphic ("G:" & pId) to tH
   set the rect of graphic ("G:" & pId) to tL, pTop, tRi, pTop + tH
   set the rect of field ("B:" & pId) to tL + tH div 3, pTop + 4, tRi - tH div 3, pTop + tH - 4
   -- the words in the middle of the bubble
   put min(tH - 8, the formattedHeight of field ("B:" & pId)) into tTextH
   set the rect of field ("B:" & pId) to tL + tH div 3, pTop + (tH - tTextH) div 2, tRi - tH div 3, pTop + (tH - tTextH) div 2 + tTextH
   set the visible of graphic ("G:" & pId) to (pTop + tH > item 2 of tR - 4 and pTop < item 4 of tR + 4) or pId is sDrag
   set the visible of field ("B:" & pId) to the visible of graphic ("G:" & pId)
end ptPlace

---------------------------------------------------------------- the right panel
command ptFillPanel
   local tH, tId
   put sSel into tId
   put "<p><font size=16><b>THE ORDER</b></font></p><p></p>" into tH
   if tId is empty then
      put "<p>The top of the tube is done first.</p><p></p>" after tH
      put "<p><b>Claude's first order:</b> the shortest Claude time first, so the fast things and the utility things get done, leaning to fun (fun counts 3/4 of its time, utility 0.85).</p><p></p>" after tH
      put "<p><b>Your order wins:</b> drag a bubble you want more over the others, time be damned. Dragging selects it; then the up and down arrows move it too (Shift: to the top or the bottom).</p><p></p>" after tH
      put "<p>A bubble's size is Claude's time; its colour is its kind:</p>" after tH
      repeat for each item tId in "utility,fun,fix,plan,big,note"
         put "<p><font bgcolor=" & quote & ptHex(ptColour(tId)) & quote & ">&nbsp;&nbsp;" & tId & "&nbsp;&nbsp;</font></p>" after tH
      end repeat
      put "<p></p><p><font color=" & quote & "#8888A0" & quote & ">" & the number of lines of sIds && "bubbles. The order is saved for Claude in LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt at every move.</font></p>" after tH
      put "<p></p><p><b>To take a bubble off the tube for good:</b> select it, then Delete (or its Remove line here). U brings back the last one removed.</p>" after tH
      if sRemoved is not empty then
         put "<p><font color=" & quote & "#8888A0" & quote & ">" & the number of lines of sRemoved && "removed so far (LIB_LLMIN/LIB_DEV/TUBE_REMOVED.txt).</font></p>" after tH
      end if
   else
      put "<p><font size=15><b>" & ptHtml(ptItem(tId, 6)) & "</b></font></p><p></p>" after tH
      put "<p><b>Number</b> " & lineOffset(tId, sIds) && "of" && the number of lines of sIds & "</p>" after tH
      put "<p><b>Claude's time</b> " & ptHtml(ptMinutes(ptItem(tId, 3))) & ", " & ptHtml(ptItem(tId, 4)) & "</p>" after tH
      put "<p><b>Why</b> " & ptHtml(ptItem(tId, 8)) & "</p>" after tH
      put "<p><b>Placed by</b> " & ptPlacedWords(tId) & "</p><p></p>" after tH
      put "<p><b>From</b> " & ptHtml(ptItem(tId, 2)) & "</p>" after tH
      put "<p><font color=" & quote & "#C8C8D8" & quote & ">" & ptHtml(ptItem(tId, 7)) & "</font></p><p></p>" after tH
      put "<p><font color=" & quote & "#8888A0" & quote & ">Up / down arrows move it, Shift to the top / bottom. Esc or a click on the black deselects.</font></p><p></p>" after tH
      put "<p><font color=" & quote & "#FF8C8C" & quote & "><a href=" & quote & "remove" & quote & ">Remove from the tube</a></font><font color=" & quote & "#8888A0" & quote & ">&nbsp;&nbsp;(Delete key; U brings it back)</font></p>" after tH
   end if
   set the htmlText of field "Panel" to tH
end ptFillPanel

function ptPlacedWords pId
   if sPlaced[pId] is "owner" then return "you"
   return "Claude's first order"
end ptPlacedWords

function ptHex pRGB
   return "#" & format("%02X%02X%02X", item 1 of pRGB, item 2 of pRGB, item 3 of pRGB)
end ptHex

---------------------------------------------------------------- moving bubbles
command ptSelect pId
   local tWas
   put sSel into tWas
   put pId into sSel
   if tWas is not empty then ptMarkSelected tWas
   if pId is not empty then ptMarkSelected pId
   ptFillPanel
end ptSelect

-- move a bubble to place pIndex (1 = the top); it is now placed by the owner
command ptMoveTo pId, pIndex
   local tN, tOld
   put lineOffset(pId, sIds) into tOld
   if tOld is 0 then exit ptMoveTo
   delete line tOld of sIds
   put the number of lines of sIds into tN
   put max(1, min(tN + 1, pIndex)) into pIndex
   if pIndex > tN then
      put pId & return after sIds
   else
      put pId & return before line pIndex of sIds
   end if
   if the last char of sIds is not return then put return after sIds
   put "owner" into sPlaced[pId]
   ptSaveOrder
   ptFillBubbles
   ptFillPanel
   ptLayout
   ptShow pId
end ptMoveTo

-- a dropped bubble: its place is where its middle lands among the others' middles
command ptDrop pId, pMiddleY
   local tIndex, tOther
   put 1 into tIndex
   repeat for each line tOther in sIds
      if tOther is pId then next repeat
      if sTopOf[tOther] - sScroll + sHOf[tOther] / 2 < pMiddleY then add 1 to tIndex
   end repeat
   ptMoveTo pId, tIndex
end ptDrop

-- scroll so the bubble shows
command ptShow pId
   local tR, tTop
   put ptTubeRect() into tR
   put sTopOf[pId] - sScroll into tTop
   if tTop < item 2 of tR then
      subtract item 2 of tR - tTop + 10 from sScroll
   else if tTop + sHOf[pId] > item 4 of tR then
      add tTop + sHOf[pId] - item 4 of tR + 10 to sScroll
   else
      exit ptShow
   end if
   ptLayout
end ptShow

function ptIdOf pName
   if char 1 to 2 of pName is among the items of "G:,B:" then return char 3 to -1 of pName
   return empty
end ptIdOf

on mouseDown pButton
   local tId
   if pButton is not 1 then pass mouseDown
   put ptIdOf(the short name of the target) into tId
   if tId is empty then
      if the short name of the target is not "Panel" then ptSelect empty
      pass mouseDown
   end if
   ptSelect tId
   put tId into sDrag
   put item 2 of the mouseLoc - the top of graphic ("G:" & tId) into sGrab
   put the mouseLoc into sDragFrom
   set the layer of graphic ("G:" & tId) to top
   set the layer of field ("B:" & tId) to top
end mouseDown

on mouseMove pX, pY
   if sDrag is empty then pass mouseMove
   if the mouse is up then
      put empty into sDrag
      exit mouseMove
   end if
   ptPlace sDrag, pY - sGrab
end mouseMove

on mouseUp pButton
   local tId
   if sDrag is empty then pass mouseUp
   put sDrag into tId
   put empty into sDrag
   if abs(item 2 of the mouseLoc - item 2 of sDragFrom) < 5 then
      ptLayout
      exit mouseUp
   end if
   ptDrop tId, the top of graphic ("G:" & tId) + sHOf[tId] / 2
end mouseUp

on mouseRelease
   if sDrag is not empty then
      put empty into sDrag
      ptLayout
   end if
end mouseRelease

on arrowKey pDir
   local tAt
   if sSel is empty or pDir is not among the items of "up,down" then pass arrowKey
   put lineOffset(sSel, sIds) into tAt
   if the shiftKey is down then
      if pDir is "up" then ptMoveTo sSel, 1
      else ptMoveTo sSel, the number of lines of sIds
   else
      if pDir is "up" then ptMoveTo sSel, tAt - 1
      else ptMoveTo sSel, tAt + 1
   end if
end arrowKey

on rawKeyDown pKey
   -- the wheel: 65308 down, 65309 up
   if pKey is 65309 then
      subtract 60 from sScroll
      ptLayout
   else if pKey is 65308 then
      add 60 to sScroll
      ptLayout
   else
      pass rawKeyDown
   end if
end rawKeyDown

on keyDown pChar
   switch pChar
      case "r"
         ptReload
         break
      case "t"
         ptTell
         break
      case "u"
         ptUnremove
         break
      default
         pass keyDown
   end switch
end keyDown

on escapeKey
   ptSelect empty
end escapeKey

---------------------------------------------------------------- removing bubbles
-- take a bubble off the tube for good: a line in LIB_LLMIN/LIB_DEV/TUBE_REMOVED.txt
command ptRemove pId
   local tFile, tText, tAt, tNext, tScroll
   if pId is empty or pId is not among the lines of sIds then exit ptRemove
   put lineOffset(pId, sIds) into tAt
   put ptInboxFile("TUBE_REMOVED.txt") into tFile
   put ptRead(tFile) into tText
   if tText is empty then
      put "# Bubbles the owner took off the Priority Tube: Claude does not work on them. U in the tube brings back the last." & return into tText
      put "# date time, id, title" & return after tText
   end if
   if the last char of tText is not return then put return after tText
   put the short date && the long time & tab & pId & tab & ptItem(pId, 6) & return after tText
   put textEncode(tText, "UTF-8") into URL ("binfile:" & tFile)
   put sScroll into tScroll
   ptBuild
   put tScroll into sScroll
   -- the bubble that took its place is selected, so Delete can go on down the tube
   put line min(tAt, the number of lines of sIds) of sIds into tNext
   ptSelect tNext
   ptLayout
   set the htmlText of field "Bar" to "<p><b>PRIORITY TUBE</b>&nbsp;&nbsp;&nbsp;<font color=" & quote & "#FFE88C" & quote & ">Removed:" && ptHtml(ptRemovedTitle(pId)) & "&nbsp;&nbsp;&nbsp;U brings it back</font></p>"
end ptRemove

-- bring back the last bubble removed (it slots in again by Claude's rule)
command ptUnremove
   local tFile, tText, tLine, tId, tScroll, i
   put ptInboxFile("TUBE_REMOVED.txt") into tFile
   put ptRead(tFile) into tText
   repeat with i = the number of lines of tText down to 1
      put line i of tText into tLine
      if char 1 of tLine is "#" or tLine is empty then next repeat
      set the itemDelimiter to tab
      put item 2 of tLine into tId
      delete line i of tText
      exit repeat
   end repeat
   if tId is empty then exit ptUnremove
   put textEncode(tText, "UTF-8") into URL ("binfile:" & tFile)
   put sScroll into tScroll
   ptBuild
   put tScroll into sScroll
   if tId is among the lines of sIds then
      ptSelect tId
      ptLayout
      ptShow tId
   end if
   set the htmlText of field "Bar" to "<p><b>PRIORITY TUBE</b>&nbsp;&nbsp;&nbsp;<font color=" & quote & "#FFE88C" & quote & ">Brought back:" && ptHtml(ptItem(tId, 6)) & "</font></p>"
end ptUnremove

function ptRemovedTitle pId
   local tLine
   set the itemDelimiter to tab
   repeat for each line tLine in ptRead(ptInboxFile("TUBE_REMOVED.txt"))
      if item 2 of tLine is pId then return item 3 of tLine
   end repeat
   return pId
end ptRemovedTitle

on deleteKey
   if sSel is empty then pass deleteKey
   ptRemove sSel
end deleteKey

on backspaceKey
   if sSel is empty then pass backspaceKey
   ptRemove sSel
end backspaceKey

on linkClicked pLink
   if pLink is "remove" and sSel is not empty then ptRemove sSel
end linkClicked

---------------------------------------------------------------- reload and tell
command ptReload
   local tCmd, tPath
   put ptFolder() & "/tools/tube_items.py" into tPath
   if tPath begins with "//wsl$/Ubuntu" or tPath begins with "//wsl.localhost/Ubuntu" then
      set the itemDelimiter to "/"
      put "/" & item 5 to -1 of tPath into tPath
      put "wsl.exe python3 -I " & quote & tPath & quote into tCmd
   else
      put "python3 -I " & quote & tPath & quote into tCmd
   end if
   get shell(tCmd)
   ptBuild
end ptReload

command ptTell
   local tFile, tText
   put ptInboxFile("TELL_CLAUDE.txt") into tFile
   put ptRead(tFile) into tText
   if tText is not empty and the last char of tText is not return then put return after tText
   put the short date && the long time & tab & "tell" & tab & "from the Priority Tube" & return after tText
   put textEncode(tText, "UTF-8") into URL ("binfile:" & tFile)
   set the htmlText of field "Bar" to "<p><b>PRIORITY TUBE</b>&nbsp;&nbsp;&nbsp;<font color=" & quote & "#FFE88C" & quote & ">Told Claude" && the short time & "</font></p>"
end ptTell

-- for checks: the order now
function sIdsNow
   return sIds
end sIdsNow
