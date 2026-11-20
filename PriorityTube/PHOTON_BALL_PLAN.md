# Photon Ball: plan (owner's words, 19 Nov 2026 night; start right after the /clear)

Vector Toss's arena made dangerous and "a lot less casual". Vector Toss itself stays FROZEN as it is
on main (owner: "fine as is"); Photon Ball is a new game made from a copy of it.

## Step 1: the game, hand-placed, NO randomness (LIB_GAMES branch `photon-ball`, off try-19nov-night)
New script `Vibecode3D_Games/Vibecode3D_Play_PhotonBall.livecodescript` (prefix `PB.`), copied from
Vector Toss and renamed. PROMPT and GLAZE in the arena. Matches get worse, one rule each:
1. The ball breaks a square. A broken square you stepped on falls apart a few seconds after you
   step off; jumping on it = smash through into oblivion.
2. The ball breaks the ground on every bounce; stepping on broken ground makes it fall apart.
3. Each bounce damages the squares near it.
4. Each bounce punches holes in the squares near it.
Lloyd moves (LIB_MOCAP cuts): hang from a broken edge, climb out, recover. Stamina counts here
(vector-toss-stamina work); low stamina may finally DO something (slower climb out, shorter hang).
Walls: build the arena from the cellmap height glyphs + slope system (LIB_BIT CELLMAP_V3, E13 walker).
Every wall except the camera side gets INTENTIONALLY PLACED extrusions / slopes / emblems
(hand-made features, chosen so they matter in play). Play test on the real engine
(LIB_GAMES/tools/engine_play.sh), headless test t62.

## Step 2: ComfyUI "dangerous mode" (LIB_COMFY, branch `comfy-photon-ball`)
Nodes that randomise what step 1 placed by hand: wall extrusions / slopes / emblems on the three
non-camera walls (seeded), and the break rules per match. Build on the remix kit (kits/remix.py,
Vibecode3D/Remix nodes, comfy-remix branch). Read LIB_COMFY/NOTES.md first. Then "see what happens".

## Defaults taken (owner asleep; change on his word)
- "Emblazoned" = glyphs/emblems drawn flat ON the wall faces (no depth), next to extruded ones.
- The camera side stays open (no wall features), as in Vector Toss.
- One branch per repo; nothing merged; LEAVE the LIB_GAMES folder on photon-ball so he sees it.
- DeadDays Lloyd climb STAYS (owner: "everything new in there enriches the legacy").
