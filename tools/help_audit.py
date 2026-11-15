#!/usr/bin/env python3
"""help_audit.py - which LIB_* repos lack a README, and which Python tools lack `--help`
(LIB_SYSTEM TODO A-50). Static: it reads the source, it never runs a tool (running an unknown
script with --help can write files, as some take no options and just do their job).

    python3 -I tools/help_audit.py [--md OUT.md]      (from LIB_DEV, or anywhere)

A tool counts as having help when it uses argparse, or its source checks for '-h' / '--help'.
Skipped: tests/ folders (test runners) and LIB_LLMIN (the inbox: files sent in, not ours).
A script without `if __name__ == '__main__'` is a module, not a tool, and is skipped.
"""
import os, re, sys

PROJECTS = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SKIP_DIRS = {'.git', 'node_modules', '__pycache__', 'venv', '.venv', 'TEMPLATES_DO_NOT_COMMIT', 'tests'}
SKIP_REPOS = {'LIB_LLMIN'}          # the inbox: other people's files, not ours to change


def tools_of(repo):
    for root, dirs, files in os.walk(repo):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if f.endswith('.py'):
                yield os.path.join(root, f)


def has_help(src):
    return 'argparse' in src or re.search(r"""['"](?:-h|--help)['"]""", src) is not None


def main(argv):
    if argv[:1] in (['-h'], ['--help']):
        print(__doc__)
        return 0
    out = None
    if argv[:1] == ['--md'] and len(argv) > 1:
        out = argv[1]
    rows, missing = [], 0
    for name in sorted(os.listdir(PROJECTS)):
        repo = os.path.join(PROJECTS, name)
        if name in SKIP_REPOS or not (name.startswith('LIB_') and os.path.isdir(os.path.join(repo, '.git'))):
            continue
        readme = os.path.exists(os.path.join(repo, 'README.md'))
        no_help = []
        for path in tools_of(repo):
            try:
                src = open(path, encoding='utf-8', errors='replace').read()
            except OSError:
                continue
            if "__name__" not in src:
                continue
            if not has_help(src):
                no_help.append(os.path.relpath(path, repo))
        missing += (not readme) + len(no_help)
        rows.append((name, readme, no_help))
    lines = ['| Repo | README | Tools without --help |', '|---|---|---|']
    for name, readme, no_help in rows:
        lines.append('| %s | %s | %s |' % (name, 'yes' if readme else '**NO**',
                                           ', '.join('`%s`' % p for p in no_help) or '-'))
    text = '\n'.join(lines) + '\n\n%d things to fix\n' % missing
    print(text)
    if out:
        open(out, 'w').write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
