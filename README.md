# LIB_DEV

The owner's brief (About_LIB_DEV.txt, 2026-11-14): where the needs of the developer are met.
Todo list apps, mind maps, status review browsers, launchers; instructions and applications for
getting started with as little effort or foreknowledge as possible, as if a curious stranger
found the project on GitHub or itch.io and wanted to hand it to AI assistance.

## Status_Browser.livecode: keep up with what the AI makes
Open it in LiveCode (keep it in LIB_DEV: it finds the other folders from there).
- **Left:** every file the AI put up for review, newest first. `o` waiting, `+` reviewed,
  `*` has your feedback. **Refresh** reloads the list.
- **Click a name:** the AI's notes show top right (LIB, work done, warnings, caveats, full path)
  and Explorer opens with the file selected.
- **Right-click a name:** Reviewed / Not Reviewed (changes its state), Open in Explorer, Copy Path.
- **Feedback + Submit:** your note about the selected file goes to the AI's inbox.
- **Tell Claude:** one click asks the AI to read your reviews now (unsent feedback is submitted
  first). It writes a line to `LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt`; the AI watches that file while a
  session is open (`tools/wait_for_tell.sh`), and checks it when the next session starts.

### The layout is yours: `livecode/Status_Browser_gui_For_edits.livecode`
Edit the GUI there (move, resize, restyle). The build (`tools/build_status_browser.lc`) reads
the layout from it, adds the scripts and saves `Status_Browser.livecode`; it never writes to
your file. Keep the control names (Scrolling List Field, LLMNote, Feedback, Label Field, Submit,
Refresh, TellClaude, ReviewMenu).

### Run it as a standalone (survives quitting LiveCode)
Build `Status_Browser_Launcher.livecode` as a standalone ONCE; it opens the current
`Status_Browser.livecode` from disk at every start, so updates need no rebuild. Closing the
browser window quits it.
1. Open `LIB_DEV/livecode/Status_Browser_Launcher.livecode` in the LiveCode IDE.
2. File > Standalone Application Settings: General: name `Status_Browser`; Windows ticked;
   Inclusions: "Search for required inclusions". Do NOT add Status_Browser.livecode as a stack file.
   (Opened in the IDE the launcher only shows itself, with a Test button; it launches only as
   a standalone. Each start is logged to LIB_LLMIN/LIB_DEV/launcher_log.txt.)
3. File > Save as Standalone Application: any folder under `projects` (it finds the projects
   folder by walking up to the one holding LIB_LLMOUT), e.g. `LIB_LLMIN/LIB_DEV/Status_Browser`.
4. Double-click the .exe (pin it to the taskbar).

| File | Who writes it |
|---|---|
| `~/projects/LIB_LLMOUT/FOR_REVIEW.txt` | the AI, with `tools/for_review.py add PATH "work done" "warnings" "caveats"` |
| `~/projects/LIB_LLMIN/LIB_DEV/REVIEW_STATE.txt` | the stack (your Reviewed / Not Reviewed clicks) |
| `~/projects/LIB_LLMIN/LIB_DEV/REVIEW_FEEDBACK.txt` | the stack (your Submit) |

Rebuild after editing `livecode/status_browser.livecodescript`:
`~/projects/LIB_MCP/tools/lcmcp --standalone run - < tools/build_status_browser.lc`
(the owner's original layout is kept in `LIB_LLMOUT/Read/LIB_DEV/Status_Browser_owner.livecode`).

## livecode/GAME_Browser.livecode: a list of the games, each played as its own program
Open it in LiveCode (keep it in LIB_DEV). The menus inside the engines had grown too long;
this is the short way in.
- **Left:** every game in `LIB_GAMES/Vibecode3D_Games`. Click (or arrow up/down) shows its details
  on the right: title, last change, number of levels, keys, rules, the script's path.
- **Double-click or Return:** play it on the engine(s) ticked at the top (Vibecode3d, xt3d, both;
  none ticked = Vibecode3D).
- **Right-click:** Play in Vibecode3D / Play in xt3d (games bench) / Open script in Explorer / Copy script path.
- **Feedback + Submit:** your note goes to `LIB_LLMIN/LIB_GAMES/GAME_NOTES.txt` (the same inbox as
  the in-game notes), marked BROWSER. **Tell Claude** wakes the AI, as in the Status_Browser.

A game never runs inside the browser:
- **Vibecode3D** starts the **Game_Player** app (`Game_Player.exe <Game>`), one program per game.
  Its window has a **...** menu top right: Pause / Resume, Reset, Levels > 1..n, Quit. Escape pauses;
  ` or F2 is the game-notes box. The status line (game, fps, level) and messages (PAUSED,
  GAME OVER, LEVEL n) are made when needed, not fixed objects. Closing the window quits the program.
  Errors: in the window, and in full in `LIB_LLMIN/LIB_DEV/GAME_PLAYER_ERRORS.txt`.
- **xt3d** starts the xt3d games bench (if it is not running) and asks it to play the game.

### Build the Game_Player app ONCE
1. Open `LIB_DEV/livecode/Game_Player_Launcher.livecode` in the LiveCode IDE (it only shows a note there).
2. File > Standalone Application Settings: General: name `Game_Player`; Windows ticked;
   Inclusions: "Search for required inclusions".
3. File > Save as Standalone Application into `LIB_DEV/Game_Player` (the browser looks in
   `LIB_DEV/Game_Player`, `LIB_DEV/Game_Player/Windows x86-64` and `LIB_LLMIN/LIB_DEV/Game_Player`).
It loads the player, the engine library and the game from disk at every start, so updates need
no rebuild.

| File | What |
|---|---|
| `livecode/GAME_Browser_gui_For_edits.livecode` | your layout: edit it freely; the build never writes to it (keep the control names) |
| `livecode/game_browser.livecodescript` | the browser's script |
| `livecode/game_launch.livecodescript` | shared: a game's details (GL.Info) and its window (GL.Open) |
| `livecode/game_player.livecodescript` | the game window: timer, drawing, ... menu, status and messages |
| `livecode/launcher_game_player.livecodescript` | the Game_Player app's launcher |
| `tools/build_game_browser.lc` | builds GAME_Browser.livecode and Game_Player_Launcher.livecode |

Rebuild after editing your layout or the browser script:
`~/projects/LIB_MCP/tools/lcmcp --standalone run - < tools/build_game_browser.lc`
The engine library is `xt3D_Raylib_Livecode_Bridge/testbench/vibe_engine_xt3d.livecodescript`
(the owner's whole engine with the drawing handed to the host; made by that project's
`tools/make_vibe_xt3d.py`).
