# Project Map

The whole project on one black, zoomable board of cards and strings: **where we are, where we are
going, and what is stopping each part right now.** Not the innards: one card per part, a few chips
under it. Open `ProjectMap.oxtstack` in OXT-Beyond.

## Reading it
| Colour | Means |
|---|---|
| purple box, yellow text | core part |
| grey box, white text | other part |
| green | a feature that works ("404 handlers in 5 scripts", "Box2DXT physics works") |
| lavender | a demo, or in production now |
| gold list | a chain of finished steps |
| white outline | NEXT: the next planned step |
| hot pink | waits for a review (files on the Status Browser, unmerged branches, loose files) |
| red | what stops the next step |
| red string | only YOU can unblock it (ends at the YOU card) |
| grey string | parts that feed each other |

The NOW, GOAL and YOU cards sit on top. The right panel, **What is stopping us**, lists every red
chip, the ones only you can unblock first; click a line to fly there.

## Files waiting for review
Click a pink chip (or YOU's red "files wait your review" chip) and a popup lists its files, newest
first by date; YOU's list is grouped by LIB. Pick one and Explorer opens with the file selected (a
folder opens itself). The paths travel with the map: make_map.py writes them into map_data.txt and
the stack keeps each chip's list in its `cFiles` property, so a click never searches the disk or
waits on the WSL bridge. Loose (uncommitted) files are listed the same way.
A listed file that has since moved shows `[moved]` and opens where it is now (found by name at
rebuild; a common name like README.md must also share a folder name with the old path); one
that is gone shows `[gone]` and opens the nearest folder that still exists.

## Reviewing from the map
Each file in a review popup has a small menu: **Open in Explorer**, **Reviewed**, **Feedback...**.
They write the Status Browser's own files (`LIB_LLMIN/LIB_DEV/REVIEW_STATE.txt`,
`REVIEW_FEEDBACK.txt`, same formats), so a review counts the same from either tool, and the AI
reads them at every session start. Reviewed rebuilds the map, so the file leaves the pink count
at once. **T** = Tell Claude (a line in `TELL_CLAUDE.txt`, which wakes a waiting session).

## Talking about a red blocker
Click a red chip: **Feedback on this blocker...** (a line of words) or **Select file(s) for
Claude...** (pick one or more files; only their paths are passed, Claude reads them). Both go to
`LIB_LLMIN/LIB_DEV/MAP_NOTES.txt` with the part and the blocker's words; press **T** to wake Claude.
A red chip that has files (YOU's review total) still lists them under these two.

## Using it
wheel = zoom at the pointer, drag the black = pan, drag a header = move a part with its chips
(kept in `positions.txt`), click a box = focus (its strings and neighbours stay lit), click the black = clear.
Keys: **F** fit all, **B** blockers only (red and pink), **R** rebuild, **T** tell Claude, **0** 100%.

## Keeping it true
- `board.txt` is the hand-kept half: edit it in any text editor (the format is at its top), then press R.
- `tools/make_map.py` adds the counted half each rebuild: handlers per part, files waiting on the
  Status Browser, branches not merged, loose files, and a red string when a review waits over 2 days.
- `map_data.txt` is what the stack draws (made by make_map.py; do not edit).
- Code: `../livecode/board_canvas.livecodescript`, the stack script shared with the On Git or Not board (apply from the file; headless checks: OXT-BEYOND/tests/t39_board_canvas.txt).

## Comments on anything
Right-click anything (a card, a chip, a column title, a string, a line of the right panel, or the black)
and a big comment box opens: Enter makes a new line, **Ctrl+Enter** or the button saves, Esc cancels.
A saved comment becomes a yellow note on the board, tied by a yellow string to what it is about; it
moves with its card, can be dragged (it keeps its place), and a click on it offers Edit / Delete.
All comments of both boards go to `LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt`, and the right panel lists
them at its end. **The order of comments is not their priority**: a priority board comes later.
