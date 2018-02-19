###############################################################################
# File  : pandoc2swigman.py
# Author: Seth R Johnson
# Date  : Mon Feb 19 15:51:49 2018
#
# Convert Pandoc-generated HTML to SWIG html
###############################################################################
from __future__ import (division, absolute_import, print_function, )
#-----------------------------------------------------------------------------#
import os
import re
from exnihiloenv.rewriter import ReWriter
###############################################################################

RE_HEADER = re.compile(r'^<h(\d) id="([^"]+)">(.*)</h(\d)>$')
RE_PRE    = re.compile(r'^<pre class="(\w+)">')
RE_LINK   = re.compile(r'<a href="#([^"]+)">')

NEW_HEADER = '<H{lev:d}><a name="{link}">{title}</a></H{lev:d}>\n'

SELECTOR = {
        'fortran': "targetlang",
        'swig':    "code",
        'c++':     "code",
        'c':       "code",
        'sh':      "shell",
        }

def convert_link(link):
    return "Fortran_" + link.replace("-","_")

def repl_link_match(match):
    return r'<a href="#{}">'.format(convert_link(match.group(1)))

def swiggify(path):
    with ReWriter(path) as rewriter:
        (oldf, newf) = rewriter.files
        rewriter.dirty = True

        in_code = False
        for line in oldf:
            if in_code:
                if "</pre>" in line:
                    line += "</div>\n\n"
                    in_code = False
                else:
                    newf.write(line)
                    continue

            match = RE_HEADER.match(line)
            if match:
                (lev, link, title, lev2) = match.groups()
                lev = int(lev) + 1 # lower the heading level
                link = convert_link(link)
                line = NEW_HEADER.format(lev=lev, link=link, title=title)
                newf.write(line)
                continue

            match = RE_PRE.match(line)
            if match:
                code = SELECTOR[match.group(1)]
                line = '\n<div class="{}"><pre>{}'.format(
                    code, line[match.end():])
                in_code = True
                newf.write(line)
                continue

            line = RE_LINK.sub(repl_link_match, line)
            line = line.replace("<p>", "\n<p>\n")
            line = line.replace("</p>", "\n</p>\n")

            newf.write(line)

def main():
    extensions = (".html",)

    from exnihiloenv.filemodify import _common
    _common.run(swiggify, default_extensions=",".join(extensions))

#-----------------------------------------------------------------------------#
if __name__ == '__main__':
    #main()
    swiggify("../Fortran.html")

###############################################################################
# end of pandoc2swigman.py
###############################################################################
