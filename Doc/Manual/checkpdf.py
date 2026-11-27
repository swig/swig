#!/usr/bin/python3

# Check the pdf documentation for problems that only show up in the pdf:
#
# Text running past the right margin of a page, such as a line of code too long for the page, which runs out of the
# coloured box it sits in and is clipped at the page edge if it is long enough. The lines of code are not wrapped, so a
# line within the length checklines.py allows can still be too long for the page when it is indented, such as in a list.
#
# No fixed-width font, which would leave every code block, shell block, diagram and inline code element in a
# proportional font.
#
# pdftotext and pdffonts from poppler-utils read the pdf.

import argparse
import html
import re
import subprocess
import sys

# The right margin of the page in mm, as in page.css
RIGHT_MARGIN = 10

parser = argparse.ArgumentParser(
    formatter_class=lambda prog: argparse.RawDescriptionHelpFormatter(prog, width=80),
    description="""\
Check the pdf documentation for problems that only show up in the pdf. A line
must not run past the right margin of a page, such as a line of code too long
for the page when it is indented in a list. The code must be in a fixed-width
font.""",
    epilog="""\
Each line past the %d mm right margin set in page.css is listed with its page.
pdftotext and pdffonts from poppler-utils (Debian, Ubuntu) or poppler
(Homebrew) are needed to read the pdf.

Exits 0 when the pdf has no problems. Exits 1 when it has a problem or when
pdftotext or pdffonts is not installed or fails.""" % RIGHT_MARGIN)
parser.add_argument("pdf", help="the pdf to check, such as SWIGDocumentation.pdf")
filename = parser.parse_args().pdf

def run(command):
    try:
        return subprocess.run(command, stdout=subprocess.PIPE, check=True, universal_newlines=True, errors="replace").stdout
    except FileNotFoundError:
        sys.exit("Error: %s not found, install poppler-utils (Debian, Ubuntu) or poppler (Homebrew) to check %s" % (command[0], filename))
    except subprocess.CalledProcessError as e:
        sys.exit("Error: %s failed with exit status %d on %s" % (command[0], e.returncode, filename))

layout = run(["pdftotext", "-bbox-layout", filename, "-"])
fonts = run(["pdffonts", filename])

errors = False

# pdftotext -bbox-layout gives each line of text with its bounding box, followed by its words
page = 0
limit = 0
right = 0
words = []
toowide = []
for line in layout.splitlines():
    m = re.search(r'<page width="([\d.]+)"', line)
    if m:
        page += 1
        limit = float(m.group(1)) - RIGHT_MARGIN * 72 / 25.4
        continue
    m = re.search(r'<line xMin="[-\d.]+" yMin="[-\d.]+" xMax="([-\d.]+)"', line)
    if m:
        right = float(m.group(1))
        words = []
        continue
    m = re.search(r"<word [^>]*>(.*)</word>", line)
    if m:
        words.append(html.unescape(m.group(1)))
        continue
    if "</line>" in line and right > limit + 0.5:
        toowide.append((page, (right - limit) * 25.4 / 72, " ".join(words)))

if toowide:
    sys.stderr.write("Error: %d lines run past the right margin of the page in %s:\n" % (len(toowide), filename))
    for page, mm, text in toowide:
        sys.stderr.write("  page %d, %.1f mm past the margin: %s\n" % (page, mm, text))
    sys.stderr.write("Please split these lines of code over more lines.\n")
    errors = True

names = [re.sub(r"^[A-Z]{6}\+", "", l.split()[0]) for l in fonts.splitlines()[2:] if l.strip()]
monospace = [name for name in names if re.search(r"mono|courier", name, re.IGNORECASE)]
if not monospace:
    sys.stderr.write("Error: no fixed-width font in %s, the fonts are:\n" % filename)
    for name in names:
        sys.stderr.write("  %s\n" % name)
    errors = True

if errors:
    sys.exit(1)

print("Pdf check: %d pages, no text past the right margin, fixed-width font: %s" % (page, ", ".join(monospace)))
