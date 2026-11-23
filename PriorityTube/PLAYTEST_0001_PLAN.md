# Play test 0001: the plan

Fable, 22 Nov 2026. From the notes of the first play test by someone other than the owner
(21 Nov 2026, the installed Vibecode3D copied from V: to a MicroSD card, then to the tester's PC).
The notes themselves stay private (LIB_LLMOUT/Read/LIB_PUBLIC). Nothing here is built yet.

**In the tube:** 37 new bubbles, ids `p1-01` to `p1-37` (`extra_items.txt`, sized in
`claude_sizes.txt`). Press R in the Priority Tube to see them. About 57 hours of Claude time in all:
30 of them are the 20 small and middle jobs most people would feel at once; 27 are the six big ones
at the bottom. Your order wins as always: drag them.

## 1. The order I suggest (the tube sorts by size; this is by what needs what)

**Wave 1: what the tester tripped over (about 5 hours)**
| Bubble | What |
|---|---|
| p1-01 | Game scan table (tool, see section 3). Goes first: three later jobs read it |
| p1-03 | Library: Show Folder / Verify Folder buttons readable |
| p1-07 | Library: numbers left of the game names |
| p1-06 | Crater Crawler wheels |
| p1-04 | Bat Duel quits on arrow keys |
| p1-02 | Clean machine check + Amazing Couple's missing library |
| p1-05 | Held keys pile up and crash XT (Genetic Anomaly star map) |
| p1-22 | Light Trail Arena frame rate |
| p1-26 | Dot Maze: the fast Lean one takes the name (your call) |

**Wave 2: no more SNAP (about 8 hours)**
| Bubble | What |
|---|---|
| p1-10 | LIB_LOADING_SCREEN plan, one page (sketch below), your yes |
| p1-09 | Sound and music back (my addition: the loading screen is where they load) |
| p1-11 | The library built |
| p1-12 | Level start: player first, the rest draws in |
| p1-08 | Play log + tester pack (uses the loading screen's record) |
| p1-14 | Tabletop Racers grid start, 3 2 1 go, and its crash |
| p1-13 | Every game with levels goes through it |

**Wave 3: the game notes, any order, one evening each or less (about 10 hours)**
p1-25 Stack Down sway, p1-24 Shaft Descent run, p1-19 Deep Dive sliders, p1-23 Probe vs Cone pulse,
p1-15 Big Ball of Vectors rain, p1-18 Squad Buggy view, p1-21 Interceptor Run, p1-16 Bounce Rally,
p1-17 Crater Crawler grenades, p1-20 Grid Sprint slopes, p1-27 Dead Days emitters, p1-28 Meadow Marsh plan,
p1-30 Probe and Cone in the Prompt & Glaze story.

**Wave 4: new games (about 7 hours)**
p1-31 Lantern and Ladders (the torch trial first), p1-32 the eagle game, p1-29 ConeProbe3D.

**Bottom, by your words:** p1-33 our Doom-style shooter, p1-34 the spreadsheet (before Christmas),
p1-35 Bit Raider & Opus (parked), p1-36 Matrix Lock, p1-37 Genetic Anomaly (last).

## 2. LIB_LOADING_SCREEN: first sketch (p1-10 turns this into the page you approve)

- **One call for a game:** `Loading.Begin "LEVEL 3"` ... `Loading.Line "walls 212"` ... `Loading.End`.
  A game that calls nothing still gets the default, because the Game Player calls it around
  `<Prefix>.StartLevel`. That is how all games stop snapping without each one being rewritten.
- **The default look (your idea):** the last frame's vectors stay, dimmed, like tube burn; a black veil
  over them; green command-line text types out what is being loaded, one line per thing.
- **Always shown**, even with nothing to load (a short least time, about a second), so sound, music
  and player objects have a place to load later.
- **Always saves:** the game state and one line in the play record (game, level, time, score) each
  time it shows. That record is what counts levels played and feeds the play log (p1-08).
- **Level start (p1-12):** the player first, alone; then the level draws itself in. Tools we have:
  the dashes of graphics (lines that grow), blendLevel fades, drawing by distance from the player.
  A few named styles (`grow`, `fade`, `rain`), one default, a game may pick.
- **Two engines:** the look must work in XT (LiveCode graphics) and in xRay (raylib). The text and the
  record are the same code; only the veil and the reveal are drawn per engine.
- Open for you: how long the least time is; whether Escape skips it; where the record lives
  (default: Documents/My Games/Vibecode3D/play_record.txt).

## 3. Helper applications to build (small tools, most in Python)

| Tool | Where | What it does | Used by |
|---|---|---|---|
| `game_scan.py` | LIB_TEST | One table of all 69 games: prefix, levels, how keys are read (messages or keysDown), libraries loaded, uses Tab/arrows | p1-02, p1-05, p1-13 |
| clean machine check | LIB_PUBLIC `vibeinstall.py` | Copies the install to an empty throw-away place (the Runaway Runtime rule: two copies at most), starts each game with no window, lists what it cannot find | p1-02, then before every card we hand to a tester |
| play log + `play_report.py` | Library, Game Player, LIB_TEST | Start, stop and level lines per game; report: "21 games in 47 minutes, 3 never got past level 1" | p1-08 |
| tester pack `.bat` | LIB_BAT | On the tester's PC: gathers the play log and the in-game notes into one folder to carry back | p1-08 |
| held-key test | OXT-BEYOND/tests | Holds two arrows for some seconds with no window and counts waiting messages: proves p1-05 and guards it | p1-05 |
| fps before/after | exists (`engine_play.sh`) | Same run, numbers before and after | p1-22, p1-26 |
| torch trial card | LIB_GAMES | One card: gradient veil + small blendLevel flicker, fps on both engines | p1-31 |
| `extra_items.txt` | this folder (done today) | Long lists become tube bubbles without filling the Project Map | every play test from now on |

## 4. Who does what (models)

| Who | Jobs | Why |
|---|---|---|
| **Fable** (heavy on the account: only these) | p1-10 loading screen page; the design of the held-key guard in p1-05 (it touches the engine's message loop); concept pages for p1-33 Doom-style and p1-34 spreadsheet; later the Genetic Anomaly hook study (p1-37) | New LIB design, engine-deep changes, plans that weeks follow |
| **Opus** (the session, one helper per bubble) | All building, bug hunts and tests: waves 1-4. Each brief names its folder, its test and the two-engines paragraph | The usual rule |
| **Sonnet helpers** | p1-13 (the same edit in many games, a batch of games each), the sweep half of p1-05, p1-07, p1-03 | Same pattern in many files |
| **Haiku helpers** | Reading logs and the clean machine check's output into a short list; catalogue rows (p1-26) | Digests |
| **Spark** (local, free) | First-draft tables only: the Meadow Marsh rename list (p1-28), ranked name and story options for p1-30. Always checked against the source | Draft only, never code, never the fun |
| **You** | Play each fix; say yes to p1-10; the calls marked "your call"; the next tester | Taste and fun |

`game_scan.py` is a plain script on purpose: counting and listing is cheaper and surer as code than
as a model reading 69 files.

## 4b. Added 22 Nov night: p1-38, it really runs DOOM (owner: "Great Plan!")
- A LiveCode external in its own folder LIB_DOOM, built like the xt3d bridge (small DLL + wrapper), on
  **doomgeneric** (step 1: check its licence is GPL). `Doom.Start`, `Doom.Tick` once a frame,
  `Doom.Frame` = the 320x200 picture for a LiveCode image, `Doom.Key`.
- DOOM's loop never returns: one step per frame. Its quit and fatal error must return, not close LiveCode.
- Data: Freedoom (free), never id's own files. Sound last, through xt3d's sound.
- The 1997 source in LIB_LLMIN/DOOM-main is reference only: its licence is non-profit use, so it never
  goes into our public folders.
- Separate from p1-33 (our own corridor shooter on cellmaps). Opus builds; about a day to picture + keys.

## 5. Things I noted, not built

- **The juice:** two games hooked the tester at once. Crater Crawler ("fun IMMEDIATELY") and Genetic
  Anomaly (understood fast, stayed). Both: you act within seconds and the world answers visibly.
  Worth holding every new game to that.
- **Dead Days' robot aura** (weapons firing with no weapon) stays, your word.
- **Bit Raider & Opus:** Opus, with full control of the vector world, trains Bit Raider (a 1980s
  vector game hero) in everything such a hero can do, in a world made around him. Runner with
  parkour, cars, ramps, bikes, wingsuits. Parked until you say.
- **"Make it run DOOM" and the TempleOS eagle game:** planned as our own games in that spirit (our
  levels, our look), not copies of the real ones. I think the eagle game meant is TempleOS's Eagle
  Dive (not checked).
- **New tickets:** ISSUES 0017 (held keys crash), 0018 (Amazing Couple missing library on the
  installed copy), 0019 (Tabletop Racers crash on a new level), 0020 (Bat Duel quits on arrow keys).
  None looked into yet.
- The tester's notes say "Grid Split"; I took it as Grid Sprint.
