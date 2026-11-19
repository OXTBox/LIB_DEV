#!/usr/bin/env python3
"""git_map: every folder of ~/projects on one of two sides, ON GIT or NOT ON GIT -> map_data.txt
(the Project Map's format, drawn by the same canvas script: LIB_DEV/livecode/board_canvas.livecodescript).

    python3 -I tools/git_map.py           writes ../map_data.txt and prints a summary
    python3 -I tools/git_map.py --text    prints the whole survey as text, writes nothing

This machine, now (the owner, 17 Nov 2026): no remotes, no backups in this build.
Per folder of ~/projects:
  green   "N files on git"                 tracked files (and the branch checked out)
  pink    "N loose files"                  new or changed, not committed and not ignored
  pink    "branch X not merged"
  grey    "N files hidden by .gitignore"   popup: each rule, its folders with counts
  dark    "private"                        ignored on purpose under a rule marked private
  lavender "big on disk only"              an ignored or loose folder of 50 MB or more
  red     "not a repository"               nothing in it is on git (red string to YOU)
Extra rows beyond make_map's P C E F Z:
  B  key  value      board settings (title, bar, help, tool, panel, legend)
  L  chipId          the right panel's lines, in this order (biggest first)
"""
import collections, datetime, os, subprocess, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))          # LIB_DEV/OnGitOrNot
LIB_DEV = os.path.dirname(HERE)
PROJECTS = os.path.dirname(LIB_DEV)
sys.path.insert(0, os.path.join(LIB_DEV, "ProjectMap", "tools"))
import make_map  # noqa: E402  (the Project Map's layout: same columns, same chip sizes)

OUT = os.path.join(HERE, "map_data.txt")
BOARD = os.path.join(LIB_DEV, "ProjectMap", "board.txt")
BIG = 50 * 1024 * 1024
MAX_FILES = 80                       # a popup lists at most this many lines; more are grouped by folder
PRIVATE_WORDS = ("private",)         # a .gitignore comment above a rule with this word marks it private
PRIVATE_PATHS = ("claude_observations", "/tron_", "/tron ")   # the owner's rule: never on git
make_map.ZONES = make_map.ZONES + ["NOTSORTED"]
make_map.ZONE_TITLE["NOTSORTED"] = "NOT SORTED"


def run(folder, *args, stdin=None):
    try:
        return subprocess.run(["git", "-C", folder] + list(args), capture_output=True, text=True,
                              input=stdin, timeout=60).stdout
    except Exception:
        return ""


def size_of(path):
    try:
        if os.path.isdir(path) and not os.path.islink(path):
            return sum(size_of(os.path.join(path, n)) for n in os.listdir(path))
        return os.lstat(path).st_size
    except OSError:
        return 0


def files_in(path):
    if os.path.isdir(path) and not os.path.islink(path):
        out = []
        for root, dirs, names in os.walk(path):
            out += [os.path.join(root, n) for n in names]
        return out
    return [path]


def mb(n):
    if n >= 1024 * 1024 * 1024:
        return f"{n / 1024 ** 3:.1f} GB"
    if n >= 10 * 1024 * 1024:
        return f"{n // (1024 * 1024)} MB"
    if n >= 1024 * 1024:
        return f"{n / 1024 ** 2:.1f} MB"
    if n >= 1024:
        return f"{n // 1024} KB"
    return f"{n} bytes"


def plural(n, word):
    return f"{n:,} {word}{'' if n == 1 else ('es' if word.endswith('ch') else 's')}"


def win(path):
    return make_map.to_win(path)


def top_of(rel):
    """the first folder of a repo-relative path ('' for a file at the top)"""
    return rel.split("/", 1)[0] if "/" in rel else ""


def grouped(folder, rels, group, flag=""):
    """F entries for a chip: one per file when few, else one per top folder with its count and size.
    flag "decide": the board offers Commit / Ignore / Delete / Leave on each line (GIT_DECISIONS.txt)"""
    rels = sorted(rels)
    if len(rels) <= MAX_FILES:
        return [[group, r, win(os.path.join(folder, r)), 0, flag] for r in rels]
    by = collections.defaultdict(list)
    for r in rels:
        by[os.path.dirname(r) or "."].append(r)
    if len(by) > MAX_FILES:
        by = collections.defaultdict(list)
        for r in rels:
            by[top_of(r) or "."].append(r)
    out = []
    for d, rs in sorted(by.items(), key=lambda kv: -len(kv[1])):
        sz = sum(size_of(os.path.join(folder, r)) for r in rs)
        out.append([group, f"{d}/  [{plural(len(rs), 'file')}, {mb(sz)}]", win(os.path.join(folder, d)), 1, flag])
    return out


