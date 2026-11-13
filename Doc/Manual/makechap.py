#!/usr/bin/env python3

###############################################################################
# Takes a chapter as input and adds internal links and numbering to all
# of the H1, H2, H3, H4 and H5 sections.
#
# Every heading HTML tag (H1, H2 etc) must have an id to link to. The id is
# kept as it is, as links to the heading use it, also from outside the
# documentation. A heading that cannot be read is an error, such as one
# without an id, with other attributes or over more than one line.
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
    if m.group(1) != None:
        headingname = m.group(1)
    else:
        amatch = alink.match(m.group(2))
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
    if m.group(1) is not None:
        if m.group(2) is not None:
            raise RuntimeError("Heading with both an id and an anchor in line:\n%s" % s)
        if len(m.group(4)) == 0:
            raise RuntimeError("No heading text in line:\n%s" % s)
        return m.group(4)
    prevheadingtext_newstyle = m.group(3)
    prevheadingtext_oldstyle = m.group(4)
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
such as a heading without an id or an anchor.""")
parser.add_argument("filename", help="the chapter, such as Android.html")
parser.add_argument("num", metavar="number", type=int, help="the number of the chapter, its position in the chapters file")
args = parser.parse_args()

filename = args.filename
filenamebase = filename.split(".")[0]
num = args.num

section = 0
subsection = 0
subsubsection = 0
subsubsubsection = 0
nameindex = 0

name = ""

# Regexs for <h1>,... <h5> sections

h1 = re.compile(r".*?<H1(?: +id=\"([^\"]*)\")?>(<a.*?>\s*[\d\.\s]*(.*?)</a>)*[\d\.\s]*(.*?)</H1>", re.IGNORECASE)
h2 = re.compile(r".*?<H2(?: +id=\"([^\"]*)\")?>(<a.*?>\s*[\d\.\s]*(.*?)</a>)*[\d\.\s]*(.*?)</H2>", re.IGNORECASE)
h3 = re.compile(r".*?<H3(?: +id=\"([^\"]*)\")?>(<a.*?>\s*[\d\.\s]*(.*?)</a>)*[\d\.\s]*(.*?)</H3>", re.IGNORECASE)
h4 = re.compile(r".*?<H4(?: +id=\"([^\"]*)\")?>(<a.*?>\s*[\d\.\s]*(.*?)</a>)*[\d\.\s]*(.*?)</H4>", re.IGNORECASE)
h5 = re.compile(r".*?<H5(?: +id=\"([^\"]*)\")?>(<a.*?>\s*[\d\.\s]*(.*?)</a>)*[\d\.\s]*(.*?)</H5>", re.IGNORECASE)

data = open(filename).read()            # Read data
open(filename+".bak","w").write(data)   # Make backup

lines = data.splitlines()
result = [ ] # This is the result of postprocessing the file
index = "<!-- INDEX -->\n<div class=\"sectiontoc\">\n" # index contains the index for adding at the top of the file. Also printed to stdout.

skip = 0
skipspace = 0

for s in lines:
    if s == "<!-- INDEX -->":
        if not skip:
            skip = 1
        else:
            skip = 0
        continue;
    if skip:
        continue

    if not s and skipspace:
        continue

    if skipspace:
        result.append("")
        result.append("")
        skipspace = 0
    
    m = h1.match(s)
    if m:
        prevheadingtext = getheadingtext(m, s)
        nameindex += 1
        headingname = getheadingname(m, s)
        result.append("""<H1 id="%s">%d %s</H1>""" % (headingname,num,prevheadingtext))
        result.append("@INDEX@")
        section = 0
        subsection = 0
        subsubsection = 0
        subsubsubsection = 0
        name = prevheadingtext
        skipspace = 1
        continue
    m = h2.match(s)
    if m:
        prevheadingtext = getheadingtext(m, s)
        nameindex += 1
        section += 1
        headingname = getheadingname(m, s)
        result.append("""<H2 id="%s">%d.%d %s</H2>""" % (headingname,num,section, prevheadingtext))

        if subsubsubsection:
            index += "</ul>\n"
        if subsubsection:
            index += "</ul>\n"
        if subsection:
            index += "</ul>\n"
        if section == 1:
            index += "<ul>\n"

        index += """<li><a href="#%s">%s</a>\n""" % (headingname,prevheadingtext)
        subsection = 0
        subsubsection = 0
        subsubsubsection = 0
        skipspace = 1        
        continue
    m = h3.match(s)
    if m:
        prevheadingtext = getheadingtext(m, s)
        nameindex += 1
        subsection += 1
        headingname = getheadingname(m, s)
        result.append("""<H3 id="%s">%d.%d.%d %s</H3>""" % (headingname,num,section, subsection, prevheadingtext))

        if subsubsubsection:
            index += "</ul>\n"
        if subsubsection:
            index += "</ul>\n"
        if subsection == 1:
            index += "<ul>\n"

        index += """<li><a href="#%s">%s</a>\n""" % (headingname,prevheadingtext)
        subsubsection = 0
        skipspace = 1        
        continue
    m = h4.match(s)
    if m:
        prevheadingtext = getheadingtext(m, s)
        nameindex += 1
        subsubsection += 1

        headingname = getheadingname(m, s)
        result.append("""<H4 id="%s">%d.%d.%d.%d %s</H4>""" % (headingname,num,section, subsection, subsubsection, prevheadingtext))

        if subsubsubsection:
            index += "</ul>\n"
        if subsubsection == 1:
            index += "<ul>\n"

        index += """<li><a href="#%s">%s</a>\n""" % (headingname,prevheadingtext)
        subsubsubsection = 0
        skipspace = 1        
        continue
    m = h5.match(s)
    if m:
        prevheadingtext = getheadingtext(m, s)
        nameindex += 1
        subsubsubsection += 1
        headingname = getheadingname(m, s)
        result.append("""<H5 id="%s">%d.%d.%d.%d.%d %s</H5>""" % (headingname,num,section, subsection, subsubsection, subsubsubsection, prevheadingtext))

        if subsubsubsection == 1:
            index += "<ul>\n"

        index += """<li><a href="#%s">%s</a>\n""" % (headingname,prevheadingtext)
        skipspace = 1
        continue

    # Any other heading would be left out of the numbering and the table of contents
    if re.search(r"<H[1-5][\s>]", s, re.IGNORECASE):
        raise RuntimeError("Heading that cannot be read, write it on one line as <H2 id=\"...\">Text</H2>, in line:\n%s" % s)

    result.append(s)

if subsubsubsection:
    index += "</ul>\n"

if subsubsection:
    index += "</ul>\n"

if subsection:
    index += "</ul>\n"

if section:
    index += "</ul>\n"

index += "</div>\n<!-- INDEX -->\n"

data = "\n".join(result)

data = data.replace("@INDEX@",index) + "\n";

# Write the file back out
open(filename,"w").write(data)

# Print the TOC data to stdout correcting the anchor links for external referencing

index = index.replace("<li><a href=\"#","<li><a href=\"%s#" % filename)
print("""<h3><a href="%s#%s">%d %s</a></h3>\n""" % (filename,filenamebase,num,name))
print(index)

