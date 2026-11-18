# Priority Tube

Everything to do as bubbles in a glass tube: **the top is done first.** Open `PriorityTube.oxtstack`.

- Bubbles: every open comment from the boards and every `next:` step of the Project Map.
- Size = Claude's time (small = quick); colour = kind: utility teal, fun magenta, fix green, plan
  lavender, big deep blue, note grey.
- Claude's first order: shortest first, leaning to fun (fun x0.75, utility x0.85).
- **Your order wins:** drag a bubble anywhere (dragging selects it), or select it and use the up/down
  arrows (Shift = top/bottom). Moved bubbles say "placed by you"; new ones slot in around them.
- Wheel scrolls, R reloads (runs `tools/tube_items.py`), T tells Claude, Esc deselects.
- The order is saved at every move in `LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt`; Claude works from the top.
- Claude's sizes: `claude_sizes.txt` (hand-kept by Claude). Script: `../livecode/priority_tube.livecodescript`;
  headless checks: OXT-BEYOND/tests/t40_priority_tube.txt. Plan: PLAN.md.
