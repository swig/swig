#!/usr/local/bin/python
# Make the SWIG web-pages
#
# Okay. Yet another bogus rewrite of Barry's work

import string
import glob
import os
import time
import stat

def makepage(filename):
        name, suffix = os.path.splitext(filename)
	f = open("default.html")
	page = f.read()
        f.close()

	# Read in the body file
        f = open(filename)
	body = f.readlines()
	f.close()
	title = body[0]
	body = string.join(body[1:])
	page = string.replace(page,"$title",title)	
	page = string.replace(page,"$body",body)

	# Read in the corner file
	try:
		f = open(name+".corner")
		corner = f.read()
		f.close()
	except IOError:
		try:
			f = open("default.corner")
			corner = f.read()
			f.close()
		except:
			corner = ""
	
	page = string.replace(page,"$corner",corner)

	# Read in the top file
	try:
		f = open(name+".top")
		top = f.read()
		f.close()
	except IOError:
		try:
			f = open("default.top")
			top = f.read()
			f.close()
		except:
			top = ""
	
	page = string.replace(page,"$top",top)

	# Read in the side file
	try:
		f = open(name+".side")
		side = f.read()
		f.close()
	except IOError:
		try:
			f = open("default.side")
			side = f.read()
			f.close()
		except:
			side = ""
	
	page = string.replace(page,"$side",side)

	# Read in the footer file
	try:
		f = open(name+".footer")
		footer = f.read()
		f.close()
	except IOError:
		try:
			f = open("default.footer")
			footer = f.read()
			f.close()
		except:
			footer = ""

	page = string.replace(page,"$footer",footer)

	mtime = os.stat(filename)[stat.ST_MTIME]
	mstr = time.ctime(mtime)

	page = string.replace(page,"$mtime",mstr);

	# Write out the page
	f = open(name+".html","w")
	f.write(page)
	f.close()
	print "Wrote ", name+".html"

files = glob.glob("*.ht")

for f in files:
	makepage(f)




