#!/usr/bin/python3

# Check that no line in a <pre> element is too long for the pdf documentation.

import glob
import html
import re
import sys

MAX_LENGTH = 130

filenames = ["index.html", "Sections.html"]
for line in open("chapters"):
    line = line.strip()
    if line and not line.startswith("#"):
        filenames.append(line)

toolong = []
for filename in filenames:
    text = open(filename, encoding="utf-8").read()
    for block in re.finditer(r"<pre>(.*?)</pre>", text, re.S | re.I):
        firstline = text[:block.start()].count("\n") + 1
        for offset, rawline in enumerate(block.group(1).split("\n")):
            # Measure the text as rendered, so without any markup and with the entities expanded
            rendered = html.unescape(re.sub(r"<[^>]+>", "", rawline))
            if len(rendered) > MAX_LENGTH:
                toolong.append((filename, firstline + offset, len(rendered), rendered))

if toolong:
    sys.stderr.write("Error: the following <pre> lines are longer than %d characters and would be\n"
                     "clipped at the page edge in the pdf documentation:\n" % MAX_LENGTH)
    for filename, lineno, length, rendered in toolong:
        sys.stderr.write("  %s:%d: %d characters\n" % (filename, lineno, length))
        sys.stderr.write("    %s\n" % rendered[:MAX_LENGTH])
    sys.stderr.write("Please split them over more lines.\n")
    sys.exit(1)

print("Check pass: all <pre> elements are shorter than %d." % MAX_LENGTH)
