#!/usr/bin/env python3

###############################################################################
# Takes a chapter as input and adds internal links and numbering to all
# of the H1, H2, H3, H4 and H5 sections.
#
# Every heading HTML tag (H1, H2 etc) must have an id to link to. The id is
# kept as it is, as links to the heading use it, also from outside the
# documentation. A heading that cannot be read is an error, such as one
# without an id, with other attributes or over more than one line. So is a
# heading that skips a level, such as an H4 after an H2. The chapter must
# start with its only H1.
#
# A heading with an anchor instead of an id, the form used before SWIG-4.6,
# is changed to use an id, keeping the anchor name as the id. For example:
#   <H2><a name="Preface_nn2">1.1 Introduction</a></H2>
# becomes:
#   <H2 id="Preface_nn2">1.1 Introduction</H2>
###############################################################################
import argparse
import sys
import re

###############################################################################
# Functions
###############################################################################

# Regexs for <a name="..."></a>
alink = re.compile(r"<a *name *= *\"(.*)\">.*</a>", re.IGNORECASE)

# Return the id of a heading, which is its id or else the name of its anchor
def getheadingname(m, s):
    if m.group(2) != None:
        headingname = m.group(2)
    else:
        amatch = alink.match(m.group(3))
        headingname = amatch.group(1) if amatch else ""
    if not headingname:
        raise RuntimeError("Heading without an id in line:\n%s" % s)
    return headingname

# Return heading - 1.1. Introduction in the examples below:
# id example:        <H2 id="Preface_nn2">1.1 Introduction</H2>
# old style example: <H2><a name="Preface_nn2"></a>1.1 Introduction</H2>
# new style example: <H2><a name="Preface_nn2">1.1 Introduction</a></H2>
# The old and new style headings are changed to the id style heading.
def getheadingtext(m, s):
    if m.group(2) is not None:
        if m.group(3) is not None:
            raise RuntimeError("Heading with both an id and an anchor in line:\n%s" % s)
        if len(m.group(5)) == 0:
            raise RuntimeError("No heading text in line:\n%s" % s)
        return m.group(5)
    prevheadingtext_newstyle = m.group(4)
    prevheadingtext_oldstyle = m.group(5)
    if prevheadingtext_oldstyle is None or prevheadingtext_newstyle is None:
        raise RuntimeError("Ill-formed heading in line:\n%s" % s)
    if len(prevheadingtext_oldstyle) == 0 and len(prevheadingtext_newstyle) == 0:
        raise RuntimeError("No heading text in line:\n%s" % s)
    if len(prevheadingtext_oldstyle) > 0 and len(prevheadingtext_newstyle) > 0:
        raise RuntimeError("Two heading texts, only one should be specified in line:\n%s" % s)
    prevheadingtext = prevheadingtext_oldstyle if len(prevheadingtext_oldstyle) > 0 else prevheadingtext_newstyle
    return prevheadingtext

###############################################################################
# Main program
###############################################################################

parser = argparse.ArgumentParser(
    formatter_class=lambda prog: argparse.RawDescriptionHelpFormatter(prog, width=80),
    description="""\
Number the headings of a chapter of the SWIG manual and regenerate the table of
contents at the top of the chapter.""",
    epilog="""\
The H1 to H5 headings are numbered from the number of the chapter, such as 24,
24.1 and 24.1.1. Each heading is written with an id, for example:
  <H2 id="Android_overview">24.1 Overview</H2>
A heading in the older form with an anchor, for example:
  <H2><a name="Android_overview">24.1 Overview</a></H2>
is changed to the id form, keeping the anchor name as the id.

The table of contents between the two <!-- INDEX --> lines is regenerated and
the entries for Contents.html are printed on stdout. A copy of the chapter is
saved first with .bak added to its name.

Run by maketoc.py for each chapter.

Exits 0 when every heading is processed and 1 for a heading it cannot process,
such as a heading without an id or an anchor. The chapter must start with its
only H1 heading. A heading must not skip a level, such as an H4 after an H2.""")
parser.add_argument("filename", help="the chapter, such as Android.html")
parser.add_argument("num", metavar="number", type=int, help="the number of the chapter, its position in the chapters file")
args = parser.parse_args()

filename = args.filename
filenamebase = filename.split(".")[0]
num = args.num

name = ""

# Regex for the H1 to H5 headings
heading = re.compile(r".*?<H([1-5])(?: +id=\"([^\"]*)\")?>(<a.*?>\s*[\d\.\s]*(.*?)</a>)*[\d\.\s]*(.*?)</H\1>", re.IGNORECASE)


data = open(filename).read()            # Read data
open(filename+".bak","w").write(data)   # Make backup

lines = data.splitlines()
result = [ ] # This is the result of postprocessing the file
index = "<!-- INDEX -->\n<div class=\"sectiontoc\">\n" # index contains the index for adding at the top of the file. Also printed to stdout.

skip = False
skipspace = False
# The level of the previous heading, 0 before the H1
prevlevel = 0
# Store sections for headers H2 to H5
sections = [0] * 4

for s in lines:
    if s == "<!-- INDEX -->":
        skip = not skip
        continue;
    if skip:
        continue

    if not s and skipspace:
        continue

    if skipspace:
        result.append("")
        result.append("")
        skipspace = False

    m = heading.match(s)
    if m:
        level = int(m.group(1))
        prevheadingtext = getheadingtext(m, s)
        headingname = getheadingname(m, s)
        if level == 1 and prevlevel > 0:
            raise RuntimeError("Second H1 heading, a chapter has only one, in line:\n%s" % s)
        if level > prevlevel + 1:
            after = "an H%d heading" % prevlevel if prevlevel > 0 else "the start of the chapter, which must be an H1 heading"
            raise RuntimeError("H%d heading skips a level after %s, in line:\n%s" % (level, after, s))
        if level == 1:
            result.append("""<H1 id="%s">%d %s</H1>""" % (headingname,num,prevheadingtext))
            result.append("@INDEX@")
            name = prevheadingtext
        else:
            if level > prevlevel:
                index += '<ul>\n' * (level - prevlevel)
            elif level < prevlevel:
                index += '</ul>\n' * (prevlevel - level)
                # Clear lower sections, as we need to restart the count
                for n in range(level + 1, prevlevel + 1):
                    sections[n - 2] = 0
            sections[level - 2] += 1
            getsections = ''
            for n in range(2, level + 1):
                getsections += "." + str(sections[n - 2])
            result.append("""<H%d id="%s">%d%s %s</H%d>""" % (level, headingname, num, getsections, prevheadingtext, level))
            index += """<li><a href="#%s">%s</a>\n""" % (headingname,prevheadingtext)
        skipspace = True
        prevlevel = level
        continue

    # Any other heading would be left out of the numbering and the table of contents
    if re.search(r"<H[1-5][\s>]", s, re.IGNORECASE):
        raise RuntimeError("Heading that cannot be read, write it on one line as <H2 id=\"...\">Text</H2>, in line:\n%s" % s)

    result.append(s)

if prevlevel > 1:
    index += '</ul>\n' * (prevlevel - 1)

index += "</div>\n<!-- INDEX -->\n"

data = "\n".join(result)

data = data.replace("@INDEX@",index) + "\n";

# Write the file back out
open(filename,"w").write(data)

# Print the TOC data to stdout correcting the anchor links for external referencing

index = index.replace("<li><a href=\"#","<li><a href=\"%s#" % filename)
print("""<h3><a href="%s#%s">%d %s</a></h3>\n""" % (filename,filenamebase,num,name))
print(index)

