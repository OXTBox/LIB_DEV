#!/usr/bin/env python3
"""for_review: put a file on the owner's review list (the Status_Browser stack shows it).

    python3 -I tools/for_review.py add PATH "work done" ["warnings"] ["caveats"]
    python3 -I tools/for_review.py list            the list, newest last
    python3 -I tools/for_review.py feedback        the owner's feedback and review states (LIB_LLMIN/LIB_DEV),
                                                   and MAP_NOTES.txt: his feedback and files on the Project Map's red blockers
    python3 -I tools/for_review.py relink          listed files that moved: point their lines to where they are now
                                                   (the Project Map runs it on every rebuild)

The list is ~/projects/LIB_LLMOUT/FOR_REVIEW.txt, one tab-separated line a file:
    date time, LIB, full Windows path (\\\\wsl$\\Ubuntu\\...), work done, warnings, caveats
Adding a path that is already listed replaces its line (it moves to the top of the stack's list);
if the owner had marked it Reviewed, it goes back to waiting (its state line says the AI changed it).
"""
import collections, os, sys, time

PROJECTS = '/home/igame3d/projects'
LIST = os.path.join(PROJECTS, 'LIB_LLMOUT', 'FOR_REVIEW.txt')
INBOX = os.path.join(PROJECTS, 'LIB_LLMIN', 'LIB_DEV')


def win_path(p):
    p = os.path.abspath(p)
    return '\\\\wsl$\\Ubuntu' + p.replace('/', '\\')


def lib_of(p):
    rel = os.path.relpath(os.path.abspath(p), PROJECTS).split(os.sep)
    return rel[0] if rel and rel[0] != '..' else '?'


def clean(s):
    return ' '.join((s or '-').replace('\t', ' ').split())


