# On Git or Not

Every folder of `~/projects` on one black, zoomable board (the Project Map's canvas), each thing on one
of two sides: **ON GIT** or **NOT ON GIT**, with the reason. This machine, now: remotes and backups
come later. Open `OnGitOrNot.oxtstack` in OXT-Beyond.

| Colour | Means |
|---|---|
| green | files on git (and the branch checked out, when it is not main) |
| hot pink | loose: new or changed files nobody committed or ignored; branches not merged |
| grey | hidden by a .gitignore rule (popup: each rule, its folders and files) |
| dark | private, never on git (a rule marked private, TRON texts, BILL/, BVH clips) |
| lavender | a big folder (50 MB or more) that lives on this disk only |
| red | a folder that is not a repository: nothing in it is on git (red string to YOU) |

Top row: ON GIT and NOT ON GIT totals, YOU. Columns are the Project Map's (board.txt zones); folders
the map does not know go to NOT SORTED. The right panel lists everything not on git: loose files
first, then folders that are not repositories, then .gitignore rules, biggest first. Click a line to fly there.
Click a chip for its files (many files are grouped by folder with counts); pick one to see it in Explorer.
Keys: F fit, B not-on-git only, R rebuild, T tell Claude, 0 100%.

- `tools/git_map.py` surveys every folder (`--text` prints it) and writes `map_data.txt` (do not edit).
- The stack script is `../livecode/board_canvas.livecodescript`, the same one the Project Map runs;
  this board's title, legend, panel and tool come from the B and L rows of map_data.txt.
- Not yet: Commit / Ignore / Delete / Leave on each loose thing (written to
  LIB_LLMIN/LIB_DEV/GIT_DECISIONS.txt for Claude to carry out): step 4 of PLAN.md.
