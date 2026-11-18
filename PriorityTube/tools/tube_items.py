#!/usr/bin/env python3
"""tube_items: the bubbles of the Priority Tube -> ../items.txt (what PriorityTube.oxtstack draws).

    python3 -I tools/tube_items.py           writes items.txt, prints a summary and the unsized bubbles

Bubbles: every open comment of the boards (LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt; the last line of an
id wins) and every `next:` step of the Project Map's parts (ProjectMap/board.txt; not GOAL or YOU).
Claude's sizes: claude_sizes.txt, hand-kept, one a line:  id TAB minutes TAB kind TAB why
  kind: utility | fun | fix | plan | big | note
items.txt, tab separated:  id  source  minutes  kind  score  title  detail  why
  score = Claude's first order (smaller = higher in the tube): minutes, fun x0.75, utility x0.85;
  an unsized bubble scores 99999 (it sinks to the bottom until Claude sizes it).
"""
import hashlib, os, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))         # LIB_DEV/PriorityTube
LIB_DEV = os.path.dirname(HERE)
PROJECTS = os.path.dirname(LIB_DEV)
COMMENTS = os.path.join(PROJECTS, "LIB_LLMIN", "LIB_DEV", "BOARD_COMMENTS.txt")
BOARD = os.path.join(LIB_DEV, "ProjectMap", "board.txt")
SIZES = os.path.join(HERE, "claude_sizes.txt")
OUT = os.path.join(HERE, "items.txt")
FACTOR = {"fun": 0.75, "utility": 0.85}
SKIP_PARTS = ("GOAL", "YOU")


def clean(s):
    return " ".join(str(s).replace("\t", " ").split())


def comments():
    last = {}
    if os.path.exists(COMMENTS):
        for l in open(COMMENTS, encoding="utf-8", errors="ignore"):
            if l.startswith("#"):
                continue
            b = l.rstrip("\n").split("\t")
            if len(b) >= 8:
                last[b[0]] = b
    out = []
    for cid, b in last.items():
        if b[5] != "open":
            continue
        text = b[7].replace("\\n", " / ").strip(" /")
        out.append([cid, f"comment on {b[2]}", clean(text)[:120] or "(empty)",
                    clean(f"{b[1]} on {b[4]}: " + b[7].replace("\\n", " / "))])
    return out


def next_steps():
    out, part = [], None
    for l in open(BOARD, encoding="utf-8"):
        if l.startswith("=="):
            part = l[2:].split("|")[0].strip()
        elif l.startswith("next:") and part not in SKIP_PARTS:
            text = l[5:].strip()
            nid = "n-" + hashlib.sha1(f"{part}|{text}".encode()).hexdigest()[:8]
            out.append([nid, f"next step of {part}", clean(text), f"Project Map, {part}: {clean(text)}"])
    return out


def sizes():
    s = {}
    if os.path.exists(SIZES):
        for l in open(SIZES, encoding="utf-8"):
            if l.startswith("#") or not l.strip():
                continue
            b = l.rstrip("\n").split("\t")
            if len(b) >= 3:
                s[b[0]] = (b[1], b[2], b[3] if len(b) > 3 else "")
    return s


def main():
    sz = sizes()
    rows, unsized = [], []
    for iid, source, title, detail in comments() + next_steps():
        if iid in sz:
            minutes, kind, why = sz[iid]
            score = round(float(minutes) * FACTOR.get(kind, 1.0), 1)
        else:
            minutes, kind, why, score = "?", "unsized", "Claude has not sized it yet", 99999
            unsized.append(f"{iid}\t\t\t# {source}: {title}")
        rows.append([iid, source, minutes, kind, score, title, detail, clean(why)])
    rows.sort(key=lambda r: (r[4], r[5].lower()))
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        for r in rows:
            f.write("\t".join(str(c) for c in r) + "\n")
    print(f"{OUT}: {len(rows)} bubbles, {len(unsized)} not sized by Claude yet")
    for u in unsized:
        print("  unsized:", u)
    return 0


if __name__ == "__main__":
    if any(a in ("-h", "--help") for a in sys.argv[1:]):
        print(__doc__)
        sys.exit(0)
    sys.exit(main())
