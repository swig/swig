## Process this file with automake to produce Makefile.in

# subdir-objects generates object files using the directory structure of the source files.
AUTOMAKE_OPTIONS = foreign nostdinc subdir-objects 1.7.2

SOURCE_DIR=$(top_srcdir)/Source
BUILD_SOURCE_DIR=$(top_builddir)/Source

SWIG_CXX_DEFS = @SWILL@

AM_CFLAGS =	-I$(BUILD_SOURCE_DIR)/Include	\
		-I$(BUILD_SOURCE_DIR)/CParse	\
		-I$(SOURCE_DIR)/Include		\
		-I$(SOURCE_DIR)/DOH		\
		-I$(SOURCE_DIR)/CParse		\
		-I$(SOURCE_DIR)/Preprocessor	\
		-I$(SOURCE_DIR)/Swig		\
		-I$(SOURCE_DIR)/Modules

AM_CXXFLAGS =	$(AM_CFLAGS)			\
		$(SWIG_CXX_DEFS)

AM_YFLAGS = -d

BUILT_SOURCES = CParse/parser.h
eswig_SOURCES =	CParse/cscanner.c		\
		CParse/parser.y			\
		CParse/templ.c			\
		CParse/util.c			\
		DOH/base.c			\
		DOH/file.c			\
		DOH/fio.c			\
		DOH/hash.c			\
		DOH/list.c			\
		DOH/memory.c			\
		DOH/string.c			\
		DOH/void.c			\
		Modules/allegrocl.cxx		\
		Modules/allocate.cxx		\
		Modules/browser.cxx		\
		Modules/cffi.cxx		\
		Modules/chicken.cxx		\
		Modules/clisp.cxx		\
		Modules/contract.cxx		\
		Modules/csharp.cxx		\
		Modules/directors.cxx		\
		Modules/emit.cxx		\
		Modules/guile.cxx		\
		Modules/java.cxx		\
		Modules/lang.cxx		\
		Modules/lua.cxx			\
		Modules/main.cxx		\
		Modules/modula3.cxx		\
		Modules/module.cxx		\
		Modules/mzscheme.cxx		\
		Modules/ocaml.cxx		\
		Modules/overload.cxx		\
		Modules/perl5.cxx		\
		Modules/php4.cxx		\
		Modules/pike.cxx		\
		Modules/python.cxx		\
		Modules/r.cxx			\
		Modules/ruby.cxx		\
		Modules/s-exp.cxx		\
		Modules/swigmain.cxx		\
		Modules/tcl8.cxx		\
		Modules/typepass.cxx		\
		Modules/uffi.cxx		\
		Modules/utils.cxx		\
		Modules/xml.cxx			\
		Preprocessor/cpp.c		\
		Preprocessor/expr.c		\
		Swig/cwrap.c			\
		Swig/error.c			\
		Swig/fragment.c			\
		Swig/getopt.c			\
		Swig/include.c			\
		Swig/misc.c			\
		Swig/naming.c			\
		Swig/parms.c			\
		Swig/scanner.c			\
		Swig/stype.c			\
		Swig/symbol.c			\
		Swig/tree.c			\
		Swig/typeobj.c			\
		Swig/typemap.c			\
		Swig/typesys.c			\
		Swig/warn.c			\
		Swig/wrapfunc.c			\
		Swig/swigkeys.c

bin_PROGRAMS = eswig
eswig_LDADD   = @SWIGLIBS@

# Override the link stage to avoid using Libtool
CXXLINK = $(CXXLD) $(AM_CXXFLAGS) $(CXXFLAGS) $(AM_LDFLAGS) $(LDFLAGS) -o $@

# The executable is copied to the root directory for installation and running the test-suite.
# This occurs on each invocation of make and is a step towards providing support for multiple 
# build directories.
all-local: eswig@EXEEXT@
	cp eswig@EXEEXT@ ../swig@EXEEXT@

clean-local:
	rm -f ../swig@EXEEXT@
	rm -f core @EXTRA_CLEAN@
