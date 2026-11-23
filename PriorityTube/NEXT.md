# Priority Tube: where we are

## DONE 22 Nov: CONSOLE IN THE GAME PLAYER, NOT MERGED (branch `console-player`)
- Branches (from main, folders LEFT on them): LIB_DEV (game_player, this note), LIB_ig3d 68f6720 (lib_console:
  Con.TabIsMine / Con.TabFromHost), xt3D bridge 16af8f3 (bench Tab guard), LIB_SYSTEM b311ba5 (ISSUES 0015).
  LIB_DEV 7a1f7ff (game_player + this note).
- Game Player (Engine 1 window, LIB_DEV/livecode/game_player.livecodescript): F4 or ... > Console shows the same
  console in the lower left (answers above, one line below; the status line moves above it). Hidden until asked
  for: the game needs the window and its keys. Typing fills in names, Tab = the menu, Return runs the line in the
  player (engine calls + Player... handlers; "this card" = the game), Up/Down. While the line has the keyboard the
  game waits (still drawn); Escape or a click on the game gives the keys back (Escape then does NOT pause).
- ISSUES 0015 guard (games NOT changed, the key is still his): Tab is the console's only while its line has the
  keyboard or no game plays. Playing: Tab is the game's, in the Game Player and in the xt3d bench.
- Try: Desktop\TEST_DESK\Tests 22 Nov\03 Console in Game Player (Vector Toss, F4) (Game_Player.exe VectorToss):
  F4, type Entity. Tab; click the game, Tab = landing ring on/off as before; Escape pauses; Tab now = the menu.
- Tests: OXT-BEYOND/tests/t67_console_player.txt NEW 25/25 on both engines (the "game waits while typing" check
  needs keyboard focus, which a run with no window does not give: skipped, INFO line); bridge
  tests/console_bench_headless.txt 19/19 both; t66 33/33, t37 39/39, t20 7/7, t51 36/36 both; t48 112/113 both
  (its one fail "profiles listed" is the old ISSUES 0006; its Hunter-in-the-player part passes). t34/t35 not run (0011).