def add(path, done, warn='-', caveat='-'):
    if not os.path.exists(path):
        sys.exit('no such file: ' + path)
    w = win_path(path)
    lines = []
    if os.path.exists(LIST):
        lines = [l for l in open(LIST, encoding='utf-8').read().splitlines()
                 if l and (l.startswith('#') or l.split('\t')[2:3] != [w])]
    if not lines or not lines[0].startswith('#'):
        lines.insert(0, '# FOR REVIEW: date, LIB, full path, work done, warnings, caveats (tab separated; LIB_DEV/tools/for_review.py)')
    lines.append('\t'.join([time.strftime('%Y-%m-%d %H:%M'), lib_of(path), w, clean(done), clean(warn), clean(caveat)]))
    open(LIST, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
    print('listed', w)
    reopen(w)


def reopen(w):
    """a file the owner marked Reviewed that changes again goes back to waiting (the browser
    keeps states by path, so it would otherwise still show + after the change)"""
    st = os.path.join(INBOX, 'REVIEW_STATE.txt')
    if not os.path.exists(st):
        return
    last = None
    for line in open(st, encoding='utf-8').read().splitlines():
        f = line.split('\t')
        if len(f) >= 2 and f[0] == w:
            last = f[1]
    if last == 'reviewed':
        with open(st, 'a', encoding='utf-8', newline='\n') as fh:
            fh.write('\t'.join([w, 'waiting', time.strftime('%m/%d/%y %I:%M:%S %p'), 'AI: changed after your review']) + '\n')
        print('  back to waiting (changed after your review)')


def linux_path(w):
    """\\\\wsl$\\Ubuntu\\home\\... -> /home/... (None for a path outside WSL)"""
    for pre in ('\\\\wsl$\\Ubuntu', '\\\\wsl.localhost\\Ubuntu'):
        if w.startswith(pre):
            return w[len(pre):].replace('\\', '/')
    return None


_NAMES = None


def find_moved(old):
    """where a file listed at linux path `old` lives now, or None. Found by its name under
    ~/projects, newest first; a common name (README.md) must also share a folder name with the old path."""
    global _NAMES
    if _NAMES is None:
        _NAMES = collections.defaultdict(list)
        for root, dirs, files in os.walk(PROJECTS):
            dirs[:] = [d for d in dirs if d not in ('.git', '__pycache__', 'node_modules')]
            for f in files + dirs:
                _NAMES[f].append(os.path.join(root, f))
    rel = os.path.relpath(old, PROJECTS)
    # a copy that mirrors the old path inside another folder (a LIB_BUILD build) is not where it went
    found = [q for q in _NAMES.get(os.path.basename(old.rstrip('/')), []) if not q.endswith('/' + rel)]
    found.sort(key=lambda q: -os.path.getmtime(q))
    if len(found) > 1:
        dirs_old = set(old.split('/')[:-1]) - {'', 'home', 'igame3d', 'projects'}
        best = max(len(dirs_old & set(q.split('/')[:-1])) for q in found)
        found = [q for q in found if best and len(dirs_old & set(q.split('/')[:-1])) == best]
    return found[0] if found else None


def relink(quiet=False):
    """Rewrites FOR_REVIEW.txt lines whose file moved (path and LIB; the caveat says from where).
    REVIEW_STATE / REVIEW_FEEDBACK lines are never moved or changed: the old path's lines are
    APPENDED again under the new path, so the browser keeps the marks and history."""
    if not os.path.exists(LIST):
        return []
    lines, moved, gone, dropped = open(LIST, encoding='utf-8').read().splitlines(), [], [], []
    listed = {l.split('\t')[2] for l in lines if not l.startswith('#') and len(l.split('\t')) > 2}
    for i, line in enumerate(lines):
        f = line.split('\t')
        if line.startswith('#') or len(f) < 3:
            continue
        old = linux_path(f[2])
        if old is None or os.path.exists(old):
            continue
        new = find_moved(old)
        if new is None:
            gone.append(f[2])
            continue
        w = win_path(new)
        if w in listed:
            lines[i] = None        # already listed at its new place: the old line goes, its marks stay with the new one
            dropped.append((f[2], w))
            continue
        moved.append((f[2], w))
        listed.add(w)
        while len(f) < 6:
            f.append('-')
        f[1], f[2] = lib_of(new), w
        f[5] = clean(f[5] + '; moved from ' + os.path.relpath(old, PROJECTS))
        lines[i] = '\t'.join(f)
    if moved or dropped:
        lines = [l for l in lines if l is not None]
        open(LIST, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
        for name, col in (('REVIEW_STATE.txt', 0), ('REVIEW_FEEDBACK.txt', 1)):
            p = os.path.join(INBOX, name)
            if not os.path.exists(p):
                continue
            add = []
            for l in open(p, encoding='utf-8').read().splitlines():
                c = l.split('\t')
                for o, w in moved:
                    if len(c) > col and c[col] == o:
                        c[col] = w
                        add.append('\t'.join(c))
            if add:
                with open(p, 'a', encoding='utf-8', newline='\n') as fh:
                    fh.write('\n'.join(add) + '\n')
    if not quiet:
        for o, w in moved:
            print('moved', o, '->', w)
        for o, w in dropped:
            print('dropped', o, '(listed again at', w + ')')
        for g in gone:
            print('gone ', g)
        print(len(moved), 'relinked,', len(dropped), 'dropped as duplicates,', len(gone), 'gone')
    return moved


def main(a):
    if len(a) >= 3 and a[0] == 'add':
        add(a[1], a[2], *(a[3:5]))
    elif a[:1] == ['relink']:
        relink()
    elif a[:1] == ['list']:
        print(open(LIST, encoding='utf-8').read() if os.path.exists(LIST) else '(empty)')
    elif a[:1] == ['feedback']:
        for f in ('REVIEW_STATE.txt', 'REVIEW_FEEDBACK.txt', 'MAP_NOTES.txt'):
            p = os.path.join(INBOX, f)
            print('==', f)
            print(open(p, encoding='utf-8').read() if os.path.exists(p) else '(none yet)')
    else:
        print(__doc__)


if __name__ == '__main__':
    if any(a in ('-h', '--help') for a in sys.argv[1:]):   # A-50: every tool answers --help
        print(__doc__)
        sys.exit(0)
    main(sys.argv[1:])