def private_rules(folder):
    """'.gitignore:line' of rules that a comment marks private (the comment block just above them)"""
    out = set()
    for root, dirs, names in os.walk(folder):
        dirs[:] = [d for d in dirs if d != ".git"]
        if ".gitignore" not in names:
            continue
        p = os.path.join(root, ".gitignore")
        rel = os.path.relpath(p, folder)
        marked = False
        for i, l in enumerate(open(p, errors="ignore"), 1):
            s = l.strip().lower()
            if s.startswith("#"):
                marked = marked or any(w in s for w in PRIVATE_WORDS)
            elif not s:
                marked = False
            else:
                if marked:
                    out.add(f"{rel}:{i}")
    return out


def survey_repo(name, folder):
    """the facts of one repository"""
    f = {"name": name, "repo": True}
    head = run(folder, "rev-parse", "--abbrev-ref", "HEAD").strip()
    main = "master" if "master" in run(folder, "branch", "--list", "master") else "main"
    f["branch"], f["main"] = head, main
    tracked = [l for l in run(folder, "ls-files", "-z").split("\0") if l]
    f["tracked"] = len(tracked)
    f["tracked_size"] = sum(size_of(os.path.join(folder, t)) for t in tracked)
    f["unmerged"] = [b.strip(" *") for b in run(folder, "branch", "--no-merged", main).split("\n") if b.strip(" *")]
    f["remotes"] = run(folder, "remote").split()
    new, changed, ignored = [], [], []
    for l in run(folder, "status", "--porcelain", "--ignored", "-uall", "-z").split("\0"):
        if len(l) < 4:
            continue
        code, rel = l[:2], l[3:]
        if code == "!!":
            ignored.append(rel)
        elif code == "??":
            new.append(rel)
        else:
            changed.append(rel)
    # a nested repository shows as one untracked folder: count what is in it
    f["new"] = []
    for r in new:
        p = os.path.join(folder, r)
        if r.endswith("/"):
            f["new"] += [os.path.relpath(x, folder) for x in files_in(p)]
        else:
            f["new"].append(r)
    f["changed"] = changed
    # each ignored file's rule
    rules = collections.defaultdict(list)
    priv = private_rules(folder)
    if ignored:
        out = run(folder, "check-ignore", "-v", "-n", "--no-index", "--stdin", "-z",
                  stdin="\0".join(ignored) + "\0")
        bits = out.split("\0")
        # -z -v: source, linenum, pattern, path (4 fields each)
        for i in range(0, len(bits) - 3, 4):
            src, ln, pat, path = bits[i:i + 4]
            key = f"{src}:{ln}"
            private = key in priv or any(w in "/" + path.lower() for w in PRIVATE_PATHS)
            rules[(pat or "?", private)].append(path.rstrip("/"))
    f["ignored"] = {}
    for (pat, private), rels in rules.items():
        allrels = []
        for r in rels:
            p = os.path.join(folder, r)
            allrels += [os.path.relpath(x, folder) for x in files_in(p)] if os.path.isdir(p) else [r]
        f["ignored"][(pat, private)] = allrels
    if any(w in folder for w in ("LIB_BVH",)):
        f["private_note"] = "BVH clips: rights not settled, kept on this machine"
    return f


def survey_plain(name, folder):
    """a folder that is not a repository: nothing in it is on git"""
    f = {"name": name, "repo": False, "tops": {}}
    total_n = total_s = 0
    for entry in sorted(os.listdir(folder)):
        p = os.path.join(folder, entry)
        fl = files_in(p)
        s = sum(size_of(x) for x in fl)
        f["tops"][entry] = (len(fl), s, os.path.isdir(p))
        total_n += len(fl)
        total_s += s
    f["files"], f["size"] = total_n, total_s
    return f


def survey():
    out = []
    for name in sorted(os.listdir(PROJECTS), key=str.lower):
        p = os.path.join(PROJECTS, name)
        if not os.path.isdir(p) or name.startswith("."):
            continue
        out.append(survey_repo(name, p) if os.path.isdir(os.path.join(p, ".git")) else survey_plain(name, p))
    loose = [n for n in sorted(os.listdir(PROJECTS)) if not os.path.isdir(os.path.join(PROJECTS, n))]
    return out, loose


