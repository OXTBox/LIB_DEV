#!/usr/bin/env python3
"""make_map: board.txt (hand-kept) + counted facts -> map_data.txt (what the Project Map stack draws).

    python3 -I tools/make_map.py            writes ../map_data.txt and prints a summary

Each rebuild first runs for_review.relink: listed files that moved get their new path in
LIB_LLMOUT/FOR_REVIEW.txt (so the Status Browser opens them too).

Counted facts, per part (folder = the part's name, xt3d = xt3D_Raylib_Livecode_Bridge):
  - handlers in .livecodescript files                    -> green  "N handlers in M scripts"
  - files on LIB_LLMOUT/FOR_REVIEW.txt not yet reviewed  -> pink   "N files wait your review"
      (a red string to YOU when the oldest waits more than 2 days)
  - branches not merged into main / master               -> pink   "branch X not merged"
  - loose (uncommitted) files                            -> pink   "N loose files not committed"

map_data.txt, tab separated, one record a line:
  P  partId  core|part  x  y  w  h  title  what        a part's header box (x,y = default place)
  C  chipId  partId  kind  dx  dy  w  h  text          a chip under its part (offset from the part)
  E  fromId  toId  grey|red                            a string between two boxes
Kinds: has (green), demo (lavender), done (gold list), next (white outline), block (red), review (pink).
"""
import collections, datetime, math, os, re, subprocess, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "tools"))
import for_review  # noqa: E402  (LIB_DEV/tools: the review list's own tool)
PROJECTS = os.path.dirname(os.path.dirname(HERE))
BOARD = os.path.join(HERE, "board.txt")
OUT = os.path.join(HERE, "map_data.txt")
FOLDER = {"xt3d": "xt3D_Raylib_Livecode_Bridge"}
ZONES = ["ENGINES", "GAMES", "BLOCKS", "TOOLS", "SYSTEM"]
ZONE_TITLE = {"ENGINES": "ENGINES", "GAMES": "GAMES", "BLOCKS": "BUILDING BLOCKS",
              "TOOLS": "TOOLS & IDE", "SYSTEM": "SYSTEM & FLOW"}
COL_W, COL_GAP, PART_W, CHIP_W, CHIP_IN = 300, 90, 280, 262, 18
CHARS = 38          # characters a chip line holds at text size 12
LINE_H, PAD = 15, 8
STALE_DAYS = 2
PART_GAP = 34


def read_board():
    parts, cur = [], None
    for raw in open(BOARD, encoding="utf-8"):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if line.startswith("=="):
            bits = [b.strip() for b in line[2:].split("|")]
            cur = {"name": bits[0], "zone": bits[1] if len(bits) > 1 else "SYSTEM",
                   "core": len(bits) > 2 and bits[2] == "core", "what": "", "chips": [], "links": []}
            parts.append(cur)
            continue
        if cur is None or ":" not in line:
            continue
        key, val = line.split(":", 1)
        key, val = key.strip().lower(), val.strip()
        if key == "what":
            cur["what"] = val
        elif key == "link":
            cur["links"] += [v.strip() for v in val.split(",") if v.strip()]
        elif key in ("has", "demo", "done", "next", "block", "review"):
            cur["chips"].append([key, val])
    return parts


def git(folder, *args):
    try:
        return subprocess.run(["git", "-C", folder] + list(args), capture_output=True,
                              text=True, timeout=20).stdout
    except Exception:
        return ""


def handler_count(folder):
    n = files = 0
    pat = re.compile(r"^\s*(private\s+)?(on|function|command)\s+[A-Za-z_.]")
    for root, dirs, names in os.walk(folder):
        dirs[:] = [d for d in dirs if d not in (".git", "TEMPLATES_DO_NOT_COMMIT", "__pycache__")]
        for f in names:
            if f.endswith(".livecodescript"):
                files += 1
                try:
                    n += sum(1 for l in open(os.path.join(root, f), errors="ignore") if pat.match(l))
                except OSError:
                    pass
    return n, files


