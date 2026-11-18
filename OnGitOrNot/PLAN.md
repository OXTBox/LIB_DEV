# On Git or Not: the plan

Monday, November 17, 2026. One page by Claude (Opus 5.5) from the owner's request, written before a
/clear so the next session starts here. The owner corrects it; build starts when he says go.

## 1. What it is for

The owner's words: "same kind of project map, but 'On git.' and 'Not on git'". After he cleared
LIB_LLMOUT by hand (17 Nov) he wants to see, for every part of `~/projects`, **what git keeps, what
it leaves out on purpose, and what is loose**, and decide each loose thing with a click, without
reading git output. Same board, same feel as the Project Map ("a whole house instead of just the
idea of one"): the view of where things are, not the innards.

## 2. What the board shows

One card per folder in `~/projects` (every LIB_*, the engines, and the non-git folders), in the
Project Map's columns (ENGINES / GAMES / BLOCKS / TOOLS / SYSTEM, from `ProjectMap/board.txt` zones;
unknown folders go to a sixth column, NOT SORTED). Under each card, chips:

| Chip | Colour | Example | Popup on click |
|---|---|---|---|
| On git | green | "93 files on git (main)" | none, or the top folders |
| Left out on purpose | grey | "216 files ignored: TEMPLATES_DO_NOT_COMMIT, __pycache__" | the ignore rules that cause it |
| Loose | hot pink | "4 files not on git" | each file: Open in Explorer / Commit / Ignore / Delete / Leave |
| Unmerged branch | pink | "branch vector-toss-dangle (3 commits)" | Merge / Keep / Delete branch |
| Big things on disk only | lavender | "LIB_LLMOUT/Read: 115 MB, 6,425 files" | Open in Explorer |
| Not a repository | red | "TO_REMOVE: 296 MB, no git" | Make it a LIB repo / Ignore folder / Delete |
| Not backed up | red, string to YOU | "no remote: only on this machine" | see section 5 |

Top row: **ON GIT** (totals), **NOT ON GIT** (totals, biggest first), **YOU** (decisions waiting).
The right panel lists every loose thing, biggest first; click to fly there (Project Map's panel).

## 3. How it works (reuse, don't copy)

- **Data:** `OnGitOrNot/tools/git_map.py` writes `OnGitOrNot/map_data.txt` in the Project Map's
  format (P / C / F / E / Z rows), so the same drawing code reads it. Per folder it runs
  `git ls-files | wc`, `git status --porcelain --ignored -uall`, `git branch --no-merged`,
  `git remote`, `du`; it groups ignored and loose files by their top folder so a chip never lists
  6,000 lines (the popup shows folders with counts, then files).
- **Stack:** `OnGitOrNot.oxtstack` uses the SAME canvas code. Step 1 of the build: move the
  drawing/zoom/pan/focus/popup handlers of `ProjectMap/livecode/project_map.livecodescript` into a
  shared library `LIB_DEV/livecode/board_canvas.livecodescript` (prefix `bc`), used by both stacks;
  each stack keeps only its own menus. The Project Map must still work after that step (test it first).
- **Decisions, not git commands, from the stack:** a click writes one line to
  `LIB_LLMIN/LIB_DEV/GIT_DECISIONS.txt` (date, folder, path, commit|ignore|delete|leave|merge|...);
  T tells Claude. Claude carries them out, commits, and the next rebuild shows the result. Nothing is
  deleted by the stack itself (deletes are only done by Claude after reading the line, and
  never inside LIB_LLMIN / LIB_LLMOUT/FOR_REVIEW / the owner's private folders).
- Paths kept in each chip's `cFiles` (no WSL search on click); Explorer via `start` (non-blocking);
  missing files: the Project Map's [moved] / [gone] rule.

## 4. Known facts to start from (17 Nov survey)

- 39 git repositories, **all without a remote**. Branches not merged: LIB_GAMES `vector-toss-dangle`
  (checked out!) and `engine-contract`, LIB_COMFY `comfy-vector-pong` (checked out), LIB_EDITOR and
  LIB_ig3d `release-checklist`, LIB_USERS `library-plans`.
- Loose now: LIB_GAMES 4 ComfyPong games (made by the Comfy node: belong with LIB_COMFY's branch),
  LIB_SYSTEM and xt3d `__pycache__/` (should be ignored), LIB_LLMOUT two README.md inside `Read/`.
- Not git: LIB_COMPANY, LIB_FACE, LIB_LUA (a lua tarball), LIB_OMEGA (empty), Next_Steps_With_Claude,
  OXT-BEYOND, XTJSON (4 MB of harvests), iGame3D_2026_CLAUDE (52 MB), logs, **TO_REMOVE (296 MB)**.
  LIB_ALPHA rule 2 says every LIB_ is a repository: LIB_COMPANY / FACE / LUA / OMEGA break it.
- Ignored on purpose, large: LIB_BUILD (3,177 files: build output), LIB_LLMOUT (6,544: read items),
  LIB_LLMIN (621: the inbox), LIB_BIN (238: third-party apps), LIB_GAMES (216: templates), LIB_UPBGE,
  LIB_MOCAP, LIB_TTRPG (models/media), xt3d (111).
- Private, never on git (owner's rule): LIB_USERS/BILL/CLAUDE_OBSERVATIONS.md, V:'s private docs,
  TRON texts, LIB_BVH clips with unsettled rights. The board shows them as grey "private" and offers
  no Commit.

## 5. Questions for the owner (default in brackets)

1. Backup: should "on git" also mean "off this machine" (a private remote, or a dated zip of every
   repo's .git to V: or another drive)? [the board shows "no remote" in red; no remote is made
   until you say where]
2. TO_REMOVE (296 MB): delete after a look? [shown red, untouched]
3. LIB_COMPANY / FACE / LUA / OMEGA: make repos, fold into another LIB, or delete? [shown red]
4. One board or a second tab in the Project Map? [a separate stack, sharing the canvas library]

## 6. Build order (each step committed before the next)

1. `board_canvas` library out of the Project Map; Project Map still passes its checks.
2. `git_map.py` + its map_data; print a text summary first and check it against the survey above.
3. `OnGitOrNot` stack on the shared canvas; look at it with the owner.
4. Decisions file + Claude's handling (CLAUDE.md note, `for_review.py feedback` prints GIT_DECISIONS).
5. Then the owner's answers to section 5.
