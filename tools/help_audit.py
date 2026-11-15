#!/usr/bin/env python3
"""help_audit.py - which LIB_* repos lack a README, and which Python tools lack `--help`
(LIB_SYSTEM TODO A-50). Static: it reads the source, it never runs a tool (running an unknown
script with --help can write files, as some take no options and just do their job).

    python3 -I tools/help_audit.py [--md OUT.md]      (from LIB_DEV, or anywhere)

A tool counts as having help when it uses argparse, or its source checks for '-h' / '--help'.
Skipped: tests/ folders (test runners) and LIB_LLMIN (the inbox: files sent in, not ours).
A script without `if __name__ == '__main__'` is a module, not a tool, and is skipped.

The Test column (A-50 "one test that runs"): the repo's tests/run_tests.py (or another runner in
tests/), and whether it needs LiveCode (it goes through LIB_MCP) or runs on plain Python. A repo
with Python tools and no test counts as one thing to fix.
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


def test_of(repo):
    """'python' / 'LiveCode' / '' : the repo's test runner and what it needs"""
    tdir = os.path.join(repo, 'tests')
    if not os.path.isdir(tdir):
        return ''
    runners = [f for f in sorted(os.listdir(tdir)) if f.startswith('run_tests') or f.endswith('_test.sh') or f == 'headless.sh']
    if not runners:
        return ''
    try:
        src = open(os.path.join(tdir, runners[0]), encoding='utf-8', errors='replace').read()
    except OSError:
        return ''
    needs_lc = runners[0].endswith('.sh') or re.search(r'Client\.standalone|Client\(|lcmcp', src)
    return 'LiveCode' if needs_lc else 'python'


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
        no_help, ntools = [], 0
        for path in tools_of(repo):
            try:
                src = open(path, encoding='utf-8', errors='replace').read()
            except OSError:
                continue
            if "__name__" not in src:
                continue
            ntools += 1
            if not has_help(src):
                no_help.append(os.path.relpath(path, repo))
        test = test_of(repo)
        missing += (not readme) + len(no_help) + (bool(ntools) and not test)
        rows.append((name, readme, no_help, ntools, test))
    lines = ['| Repo | README | Tools | Test that runs | Tools without --help |', '|---|---|---|---|---|']
    for name, readme, no_help, ntools, test in rows:
        lines.append('| %s | %s | %d | %s | %s |' % (name, 'yes' if readme else '**NO**', ntools,
                                                     test or ('**NO**' if ntools else '-'),
                                                     ', '.join('`%s`' % p for p in no_help) or '-'))
    tested = sum(1 for r in rows if r[4])
    plain = sum(1 for r in rows if r[4] == 'python')
    text = '\n'.join(lines) + '\n\n%d of %d repos have a test that runs (%d on plain Python, %d need LiveCode)\n%d things to fix\n' % (
        tested, len(rows), plain, tested - plain, missing)
    print(text)
    if out:
        open(out, 'w').write(text)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
