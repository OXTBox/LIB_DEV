# LIB_DEV: notes for AI models
- Every file you make or change for the owner: `python3 -I tools/for_review.py add PATH "work done" "warnings" "caveats"`
  (say the branch in caveats when it is not main).
- Each session: `python3 -I tools/for_review.py feedback` to read the owner's states and feedback;
  act on the feedback and log it in LIB_LLMOUT/LIB_DEV/FEEDBACK_HANDLED.txt. Do NOT move the
  lines: the browser reads REVIEW_STATE.txt and REVIEW_FEEDBACK.txt for its marks and history.
- "Tell Claude" button: it writes a line to LIB_LLMIN/LIB_DEV/TELL_CLAUDE.txt. While a session is
  open, keep `tools/wait_for_tell.sh` running in the background; when it exits, read the feedback,
  act on it, and start it again. At a session start, also check that file for clicks made while away.
- Project Map (ProjectMap/): the owner can give feedback or pick files on a red blocker; they land in
  LIB_LLMIN/LIB_DEV/MAP_NOTES.txt (date, part, blocker, feedback|file, text or Windows path). `feedback`
  prints it. Read the files he points to, act on the blocker, update ProjectMap/board.txt, log what you did
  in LIB_LLMOUT/LIB_DEV/FEEDBACK_HANDLED.txt.
- Board comments (Project Map, On Git or Not): right-click anything on a board writes a comment to
  LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt (id, date, board, target, words, open|deleted, where, text; the
  last line of an id wins). `feedback` prints it. The order of comments is NOT their priority. Act on open
  comments; log what you did in LIB_LLMOUT/LIB_DEV/FEEDBACK_HANDLED.txt.
- Priority Tube (PriorityTube/): the owner's order of everything to do, top first; `feedback` prints
  LIB_LLMIN/LIB_DEV/PRIORITY_ORDER.txt. **Work from the top.** Size every new bubble (comments, next
  steps) in PriorityTube/claude_sizes.txt (id, Claude minutes, kind, why): `tools/tube_items.py` lists
  the unsized ones. Never reorder bubbles the owner placed.
  Bubbles he takes off the tube (Delete) are listed in LIB_LLMIN/LIB_DEV/TUBE_REMOVED.txt: never work on them.
- On Git or Not decisions: a loose file's menu offers Commit / Ignore / Delete / Leave; each pick appends
  `date time, folder, Windows path, commit|ignore|delete|leave` to LIB_LLMIN/LIB_DEV/GIT_DECISIONS.txt
  (the last line of a path wins; `feedback` prints it). Claude carries them out: commit (on the repo's
  branch rules), add a .gitignore rule, delete (never inside LIB_LLMIN, LIB_LLMOUT/FOR_REVIEW or the
  owner's private folders; ask when unsure), leave = nothing; then rebuild the board (git_map.py) and log
  it in LIB_LLMOUT/LIB_DEV/FEEDBACK_HANDLED.txt. The board itself runs no git.
- Menus on the boards: every menu ends with "Leave comment..." and "Explore here..." (one handler,
  LIB_MENU's Menu.End; the boards load ~/projects/LIB_MENU/livecode/lib_menu.livecodescript themselves);
  rules in ~/projects/LIB_MENU/PLAN.md. Test: OXT-BEYOND/tests/t39_board_canvas.txt works in its own
  folder (_work_t39), never in the real LIB_LLMIN.
  The Priority Tube (right-click a bubble) and the Status Browser (right-click a file) end their menus the
  same way and load LIB_MENU the same way; their comments use board PRIORITY TUBE (target = bubble id) and
  STATUS BROWSER (target = the file's path). Tests t40 / t13 work in _work_t40 / _work_t13.
