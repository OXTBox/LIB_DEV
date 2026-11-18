# Priority Tube: the plan

Monday, November 17, 2026. One page by Claude (Opus 5.5) from the owner's words, built the same evening.

## 1. What it is for

The comments on the boards are kept in the order written, which is not their priority. This board
puts them in order. The owner's words: "guided by Claude compute time first, get the fast stuff done
and the utility things done while being focused on fun. That's how it should be presented first.
Something someone like myself might really want more, time be damned, will just slide their cube of
interest over top of other things. Like bubbles in a test tube; dragging = selecting, and once
selected the arrow keys are an alternative repositioning input."

## 2. What it shows

One tall glass tube. Each thing to do is a bubble in it; **the top of the tube is done first**.
- **The bubbles:** every open comment from the boards (BOARD_COMMENTS.txt) and every `next:` step of
  the Project Map's parts (board.txt; the GOAL and YOU cards are goals and notes, not steps).
- **Bubble size = Claude's time:** a small bubble is quick work, a big one is long work. The colour is
  its kind: utility (teal), fun (magenta), fix (green), plan (lavender), big (deep blue), a note
  that needs no work (grey). A bubble Claude has not sized yet is dark and sinks to the bottom.
- **Claude's first order:** shortest Claude time first, with fun counted at 3/4 of its time and
  utility at 0.85 of its time (fast and useful first, leaning to fun).
- **The owner's order wins:** drag a bubble anywhere (dragging also selects it), or select it and
  use the up and down arrows (Shift = to the top or the bottom). A moved bubble is marked as placed
  by the owner. New bubbles slot in by Claude's rule around those he placed, never moving them.
- **The right panel:** the selected bubble in full: its words, Claude's time and why, where it came from.

## 3. How it works

- `tools/tube_items.py` gathers the bubbles into `items.txt` (the stack reads only that) and lists the
  ones Claude has not sized yet. Claude's sizes are hand-kept in `claude_sizes.txt`
  (id, minutes, kind, why). R in the stack runs the tool and redraws.
- The order is the owner's file: `LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt` (top first; each line says
  whether the owner or Claude placed it). `for_review.py feedback` prints it; **Claude works from the top.**
- Stack `PriorityTube.oxtstack`, script `LIB_DEV/livecode/priority_tube.livecodescript`; headless
  checks in OXT-BEYOND/tests/t40_priority_tube.txt. T tells Claude, as on the other boards.

## 4. Later (not in this build)

Bubbles from more places (TODO.md, GAME_NOTES.txt, the On Git or Not decisions); fly from a bubble to
its note on its board; Claude's time compared with the time it really took.
