# Generated automatically from Makefile.in by configure.
# Generated automatically from Makefile.in by configure.

SHELL     = /bin/sh
prefix    = /usr/local
execprefix= ${prefix}
LIB        = $(execprefix)/lib

# Location of your Python installation
PYINCLUDE = -I/usr/local/include/python2.0

# Location of your Tcl installation
TCLINCLUDE = -I/usr/local/include

# Location of your Perl installation
PERLINCLUDE = -I/usr/perl5/5.00503/sun4-solaris/CORE

all: wad python tcl perl

wad:
	@cd Wad; $(MAKE) wad

python:
	@cd Wad; $(MAKE) SINCLUDE='$(PYINCLUDE)' python

tcl:
	@cd Wad; $(MAKE) SINCLUDE='$(TCLINCLUDE)' tcl

perl:
	@cd Wad; $(MAKE) SINCLUDE='$(PERLINCLUDE)' perl

install:
	cp libwad*.so $(LIB)
	chmod a+rx $(LIB)/libwad*.so

clean:
	@cd Wad; $(MAKE) clean
	rm *.so

