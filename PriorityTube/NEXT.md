# Priority Tube: where we are

## START HERE NEXT SESSION (19 Nov 2026, ~10:15 AM)
- DONE tube #1 n-1cb5d94e "Step code by Claude, step words by Spark" (LIB_HOWTO): all 18 topics,
  92 steps. Each step = `LIB_HOWTO/topics/<id>_<Title>/step_<n>.livecodescript` (the whole card
  script after that step) + `step_<n>.txt` (Spark's words, 38 fixed by Claude).
  Every step played on the real engine (`LIB_HOWTO/tests/play_step.sh`), pictures looked at;
  `tests/check_calls.py`: only Engine 1 calls (+ Game.FindFile, + LIB_BIT/LIB_MAP/cellmap calls);
  lint clean. NOT tried in the xt3d bench. What differs from the outline: LIB_HOWTO/README.md.
- Branches (not merged): LIB_HOWTO `howto-steps` (6fa6703), LIB_SPARK `howto-steps` (4ef7cd6).
- Found: the Game Player plays no sound (LIB_SYSTEM/ISSUES 0013, on LIB_SYSTEM main 774b3f2).
- Board: LIB_HOWTO next = "The HOWTO stack ..." (new bubble n-cde3c9de, sized 120 fun);
  block = owner reads a few steps. PRIORITY_ORDER.txt still lists n-1cb5d94e until the tube
  stack is opened again (his file; not edited).
- Next in the tube: the new top of PRIORITY_ORDER.txt (#2 n-c8710ff2 cellmap v3 Slope tool).

## EARLIER (19 Nov 2026, ~9:45 AM): topics 01-02 and the pipeline, then 03-18 on the owner's "yes please continue"

## EARLIER START HERE (19 Nov 2026, later)
- DONE tube #2 n-699218f7 "E03-E12, E14, E15 on the cellmap format" (+ its comment c1794994520898).
  The cards were built on the Fable night (LIB_EDITOR `editor-cards`, all 15 cards now exist).
  Today: they were ported to the waiting heights format on LIB_EDITOR branch **`cards-heights`**
  (a6de99a = heights-floor-ceiling + editor-cards + the port). Yard doors are From Ceiling under
  `top 101`; E06/E07 set `from` 2 instead of green. Issue 0010 fixed there.
  All 13 card tests pass against LIB_BIT heights-floor-ceiling: 166 checks, 0 failures.
- For the owner's merge: LIB_BIT `heights-floor-ceiling` and LIB_EDITOR `cards-heights` go in
  TOGETHER (cards-heights doors need the `[from]` layer; on LIB_BIT main they would be walkable).
  LIB_EDITOR is now checked out on `cards-heights`.
- Owner's answer (19 Nov): drop the 'ceiling at or below its ground is solid' line. Done: LIB_BIT
  heights-floor-ceiling c3664fb. A solid down to the ground is said with From Ceiling now.
- Not seen in a window: none of E08-E15, nor the ported doors (headless only).
- Next in the tube: the new top of PRIORITY_ORDER.txt.

## EARLIER START HERE (19 Nov 2026)
- DONE tube #1 n-d88a4930 (LIB_UNICODE): `LIB_UNICODE/livecode/lib_unicode.livecodescript` reads
  REGISTRY.tsv (Unicode.Char / Meaning / Procedure / Code / List / Check / Build) and the first
  procedure Proc.House (walls + gable roof + door, by math, engine mesh format). LIB_UNICODE branch
  `unicode-library` (652ee05, NOT merged). Headless tests pass, plain and through Engine 1's
  Mesh.Finalize/Merge. Not yet seen in a game window. Picture: LIB_UNICODE/preview/house_by_math.svg.
  Registry fix: the em space line held a plain space (U+0020); now U+2003.
- Its next step is a new bubble n-9e136064 (picker palette, 90 min, fun) at the bottom of the tube.
- Next in the tube: #2 n-699218f7 "E03-E12, E14, E15 on the cellmap format" (owner, 300 min).

## EARLIER START HERE (18 Nov 2026, ~8 PM)
- DONE the BitEditor heights job (bubble c1795032797521 done): LIB_BIT 1017033 + LIB_EDITOR ec30964,
  both on branch `heights-floor-ceiling` (NOT merged; waits for his try and his word).
  - Bands: green g = a block whose top is 255+g hu, blue b = 510+b (slab 10 thick); a cell can hold both.
  - [from] layer per cell: 1 From Floor (pillar from the ground up to its highest block), 2 From
    Ceiling (from the map top down to its roof, else its lowest block), 3 both = floor to top.
  - Map top = its own `top` else 765; shown in the Heights row ("top 765"), a click changes it.
  - Editor: From boxes are a brush (click a box, then cells); orange bar = From Floor, sky-blue bar =
    From Ceiling on the map; "Extrude Glyphs" button = Mesh > Extrude: Glyph Shape.
  - Try copy: LIB_BIT/editor/BitEditor_HEIGHTS_TRY.livecode (not committed). The real
    BitEditor.livecode holds his 15 Nov changes: NOT rebuilt; he decides.
  - Old maps with green/blue change their look (green no longer stands on the grey; e.g.
    16x16_Cropped_wizard_pool). wizard_pool sample rebuilt the new way (tower same 455).
  - Tests pass both engines + Python: py_*/lc_v2/v3/check/fill/roundtrip, lc_heights_from + layout2
    in a copy, LIB_EDITOR e03/e04/e13.
- "Tests 18 Nov" desktop folder: his WHAT_BILL_TESTED.txt said all 6 work (logged in FEEDBACK_HANDLED,
  file removed on his word). The 6 shortcuts stay.
- Betas: 14 games promoted (LIB_PUBLIC cbfc524); still beta DeadDays, GridSprint, InterceptorRun.
- BUGGED, parked (owner): BitEditor erases the glyphs after the heights work: ISSUES 0008, board block line.
  Owner: "our procedural levels are more valuable than making editing tools right now".
- COMFY REMIX (Fable job 4) STEPS 1+2+3 DONE 18 Nov night (step 3 = When nodes: events -> actions): LIB_COMFY branch `comfy-remix` (not merged).
  13 Remix nodes, Mutate, workflows/squad_remix.json + toss_remix.json; installed into both Comfy
  installs; seeds 1-50 pass tests/remix_play_test.py. NOT yet queued in ComfyUI (it was not running):
  he restarts Comfy, drags a workflow in, Queues, plays, leaves game notes. Then read his notes;
  tune ranges, mutations and rules from them. Details: last section of LIB_COMFY/NOTES.md.
- Owner wants Comfy nodes for Vector Toss + Squad Buggy ("weird variations"): a FABLE job, brief
  Next_Steps_With_Claude/FABLE_JOB_4_COMFY_REMIX.md (remix kit on the games' constants; 2 steps with stops).
- Next in the tube: #2 n-699218f7 "E03-E12, E14, E15 on the cellmap format" (owner, 300 min).
- Game notes seen 18 Nov evening: VectorToss "get this into a ComfyUI workflow ASAP"; CraterCrawler
  "I thought I approved these bet games days ago?" (not acted on yet; ask him).
- Waiting for his merge: LIB_BIT + LIB_EDITOR `heights-floor-ceiling`, LIB_RTS `rts-demo-guard`.

## EARLIER START HERE (18 Nov 2026, ~7:30 PM, the owner's answers before a /clear) -- DONE ~8 PM
Job: the BitEditor heights, two parts, in this order (LIB_BIT; one helper agent per part, or do it in the
main session; start from branch `heights-floor-ceiling`, NOT merged yet, it holds part 0):
0. What exists (branch heights-floor-ceiling, 90d1db0): "From Floor" / "From Ceiling" boxes, ONE setting
   for the whole map ([map] fromFloor 1 / fromCeiling 1, optional top <hu>); only blue floats.
1. **Rework the toggles to CELL BY CELL** (owner: "The extrusions should be cell by cell, that's what the
   whole height painting is for"). From Floor / From Ceiling get painted per cell like heights.
   - From Floor = the block is a PILLAR from the floor up (stalagmite), not a free floating platform.
   - From Ceiling = it hangs from the top of the map (stalactite).
   - Both off = floating platform. Both on = solid floor to top.
   - "Ceiling" = the top of the map; the owner: "that probably should be somewhat finite, I'm looking
     forward to seeing it" (keep `top <hu>`, give it a sensible finite default and show it).
   - The owner found "a room under it disappears" weird: it is just what a pillar is. Say it as
     "From Floor fills the cell solid under the block" and nothing more.
   - Old maps: both off. Drop or migrate the whole-map [map] lines (they were never released).
2. **Stack the colours (bubble c1795032797521)**: Green starts at White's highest, Blue at Green's
   highest (White16 = 10 ft -> Green1 = 10 ft, Green16 = 20 ft, Blue1 = 20 ft, Blue16 = 30 ft). Green
   then floats too, so the cell toggles cover green and blue.
3. **"Extrude Glyphs to Heights" is a SECONDARY procedure**, maybe a secondary tab (owner: it adds a lot
   of visual noise; "we shall see"). Height painting stays clean without extruded glyphs; the extrusion
   is a separate button/menu/tab you turn to. Menus pop on mouseUp.
Then: tests both engines + Python, ISSUES 0007 (never run lc_editor_test in place), tell him what to try.
Waiting for his merge too: LIB_RTS `rts-demo-guard`.

## NEWEST (18 Nov 2026, ~6:45 PM)
- Read the 4 new board notes. RTS_Demo "error in left operand" in Demo.PZ: NOT reproduced headless
  (30,000 random steps, clicks, keys, both engines). Demo.PX/PZ now draw a bad value at 0 and write
  "BAD z [value] from: <callers>" to LIB_LLMIN/LIB_GAMES/GAME_NOTES.txt once a run. LIB_RTS branch
  `rts-demo-guard` (507c796); t_rts_demo now expects "FOR OWNER". If a BAD line shows up in GAME_NOTES,
  its callers name the real cause: fix that.
- Map: GAD battles plan -> done (his YES), TTRPG Studio -> done ("A work of art"), qwen RAM note is
  green has: now (red was too harsh).
- Shortcut 6: the popup closed at once (it popped on mouseDown). Now mouseUp (LIB_MENU + editor);
  owner: "looks great". editor-library-menu merged to main in LIB_MENU, LIB_EDITOR, LIB_DEV.
- Tube #1 DONE by a helper: LIB_BIT branch `heights-floor-ceiling` (4220248 library, 90d1db0 editor).
  Two boxes "From Floor" / "From Ceiling" in the Heights tab tool row; whole-map setting, cellmap [map]
  lines fromFloor 1 / fromCeiling 1 (+ optional top <hu>); only blue floats today. Tests pass both
  engines + Python. Not seen on a screen. Open questions for the owner: per map or per cell? "Ceiling"
  = top of the map? From Floor fills a room under the block. ISSUES 0007 (lc_editor_test rebuilds his
  real BitEditor; restored from git).
- Waiting for his merge: LIB_BIT `heights-floor-ceiling`.
- Waiting for his merge: LIB_RTS `rts-demo-guard`.

## EARLIER (18 Nov 2026, ~6:15 PM, before a /clear)
- The owner tested the editor's new Library menu (desktop shortcut 6): the dropdown text is "extreme green".
  A dark background on the menu buttons did NOT fix it.
- His design, being built by a helper on branch `editor-library-menu` (LIB_MENU + LIB_EDITOR): menu titles
  are green GRAPHICS; ONE popup button per stack ("one popup button to rule them all") is filled at
  mousedown from what was clicked and popped there, with plain colours. It goes in LIB_MENU so games can use it.
- DONE before the clear: LIB_MENU 944ff31 (Menu.PopFor, Menu.PopFill, Menu.PopButton, Menu.PopPick,
  Menu.MakeTitle; popup black on white), LIB_EDITOR 1476053 (titles = graphics menuTitle_<Name>, one popup
  LIB_MENU_Popup, Ctrl+letter via commandKeyDown). t20, t37, t43, t51, t52 all pass, both engines.
  Not seen on a screen yet: the owner tries shortcut 6 again. Then he says merge (branch editor-library-menu
  in LIB_MENU, LIB_EDITOR, LIB_DEV).
- His rule (saved): colour the template BEFORE every create.

## LATEST (18 Nov 2026, late evening)
- The owner said "merge everything, commit everything". Done: every branch in every repo is on main
  (one clash, LIB_ig3d README, kept Fable's 16 Nov map whole). LIB_COMFY sits on main too.
- "Menu folders your way" (#4) is done (LIB_MENU, now on main).
- Tests after the merge: t22 and t28 fixed (they now add the alias file). Four tests still expect old
  counts: LIB_SYSTEM/ISSUES 0005 and 0006.
- The owner has a folder "Tests 18 Nov" on his Windows desktop: 5 shortcuts + WHAT TO TEST.txt.
  Read his notes from those tests first next session.
- #3 "A Library menu in a real stack" DONE in the iGame3D XT editor (the owner's pick). Branch
  `editor-library-menu` in LIB_EDITOR, LIB_MENU and LIB_DEV (all three folders sit on it, not merged).
  Desktop shortcut 6 opens it (Game_Player.exe Ig3dEditor). Waiting for his test notes, then his merge.
- His note on "Explore here..." (50+ scripts in one folder): later, in LIB_MENU/NEXT.md.

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
