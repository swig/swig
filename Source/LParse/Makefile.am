include $(top_srcdir)/Makefile.common

INCLUDES = $(SWIG_INCLUDES) \
	  -I$(top_srcdir)/Source/Swig \
	  -I$(top_srcdir)/Source/Include \
	  -I$(top_srcdir)/Source/Preprocessor

noinst_LIBRARIES = liblparse.a

liblparse_a_SOURCES = parser.y cscanner.c type.c

noinst_HEADERS = lparse.h
