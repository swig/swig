#!/usr/local/bin/python

# Takes a chapter as input and adds internal links and numbering to all
# of the h1, h2, h3, h4 sections and so forth.
#

import sys
import re

if len(sys.argv) != 3:
    print "usage: makechap.py filename num"
    sys.exit(1)

filename = sys.argv[1]
num      = int(sys.argv[2])

section = 0
subsection = 0
subsubsection = 0
nameindex = 0

name = ""

# Regexs for <h1>,... <h4> sections

h1 = re.compile(r".*?<H1>[\d\.\s]*(.*?)</H1>", re.IGNORECASE)
h2 = re.compile(r".*?<H2>[\d\.\s]*(.*?)</H2>", re.IGNORECASE)
h3 = re.compile(r".*?<H3>[\d\.\s]*(.*?)</H3>", re.IGNORECASE)
h4 = re.compile(r".*?<H4>[\d\.\s]*(.*?)</H4>", re.IGNORECASE)
h5 = re.compile(r".*?<H5>[\d\.\s]*(.*?)</H5>", re.IGNORECASE)

data = open(filename).read()            # Read data
open(filename+".bak","w").write(data)   # Make backup

lines = data.splitlines()
result = [ ]
index = "<!-- INDEX -->\n<ul>\n"

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
        nameindex += 1
        result.append("""<a name="n%d"></a><H1>%d %s</H1>""" % (nameindex,num,m.group(1)))
        result.append("@INDEX@")
        section = 0
        subsection = 0
        subsubsection = 0
        subsubsubsection = 0
        name = m.group(1)
        skipspace = 1
        continue
    m = h2.match(s)
    if m:
        nameindex += 1
        section += 1
        result.append("""<a name="n%d"></a><H2>%d.%d %s</H2>""" % (nameindex,num,section, m.group(1)))
        if subsubsection:
            index += "</ul>\n"
        if subsection:
            index += "</ul>\n"
        index += """<li><a href="#n%d">%s</a>\n""" % (nameindex,m.group(1))
        subsection = 0
        subsubsection = 0
        subsubsubsection = 0
        skipspace = 1        
        continue
    m = h3.match(s)
    if m:
        nameindex += 1
        subsection += 1
        result.append("""<a name="n%d"></a><H3>%d.%d.%d %s</H3>""" % (nameindex,num,section, subsection, m.group(1)))

        if subsubsection:
            index += "</ul>\n"
            
        if subsection == 1:
            index += "<ul>\n"
        index += """<li><a href="#n%d">%s</a>\n""" % (nameindex,m.group(1))

        subsubsection = 0
        skipspace = 1        
        continue
    m = h4.match(s)
    if m:
        nameindex += 1
        subsubsection += 1
        subsubsubsection = 0
        result.append("""<a name="n%d"></a><H4>%d.%d.%d.%d %s</H4>""" % (nameindex,num,section, subsection, subsubsection, m.group(1)))
        if subsubsection == 1:
            index += "<ul>\n"
        index += """<li><a href="#n%d">%s</a>\n""" % (nameindex,m.group(1))
        skipspace = 1        
        continue
    m = h5.match(s)
    if m:
        nameindex += 1
        subsubsubsection += 1
        result.append("""<a name="n%d"></a><H5>%d.%d.%d.%d.%d %s</H5>""" % (nameindex,num,second,subsection,subsubsection,subsubsubsection, m.group(1)))
        skipspace = 1
        continue
    
    result.append(s)

if subsubsection:
    index += "</ul>\n"

if subsection:
    index += "</ul>\n"

if section:
    index += "</ul>\n"

index += "<!-- INDEX -->\n"

data = "\n".join(result)

data = data.replace("@INDEX@",index) + "\n";

# Write the file back out
open(filename,"w").write(data)

# Print the TOC data

index = index.replace("#n","%s#n" % filename)
print """<h3><a href="%s">%d %s</a></h3>\n""" % (filename,num,name)
print index

        

    
