include $(top_srcdir)/Makefile.common

INCLUDES = $(SWIG_INCLUDES) \
	  -I$(top_srcdir)/Source/Swig \
	  -I$(top_srcdir)/Source/Include

noinst_LIBRARIES = libpreprocessor.a

libpreprocessor_a_SOURCES = expr.c cpp.c

noinst_HEADERS = preprocessor.h
