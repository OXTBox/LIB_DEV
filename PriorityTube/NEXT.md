# Priority Tube: where we are

## START HERE (23 Nov, night): p1-33 "Make it run DOOM" DONE and MERGED (owner: "PERFECTLY acceptable game,
   very well done"). CORRIDOR LAB (LIB_GAMES main 05d7309): first-person raycast shooter, black dedication screen
   in memory of Scott McDonald (The LiveCode Lab), level 1 = Scott's own map, looks solid/glass/lines (V), rays (C).
   New repo LIB_RAYCAST (Ray.*, Scott's join-rays-into-polygons idea + exact corners); his stack harvested and filed.
   Tests: LIB_RAYCAST/tests (19 + 1), OXT-BEYOND/tests/t77_corridor_lab.txt 33/33. Live: 31 fps solid and glass.
   Fixed after his look: a close right-hand wall vanished at 1-15 degrees of turn (an end behind the eye).
   Known: solid walls jitter a little (ideas in CorridorLab/README.md). LIB_GAMES folder back on main.
   NEXT (owner): put SOUND AND MUSIC back into the engine, after he clears.

## START HERE (23 Nov, last): owner "Greatest games of all time, merge!": Squad Buggy (wider view + G grenades)
   MERGED to LIB_GAMES main 28ad885; LIB_COMFY squadbuggy-wreck-knob merged (main), tools/install.sh run: the
   wreck slider shows after a Comfy restart (reload squad_remix workflow). p1-18 done: all 11 fun bubbles done.
   LIB_GAMES folder on main. Next in the tube: p1-33 DOOM, only after the test-subject review is looked at.

## START HERE (23 Nov, latest): owner "they are great": 10 fun games MERGED to LIB_GAMES main (839068f, Big Ball
   fixed first: the HAZARDS rain, never on the ball or its rolling path; agents on the board). Bubbles marked done.
- p1-18 Squad Buggy goes on: owner, the wider view is for OUR grenades to wreck the land ahead/behind. Built on
  LIB_GAMES `squadbuggy-view` (= main + wider view + grenades, 28ad885): G / right button lobs a grenade to the
  ground under the reticle; crater sized by kWreck; hold G = one every 20 steps; too near = a soldier thrown off.
  t76_squadbuggy_grenade 8/8, t76_squadbuggy_view 16/16, t24 34/34, t70 Squad 2/2, both engines.
  LIB_GAMES FOLDER LEFT ON squadbuggy-view for his look. "merge" -> merge it to main, then LIB_COMFY
  squadbuggy-wreck-knob (needs kWreck; then tools/install.sh + restart Comfy), p1-18 done.
- try-23nov-fun branch is now history (main has it all but Squad Buggy). Worktrees removed.

## START HERE (23 Nov, late night): the 11 FUN BUBBLES p1-24, p1-19, p1-23, p1-15, p1-18, p1-21, p1-16, p1-20,
   p1-32, p1-31, p1-29 ALL BUILT (owner away; "stop at Make it run DOOM": stopped there, p1-33 not started).
- One helper per bubble, each on its own LIB_GAMES branch (shaft-run, deepdive-prefs, probecone-pulse, bigball-rain,
  squadbuggy-view, interceptor-heli, bouncerally-spin, gridsprint-open, eagle-dive, lantern-ladders, coneprobe3d
  (on top of probecone-pulse)) + LIB_COMFY squadbuggy-wreck-knob. Worktrees left in the session scratchpad.
- All combined in LIB_GAMES `try-23nov-fun`; the LIB_GAMES FOLDER IS LEFT ON IT so the Game Browser shows them.
  Every t76_* passes on both engines there; t70 168/0 (now lists ConeProbe3D, LanternLadders, EagleDive, reads T74_ROOT).
  t76_interceptor_heli got `set the randomSeed to 3` (the hover leaves at random; seed 7/1/2 failed).
