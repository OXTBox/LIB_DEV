script "Shape Lab"
######################################################################################
## STACK: "Shape Lab"  (LIB_DEV/livecode, 16 Nov 2026, Opus)
## Scott Rossi's WindowLab, remade on the WindowShape library (window_shape.livecodescript
## beside this file): make a window any shape, or paint one.
##   Rectangle / Rounded / Oval / Circle   a ready-made outline for the test window
##   Image File...                         any PNG or GIF: where it is transparent, no window
##   Paint                                 the test window turns magenta: paint the window
##                                         (white) with the brush, Eraser takes it away;
##   Done Painting                         what you painted is the window
##   Ordinary                              the plain rectangle again
## The test window has no title bar: drag it by its body, double-click it to close it.
## The window is made by Lab.Build when the stack opens; nothing is kept in the file.
######################################################################################

constant kTest = "Shape Lab Window"

on openStack
   if the short name of the owner of the target is not the short name of me then pass openStack
   Lab.Start
end openStack

on closeStackRequest
   if the short name of the owner of the target is not the short name of me then pass closeStackRequest
   if there is a stack kTest then
      set the destroyStack of stack kTest to true
      close stack kTest
   end if
   set the destroyStack of me to true
   pass closeStackRequest
end closeStackRequest

command Lab.Start
   local tLib
   set the itemDelimiter to "/"
   put item 1 to -2 of the effective filename of me & "/window_shape.livecodescript" into tLib
   set the itemDelimiter to comma
   if not ("WindowShape" is among the lines of the stacksInUse) then start using stack tLib
   set the title of me to "FOR OWNER | Shape Lab"
   dispatch "Users.TitleStack" with the short name of me, "Shape Lab"   -- LIB_USERS words it, when in use
   Lab.Build
end Lab.Start

-- the lab's controls, made fresh each time
command Lab.Build
   local tY, tName, tB
   lock screen
   lock messages
   repeat while the number of controls of card 1 of me > 0
      delete control 1 of card 1 of me
   end repeat
   set the width of me to 250
   set the height of me to 372
   set the backgroundColor of me to "#101418"
   create field "Info" in card 1 of me
   set the rect of field "Info" of me to 8, 8, 242, 74
   set the lockText of field "Info" of me to true
   set the opaque of field "Info" of me to false
   set the showBorder of field "Info" of me to false
   set the textColor of field "Info" of me to "#C8E8C8"
   set the textSize of field "Info" of me to 11
   put "Make the test window any shape. It has no title bar:" && \
         "drag it by its body, double-click it to close it." && \
         "Paint: white is window, the eraser takes it away." into field "Info" of me
   put 80 into tY
   repeat for each item tName in "Rectangle,Rounded,Oval,Circle,Image File...,Paint,Done Painting,Ordinary"
      Lab.Button tName, 8, tY, 120
      add 26 to tY
   end repeat
   put 80 into tY
   repeat for each item tName in "Small brush,Medium brush,Large brush,Clear Paint"
      Lab.Button tName, 136, tY, 106
      add 26 to tY
   end repeat
   create button "Eraser" in card 1 of me
   set the style of button "Eraser" of me to "checkbox"
   set the textColor of button "Eraser" of me to "#C8E8C8"
   set the rect of button "Eraser" of me to 136, tY, 242, tY + 22
   set the script of button "Eraser" of me to "on mouseUp" & cr & "   Shape.Eraser the hilite of me" & cr & "end mouseUp"
   create field "Status" in card 1 of me
   set the rect of field "Status" of me to 8, 296, 242, 364
   set the lockText of field "Status" of me to true
   set the opaque of field "Status" of me to false
   set the showBorder of field "Status" of me to false
   set the textColor of field "Status" of me to "#FFE080"
   set the textSize of field "Status" of me to 11
   unlock messages
   unlock screen
end Lab.Build

command Lab.Button pName, pX, pY, pW
   create button pName in card 1 of me
   set the rect of button pName of me to pX, pY, pX + pW, pY + 22
   set the script of button pName of me to "on mouseUp" & cr & "   Lab.Do the short name of me" & cr & "end mouseUp"
end Lab.Button

