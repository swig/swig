# Simple makefile to create the web pages and update/synchronise to the real web server

USERNAME=wsfulton

all: makeweb rsync

makeweb:
	python makeweb.py

rsync:
	rsync -r --cvs-exclude --rsh="ssh" . $(USERNAME)@shell.sf.net:/home/groups/s/sw/swig/swigweb