def board_zones():
    """zone and core flag of each folder, from the Project Map's board.txt"""
    zones = {}
    for l in open(BOARD, encoding="utf-8"):
        if l.startswith("=="):
            b = [x.strip() for x in l[2:].split("|")]
            folder = make_map.FOLDER.get(b[0], b[0])
            zones[folder] = (b[1] if len(b) > 1 else "SYSTEM", len(b) > 2 and b[2] == "core")
            if "/" in b[0]:                       # "LIB_LLMIN / LLMOUT"
                zones["LIB_LLMIN"] = zones["LIB_LLMOUT"] = zones[folder]
    return zones


def parts_of(facts, loose_top):
    zones = board_zones()
    parts, panel = [], []          # panel: (size, partName, chipIndex)
    tot = collections.Counter()
    for f in facts:
        name = f["name"]
        folder = os.path.join(PROJECTS, name)
        zone, core = zones.get(name, ("NOTSORTED", False))
        if zone == "TOP":
            zone = "NOTSORTED"
        p = {"name": name, "zone": zone, "core": core, "what": "", "chips": [], "links": [], "stale": False}
        parts.append(p)
        if not f["repo"]:
            p["what"] = "Not a repository"
            files = [[name, f"{e}{'/' if d else ''}  [{plural(n, 'file')}, {mb(s)}]", win(os.path.join(folder, e)), 1 if d else 0, ""]
                     for e, (n, s, d) in sorted(f["tops"].items(), key=lambda kv: -kv[1][1])]
            words = "empty folder" if not f["files"] else f"{plural(f['files'], 'file')}, {mb(f['size'])}"
            p["chips"].append(["block", f"owner: not a repository, nothing here is on git ({words})", files])
            panel.append((1, f["size"], name, len(p["chips"])))
            tot["plain_files"] += f["files"]
            tot["plain_size"] += f["size"]
            tot["plain_folders"] += 1
            continue
        on = f"{plural(f['tracked'], 'file')} on git ({mb(f['tracked_size'])})"
        if f["branch"] != f["main"]:
            on += f", branch {f['branch']} checked out, not {f['main']}"
        p["what"] = "Repository" + (", remotes: " + ", ".join(f["remotes"]) if f["remotes"] else "")
        p["chips"].append(["has", on])
        tot["tracked"] += f["tracked"]
        tot["tracked_size"] += f["tracked_size"]
        tot["repos"] += 1
        for b in f["unmerged"]:
            p["chips"].append(["review", f"branch {b} not merged into {f['main']}"])
            tot["branches"] += 1
        loose = f["new"] + f["changed"]
        if loose:
            sz = sum(size_of(os.path.join(folder, r)) for r in loose)
            words = []
            if f["new"]:
                words.append(f"{len(f['new'])} new")
            if f["changed"]:
                words.append(f"{len(f['changed'])} changed")
            p["chips"].append(["review", f"{plural(len(loose), 'loose file')} ({', '.join(words)}, {mb(sz)}): not on git, not ignored",
                               grouped(folder, loose, name, "decide")])
            panel.append((2, sz, name, len(p["chips"])))
            tot["loose"] += len(loose)
            tot["loose_size"] += sz
        for private in (False, True):
            rules = {pat: rels for (pat, pv), rels in f["ignored"].items() if pv == private}
            if not rules:
                continue
            n = sum(len(r) for r in rules.values())
            sz = sum(size_of(os.path.join(folder, r)) for rs in rules.values() for r in rs)
            files = []
            for pat, rels in sorted(rules.items(), key=lambda kv: -len(kv[1])):
                files += grouped(folder, rels, f"rule {pat}  [{len(rels)}]")
            names = ", ".join(pat for pat, _ in sorted(rules.items(), key=lambda kv: -len(kv[1]))[:4])
            if private:
                p["chips"].append(["private", f"private, never on git: {plural(n, 'file')} ({mb(sz)}) by {names}", files])
                tot["private"] += n
                tot["private_size"] += sz
            else:
                p["chips"].append(["ignored", f"{plural(n, 'file')} hidden by .gitignore ({mb(sz)}): {names}", files])
                panel.append((0, sz, name, len(p["chips"])))
                tot["ignored"] += n
                tot["ignored_size"] += sz
        # big folders that live on this disk only
        tops = collections.Counter()
        for rs in list(f["ignored"].values()) + [loose]:
            for r in rs:
                tops[top_of(r) or r] += size_of(os.path.join(folder, r))
        for t, s in tops.most_common():
            if s >= BIG:
                p["chips"].append(["demo", f"big, on this disk only: {t}/ {mb(s)}", [[name, t, win(os.path.join(folder, t)), 1, ""]]])
        if f.get("private_note"):
            p["chips"].append(["private", "private: " + f["private_note"]])
    # the top row
    top_on = {"name": "ON GIT", "zone": "TOP", "core": True, "what": "What git keeps on this machine", "links": [], "stale": False,
              "chips": [["has", f"{plural(tot['tracked'], 'file')} in {tot['repos']} repositories ({mb(tot['tracked_size'])})"],
                        ["next", "No repository has a remote yet: remote locations and backups come later"]]}
    if tot["branches"]:
        top_on["chips"].append(["review", f"{plural(tot['branches'], 'branch')} not merged into main"])
    off = {"name": "NOT ON GIT", "zone": "TOP", "core": True, "what": "Everything git does not keep, and why", "links": [], "stale": False,
           "chips": [["review", f"{plural(tot['loose'], 'loose file')} ({mb(tot['loose_size'])}): nobody committed or ignored them"],
                     ["block", f"{plural(tot['plain_folders'], 'folder')} not a repository: {plural(tot['plain_files'], 'file')} ({mb(tot['plain_size'])})"],
                     ["ignored", f"{plural(tot['ignored'], 'file')} hidden by .gitignore rules ({mb(tot['ignored_size'])})"],
                     ["private", f"{plural(tot['private'], 'file')} private, never on git ({mb(tot['private_size'])})"]]}
    if loose_top:
        files = [["projects", n, win(os.path.join(PROJECTS, n)), 0, ""] for n in loose_top]
        off["chips"].append(["review", f"{plural(len(loose_top), 'file')} loose at the top of projects", files])
    you = {"name": "YOU", "zone": "TOP", "core": True, "what": "The owner: red strings end here (a decision only you can make)",
           "links": [], "stale": False,
           "chips": [["next", "Click a chip to see its files and open them in Explorer; R rebuilds, T tells Claude"],
                     ["next", "Click a loose file: Commit / Ignore / Delete / Leave, written for Claude to carry out (T tells Claude)"]]}
    return [top_on, off, you] + parts, panel, tot


