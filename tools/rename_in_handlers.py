#!/usr/bin/env python3
"""rename_in_handlers.py - rename a variable inside named handlers only (the owner, 2026-11-15:
"if you want to rename the tArray variables in scripts, I'm fine with that ... clear variable
names will be better for future programmers and llms").

    python3 -I tools/rename_in_handlers.py SCRIPT MAP [--write]
    python3 -I tools/rename_in_handlers.py --help

MAP is a text file, one line per handler:   handlerName  oldName  newName
(a # starts a comment). Without --write it prints what would change and touches nothing.

Inside each named handler (from its on/function/command/getprop/setprop line to its end line)
every whole-word oldName becomes newName, case-insensitively as xTalk reads names, INCLUDING
inside quoted strings: a `do "put ... into tArray"` runs in the handler's own context, so the
name inside the string must change too. Refused (nothing written) when:
  - newName is already used in that handler (it would merge two variables);
  - the handler is not found, or oldName does not occur in it;
  - oldName is declared global anywhere in the script (then it is not the handler's own).
The file's line endings are kept.
"""
import re, sys

START = re.compile(r'^\s*(?:private\s+)?(?:on|function|command|getprop|setprop|before|after)\s+([\w.]+)', re.I)


def handlers(lines):
    """{name.lower(): (first, last)} line indexes, inclusive"""
    out, i = {}, 0
    while i < len(lines):
        m = START.match(lines[i])
        if not m:
            i += 1
            continue
        name = m.group(1)
        end = re.compile(r'^\s*end\s+' + re.escape(name) + r'\b', re.I)
        j = i + 1
        while j < len(lines) and not end.match(lines[j]):
            j += 1
        out.setdefault(name.lower(), (i, min(j, len(lines) - 1)))
        i = j + 1
    return out


def word(name):
    return re.compile(r'(?<![\w.])' + re.escape(name) + r'(?![\w])', re.I)


def plan(text, mapping):
    """(new text, changes [(line no, before, after)], problems)"""
    nl = '\r\n' if '\r\n' in text else '\r' if '\r' in text and '\n' not in text else '\n'
    lines = text.split(nl)
    hs = handlers(lines)
    problems, changes = [], []
    globals_ = {g.lower() for l in lines for g in re.findall(r'[\w.]+', l.split('--')[0][len('global'):])
                if l.strip().lower().startswith('global ')}
    for hname, old, new in mapping:
        if old.lower() in globals_:
            problems.append('%s: %s is declared global in this script; not renamed' % (hname, old))
            continue
        if hname.lower() not in hs:
            problems.append('%s: no such handler' % hname)
            continue
        a, b = hs[hname.lower()]
        body = lines[a:b + 1]
        if any(word(new).search(l) for l in body):
            problems.append('%s: %s is already used there' % (hname, new))
            continue
        hits = 0
        for k in range(a, b + 1):
            after = word(old).sub(new, lines[k])
            if after != lines[k]:
                changes.append((k + 1, lines[k], after))
                lines[k] = after
                hits += 1
        if not hits:
            problems.append('%s: %s does not occur there' % (hname, old))
    return nl.join(lines), changes, problems


def main(argv):
    if len(argv) < 2 or argv[0] in ('-h', '--help'):
        print(__doc__)
        return 0
    script, mapfile, write = argv[0], argv[1], '--write' in argv
    mapping = []
    for line in open(mapfile, encoding='utf-8'):
        line = line.split('#')[0].strip()
        if line:
            f = line.split()
            if len(f) != 3:
                print('map line needs 3 words: %s' % line)
                return 2
            mapping.append(tuple(f))
    text = open(script, 'rb').read().decode('latin-1')
    new, changes, problems = plan(text, mapping)
    for no, before, after in changes:
        print('%5d  - %s\n       + %s' % (no, before.strip()[:110], after.strip()[:110]))
    for p in problems:
        print('REFUSED  ' + p)
    if problems:
        print('%d change(s) planned, %d problem(s): nothing written' % (len(changes), len(problems)))
        return 1
    if write:
        open(script, 'wb').write(new.encode('latin-1'))
    print('%d line(s) %s' % (len(changes), 'changed' if write else 'would change (add --write)'))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
