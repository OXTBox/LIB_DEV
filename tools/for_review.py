#!/usr/bin/env python3
"""for_review: put a file on the owner's review list (the Status_Browser stack shows it).

    python3 -I tools/for_review.py add PATH "work done" ["warnings"] ["caveats"]
    python3 -I tools/for_review.py list            the list, newest last
    python3 -I tools/for_review.py feedback        the owner's feedback and review states (LIB_LLMIN/LIB_DEV)

The list is ~/projects/LIB_LLMOUT/FOR_REVIEW.txt, one tab-separated line a file:
    date time, LIB, full Windows path (\\\\wsl$\\Ubuntu\\...), work done, warnings, caveats
Adding a path that is already listed replaces its line (it moves to the top of the stack's list).
"""
import os, sys, time

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


def main(a):
    if len(a) >= 3 and a[0] == 'add':
        add(a[1], a[2], *(a[3:5]))
    elif a[:1] == ['list']:
        print(open(LIST, encoding='utf-8').read() if os.path.exists(LIST) else '(empty)')
    elif a[:1] == ['feedback']:
        for f in ('REVIEW_STATE.txt', 'REVIEW_FEEDBACK.txt'):
            p = os.path.join(INBOX, f)
            print('==', f)
            print(open(p, encoding='utf-8').read() if os.path.exists(p) else '(none yet)')
    else:
        print(__doc__)


if __name__ == '__main__':
    main(sys.argv[1:])
