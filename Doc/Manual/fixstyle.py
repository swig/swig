#!/usr/bin/python

# Adds the SWIG stylesheet to the generated documentation on a single page

import sys
import string

filename = sys.argv[1]

data = open(filename).read()
open(filename+".bak","w").write(data)

swigstyle = "\n" + open("style.css").read()

lines = data.splitlines()
result = [ ]
for s in lines:
	if s == "<STYLE TYPE=\"text/css\"><!--":
		result.append(s + swigstyle)
	else:
		result.append(s)

data = "\n".join(result)

open(filename,"w").write(data)
