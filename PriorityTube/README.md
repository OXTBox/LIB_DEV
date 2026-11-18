# Priority Tube

Everything to do as bubbles in a glass tube: **the top is done first.** Open `PriorityTube.oxtstack`.

- Bubbles: every open comment from the boards and every `next:` step of the Project Map.
- Size = Claude's time (small = quick); colour = kind: utility teal, fun magenta, fix green, plan
  lavender, big deep blue, note grey.
- Claude's first order: shortest first, leaning to fun (fun x0.75, utility x0.85).
- **Your order wins:** drag a bubble anywhere (dragging selects it), or select it and use the up/down
  arrows (Shift = top/bottom). Moved bubbles say "placed by you"; new ones slot in around them.
- **Right-click a bubble** for its menu: Move to top / Move to bottom / Remove from the tube, then the
  ending every menu has (LIB_MENU): **Leave comment...** writes a line to `LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt`
  (board `PRIORITY TUBE`, target = the bubble's id; it comes back as a new bubble at the next reload) and
  **Explore here...** opens Explorer at the bubble's part folder (a next step), at the folder of the part a
  comment is about, or at the file it came from (board.txt / BOARD_COMMENTS.txt); otherwise the bar says
  "No file or folder for this bubble". Delete, U, the arrows and dragging work as before.
- LIB_MENU is loaded by the tube itself (`~/projects/LIB_MENU/livecode/lib_menu.livecodescript`, found two
  folders above the stack). Without it the menu is plain (no ending) and the bar says "Menus need LIB_MENU".
- Wheel scrolls, R reloads (runs `tools/tube_items.py`), T tells Claude, Esc deselects.
- The order is saved at every move in `LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt`; Claude works from the top.
- Claude's sizes: `claude_sizes.txt` (hand-kept by Claude). Script: `../livecode/priority_tube.livecodescript`;
  headless checks: OXT-BEYOND/tests/t40_priority_tube.txt (52 checks, in its own folder `_work_t40`, 6 of them without LIB_MENU). Plan: PLAN.md.
