# Generated automatically from Makefile.in by configure.
#######################################################################
# WAD Makefile
#
# David Beazley
# January 1, 2001
#######################################################################

# These are the files that make up the WAD core
WADSRCS = vars.c io.c memory.c return.c default.c stack.c stab.c elf.c object.c init.c segment.c signal.c
WADOBJS = vars.o io.o memory.o return.o default.o stack.o stab.o elf.o object.o signal.o segment.o init.o
INCLUDE = -I../Include -I.  $(SINCLUDE)
WADOPT     = -DWAD_LINUX

# Location of your Python installation
PYINCLUDE = -I/usr/local/include/python2.0
PYCSRCS   = wadpyinit.cxx
PYOBJS    = wadpy.o

# Location of your Tcl installation
TCLINCLUDE = -I/usr/local/include
TCLSRCS    = wadtcl.cxx
TCLOBJS    = wadtcl.o

# Location of your Perl installation
PERLINCLUDE = -I/usr/lib/perl5/5.00503/i386-linux/CORE
PERLSRCS   = wadpl.cxx
PERLOBJS   = wadpl.o

# C Compiler
CC = gcc
CFLAGS = #-fpic

# C++ Compiler
CXX = c++
CXXFLAGS = #-fpic

# Linking options
CLINK = 
CXXLINK = g++ -shared

# AR
AR = ar

# Rules for creation of a .o file from .cxx
.SUFFIXES: .cxx
.cxx.o:
	$(CXX) $(CXXFLAGS) $(WADOPT) $(INCLUDE) -c -o $*.o $<

.c.o:
	$(CC) $(CFLAGS) $(WADOPT) $(INCLUDE) -c -o $*.o $<

wad:    $(WADOBJS) main.o
	$(CXXLINK) $(WADOBJS) main.o -o libwad.so 
	$(AR) cr libwadcore.a $(WADOBJS)
	cp libwad.so ..
	cp libwadcore.a ..

python: $(WADOBJS) $(PYOBJS)
	$(CXXLINK) $(WADOBJS) $(PYOBJS) -o libwadpy.so
	cp libwadpy.so ..

tcl: $(WADOBJS) $(TCLOBJS)
	$(CXXLINK) $(WADOBJS) $(TCLOBJS) -o libwadtcl.so
	cp libwadtcl.so ..

perl: wad_perl_handler.c $(WADOBJS) $(PERLOBJS)
	$(CXXLINK) $(WADOBJS) $(PERLOBJS) -o libwadpl.so
	cp libwadpl.so ..

wad_perl_handler.c:
	python makehandler.py

debug::
	cc -g debug.c $(INCLUDE) -L. -R. -lwad

plus::
	CC -g debug.cxx $(INCLUDE) -L. -R. -lwad

wc::
	wc $(SRCS)

semi::
	egrep ";" $(SRCS) wadpy.cxx | wc


clean::
	rm -f *.o *.so *~ 