command Lab.Say pText
   if there is a field "Status" of me then put pText into field "Status" of me
end Lab.Say

-- a button was pressed
command Lab.Do pName
   local tFile
   switch pName
      case "Rectangle"
         Lab.TestWindow
         Shape.Make kTest, "rect", 300, 200
         Lab.Say "A rectangle, 300 x 200."
         break
      case "Rounded"
         Lab.TestWindow
         Shape.Make kTest, "round", 300, 200, 40
         Lab.Say "Rounded corners, 40."
         break
      case "Oval"
         Lab.TestWindow
         Shape.Make kTest, "oval", 320, 180
         Lab.Say "An oval, 320 x 180."
         break
      case "Circle"
         Lab.TestWindow
         Shape.Make kTest, "oval", 240, 240
         Lab.Say "A circle, 240 across."
         break
      case "Image File..."
         answer file "A PNG or GIF (its transparent parts are not window):"
         put it into tFile
         if tFile is empty then exit Lab.Do
         Lab.TestWindow
         Shape.FromFile kTest, tFile
         if the result is empty then
            Lab.Say "The window is the picture's outline."
         else
            Lab.Say the result
         end if
         break
      case "Paint"
         Lab.TestWindow
         Shape.PaintStart kTest, 320, 240
         Lab.Say "Paint in the magenta window (white is window), then Done Painting."
         break
      case "Done Painting"
         if there is not a stack kTest then exit Lab.Do
         Shape.PaintEnd kTest
         if the result is empty then
            Lab.Say "What you painted is the window."
         else
            Lab.Say the result & ": still painting."
         end if
         break
      case "Ordinary"
         if there is a stack kTest then Shape.Clear kTest
         Lab.Say "An ordinary window again."
         break
      case "Small brush"
         Shape.Brush 3
         Lab.Say "Small brush."
         break
      case "Medium brush"
         Shape.Brush 8
         Lab.Say "Medium brush."
         break
      case "Large brush"
         Shape.Brush 11
         Lab.Say "Large brush."
         break
      case "Clear Paint"
         if there is a stack kTest then Shape.PaintClear kTest
         Lab.Say "Nothing painted."
         break
   end switch
end Lab.Do

-- the test window: made once, beside the lab, coloured so its outline shows
command Lab.TestWindow
   local tWas
   if there is a stack kTest then
      choose browse tool
      if there is a graphic "WindowMaskGround" of stack kTest then set the visible of graphic "WindowMaskGround" of stack kTest to false
      if there is an image "WindowMask" of stack kTest then set the visible of image "WindowMask" of stack kTest to false
      exit Lab.TestWindow
   end if
   put the defaultStack into tWas
   lock messages
   create invisible stack kTest
   set the destroyStack of stack kTest to true
   set the backgroundColor of stack kTest to "#2A6AA0"
   set the rect of stack kTest to the right of me + 20, the top of me, the right of me + 340, the top of me + 220
   set the script of card 1 of stack kTest to "on mouseDown" & cr & "   if the tool is " & quote & "browse tool" & quote & " then Shape.DragWindow the short name of this stack" & cr & "end mouseDown" & cr & \
         "on mouseDoubleUp" & cr & "   close this stack" & cr & "end mouseDoubleUp"
   create field "Hint" in card 1 of stack kTest
   set the rect of field "Hint" of stack kTest to 20, 20, 280, 60
   set the lockText of field "Hint" of stack kTest to true
   set the opaque of field "Hint" of stack kTest to false
   set the showBorder of field "Hint" of stack kTest to false
   set the textColor of field "Hint" of stack kTest to "white"
   put "Drag me. Double-click to close." into field "Hint" of stack kTest
   unlock messages
   if there is a stack tWas then set the defaultStack to tWas
   if the environment is not "server" then show stack kTest
end Lab.TestWindow

-- test hook: the lab's state  shape id | width x height | painting
function Lab.State
   if there is not a stack kTest then return "none"
   return Shape.Current(kTest) & "|" & the width of stack kTest & "x" & the height of stack kTest & "|" & (there is a graphic "WindowMaskGround" of stack kTest and the visible of graphic "WindowMaskGround" of stack kTest)
end Lab.State
