# When we resume (written 17 Nov 2026, late, before a /clear)

The owner is going to use the boards **one note at a time and see what happens**. So the next session is
a loop, not a build:

1. **Start:** `python3 -I tools/for_review.py feedback` (prints BOARD_COMMENTS.txt and PRIORITY_ORDER.txt
   with the rest), and check LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt. While the owner is at the keyboard keep
   `tools/wait_for_tell.sh` running in the background (T on any board wakes it); never while he is away.
2. **A new comment:** size it in `PriorityTube/claude_sizes.txt` (id, Claude minutes, kind
   utility|fun|fix|plan|big|note, why), then `python3 -I PriorityTube/tools/tube_items.py` (it lists what is
   still unsized). Tell him to press R in the tube; the bubble slots in by Claude's rule.
3. **Work from the top** of PRIORITY_ORDER.txt. Never reorder a bubble he placed ("owner").
4. **A comment done:** append its line again to BOARD_COMMENTS.txt with state `done` (the last line of an
   id wins; boards and the tube show only `open`). Log it in LIB_LLMOUT/LIB_DEV/FEEDBACK_HANDLED.txt.
   A `next:` step done: change it in ProjectMap/board.txt (done: line), so its bubble leaves the tube.
5. **Watch and write down** what happens with the tube in use (he said "there's something there"; it
   echoes the old post-Antack T3D game menu). Change little until he asks; collect his reactions in
   PLAN.md section 5.

## Where things stand (updated 18 Nov, just after midnight)
- 17 Nov night, done from the tube (one helper agent per task kept memory small): LIB_GUI stages 1-2
  (branch gui-step1), Users.Title (LIB_USERS branch users-title) + 9 scripts moved to it (branches
  users-title / current), board menus "Leave comment..." / "Explore here...", On Git or Not step 4
  (GIT_DECISIONS.txt), tube Delete/U removal (TUBE_REMOVED.txt), comment window titles.
- LIB_MENU is its own LIB (owner); PLAN.md sections 5/5b = his iGame3D 2009/2013 Data/Scripts menus
  (one file per menu, Default set + user override, folder-filled Wizard menu). Steps 1-2 are bubbles.
- t40 now runs in its own folder (_work_t40). **t39 still backs up the real BOARD_COMMENTS /
  GIT_DECISIONS**: give it its own folder too before running it again and again.
- Waiting on the owner: look at LIB_GUI notes.gui; try the new board menus; "FOR OWNER" vs his name in
  titles; LIB_ALPHA rules 13/14 -> Users.Title; game pause menus follow LIB_MENU rules (dev mode only?).
- Next in his tube: Step code by Claude / Spark (needs his outline review), cellmap v3 follow-ups.

## Older (17 Nov evening)
- All of tonight's work is on LIB_DEV branch `on-git-or-not` (not merged): On Git or Not board,
  shared `livecode/board_canvas.livecodescript` (Project Map runs it too), right-click comments with
  yellow note nodes, the Priority Tube. Headless: OXT-BEYOND/tests t39 (48 checks), t40 (17 checks).
- Open in his OXT-Beyond: ProjectMap, OnGitOrNot, PriorityTube.
- Known small things: the last visible bubble pokes past the tube's bottom edge; On Git or Not step 4
  (Commit / Ignore / Delete / Leave clicks) is a bubble in the tube, not built.

## Traps learned tonight
- `set the script` of a stack fails while one of its scripts is paused in the debugger: stop_paused_script first.
- A popup button cannot be deleted while its menu is in use: the canvas now reuses HUD_Popup.
- xTalk chunks go big to small: `item 1 of char 3 to -1` does not compile.
- Apply a script to an open stack from a **sandbox** run (`set the script of stack X to textDecode(url ...)`,
  `send "pmBuild"`, `save stack X`): the fileName stays real (a where=stack run moves it to Temp).
- A test that throws skips its own cleanup: t39/t40 back up and restore the real inbox files, but only
  when they reach the end.
