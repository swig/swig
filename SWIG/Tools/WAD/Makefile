# Generated automatically from Makefile.in by configure.
# Generated automatically from Makefile.in by configure.


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


clean:
	@cd Wad; $(MAKE) clean
	rm *.so