- Open: (1) the key for the five Tab games (his call, ISSUES 0015). (2) The installed V: copy has no LIB_ig3d, so
  its Game Player says "No console here" (vibeinstall.py would need lib_console + lib_suggest + contract_words).
  (3) ` typed in the line opens the game notes (GameNotes sees keys first). (4) Lines cannot call the game's own
  card handlers (they run in the player's stack script); engine calls are fine.
- xRay window (noted, not built): there is no xRay player yet (ENGINE_CONTRACT "iGame3D xRay: its own player").
  If it shows raylib's frame in a LiveCode image like the bench, it gets the console for free: two fields, Con.Attach,
  a Con.DoHere, a stack tabKey asking Con.TabIsMine, and skip Vibe.Step while Con.Typing() (as game_player does).
  If raylib owns the window, there are no LiveCode fields: the line would be drawn by raylib (raygui text box,
  LIB_RAYGUI), keys read with GetCharPressed / IsKeyPressed (new shim helpers + EXTRA in gen_xt3d.py + build.bat),
  lib_console would need a field-free entry (Con.Key on a text, not a field) and the Tab menu a raygui list.

## START HERE AFTER THE 22 Nov REBOOT: THE CONSOLE IS DONE AND MERGED
- Owner tried both consoles 22 Nov ("only took 21 years to get that! Great work.") and said "commit, merge".
  Merged to main: LIB_ig3d dc85837, LIB_EDITOR 1cb0ddb, xt3D bridge master 64a98e8. Branch `console` can go.
- Where it is: LIB_ig3d/livecode/lib_console.livecodescript (the thinking, one place; words from lib_suggest);
  iGame3D XT editor: Window > Console (lower left, Ig.Console*); xt3d Games bench: always under the view
  (xbConsoleSetup, a game waits while the line has the keyboard, click the view to give keys back,
  Tab anywhere in the bench = the console's Tab, engine calls with no game say "pick a game").
- Tests: OXT-BEYOND/tests/t66_console.txt (33 checks), xt3D bridge tests/console_bench_headless.txt (16),
  both engines, green on main.
- Desktop "Tests 22 Nov": 01 iGame3D XT (Game_Player.exe Ig3dEditor), 02 Games bench (.url: PowerShell
  kept timing out from WSL, so not a .lnk).
- OPEN, owner's note: games that use Tab need another key: LIB_SYSTEM/ISSUES/0015 (Amazing_Couple,
  PromptAndGlazeMaze, VectorToss, PhotonBall, Thrmnlra). Ask him which key; cheap guard idea in the ticket.
- Next ideas from CONSOLE_NOTE.md: the console in the Game Player and xRay windows; comments to Claude
  through it. Not started. Otherwise: top of LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt.
- Not mine, left alone: LIB_SYSTEM/LIB_ALPHA.md has an uncommitted change (the owner's?).

## DONE 22 Nov: THE CONSOLE BUILT, NOT MERGED (LIB_EDITOR branch `console`, db8d5e0)
- Window > Console in iGame3D XT: lower left, answers above, one line below. Typing fills in the rest of a
  contract name (rest selected: type on or Backspace); Tab = a popup of what fits ("Entity." all Entity calls,
  "Entity.Po" the Position calls; one fit goes in at once; no cycling); a pick puts the call in with its
  parameters selected and its meaning in the answers; Return runs (gives-a-value calls show it, even typed as
  commands); Up/Down history; help, clear. Camera keys and Ctrl+A/C/V/X/Z belong to the line while it has focus.
- Test: OXT-BEYOND/tests/t66_console.txt 64/64 on both engines; t37/t20/t51 still green (t34/t35 = ISSUES 0011, old).
- Owner tries it in a real window, then "merge". Note: there is no Entity.Position in the contract.
- Owner tried it 22 Nov: "only took 21 years to get that! Great work." Then: put it in the xt3d bench as a
  CONSTANT console under the viewport. Done the same evening: the thinking moved to LIB_ig3d
  `livecode/lib_console.livecodescript` (branch `console`, 4c0f812), the editor uses it (LIB_EDITOR 0d23985,
  t66 66/66), the Games bench has it always under the view (xt3D bridge branch `console`, 69b8873;
  tests/console_bench_headless.txt 13/13 both engines). In the bench a game waits while the line has the
  keyboard (games read the keysDown themselves); a click on the view gives the keys back.
- Three folders sit on `console` (LIB_ig3d, LIB_EDITOR, xt3D bridge): merge all three on his word.

## (done, see above) START HERE (owner, 22 Nov, before his /clear): THE CONSOLE
- Build the console in the iGame3D XT editor first: read `LIB_EDITOR/iGame3D_XT/CONSOLE_NOTE.md` (his words, what to
  build, what already exists: LIB_ig3d lib_suggest + Data/contract_words.txt). Tube bubble n-6976b289.
- Lower left of the window, like Blender's Python console. Try BOTH: autofill while typing (Entity.Po -> Entity.Position)
  and Entity. + Tab pops a menu of the group's words. Not Tab cycling one word at a time.
- Lean style is merged (22 Nov); its three follow-ups are small bubbles in the tube.

## DONE 20 Nov (night): PHOTON BALL STEP 2, COMFYUI DANGEROUS MODE, NOT MERGED
- LIB_COMFY branch `comfy-photon-ball` (from comfy-games-app; folder LEFT on it): kits/photon.py + nodes Walls and
  Break Rules (Vibecode3D/Photon Ball), Photon Ball in Remix Source, genre Photon, workflows/photon_dangerous(.json, _api).
  LIB_GAMES `photon-ball` 1b8136d: hooks kMatchRules / kMatchOffMS / kMatchOnMS, PB.WallsText (folder LEFT on photon-ball).
- Tests: tests/photon_play_test.py 0 failed (incl. real engine); t65_photon_dangerous 17/17; t63 87/87 both engines; t64 45/45.
- YOUR STEP: `tools/install.sh` in LIB_COMFY, restart Comfy Desktop (not done: you were away). Try: Desktop\Tests 20 Nov\03 Photon
  Dangerous (seeds 11-13 under genre Photon in Comfy Games). What playing showed: LIB_COMFY/NOTES.md, last section.

## DONE 20 Nov (night): COMFY GAMES APP BUILT, NOT MERGED (bubble n-7e9762f3)
- LIB_COMFY branch `comfy-games-app` (from comfy-remix; folder LEFT on it), LIB_PUBLIC branch `comfy-games-app`
  (vibeinstall.py comfygames; LIB_PUBLIC folder back on main), LIB_UNICODE branch `comfy-games-app` (✦ ✧ rating stars).
- Try: Desktop\Tests 20 Nov\02 Comfy Games - open the app in OXT-Beyond (ComfyGames.livecode). Pick a genre, pick a
  game, PLAY; click stars; Best rated / Newest / A-Z; Make a new one (no ComfyUI); Open in ComfyUI (needs it running).
  The .exe is still the 18 Nov build: build recipe in LIB_COMFY/Player/README.md.
- Tests: OXT-BEYOND/tests/t64_comfy_games_app.txt 45/45 on both engines; t53 updated 21/21. What's next:
  LIB_COMFY/PLAN_STANDALONE.md (end).

## DONE 20 Nov (night): PHOTON BALL STEP 1 BUILT, NOT MERGED (step 2 ComfyUI not started)
- LIB_GAMES branch `photon-ball` (from try-19nov-night; folder LEFT on it so the Game Player / Game Browser list it).
  `Vibecode3D_Games/Vibecode3D_Play_PhotonBall.livecodescript` (PB.), data `Vibecode3D_Games/PhotonBall/`
  (walls.cellmap, banter.txt, README.md = how to play + the wall layout format step 2 must write),
  `Animations/PhotonBall.anims.txt`. Vector Toss untouched.
- Play: open Photon Ball from the Game Player / Game Browser (LIB_GAMES on photon-ball), or LIB_TEST
  INSTALL_ALL_GAMES then the game menu. Mouse aims + button throws, WASD run, SPACE jump, SPACE/W/UP climbs out of a hole.
- Matches (10 catches each, floor mended): 1 first touch breaks a square; 2 every bounce breaks; 3 + cracks the 8
  round it; 4+ punches holes. Broken squares fall 2.5 s after you step off (match 1) / 1.5 s after you step on (2+);
  landing on one from a jump smashes through (no hang). Lloyd grab/hang/recover; stamina: grip 1.5-5 s, climb 40-100% speed.
- Tests: OXT-BEYOND/tests/t63_photon_ball.txt 75/75 on both engines; real engine via engine_play.sh (auto play to
  match 4, a hang and SPACE climb-out; 7-17 fps on a busy PC, Vector Toss 7-10 the same minutes).
- LIB_PUBLIC branch `photon-ball`: BETA_BRANCHES + catalog row 1540 (beta). LIB_PUBLIC folder left on main.
- Shortcuts: Desktop "Tests 20 Nov" (01 Photon Ball ...). Next: the owner plays it; then step 2 (LIB_COMFY comfy-photon-ball).

## START HERE AFTER THE 19 Nov NIGHT /clear: BUILD PHOTON BALL (owner said go)
- Plan: LIB_DEV/PriorityTube/PHOTON_BALL_PLAN.md (step 1 hand-placed game + play test, step 2 ComfyUI random mode).
- Owner's decisions 19 Nov late: Vector Toss frozen as is; DeadDays work stays; Pythonizing postponed (loose ends first).
- Still open from him: two Project Map comments of 9:35 PM ("What do you mean which face?", RELEASE_CHECKLIST gone?).
- Owner asleep: one helper per step, shortcuts in Desktop "Tests 20 Nov", logs via LIB_BAT/save_session_log.sh,
  nothing armed when done.

## START HERE NEXT SESSION (after the 19 Nov night run): ALL SMALL BUBBLES BUILT, NONE MERGED
- Summary for the owner: LIB_LLMOUT/NIGHT_19NOV_RESULTS.txt (Desktop "Tests 19 Nov night", shortcut 00).
- LIB_GAMES folder is ON "try-19nov-night" (all six LIB_GAMES branches combined, 5 tests green) so he can play them; merge = those branches into main, then back to main.
- Branches waiting for his try + "merge": LIB_GAMES vector-toss-stamina, deaddays-lloyd-take, notes-16nov,
  thrmnlra-redesign, nine-ball, bank-shot-bounce; LIB_MOCAP deaddays-lloyd-take (folder LEFT on it: the clip
  Vector Toss needs lives there); xt3D bridge e13-xt3d-bench (folder LEFT on it); LIB_SPARK bank-shot-bounce.
- Left in the tube: Pythonizing day and Comfy Games app (big, by his word only). Ask him what is next.
- Leftover: ~/Documents/Data in WSL made by the stamina test (harmless; ask before deleting).

## START HERE NEXT SESSION (19 Nov late evening): tube #3 n-b3296cad STEP 9 WORLD CODE: BUILT, NOT MERGED
- LIB_TTRPG branch `ttrpg-world-code` (9a15f7c). Spec `ref/ttrpg_world.py`, port
  `livecode/lib_ttrpg_world.livecodescript`, same answers on `ref/world_vectors.json`; map of every
  old handler in `livecode/WORLD_PORT.md`. Words from LIB_LISTS by name (they were already there).
- Owner tries it: `cd ~/projects/LIB_TTRPG; python3 ref/ttrpg_world.py new; python3 ref/ttrpg_world.py play`.
  Then merge on his word. Next for it (ask him): a World panel in the Studio window.
- Trap: `python3 ref/ttrpg_ref.py test` LOADS gemma-2-2b (live test). Unloaded again 19 Nov.
- Owner tried it: "works great, like 1981 all over again". Merge not asked for yet: ask once.
- Raon-1-nano NPC model: PARKED by the owner (build + test later); plan in LIB_TTRPG/NEXT.md.
- AFTER THE REBOOT (19 Nov late): the owner is deleting done bubbles from the tube (it "looks stuck":
  #1 and #2 are done but still listed). Re-read LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt fresh and take
  the top bubble that is not done; was going to be n-df980b7d Vector Toss Stamina rules.


## START HERE NEXT SESSION (19 Nov evening): tube #2 SLOPE TAB + PACK WINDOW: DONE AND MERGED
- Owner: "Very cool tool!, Merge that!". LIB_BIT main 7b838d7 (brought heights-floor-ceiling with it),
  LIB_EDITOR main 9cac9e0 (its heights-floor-ceiling: E13 test at the green band). Tests green on main.
  ISSUES 0008 (glyph erasing) is still parked, now on main.
- NEXT = tube #3 n-b3296cad "Step 9: the old studio's world code". OWNER SAID GO TONIGHT (19 Nov evening,
  "we may as well do that tonight"): it is no longer "later". It is LIB_TTRPG's job: read LIB_TTRPG/NEXT.md
  (item 7), OPUS_BUILD.md step 9 and DESIGN.md line ~132; the source is the harvested old studio stack
  XTJSON/batch/TTRPG_STUDIO_020920229AM (in LIB_LLMOUT/Read/LIB_XTJSON). Carry the world / item code into
  LIB_TTRPG on a branch (e.g. ttrpg-world-code), Python ref is the spec (memory lib-ttrpg). He is head
  congested: work quietly, plain words, show results at the end.

## (earlier, ~5 PM) tube #2 n-c8710ff2 cellmap v3 SLOPE TOOL + PACK WINDOW: BUILT
- LIB_BIT branch `cellmap-v3-slope-tool` (d8dc25c), built ON `heights-floor-ceiling` (not merged; the
  Slope tool sits in the same Heights tab). Neither is merged. LIB_BIT is checked out on it.
  `LIB_BIT/editor/BitEditor.livecode` is rebuilt: open it in OXT-Beyond to try.
- Slope tool: Heights tab, button "Slope" beside Floor / Ceiling. Grey swatch = rise; click near a cell's
  edge / corner lifts it; drag = same part on every cell; grey 0 flattens; right-click picks a cell's
  rises up and stamps them. Arrows uphill (red = steep), corner dots, hover words. Tidy: all four lifted
  -> floor raised.
- Pack window: File > Open Pack... (try maps/two_rooms/two_rooms.cellpack) / New Pack... / Pack Window /
  Check Map (E12). Maps list (double-click paints), Up/Down/Place/Add/Remove/Start, doors (Door to...),
  checker lines (click frames the cell in pink).
- Tests (run in a COPY, they rebuild the stack): tests/lc_slope_tool_test.txt, lc_pack_panel_test.txt,
  21 checks each, both headless engines; lc_heights_from / lc_layout2 still pass.
- Not built: map below drawn dimly ("line rooms up"), slopes in LevelBoxes / Pick, door far cell by click.
  3D-preview slope painting uses the edge/corner last chosen in the 2D map.
- OWNER'S FIRST TRY (19 Nov ~5:15 PM): needs its own tab, direction control, slopes that connect (not /|/|/|),
  hiding options in a menu (extruded glyphs = chaos). DONE same evening (cf7be6d): Slope TAB (compass, Ramp =
  drag a box -> one plane, Join floor-before to floor-after, One Cell, Flatten; Heights tab back as before),
  Scene menu Hiding: Off / Hidden Lines (~200 ms wizard_pool, when the view stops) + Show: <class> / All.
- NEXT: owner tries the Slope tab + Hiding in a window. Then tube #3 (read PRIORITY_ORDER.txt).

## START HERE NEXT SESSION (19 Nov, ~5 PM): tube #1 n-7c48878c 웃 PERSON + xt3d DROP: DONE AND MERGED
- Owner tried the xt3d drop live: "works great merge it!". LIB_UNICODE main 85ee5cb, no branches left.
- NEXT = tube #2 n-c8710ff2 cellmap v3 Slope tool (read PRIORITY_ORDER.txt first).

## (earlier, ~4:30 PM) the person half
- LIB_UNICODE branch `unicode-person` (c846437, on top of unicode-picker; none merged):
  Proc.Person + Person.Pose/Mesh/Frames/Stride/FromClip (bones = LIB_MOCAP's 25 joints; stand/walk/
  run/wave by math, or any LIB_MOCAP stick clip); picker "웃 moves" button, dropped people animate
  (walk/run round a ring, wave, dance = FreeBVH_DANCE). Headless tests pass; preview/person_by_math.svg.
  UnicodePicker.oxtstack re-saved headless. NOT seen in a real window yet: first thing to try with him.
- Owner: "working great". MERGED to LIB_UNICODE main (unicode-library/picker/person, 19 Nov ~4:45 PM).
- xt3d drop DONE on LIB_UNICODE branch `xt3d-drop` (85ee5cb): the bench's raylib camera IS the engine's
  camera (drawn into its image "view"), so only the mouse mapping + Vibe.ApplyRect were needed; drops
  only while a game plays there. Headless test passes; not yet tried with the real mouse.
- Then tube #2 n-c8710ff2 (cellmap v3 Slope tool).

## START HERE NEXT SESSION (after 19 Nov night): tube #1 n-9e136064 UNICODE PICKER is DONE
- LIB_UNICODE branch `unicode-picker` (4e6bedd, on top of unicode-library; neither merged):
  livecode/UnicodePicker.oxtstack + unicode_picker.livecodescript, Proc.Car/Truck/Cloud/StormCloud.
  Drop tested by script in OXT-Beyond on Simple_Test1; the real-mouse drag waits for the owner.
- NEXT = tube #2 n-c8710ff2 cellmap v3 Slope tool (see the section below). Read PRIORITY_ORDER.txt first.

## START HERE NEXT SESSION (after the 19 Nov evening /clear)
- HOWTO is DONE and MERGED (owner: "excellent work, lets merge this and move on"):
  LIB_HOWTO main 356e705, xt3D bridge master e37bfbc, LIB_DEV main 63ab374 (Player.Halt),
  LIB_SPARK main 936a606 (step words). The section below has the details and traps.
- DONE 19 Nov evening (owner: do it first): bubble n-9e665fa2. LIB_HOWTO/livecode/HOWTO.oxtstack is the
  stable stack (LIB_HOWTO main); opened fresh from the file it shows itself and plays. Dev file deleted.
  The owner may reorder the tube: read PRIORITY_ORDER.txt again before starting.
- NEXT = tube #2 n-c8710ff2 "cellmap v3: BitEditor Slope tool, pack panel, E12 checker (A-92 3-5)"
  (#1 n-1cb5d94e is done; PRIORITY_ORDER.txt still lists it until the tube stack is opened again).
  Start by reading LIB_BIT's cellmap v3 notes (A-92) and ISSUES 0008 (BitEditor erases glyphs, parked).
- Each session: for_review.py feedback, LIB_LLMIN/LIB_GAMES/GAME_NOTES.txt, MAP_NOTES, BOARD_COMMENTS.

## START HERE NEXT SESSION (19 Nov 2026, late evening): HOWTO = STRIP + TWO FLOATING GAME WINDOWS
- Owner's layout: HOWTO is one 1500x360 strip at the bottom of the screen, scale 1 (topics | steps |
  words | code; < step / Run / Stop / step > + engine toggle along the bottom). Vibecode3D plays in its
  own titled window top left, xt3d (bench script in view-only mode, in OXT-Beyond) top right.
  Run restarts only its own engine, so the same step can show in both; Stop / a new step end both.
- WHY: a stack with scaleFactor 0.95 in OXT-Beyond is NOT drawn where its rect, globalLoc or mouseLoc
  say (measured ~+23,+34 off at 200,32); windows laid over its card never lined up. Don't go back.
- Branches: LIB_HOWTO `howto-stack` (905673e), xt3D bridge `howto-xt3d` (dd55046). Merge waits for him.
- Tried in OXT-Beyond: 2.4 in xt3d, 5.3 in both side by side. Known limit: both engines share the
  scene globals (gObjectTransforms...), so the two windows show ONE simulation (cube at the same spot).
- `LIB_HOWTO/tests/play_step_xt3d.sh` (bench standalone): 92/92 steps start in xt3d.
- Windows stay: picking a step / Stop halts the games (Player.Halt, LIB_DEV branch `howto-player`
  b/c it changes the shared Game Player; LIB_DEV is checked out on it) and Run reuses the windows.
- NEXT: he plays steps; then HOWTO_dev stack + stable HOWTO.oxtstack, commit.
- NEVER export snapshots of the whole screen (private windows get captured); look_at_card only.

## START HERE NEXT SESSION (19 Nov 2026, afternoon): FINISH THE HOWTO STACK'S xt3d VERSION
- HOWTO stack script: LIB_HOWTO/livecode/howto_stack.livecodescript, branch `howto-stack` (1f98080).
  Owner saw it: "looks great", candy syntax colours "very approachable". Opens at 200,32, scale 0.95.
- NEXT: the xt3d toggle runs the step in the xt3d bench (bench xbPlayGame takes only a LIB_GAMES game
  name: add a play-this-script command; never write steps into LIB_GAMES). Run not yet tried in a window.
- Then: new HOWTO_dev stack, look at it with him, save the stable HOWTO.oxtstack, commit.

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
- OWNER (19 Nov ~10:20 AM, watched it being made): "looks GREAT. i'll clear and then you can go on
  with your next phase of this". So NEXT = bubble n-cde3c9de, THE HOWTO STACK (before tube #2):
  build LIB_HOWTO/livecode/HOWTO stack per LIB_HOWTO/PLAN.md (dark mode; topic list on the left on
  every card; Vibecode3D viewport right with an xt3d toggle; step words + syntax-coloured code
  field bottom right; < step / run this step / step > buttons). It READS topics/*/step_n files
  (never holds lesson text). Run a step = same trick as tests/play_step.sh. Build it in OXT-Beyond
  (bridge) as a dev stack, stack title "Opus | HOWTO" while I drive; template colours before every
  create; closeStackRequest frees it. Branch howto-steps (or howto-stack from it).
- After that: tube #2 n-c8710ff2 (cellmap v3 Slope tool).

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
