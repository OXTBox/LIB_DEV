# Priority Tube: where we are

## LATEST (18 Nov 2026, late evening)
- The owner said "merge everything, commit everything". Done: every branch in every repo is on main
  (one clash, LIB_ig3d README, kept Fable's 16 Nov map whole). LIB_COMFY sits on main too.
- "Menu folders your way" (#4) is done (LIB_MENU, now on main).
- Tests after the merge: t22 and t28 fixed (they now add the alias file). Four tests still expect old
  counts: LIB_SYSTEM/ISSUES 0005 and 0006.
- The owner has a folder "Tests 18 Nov" on his Windows desktop: 5 shortcuts + WHAT TO TEST.txt.
  Read his notes from those tests first next session.
- Next bubble: #3 "A Library menu in a real stack". He picks: Status Browser or a game pause menu
  (Claude suggests Status Browser).

## READ THIS FIRST (written 18 Nov 2026, evening, before a /clear; weeks may pass)

### What got done on 18 Nov (evening)
1. **Menus now have a home in the Data folder.**
   - The Data folder (Documents/Data) has a new folder kind called `Menus`.
   - Each game or app gets its own folder in it: `Menus/<game or app name>/`.
   - The menu word lists go in that folder. The code the menus run goes in its `Functions/` folder inside it.
   - Code asks for the folder like this: `Data.MenuFolder("DeadDays")`, or `Data.MenuFolder("DeadDays", true)` for `Functions/`.
   - Where it lives: LIB_DATA, branch `data-menus`. The doc table in LIB_ig3d (`DATA_FOLDER.md`) is on a branch of the same name.
   - Test: `OXT-BEYOND/tests/t50_data_menus.txt`. 13 checks, all pass on both engines.
   - NOT done yet: LIB_MENU still reads its menus from the old place (`Scripts/Menus`). Moving it is the
     tube bubble "Menu folders your way".
2. **The Vector Toss branch got merged.** LIB_GAMES branch `vector-toss-dangle` went into `main` (the owner said yes).
   - Three files in the LIB_GAMES folder had old changes that were already on main: Hunter, engine_stubs and ComfyPong1.
     They were put in a git stash, not thrown away (`git stash list` in LIB_GAMES).
3. **Rename Day is finished for the games.** A helper moved Block City Hustle (27 places) and Vector Toss (16 places) to the new call names.
   - Where it lives: LIB_GAMES branch `rename-day-last4` (NOT merged). The LIB_GAMES folder is checked out on that branch now.
   - Tests: both games end the same as before, checked headless. The look was not checked on a screen.
   - The checker still counts 60 old names. That is expected:
     - Ig3dEditor has 28 of them. It is already fixed on LIB_EDITOR main, but the LIB_EDITOR folder sits on
       branch `editor-cards`, which does not have the fix yet. They go away when editor-cards takes main.
     - demo (19) and Simple_Test2 (13) are kept old on purpose (owner, 17 Nov).
   - One small leftover: Vector Toss line 524 still uses `the mouse is "down"`. The checker does not flag it.

### Waiting for the owner (merges: DONE 18 Nov late evening)
- Merge these branches when happy: LIB_DATA `data-menus`, LIB_ig3d `data-menus`, LIB_GAMES `rename-day-last4`.
  LIB_EDITOR `editor-cards` also needs to take main.
- Which comes first in the tube: #3 "A Library menu in a real stack" or #4 "Menu folders your way".
  Claude suggests #4 first, because #3 builds on it. #3 is the owner's bubble, so the owner decides.

### How to start next time (in plain steps)
1. Read `LIB_SYSTEM/LIB_ALPHA.md`, then this file.
2. Run `python3 -I tools/for_review.py feedback` in LIB_DEV. It shows the owner's comments and the tube order.
3. Do the bubble at the top of `LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt`. Never move a bubble the owner placed.
4. When a bubble is done:
   - Change its `next:` line in `ProjectMap/board.txt` to `done:`.
   - Add a line to `LIB_LLMOUT/LIB_DEV/FEEDBACK_HANDLED.txt`.
   - Add new files to the review list with `tools/for_review.py add`.
5. One helper agent per bubble (owner's rule). Headless tests run under `flock /tmp/oxt_headless.lock`.

### Traps met on 18 Nov
- `lcmcp compile` (LIB_MCP) hung for 2 minutes. Use the OXT-Beyond headless runner instead:
  `python3 -I OXT-BEYOND/tests/oxt_headless.py --engine both tNN.txt`.
- xTalk strings have no escapes: `"\\"` is TWO backslashes. One backslash is written `"\"`.
- Do not `pkill -f` with a pattern that is also in your own command line. It kills your own shell.

## The loop (written 17 Nov 2026, still true)

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

## FOR THE NEXT SESSION (18 Nov, afternoon, before a /clear) -- START HERE (done, see above)
Owner's order for the next session:
1. **Main session: "A Menus kind in LIB_DATA"** (bubble n-3a5a9676, ~15 min). LIB_MENU is on main
   (steps 1-2 merged). Mind his layout answer in LIB_MENU/NEXT.md step 0: menus live per game or app,
   `Data/Default/<game or app>/Menus/` (item lists) + `Menus/Functions/` (callbacks). Make the kind fit that.
2. **One helper agent: "The last 4 Rename Day games"** (bubble n-944ad4da, ~30 min). Brief:
   Next_Steps_With_Claude/FOR_OPUS_RENAME_DAY_STEP3_11_18_2026.md (+ TWO ENGINES note). It "waits for
   vector-toss-dangle to merge": LIB_GAMES is checked out on branch `vector-toss-dangle` (not merged);
   ask the owner whether to merge it first if the helper needs VectorToss.
Done this session: LIB_MENU merged to main + 3 sized next bubbles; GAD battles step 2 built, played
("working great"), bug 0004 fixed (Base followed the squad), merged to LIB_GAD main. Owner's two
BitEditor Heights-tab notes sized (c1795032797521, c1795033087850).

## Earlier (18 Nov, midday, before a /clear)
Done this session: LIB_SYSTEM notes (STATUS archived, operating prompt draft 2, DONE list), LIB_GUI popup
kind, Users.Title for built apps, battles plan (LIB_GAD `gad-battles`, step 2 waits for the owner's go).
Owner's tube rule: "We'll pile up big jobs until we can't find any old small ones left to push through":
take small/old bubbles first. Tube questions answered in chat: cellmap v3 tools are Opus work, not Fable;
Step 9 = TTRPG world code (keep or drop: no answer yet).

## Earlier (written 18 Nov, ~00:00 WSL clock; the long session was making the laptop hot)
Start a FRESH session (not --continue). Then:
1. **LIB_GUI popup kind** (owner: "yes we need a pop up kind of menu, but in a new session"): a `popup`
   widget kind in .gui (right-click menus, the LIB_MENU ending), and Gui.FromStack reading popups
   (the Status Browser's `ReviewMenu` was its one unknown control). Bubble n-e8a10791, ~40 min.
   LIB_GUI branch gui-step1; t41 has 221 checks.
2. **Editor cards**: E03, E04, E05, E06 are done and committed (LIB_EDITOR branch `editor-cards`).
   The helper was stopped (heat) in the middle of **E07** (pad opens door): uncommitted files in
   LIB_EDITOR: examples/E07_PadOpensDoor.livecodescript, tests/e07_headless.txt,
   tests/_engine_stubs.livecodescript, changes to maps/cards_yard.cellmap and tools/make_card_maps.py.
   Check them, finish E07, then E08-E12, E14, E15.
3. **Status Browser**: copy the owner's wheel-zoom (scaleFactor) handlers from Status_Browser.livecode
   into livecode/status_browser.livecodescript BEFORE loading the new LIB_MENU menu (bubble n-7bcf81f6).
4. **Fable** runs in its own session: Next_Steps_With_Claude/FABLE_JOB_1..3 (TWO ENGINES note inside).
   When the owner says a Fable job is done: review its branch, run tests, update the Project Map.
Rules learned tonight: one helper agent per bubble; tests run under `flock /tmp/oxt_headless.lock`
and in their own work folders (t39, t40, t13 do now), never the real LIB_LLMIN; the main session
alone loads scripts into his open stacks and edits ProjectMap/board.txt.

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
