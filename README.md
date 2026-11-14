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

| File | Who writes it |
|---|---|
| `~/projects/LIB_LLMOUT/FOR_REVIEW.txt` | the AI, with `tools/for_review.py add PATH "work done" "warnings" "caveats"` |
| `~/projects/LIB_LLMIN/LIB_DEV/REVIEW_STATE.txt` | the stack (your Reviewed / Not Reviewed clicks) |
| `~/projects/LIB_LLMIN/LIB_DEV/REVIEW_FEEDBACK.txt` | the stack (your Submit) |

Rebuild after editing `livecode/status_browser.livecodescript`:
`~/projects/LIB_MCP/tools/lcmcp --standalone run - < tools/build_status_browser.lc`
(the owner's original layout is kept in `LIB_LLMOUT/Read/LIB_DEV/Status_Browser_owner.livecode`).