def main():
    facts, loose_top = survey()
    parts, panel, tot = parts_of(facts, loose_top)
    if "--text" in sys.argv:
        for p in parts:
            print(f"== {p['name']}  [{p['zone']}]  {p['what']}")
            for c in p["chips"]:
                print(f"   {c[0]:8} {c[1]}" + (f"   ({len(c[2])} lines)" if len(c) > 2 else ""))
        return 0
    rows = make_map.layout(parts)
    rows = [["B", "title", "FOR OWNER | On Git or Not"],
            ["B", "bar", "ON GIT OR NOT"],
            ["B", "help", "wheel zoom | drag black to pan | drag a header to move | click a box for its menu | right-click anything to comment | F fit  B not-on-git only  R rebuild  T tell Claude  0 100%"],
            ["B", "tool", "tools/git_map.py"],
            ["B", "panel", "NOT ON GIT: loose files, then folders not on git, then .gitignore (biggest first)"],
            ["B", "legend", "26,110,52|255,255,255|on git"],
            ["B", "legend", "215,35,140|255,255,255|loose: not on git, not ignored"],
            ["B", "legend", "70,70,80|225,225,230|hidden by .gitignore"],
            ["B", "legend", "20,20,24|150,150,165|private"],
            ["B", "legend", "128,100,180|255,255,255|big, this disk only"],
            ["B", "legend", "190,22,22|255,255,255|not a repository"]] + rows
    for order, size, name, i in sorted(panel, reverse=True):
        rows.append(["L", f"{name}#{i}"])
    with open(OUT, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(f"# map_data.txt made {datetime.datetime.now():%Y-%m-%d %H:%M} by OnGitOrNot/tools/git_map.py; do not edit\n")
        for r in rows:
            fh.write("\t".join(str(c).replace("\t", " ").replace("\n", " ") for c in r) + "\n")
    print(f"{OUT}: {tot['repos']} repositories, {tot['tracked']:,} files on git; NOT ON GIT: {tot['loose']} loose, "
          f"{tot['ignored']:,} ignored, {tot['private']} private, {tot['plain_folders']} folders not a repository "
          f"({tot['plain_files']:,} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
