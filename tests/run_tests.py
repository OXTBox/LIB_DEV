#!/usr/bin/env python3
"""LIB_DEV's check that runs without LiveCode (A-50): help_audit's rule for "has help", and
for_review's Windows paths. Nothing is added to the review list.

    python3 -I tests/run_tests.py
"""
import os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import help_audit, for_review               # noqa: E402

CHECKS, FAILS = [0], []


def check(name, ok, got=None):
    CHECKS[0] += 1
    if not ok:
        FAILS.append(name)
        print("FAIL  %s%s" % (name, "" if got is None else "  (got %r)" % (got,)))
    else:
        print("ok    %s" % name)


def done():
    print("\n%d of %d passed" % (CHECKS[0] - len(FAILS), CHECKS[0]))
    return 1 if FAILS else 0


def main():
    check('argparse counts as help', help_audit.has_help('import argparse'))
    check("a check for '--help' counts", help_audit.has_help("if a in ('-h', '--help'):"))
    check('no check is no help', not help_audit.has_help('print(1)'))
    w = for_review.win_path('/home/igame3d/projects/LIB_DEV/README.md')
    check('WSL path to a Windows path', w == '\\\\wsl$\\Ubuntu\\home\\igame3d\\projects\\LIB_DEV\\README.md', w)
    check('the LIB of a path', for_review.lib_of('/home/igame3d/projects/LIB_DEV/tools/x.py') == 'LIB_DEV')
    check('tabs and newlines are cleaned out of list fields', for_review.clean('a\tb\n c') == 'a b c')
    return done()


if __name__ == '__main__':
    sys.exit(main())