def reviews():
    state = {}
    p = os.path.join(PROJECTS, "LIB_LLMIN", "LIB_DEV", "REVIEW_STATE.txt")
    if os.path.exists(p):
        for l in open(p, errors="ignore"):
            b = l.rstrip("\n").split("\t")
            if len(b) >= 2:
                state[b[0]] = b[1]
    waiting = collections.defaultdict(list)
    p = os.path.join(PROJECTS, "LIB_LLMOUT", "FOR_REVIEW.txt")
    if os.path.exists(p):
        for l in open(p, errors="ignore"):
            if l.startswith("#"):
                continue
            b = l.split("\t")
            if len(b) >= 3 and state.get(b[2]) != "reviewed":
                waiting[b[1]].append(file_entry(b[1], b[2], b[0][:10], b[3] if len(b) > 3 else ""))
    return waiting


def to_linux(win):
    """\\\\wsl$\\Ubuntu\\home\\... -> /home/... (other Windows paths stay as they are)"""
    m = re.match(r"^\\\\(wsl\$|wsl\.localhost)\\[^\\]+(\\.*)$", win)
    return m.group(2).replace("\\", "/") if m else win


def to_win(linux):
    return "\\\\wsl$\\Ubuntu" + linux.replace("/", "\\")


def file_entry(group, win, date, note):
    """one file for a pink chip's popup: group, label, Windows path, 1 when it is a folder.
    A file that has moved points to where it is now ([moved]); one that is gone opens the
    nearest folder that still exists ([gone]), never Explorer's This PC."""
    win = win.strip()
    name = re.split(r"[\\/]", win.rstrip("\\/"))[-1]
    label = (date[5:] + "  " if date else "") + name
    path = to_linux(win)
    if path.startswith("/") and not os.path.exists(path):
        found = for_review.find_moved(path)
        if found:
            return [group, label + " [moved]", to_win(found), 0, date]
        while path not in ("", "/") and not os.path.isdir(path):
            path = os.path.dirname(path)
        return [group, label + " [gone]", to_win(path), 1, date]
    folder = 1 if os.path.isdir(path) else 0
    return [group, label, win, folder, date]


def add_counted(parts):
    waiting = reviews()
    today = datetime.date.today()
    all_waiting = []
    for p in parts:
        folder = os.path.join(PROJECTS, FOLDER.get(p["name"], p["name"]))
        lib = FOLDER.get(p["name"], p["name"])
        p["stale"] = False
        if os.path.isdir(folder):
            n, files = handler_count(folder)
            if n:
                p["chips"].insert(0, ["has", f"{n} handlers in {files} scripts"])
            if os.path.isdir(os.path.join(folder, ".git")):
                main = "master" if "master" in git(folder, "branch", "--list", "master") else "main"
                for b in git(folder, "branch", "--no-merged", main).split("\n"):
                    b = b.strip(" *")
                    if b:
                        p["chips"].append(["review", f"branch {b} not merged"])
                loose = [l[3:].strip().strip('"') for l in git(folder, "status", "--porcelain").split("\n") if l.strip()]
                if loose:
                    files_ = [file_entry(lib, to_win(os.path.join(folder, f.split(" -> ")[-1]).rstrip("/")), "", "")
                              for f in loose]
                    p["chips"].append(["review", f"{len(loose)} loose file{'s' if len(loose) > 1 else ''} not committed", files_])
        w = waiting.pop(lib, [])
        if w:
            oldest = min(e[4] for e in w)
            all_waiting.extend(w)
            p["chips"].append(["review", f"{len(w)} file{'s' if len(w) > 1 else ''} wait{'' if len(w) > 1 else 's'} your review (oldest {oldest})", w])
            try:
                age = (today - datetime.date.fromisoformat(oldest)).days
            except ValueError:
                age = 0
            if age > STALE_DAYS:
                p["stale"] = True
    # reviews of folders that are not parts land on YOU
    rest = [e for v in waiting.values() for e in v]
    all_waiting.extend(rest)
    you = next((p for p in parts if p["name"] == "YOU"), None)
    if you is not None:
        you["chips"].insert(0, ["block", f"owner: {len(all_waiting)} files wait your review in all (Status Browser)",
                                sorted(all_waiting, key=lambda e: (e[0], e[4]))])
        if rest:
            you["chips"].append(["review", f"{len(rest)} more wait your review in " + ", ".join(sorted(waiting)), rest])
    return parts


def lines_of(text, chars):
    words, lines, cur = text.split(), 0, 0
    for w in words:
        if cur and cur + 1 + len(w) > chars:
            lines += 1
            cur = len(w)
        else:
            cur += (1 if cur else 0) + len(w)
    return lines + 1


