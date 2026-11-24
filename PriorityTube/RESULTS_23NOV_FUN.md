# 23 Nov night: fun bubbles (helper results, newest last)

## p1-15 Big Ball of Vectors: rain on shadow rings — branch bigball-rain eb7dc03
- Grey ring on the floor ~26 frames before each new agent drops (7-frame fall, green trail + puff); never within 160+ball size of the ball (ring jumps if the ball rolls near); first wave of a level rains in one by one.
- Constants kSafeR, kWarnTicks, kFallTicks, kDropH, kStagger. Hazards still pop in (bubble was about enemies).
- t76_bigball_rain 9/9 both engines; t70 (Big Ball) 2/2 both.

## p1-20 Grid Sprint: wide open grid, few rivals, low hills — branch gridsprint-open 31dedc8
- Road half width 300 (was 180), 3 rivals (was 7, kRivals), 3-4 low hills a level (40-70 high, 3200 apart, start flat, same per level); car, rivals, signs ride the hills, nose tips, uphill slows a little.
- Try: level 1, hold Up: first hill ~2-3 s after the first green gate. Win bonus now (5-place)x100xlevel.
- t76_gridsprint_open 9/9, t58 31/31, t70 2/2, both engines; frame time a bit faster (7.06 -> 6.79 ms).
- Already on main, not changed: low gear for 600 frames runs the gate timer out on level 2.

## p1-23 Probe vs Cone: energy pulse + javelin never out of reach — branch probecone-pulse da234ca
- Blue-violet wiggling line between neighbouring standing cubes of the outer ring stops the javelin (falls back, blue sparks); a broken cube opens both links beside it. Hitting a cube directly still breaks it.
- Your note (javelin quiet at the cone, unreachable): the Cone turned a slow javelin back every frame so it shook to a stop there. Now it only turns back javelins coming at it, and a slow javelin out of reach (Cone, inside shield, under top wall from level 4) slides to the nearest reachable spot; slow javelins no longer break cubes.
- His choices: pulse on outer ring only; early levels a bit harder now.
- t76_probecone_pulse 14/14 both engines (48 throws, none out of reach); t70 2/2.

## p1-19 Deep Dive: P = pause / preferences, two sliders — branch deepdive-prefs 4b5242e
- HUD "P: PAUSE / PREFERENCES" (HUD letters have no "="). P pauses + panel: MOST AIR (level 1 seconds, 6-40; -2 s a level, min 6) and DANGER (fish speed %, 50-250). Live; kept through Reset/levels for the session, not saved to disk (your choice if you want saving).
- New defaults: air 18 s on level 1 (was 26), danger 130 % (was 100).
- Note: in the Vibecode3D app P also opens the app's own Pause menu next to the panel.
- t76_deepdive_prefs 24/24 both engines; t70 all 156 checks both engines.

## p1-21 Interceptor Run: straight helicopter with turret, cars sink — branch interceptor-heli 45aedea
- From level 2 the helicopter flies straight down to mid-screen, hovers, climbs out; body never turns, only a smaller rotor spins; a small yellow turret follows your car and fires red shots (~every 2 s, faster each level; a hit costs a life). A missile still downs it.
- Red/white cars and orange trucks that reach the water turn blue-grey, tip and sink, gone in ~1 s (red car sunk = 150). Your car still turns into a boat (unchanged). Dock pile-ups later.
- His choice: turret shots replaced the old bombs (can bring bombs back too).
- t76_interceptor_heli 19/19 both engines; t58 no FAIL; t70 156 pass.

## p1-18 Squad Buggy: wider view + wreck knob in ComfyUI — LIB_GAMES squadbuggy-view a5c372d, LIB_COMFY squadbuggy-wreck-knob 95e987b
- kCamBack = 150: camera further back/higher, ground line stays put, ~half as much land again each side (0 = old view). Walkers/bombers enter from past the wider edges (arrive ~2-3 s later).
- kWreck = 1 (today's craters); Squad.SetWreck 0..2 while playing. ComfyUI Terrain node has a new `wreck` slider (0..2).
- MERGE ORDER: LIB_GAMES branch before/with the LIB_COMFY one (Comfy build needs kWreck). Comfy: run tools/install.sh, restart Comfy, reload squad_remix workflow.
- t76_squadbuggy_view 16/16 both engines; t70 156 pass; t24 (now runs past Camera.Reset) 63 pass / 3 old fails also on main (bomber-from-behind checks); remix tests seeds 1-10 ok.

## p1-31 NEW GAME Lantern and Ladders — branch lantern-ladders 52e7506
- Torch trial: one radial-gradient graphic over the view, clear round the lantern, follows it, shrinks with the oil (70-180 px), blendLevel flicker 0-8 every third frame. HUD words in their own field above the dark.
- Game: climb a dark tower by ladders (never one above another: walks in the dark over gaps), oil drains like Shaft Descent's air, oil flasks +15 s, bats, falling stones, green door = next level (loading screen). 5 levels, 3 lives; a lost life = back to the bottom.
- Keys: A/D walk, W/S climb, Shift run (1.7x, oil 2x), Space jump (+ Left/Right to jump off a ladder).
- Look for: spooky enough? flicker right? light shrinks with oil? words readable? Not seen on screen, not on xRay.
- t76_lantern_ladders 24/24 both engines (~0.7 ms a frame); t70 156 pass.

## p1-29 NEW GAME ConeProbe3D (third person, power bar) — branch coneprobe3d 114581f (built on probecone-pulse)
- Probe vs Cone's rules (rings, pulse, password keys, foes, Cone, 5 levels) seen from behind/above Probe; camera swings round as he turns.
- Keys: W/S run, A/D turn, Q/E step sideways; HOLD Space (or mouse) to charge (arm draws back, dotted line grows), let go to throw. Power bar bottom left: 1 quick throw, 2 dash (3 s), 3 recall javelin (8 s).
- Look for: camera height/distance (150 back, 75 up), charge time (1 s), where the bar sits.
- t76_coneprobe3d 28/28 both engines (level 4 ~13 ms a frame); t76_probecone_pulse all pass; t70 copy with CP3 all pass.

## p1-24 Shaft Descent: Shift = run, uses more air — branch shaft-run 95af978
- Hold Left/Right + Shift: 1.7x speed (kRunFactor), air counts down 2x (kRunAir). Shift standing still uses normal air. New help line near the top: "ARROWS RUN   SPACE JUMP   SHIFT = RUN (MORE AIR)".
- t76_shaft_run 14/14 both engines; t70 156 pass.

## p1-16 Bounce Rally: no overlaps, hit cars spin out one way and leave — branch bouncerally-spin 1361228
- Red/purple cars that overlap are pushed apart each frame. A car you bump or land on (Space) picks one spin direction at the first hit, spins and slides off the side (~2 s), then is removed; a spinning car can knock another one out.
- Score: spun red car 100 once; landing on purple 200 then it spins away. Driving into a purple car on the ground still costs a life.
- t76_bouncerally_spin 12/12 both engines; t22 smoke ok; t70 ok.
