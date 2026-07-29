#!/usr/bin/python3

# Check that one of the fixed-width fonts named in style.css is installed.
#
# wkhtmltopdf does not honour the generic monospace CSS fallback, so unless one of the font
# families explicitly named in style.css is installed, every code block, shell block, diagram
# and inline code element in the pdf is silently rendered in a proportional font instead.

import re
import subprocess
import sys

css = open("style.css").read()

# Collect the named families from the font-family declarations ending in monospace, keeping
# the order they are listed in as that is the order the pdf generation will prefer them in
families = []
for declaration in re.findall(r"font-family:([^;]*monospace)\s*;", css):
    for family in declaration.split(","):
        family = family.strip().strip('"').strip("'")
        if family and family != "monospace" and family not in families:
            families.append(family)

if not families:
    sys.exit("checkfonts.py: no monospace font-family declaration found in style.css")

# Note that fc-list exits with success even when nothing matches, so check the output instead
try:
    installed = [f for f in families if subprocess.run(["fc-list", ":family=" + f], stdout=subprocess.PIPE).stdout.strip()]
except FileNotFoundError:
    print("Warning: fc-list not found (fontconfig is not installed), skipping the font check")
    sys.exit(0)

if not installed:
    sys.stderr.write("Error: none of the fixed-width fonts named in style.css are installed:\n")
    for family in families:
        sys.stderr.write("         " + family + "\n")
    sys.stderr.write("wkhtmltopdf does not honour the generic monospace CSS fallback, so the code\n"
                     "blocks in the pdf would all be rendered in a proportional font.\n"
                     "On Debian/Ubuntu install the \"Courier 10 Pitch\" font with:\n"
                     "         sudo apt install xfonts-scalable\n")
    sys.exit(1)

print("Fixed-width font check: using \"" + installed[0] + "\"")
