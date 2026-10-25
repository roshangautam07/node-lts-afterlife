#!/usr/bin/env python3
"""Resolve every conflict hunk in the given files by taking the incoming
(upstream) side. Use only after reviewing the conflict."""
import re, sys
for p in sys.argv[1:]:
    s = open(p).read()
    s = re.sub(r"<<<<<<< [^\n]*\n.*?=======\n(.*?)>>>>>>> [^\n]*\n", r"\1", s, flags=re.S)
    open(p, 'w').write(s)