- His list: TRY_23NOV_FUN.txt; details + choices made for him: RESULTS_23NOV_FUN.md; brief: BRIEF_23NOV_FUN.md.
  Desktop\Tests 23 Nov has 00/01 shortcuts.
- "merge" -> merge try-23nov-fun (or the named branches) to main; then LIB_COMFY squadbuggy-wreck-knob (needs kWreck
  in the game first); then mark the bubbles done. Next in the tube: p1-33 DOOM, only after the test-subject review.
- Open: Comfy Photon game note "player respawns on open holes" (not high priority, his words), still in GAME_NOTES.

## 23 Nov, night: p1-14 Tabletop grid MERGED (owner: "works splendidly", LIB_GAMES main b4f1104), ISSUES 0019
## closed; p1-28 Meadow Marsh merged earlier; p1-22 Light Trail bubble cleared on his word. Folder on main.
## Owner clears context next; start from the top of PRIORITY_ORDER.txt.

## START HERE (23 Nov, night): p1-25 STACK DOWN SWAY MERGED (owner: "Not as fanciful as I pictured it in my head,
   but it breaks nothing, MERGE"), LIB_GAMES main; LIB_GAMES folder back on main; V: has it; p1-25 done.
   If he wants it fancier later: bigger kSwayTurn, or a nod (pitch) on its own slower sine.

### Before the merge

- 3rd try (his words: "the pivot point should be at the center of the game board ... shaking head no"): the camera
  goes on an arc round the well's middle (0,0,kZ) and looks at it: 6 deg each way / 20 s (kSwayTurn, kSwayTurnSecs).
  t75 6/6 both engines: middle stays put, a back edge swings ~6.5 px (the perspective is weak: raise kSwayTurn
  if he wants more).
