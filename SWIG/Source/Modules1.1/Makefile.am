include $(top_srcdir)/Makefile.common

SWIG_LIB = $(prefix)/lib/swig1.3

INCLUDES = -I$(top_srcdir)/Source/SWIG1.1 \
	   -I$(top_srcdir)/Source/Include \
	   -DSWIG_LIB='"$(SWIG_LIB)"' \
	   -DSWIG_CC='"$(CC)"'

noinst_LIBRARIES = libmodules.a

libmodules_a_SOURCES = ascii.cxx guile.cxx html.cxx java.cxx perl5.cxx pycpp.cxx \
	               python.cxx swigmain.cxx tcl8.cxx

noinst_HEADERS = ascii.h guile.h html.h java.h nodoc.h perl5.h python.h tcl8.h wrap.h
