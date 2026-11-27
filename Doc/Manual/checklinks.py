#!/usr/bin/python3

# Check that every relative link in the manual has a target in the file it names.
#
# A link such as href="Python.html#Python_nn2" must name an anchor that is in Python.html itself. In the single page
# html and the pdf every anchor is in the one document, so a link naming the wrong chapter can only be found here.

import argparse
import os
import re
import sys

parser = argparse.ArgumentParser(
    formatter_class=lambda prog: argparse.RawDescriptionHelpFormatter(prog, width=80),
    description="""\
Check that every relative link in the SWIG manual has a target in the file it
names, such as href="Python.html#Python_nn2" naming an anchor in Python.html.""",
    epilog="""\
Checks the links in index.html, Sections.html, Contents.html and the chapters
listed in the chapters file, read from the current directory, which must be
Doc/Manual. An anchor is the id of an element, such as a heading. A few
chapters still have older <a name="..."> anchors inside the text, so their
names are anchors too. A link is reported when:
  - the file it names does not have its anchor
  - it links to a chapter without an anchor, a broken link in the single page
    html and the pdf
  - it links to a file that does not exist
A link with a scheme, such as https:, is not checked. SWIGDocumentation.html
and SWIGDocumentation.pdf are generated, so a link to them is not checked.

Exits 0 when every link has a target and 1 otherwise.""")
parser.parse_args()

GENERATED = ("SWIGDocumentation.html", "SWIGDocumentation.pdf")

filenames = ["index.html", "Sections.html", "Contents.html"]
for line in open("chapters"):
    line = line.strip()
    if line and not line.startswith("#"):
        filenames.append(line)

anchors = {}
for filename in filenames:
    text = open(filename, encoding="utf-8", errors="replace").read()
    anchors[filename] = set(re.findall(r'\sid="([^"]*)"', text, re.IGNORECASE)) | set(re.findall(r'<a\s+name="([^"]*)"', text, re.IGNORECASE))

count = 0
broken = []
for filename in filenames:
    for lineno, line in enumerate(open(filename, encoding="utf-8", errors="replace"), 1):
        for href in re.findall(r'href="([^"]*)"', line, re.IGNORECASE):
            if re.match(r"[a-zA-Z][a-zA-Z0-9+.-]*:|//", href):
                continue
            count += 1
            path, hashmark, anchor = href.partition("#")
            target = path if path else filename
            if target in anchors:
                if not hashmark:
                    broken.append((filename, lineno, href, "links to a chapter without an anchor"))
                elif anchor not in anchors[target]:
                    broken.append((filename, lineno, href, "names an anchor that is not in %s" % target))
            elif path not in GENERATED and not os.path.exists(path):
                broken.append((filename, lineno, href, "links to %s, which does not exist" % path))

if broken:
    sys.stderr.write("Error: %d links have no target:\n" % len(broken))
    for filename, lineno, href, problem in broken:
        sys.stderr.write("  %s:%d: href=\"%s\" %s\n" % (filename, lineno, href, problem))
    sys.exit(1)

print("Link check: %d relative links in %d files, every link has a target" % (count, len(filenames)))