def block_of(p):
    """a part as rows relative to its header: (header height, chip rows, edges, total height)"""
    chips, edges = [], []
    done = [c[1] for c in p["chips"] if c[0] == "done"]
    for c in p["chips"]:
        k, t, files = c[0], c[1], (c[2] if len(c) > 2 else [])
        if k == "done":
            if done is not None:
                chips.append(["done", "DONE\\n" + "\\n".join("- " + d for d in done), len(done) + 1, []])
                done = None
            continue
        if files:
            t += " - click to list them"
        chips.append([k, t, lines_of(t, CHARS), files])
    title_lines = 1 + (lines_of(p["what"], CHARS) if p["what"] else 0)
    head_h = 22 + LINE_H * title_lines
    rows, dy = [], head_h + 6
    for i, (k, t, n, files) in enumerate(chips, 1):
        cid = f"{p['name']}#{i}"
        h = LINE_H * n + PAD + (4 if k == "done" else 0)
        rows.append(["C", cid, p["name"], k, CHIP_IN, dy, CHIP_W, h, t])
        for g, label, win, isdir, _ in files:
            rows.append(["F", cid, g, label, win, isdir])
        if k == "block" and t.lower().startswith("owner:") and p["name"] != "YOU":
            edges.append(["E", cid, "YOU", "red"])
        dy += h + 4
    if p.get("stale"):
        edges.append(["E", p["name"], "YOU", "red"])
    for l in p["links"]:
        edges.append(["E", p["name"], l, "grey"])
    return head_h, rows, edges, dy


def layout(parts):
    """zones left to right; a tall zone wraps into more columns so the whole board is about 16:9"""
    out, edges, zones = [], [], []
    blocks = {p["name"]: block_of(p) for p in parts}
    body = [p for p in parts if p["zone"] != "TOP"]
    total = sum(blocks[p["name"]][3] + PART_GAP for p in body)
    ncols = max(len(ZONES), round(math.sqrt(1.7 * total / (COL_W + COL_GAP))))
    target = total / ncols
    x, y0 = 0, 260
    for z in ZONES:
        zparts = [p for p in body if (p["zone"] if p["zone"] in ZONES else ZONES[-1]) == z]
        if not zparts:
            continue
        zx, y = x, y0
        for p in zparts:
            h = blocks[p["name"]][3]
            if y > y0 and y + h - y0 > target:
                x += COL_W + COL_GAP // 3
                y = y0
            place(out, edges, p, blocks[p["name"]], x, y)
            y += h + PART_GAP
        zones.append(["Z", z, ZONE_TITLE[z], zx, y0 - 76, x + COL_W - zx])
        x += COL_W + COL_GAP
    width = x - COL_GAP
    top = [p for p in parts if p["zone"] == "TOP"]
    tx = max(0, (width - len(top) * (COL_W + COL_GAP * 2)) // 2)
    top_h = max([blocks[p["name"]][3] for p in top] or [0])
    for p in top:
        place(out, edges, p, blocks[p["name"]], tx, y0 - 100 - top_h)
        tx += COL_W + COL_GAP * 2
    names = {p["name"] for p in parts}
    edges = [e for e in edges if e[2] in names or "#" in e[2]]
    return zones + out + edges


def place(out, edges, p, block, x, y):
    head_h, rows, bedges, _ = block
    out.append(["P", p["name"], "core" if p["core"] else "part", x, y, PART_W, head_h, p["name"], p["what"]])
    out.extend(rows)
    edges.extend(bedges)


def main():
    moved = for_review.relink(quiet=True)   # keep FOR_REVIEW.txt current: moved files point to where they are now
    if moved:
        print(f"relinked {len(moved)} moved files on the review list")
    parts = add_counted(read_board())
    rows = layout(parts)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(f"# map_data.txt made {datetime.datetime.now():%Y-%m-%d %H:%M} by tools/make_map.py; do not edit (edit board.txt)\n")
        for r in rows:
            f.write("\t".join(str(c).replace("\t", " ") for c in r) + "\n")
    kinds = collections.Counter(r[3] for r in rows if r[0] == "C")
    print(f"{OUT}: {sum(1 for r in rows if r[0]=='P')} parts, {sum(kinds.values())} chips {dict(kinds)}, "
          f"{sum(1 for r in rows if r[0]=='E')} strings")


if __name__ == "__main__":
    sys.exit(main())
