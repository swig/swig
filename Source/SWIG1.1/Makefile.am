include $(top_srcdir)/Makefile.common

SWIG_LIB = $(prefix)/lib/swig1.3

INCLUDES = $(SWIG_INCLUDES) \
	  -I$(top_srcdir)/Source/Swig \
	  -I$(top_srcdir)/Source/Include \
	  -I$(top_srcdir)/Source/Preprocessor \
	  -I$(top_srcdir)/Source/Modules1.1 \
          -DSWIG_LIB='"$(SWIG_LIB)"' \
	  -DSWIG_CC='"$(CC)"'

SWIG1_LIBS = $(SWIG_LIBS) \
	  $(top_builddir)/Source/Swig/libswig.a \
	  $(top_builddir)/Source/Preprocessor/libpreprocessor.a \
	  $(top_builddir)/Source/Modules1.1/libmodules.a

bin_PROGRAMS = swig

swig_SOURCES = parser.yxx main.cxx scanner.cxx symbol.cxx include.cxx types.cxx parms.cxx emit.cxx \
	       newdoc.cxx cplus.cxx lang.cxx hash.cxx \
               sstring.cxx wrapfunc.cxx comment.cxx typemap.cxx naming.cxx 
swig_LDADD = $(SWIG1_LIBS) $(SWIG1_LIBS)
swig_DEPENDENCIES = $(SWIG1_LIBS)

noinst_HEADERS = internal.h parser.h swig11.h