- 2nd try: Camera.SetLook each frame (Stack.Sway): YAW ONLY (owner: "Yaw is the way it should go"), 1.5 deg over 20 s;
  first try was roll 1.5 + yaw 1 (he said "very gentle":
  less than the bubble's 2); constants kSwayRoll / kSwayRollSecs / kSwayTurn / kSwayTurnSecs at the top.
  Game.OnStop straightens the camera. Play unchanged.
- Test OXT-BEYOND/tests/t75_stackdown_sway.txt 4/4 both engines (T74_ROOT for a folder copy).
- LIB_GAMES folder now on stackdown-sway (on top of main b4f1104; owner tests in the Game Browser); the file is also
  copied onto V: (Stack Down) for his look. "merge" -> merge in a worktree on main, p1-25 done.

## START HERE (23 Nov, night): p1-14 TABLETOP RACERS GRID START on LIB_GAMES branch `tabletop-grid` (waits for his look)

- Each table and each retry: empty stretch (clutter from 900), you pull up to a green start line, the rivals
  pull up in their own grid slots, 3 2 1 GO; keys and clock wait for GO.
- ISSUES 0019 not reproduced: t75_tabletop_grid.txt 9/9 on both engines plays all five tables through the
  loading screen; off-table, game over and long waits gave no error either.
- p1-28 Meadow Marsh MERGED (LIB_GAMES 6cca4a7, owner: "great prototype"); p1-22 Light Trail is another
  session's (branch light-trail-fps). LIB_GAMES folder left on `tabletop-grid`.

## START HERE (23 Nov, night): p1-28 MEADOW MARSH FIRST PLAYABLE on LIB_GAMES branch `meadow-marsh` (waits for his look)

- Owner's words: copy Dead Days into open country (hills, villages; dungeons/castles later), uDead's orders
  (click, R rush, F follow, stop moved from Space to H), mana + LIB_EMITTERS spells, soldiers -> casters /
  bowmen with their own emitters, slightly raised camera, food + jewels refill mana. Gameplay first.
- Built: LIB_GAMES edb8adc `Vibecode3D_Play_MeadowMarsh.livecodescript` (prefix MM., Engine 1) +
  `MeadowMarsh/README.md` (controls, spells-in-3D trick, 14 tutorial sections, MMO ladder).
  Two places (Meadow: village + 3 goblin camps; Marsh: water slows, ruin, bog witch), prisoners join you,
  right click = everyone. Dead Days untouched.
- Test OXT-BEYOND/tests/t74_meadow_marsh.txt 16/16 (Beyond). 47-50 ms a frame headless (Dead Days 41);
  own lean trees (the prop maker's trees were 3558 lines).
- NOT seen on a screen (he was in the Priority Tube). His first game: camera height, spell planes, hills.
- The LIB_GAMES folder is left on `meadow-marsh` (it holds main's crater-wheels merge too).

## START HERE (23 Nov, night): p1-22 LIGHT TRAIL ARENA FPS MERGED (owner: "merge, that is one of the best light cycle
   games ever made!"), LIB_GAMES main ed80ee3 (merged in a worktree: the main folder is on another session's
   tabletop-grid); V: already has it; p1-22 done.

### Before the merge

- Cause: every straight trail (and every 4-cell piece of the open run) was its own object; the engine pays
  ~0.15 ms an object a frame. Now a bike's trails are drawn as chunks (kChunk = 12 runs = ONE mesh object,
  rebuilt on a turn or a wall break) and the open run is one line made longer. Rules untouched.
- New test OXT-BEYOND/tests/t74_lta_fps.txt (real engine, no window, seed 7, rounds 3+, T74_ROOT = a folder
  copy): before 17.4 ms a frame / 187 objects most; after ~6 ms / 26. t25 26/26 both engines before and after
  (t25 now loads LIB_ig3d contract_aliases, so it runs past Camera.Reset: ISSUES 0011's fix for one test).
- LIB_GAMES' own folder is on `meadow-marsh` (another session), so the branch is a worktree in my scratchpad;
  the branch file is copied onto V: (Light Trail Arena) for his look. "merge" -> merge light-trail-fps into main
  (from the worktree), set p1-22 done. "no" -> put main's copy back on V:.
- Not done: tails eating themselves / more balls (the tester's other ideas): rules changes, ask him.

## START HERE (23 Nov, night): p1-06 CRATER CRAWLER WHEELS MERGED (owner: "Wheels look great"), LIB_GAMES main bf466f4

- One sign: Entity.SetRotation sWheel[i], 0, 0, sDist / 9 (was -sDist / 9), line 436. LIB_GAMES checked out on the
  branch so the Game Browser plays it. t22 + t70 pass both engines; t26 stops at Camera.Reset (ISSUES 0011).
- p1-06 set done.

## START HERE (23 Nov, night): p1-05 GENETIC ANOMALY ARROWS MERGED (owner: "Maximum Key mashing is crash free")

- LIB_GAD main d4fce48; game file copied onto V:; ISSUES 0017 closed; p1-05 done (bubble gone).
- Seen: the Game Browser lists LIB_GAMES only, so Genetic Anomaly (home LIB_GAD) is not in it: he played it from
  the V: Library. Offered: let GL.GameFile look in LIB_GAD too (game_launch has another session's unsaved edits).

### Before the merge

- Same cause as Bat Duel (ISSUES 0020): no `on arrowKey` in the game, so Left = previous card. Not a pile-up.
  The Game Player has swallowed stray arrows since 8232292, so it should already be fine there; the game now has
  its own empty handler too (LIB_GAD d4fce48), for the xRay bench.
- t71 now includes GeneticAnomaly: 12/12 PASS both engines. t15 stops at Camera.Reset as before (ISSUES 0011).
- His try: hold two arrows on the star map in the Game Player; then "merge" -> close 0017, set p1-05 done,
  reinstall V: (GeneticAnomaly comes from LIB_GAD main).

## START HERE (23 Nov, late afternoon): n-5c59e4c5 WORLD PANEL IN THE STUDIO DONE on LIB_TTRPG branch `world-panel` (waits for his look)

- Asked him first (bubble said so): own card; New/Load/Save World; NPCs here -> Add Character; small map (click a
  neighbour = walk); Scene here; NO "You are at" prose: cell = plain data he (later a model) edits; Verbose = DM
  model pads it into words; typing tries world actions first.
- LIB_TTRPG 7e7fbf3 (spec + port + vectors: cell_data / set_cell_data / map_lines) and 49585b8 (World card,
  lc_world_ui_test.txt 0 fails; world/ui/mock/selftest/skills/build tests still pass). Details: LIB_TTRPG/NEXT.md.
- Choice I made: during a running scene, typed look / search still go to the DM (clues); go/take/drop/open/close
  go to the world. Not seen on a screen yet. LIB_TEST's Studio copy is old (LIB_TEST is on play-log): untouched.
- Owner 23 Nov: Verbose talks as if it sees a LiveCode object / the whole map (needs a real system prompt). Whole Studio PARKED in bubble n-58af1221 "TTRPG STUDIO: Total Application Review & Comments Required by Owner." at the bottom of the tube (sized 490, just above Genetic Anomaly). Do not work on TTRPG until he lifts it.

## START HERE (23 Nov, 15:00): n-7ce789eb LEAN IN SIX EDITOR CARDS DONE on LIB_EDITOR branch `lean-cards` (waits for his look)

- E05 E06 E08 E09 E11 E12 load lib_lean (optional) and draw through <Prefix>.LevelSegments: Lean.MapSegments with
  the map's meta lean when meta style is lean, else CellMap.LevelSegments. LIB_EDITOR f41877a.
- Test LIB_EDITOR/tests/lean_cards_headless.txt 36/36 both engines (plain 297 lines, lean 109 on cards_yard);
  e05..e12 headless tests all pass unchanged. cards_yard itself is not lean: save it lean in BitEditor to see it.
- Board: LIB_EDITOR next -> done; bubble gone. Owner moved n-c58324eb (Comfy installer) to the bottom: his
  rebuild of ComfyGames.exe is in LIB_COMFY/Player/build/ComfyGames (23 Nov 14:17); bubble kept as is.
- Seen: tube comment c1795473221928 "fixed by Bill" on p1-03 (Library buttons): he fixed it himself.
- Another session takes the next bubble.

## START HERE (23 Nov, afternoon): n-d241ef1c MERGED (owner: "merge"), LIB_GAMES main e55337b, installed on V: (verify: Dot Maze start ok)

- DotMazeLean's walls: `Lean.Walls(sMaze, kCell, Lean.Style("view=front|layers=-20,20|posts=none"))`; its own
  builder (Maze.Wall / CornerX / CornerY / AddSeg) is gone. lib_lean loaded by Game.FindFile
  ("LIB_BIT/livecode/lib_lean.livecodescript"); missing = empty walls + a HUD line, no crash.
- Test OXT-BEYOND/tests/t73_dotmaze_lean_walls.txt PASS both engines: the same 208 lines as the old builder
  (kept in the test as Old.*), lib_lean in use, 60 frames no error. fps not measurable headless.
- V: reinstalled after the merge (54 titles); lib_lean in Vibecode3D Common/LIB_BIT/livecode.
- Trap seen: a parameter named pI is the constant pi (compile error 165): never name a variable pI.
- NEXT on the tube: n-7ce789eb (lean style in E05, E06, E08, E09, E11, E12).

## START HERE (23 Nov, 13:50): p1-07 LIBRARY NUMBERS DONE on LIB_PUBLIC branch `library-numbers` (on top of `dot-maze-name`)

- The list reads "21<tab>Floppy Flynn"; the title line "21  Floppy Flynn". Numbers follow the filter shown.
  t72 (8 checks) + t27 (counts updated to the 23 Nov install: 54 titles, 4 betas, 4 tools) pass both engines.
- He rebuilt the Library at 13:44 for p1-26; rebuild once more for p1-07 (paste the script minus line 1).
  His saved Vibecode3D_Launcher.livecode is uncommitted in LIB_PUBLIC: commit it after this rebuild.
- 13:55 SOLVED: he had cleared the build folder (build1/build2 clutter) and rebuilt 64-bit only, so there is no
  "Windows x86-64" folder. vibeinstall LAUNCHER_DIR = launcher/build/Vibecode3D Library (skips .lnk); installed on V:,
  Library exe = Vibecode3D.exe there. His saved stack (p1-26 + p1-07 script) committed on library-numbers (fd19d03).
  ENGINE_BUILD and the Comfy Games exe path still point at "Windows x86-64" folders.
- NEXT on the tube: n-d241ef1c (DotMazeLean uses the shared Lean.Walls).

## START HERE (23 Nov, night): p1-26 DOT MAZE NAME DONE on LIB_PUBLIC branch `dot-maze-name` (waits for his look)

- Library: "Dot Maze" = the lean one (appid 1560, 30 fps); the old slow one = "Dot Maze Original" (1150), with
  `listed last` in its game.txt (vibeinstall LAST set) so the Library sorts it after every title. Installed on V:
  (whole install: old "Dot Maze Lean" folder pruned). Test OXT-BEYOND/tests/t72_library_order.txt 3/3 both engines.
- The Library .exe on V: is the 16 Nov build: it needs a rebuild in OXT-Beyond (launcher/README "Build") to sort
  "listed last"; until then Original sits right under Dot Maze. p1-07 (numbers left of names) is launcher work too:
  one rebuild can carry both.
- Seen: `vibeinstall.py catalog` would add BankShotBounce, NineBall, uDead_CullTest (a test) and flip PhotonBall's
  ref to main. NOT done (catalog rows edited by hand); his word first.
- extra_items: p1-26 and p1-04 set done. NEXT on the tube: p1-07, then n-d241ef1c.

## START HERE (23 Nov, late): LEAN WATER SWITCH (n-15396035) MERGED to main (owner said merge)

- lib_lean style key `water` (marks = default | off). A map keeps its lean style text in meta `lean`
  ("water=off"). BitEditor: Scene > "Lean: Water Marks Off" (under Lean Style; an old built editor gets the
  item when a map loads, no rebuild needed). E13 reads meta lean too. wizard_pool lean 295 -> 253 lines.
- LIB_BIT f688326 + LIB_EDITOR 69454e0. lc_lean_seams_test 14/14 both engines; both scripts compile both engines.
- His try: BitEditor, wizard_pool, Scene > Lean Style, then Scene > Lean: Water Marks Off (save, open in E13).
- Seen on the way: E13 test teleporter FAIL (y 265, wants 231) is on main already: ISSUES 0021.
- NEXT on the tube: p1-26 (Dot Maze: the Lean one takes the name), then p1-07, n-d241ef1c.

## START HERE (23 Nov, evening): BAT DUEL ARROW CRASH FIXED AND MERGED (owner: "Fixed Achieved ... no crash")

- Cause: Bat Duel (and Floppy Flynn) had no `on arrowKey`; Left went to card navigation = previous card. Not a
  pile-up. Details: LIB_SYSTEM/ISSUES/0020. LIB_GAMES 3d606cb (both games) + LIB_DEV 8232292 (Game Player swallows
  any arrow no game took, console line excepted). Test OXT-BEYOND/tests/t71_arrow_keys_stay.txt 10/10 PASS.
- He held every key he could: no crash. Merged to main, branches deleted. ISSUES 0020 closed.
- NEXT on the tube after this: n-15396035; 0017 (GA star map) still open; p1-08 play log still waits on `play-log`.

## START HERE (23 Nov, after p1-08): BAT DUEL CRASH ON TWO HELD ARROWS = TOP PRIORITY (owner)

- Owner: "Down and Left crashed it in about a tenth of a second" (Bat Duel, Game Player, XT). Bubbles p1-04
  (Bat Duel quits on arrows) + p1-05 (held keys pile up, ISSUES 0017) meet here.
- Read first: LIB_SYSTEM/ISSUES/0020 (start steps added 23 Nov) and 0017 (Fable's guard design: repeats
  swallowed at the door, tick wait 4 ms, navigationArrows off). 0.1 s is too fast for a pile-up: find the
  error text first (LIB_LLMIN/LIB_DEV/GAME_PLAYER_ERRORS.txt), then Game.OnUpdate with both keys held.
- Game: LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_BatDuel.livecodescript (keysDown once a frame, no key handlers).
- Fix on a branch, test both engines, held-key test in OXT-BEYOND/tests; then the other games game_scan lists.
- p1-08 (play log) still waits for his look on branches play-log (LIB_TEST, LIB_BAT).

## START HERE (23 Nov, morning): p1-08 PLAY LOG BUILT ON BRANCHES `play-log`, waits for his look; NEXT = n-15396035

- The record was already there (LIB_LOADING_SCREEN writes start / level / end / quit lines to
  Documents/My Games/Vibecode3D/play_record.txt), so p1-08 is two tools, nothing in the engines changed:
  - LIB_TEST 065fb70 `play_report.py` (MIT): `python3 -I play_report.py` = his last session; `--all`, `--date`,
    `--gap 30`, `--out`; a tester pack folder also lists the notes written during each session. On his record
    of 23 Nov: "10 games in 22.6 minutes, 10 never got past level 1" (4:41) and "7 games in 39.4 minutes" (6:35).
  - LIB_BAT c5f7f46 `tester_pack.bat`: double-click on the tester's PC; record + last.state + tell_*.txt notes
    into Desktop\Vibecode3D_PlayPack_<stamp> + .zip. Tried from WSL into a temp folder: 19 notes + record, zip ok.
- Not done: the Game Player's error log goes to LIB_LLMIN (missing on a tester's PC), so crashes are not in the
  pack (only seen as "open" runs). The bat is not yet copied onto the V: install / tester card (vibeinstall.py).

## START HERE (23 Nov, night): p1-12 AND p1-13 MERGED; NEXT = p1-08 (play log)

- p1-13 merged on his word ("Merge, the effects are really neat ... original film transition! Harold Lloyd would approve"):
  LIB_GAMES 18b842d, LIB_COMFY fc58cd6, LIB_LOADING_SCREEN c5cc39d, bridge 07b914d. Old notes below about branches are history.

- p1-12 merged on his word ("very nice, very computer feeling. merge!"): Vibecode3D 922ed68, bridge b0133cd, LIB_LOADING_SCREEN 24570ff.
- p1-13 on branches `loading-rollout` (folders LEFT on them): LIB_GAMES 9bd3c8c (39 games), LIB_COMFY 6064f65 (7 kit
  parts + the 25 made games, same change), LIB_LOADING_SCREEN ec006d1, bridge 96c1b16.
- The change in a game: a `<Prefix>.GoLevel pLevel` handler (Loading.Go when "LIB_LOADING" is in the stacksInUse, else
  `<Prefix>.StartLevel` at once, so the V: install and the Vibecode3D GUI play as before). 80 calls changed: next level,
  menu picks, back to level 1 after game over. KEPT as they were: `StartLevel sLevel` (12, the same level again after
  a loss: a retry stays instant) and every call inside Game.OnStart (the host does the first level).
- Library: global gLoadingBusy; the engine's Vibe.Step stops stepping the moment the screen is up (else a catch-up
  burst ran the "level won" code again: Deep Dive's air bonus twice). After the build it calls `<Prefix>.ShowHUD`.
- Test: OXT-BEYOND/tests/t70_loading_rollout.txt NEW: each of the 39 games opened as the Game Player opens it,
  first level, then its own GoLevel: screen up, built once, no error. 78/78 on both engines (env T70_GAMES="A,B"
  for a few). t68 t69 t67 green; LIB_COMFY kit_play_test 0 failed.
- His look: Desktop\Tests 23 Nov\04 Soft Landing, 05 Comfy Pong (play to level 2).
- Not done: players named per game (Loading.Player) - the guess finds Ship/Player/Hero keys only; Comfy's generator
  kit_test needs PIL for previews (old). LIB_TEST game-scan branch still not merged (a reading tool).

## START HERE (23 Nov, evening): p1-12 LEVEL REVEAL BUILT, NOT MERGED; waits for his look; NEXT = p1-13

- Branches `level-reveal` (folders LEFT on them): Vibecode3D 7385ef3 (Engine 1: `Scene.SetReveal pX,pY,pZ,pRadius,pKeep,pStyle`,
  `Scene.Reveal()`, `Scene.RevealReach()`, `Reveal.Share`; off by default; Game.Exit turns it off), xt3D bridge 0c06f44
  (xRay `Vibe.Frame`: object by object, faded by its share; engine regenerated), LIB_LOADING_SCREEN 63d5fdf (reveal phases,
  styles grow / dash / fade / none, `Loading.Player` guess: `<Prefix>.Player()`, else a key beginning player/hero/ship, else
  the middle of the view). README.md has the how.
- Reveal timing: veil black 0.3 s, lifts 0.2 s, player alone 0.25 s, the radius grows ~1 s (quick first, slow at the end).
- Test: OXT-BEYOND/tests/t69_level_reveal.txt NEW, 26 checks, both engines green; t68 t54 t67 still green (308 passes
  together; t54's mode-0 md5s unchanged = the picture with the reveal off is as before).
- His look (plan: "a look at three games in a real window"): Desktop\Tests 23 Nov\01 Canyon (from the ship),
  02 Vector Toss (from the middle: no player key yet), 03 Deep Dive (use Levels menu for a second reveal).
  No game calls Loading.Go yet (p1-13), so the reveal shows at the first level, Levels menu and Reset.
- Not done: the VIBECODE3D_GUI_v1 stack embeds its own engine copy (not patched; the Game Player uses the generated one).
  p1-13 adds `Loading.Player` / a style per game where the guess is wrong (VectorToss VT.Ball, DeepDive, ShaftDescent).
- Game note read (23 Nov 4:50): ProbeVsCone "javelin lands quietly at the cone, unreachable": belongs with p1-23.

## START HERE (23 Nov, later): p1-01 GAME SCAN DONE (branch game-scan in LIB_TEST); NEXT = p1-12

- `LIB_TEST/game_scan.py` (MIT, reads only): `python3 -I game_scan.py` writes `game_scan.tsv`,
  `game_scan_level_calls.tsv` and `GAME_SCAN.md` beside it. `--no-comfy` leaves out LIB_COMFY/games.
- **The count: 92 card scripts** = 56 LIB_GAMES + 1 LIB_GAD (Genetic Anomaly) + 35 LIB_COMFY (generated).
  The plan's "69" was never found; the Library on V: lists 55 (catalog.tsv). Not in the catalog:
  BankShotBounce, NineBall, uDead_CullTest.
- 66 have their own `<Prefix>.StartLevel` (41 in LIB_GAMES, 25 Comfy); 209 calls of it; 85 of them have
  code after them in the same handler (mostly `put tKeys into sKeysWas` or `X.ShowHUD`), the p1-13 list.
  Spot-checked by hand: BatDuel 142/145, RockField 109, Antack's switch cases (correctly "nothing").
- Found, not changed: Genetic Anomaly and 10 Comfy Photon/Toss games still read Tab (65289), the
  console's key since ISSUES 0015 (the LIB_GAMES games were moved off it 22 Nov).
- Levels: "header" = the card's comment says "5 levels"; "compare" = biggest number sLevel is compared
  with (a guess); "?" = StartLevel but no count (Antack, uDead).
- Next: p1-12 (Scene.SetReveal: the player first, the rest draws in), then p1-13 reads the calls list.

## START HERE (23 Nov): LOADING SCREEN MERGED; NEXT = p1-01 GAME SCAN

**Done and merged (owner: "merge", 23 Nov):** the loading screen, p1-10 + p1-11.
- LIB_LOADING_SCREEN: own repo, main. `livecode/lib_loading.livecodescript`, README.md (how a game uses it),
  PLAN.md (his yes + answers). LIB_DEV main 2af8935 (Game Player), bridge master 4506d1a (xt3d bench).
- Test: `OXT-BEYOND/tests/t68_loading_screen.txt`, 31 pass on each headless engine.
- His first look: the dimmed last picture is too quick to see, the green text "nearly blink of an eye":
  **fine for now; don't slow things down for non-gameplay gimmicks.** Smooth it out later.
- Traps learned: after the screen the host calls `Vibe.Go` (fresh clock), or the engine runs ~8 catch-up steps;
  tests that tick right after `Player.Start` call `Loading.Stop` first (t48, t67 do). Old failures, not ours:
  t33-t36 Camera.Reset throws, t48 "profiles listed".
- Not on V: (install sim) yet: the installed Game Player won't find the library until vibeinstall copies it.
- Uncommitted in LIB_DEV (the owner's, leave alone): PriorityTube/items.txt, ProjectMap/map_data.txt,
  livecode/game_launch.livecodescript.

**Next: p1-01 game scan** (about 30 min, utility; plan section 3 of PLAYTEST_0001_PLAN.md).
- A plain Python tool `LIB_TEST/game_scan.py` (counting is surer as code than as a model reading files).
  It changes no game.
- Reads every game card script: `LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_*.livecodescript` (56 today),
  plus LIB_GAD/GeneticAnomaly and the other game folders the plan's "69" counted (find them; say the count).
- One table row a game: prefix (`on X.StartLevel` / handler names), levels (count, how found), how keys are
  read (keyDown/rawKeyDown messages or `the keysDown`), uses Tab / arrows, libraries loaded (`start using`),
  **and for p1-13: each line that changes level by calling its own `<Prefix>.StartLevel`, and whether code
  after it expects the new level at once** (41 games have a StartLevel today).
- Out: a TSV + a short markdown table; it feeds p1-02, p1-05 and p1-13. Then p1-12 (Scene.SetReveal).
- Python: MIT licence; run with `python3 -I`; add to FOR_REVIEW via `LIB_DEV/tools/for_review.py add`;
  set p1-01 `done` in extra_items.txt when finished.

## START HERE (22 Nov night): PLAY TEST 0001 IS PLANNED, NOTHING BUILT
- First outside tester (21 Nov). Their notes became 37 bubbles `p1-01`..`p1-37` (`extra_items.txt`, a new third
  source read by tools/tube_items.py; set a line to `done` when finished). Plan: `PLAYTEST_0001_PLAN.md`
  (order in four waves, LIB_LOADING_SCREEN sketch, helper tools, which model does what).
- Order re-made 22 Nov night on his word (PRIORITY_ORDER.txt): p1-10 his yes, p1-01, p1-11, p1-12, p1-13, p1-08, utilities, fixes, fun.
  Fable work done: ~/projects/LIB_LOADING_SCREEN/PLAN.md (waits for his yes + 3 answers; folder not under git yet) and the
  held-keys fix design at the end of ISSUES 0017. Opus can take everything from p1-01 down.
- Tickets opened, not looked into: ISSUES 0017-0020. Never write the tester's name in a public folder.
- The notes file is in LIB_LLMOUT/Read/LIB_PUBLIC. t40 not rerun after the tube_items.py change.


## DONE 22 Nov: CONSOLE IN THE GAME PLAYER, MERGED (owner tried it: "works great!", then "merge"; LIB_DEV f2da048, LIB_ig3d 42498fb, xt3D bridge f289a4f, LIB_SYSTEM c8e9fed)
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
