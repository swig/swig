#!/usr/bin/env python3

import argparse
import sys
import os

parser = argparse.ArgumentParser(
    formatter_class=lambda prog: argparse.RawDescriptionHelpFormatter(prog, width=80),
    description="""\
Regenerate the heading numbers and the table of contents of every chapter of
the SWIG manual and the contents of the whole manual, Contents.html.""",
    epilog="""\
Runs makechap.py on each chapter listed in the chapters file in turn, numbering
the chapters in the order they are listed. What it prints is collected into
Contents.html. Reads the chapters from the current directory, which must be
Doc/Manual.

Exits 0 when every chapter is processed and 1 when makechap.py fails on a
chapter, naming the chapter.""")
parser.parse_args()

chs = open("chapters").readlines()

f = open("Contents.html","w")
f.write("""
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>
<TITLE>SWIG Users Manual</TITLE>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
</HEAD>
<BODY BGCOLOR="#ffffff">

<H1 id="Contents">SWIG Users Manual</H1>

<p>

""")

f.close()

num = 1

for c in chs:
    c = c.strip()
    print("Processing " + c)
    if c:
        if os.system("python3 makechap.py %s %d >> Contents.html" % (c,num)) != 0:
            sys.exit("Error: makechap.py failed on " + c)
    num += 1

f = open("Contents.html","a")
f.write("""
</BODY>
</HTML>

""")


