## Process this file with automake to produce Makefile.in

# subdir-objects generates object files using the directory structure of the source files.
AUTOMAKE_OPTIONS = foreign nostdinc subdir-objects 1.7.2

SOURCE_DIR=$(top_srcdir)/Source
BUILD_SOURCE_DIR=$(top_builddir)/Source

AM_CPPFLAGS =	-I$(BUILD_SOURCE_DIR)/Include	\
		-I$(BUILD_SOURCE_DIR)/CParse	\
		-I$(SOURCE_DIR)/Include		\
		-I$(SOURCE_DIR)/DOH		\
		-I$(SOURCE_DIR)/CParse		\
		-I$(SOURCE_DIR)/Doxygen		\
		-I$(SOURCE_DIR)/Preprocessor	\
		-I$(SOURCE_DIR)/Swig		\
		-I$(SOURCE_DIR)/Modules

AM_CXXFLAGS =

AM_YFLAGS = -d -Wall -Werror


BUILT_SOURCES = CParse/parser.c CParse/parser.h
eswig_SOURCES =	CParse/cscanner.c		\
		CParse/parser.c			\
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
		Doxygen/csharpdoc.cxx		\
		Doxygen/csharpdoc.h		\
		Doxygen/doxyentity.cxx		\
		Doxygen/doxyentity.h		\
		Doxygen/doxyparser.cxx		\
		Doxygen/doxyparser.h		\
		Doxygen/doxytranslator.cxx	\
		Doxygen/doxytranslator.h	\
		Doxygen/javadoc.cxx		\
		Doxygen/javadoc.h		\
		Doxygen/pydoc.cxx		\
		Doxygen/pydoc.h			\
		Modules/allocate.cxx		\
		Modules/contract.cxx		\
		Modules/c.cxx			\
		Modules/csharp.cxx		\
		Modules/d.cxx			\
		Modules/directors.cxx		\
		Modules/emit.cxx		\
		Modules/go.cxx			\
		Modules/guile.cxx		\
		Modules/interface.cxx		\
		Modules/java.cxx		\
		Modules/javascript.cxx		\
		Modules/lang.cxx		\
		Modules/lua.cxx			\
		Modules/main.cxx		\
		Modules/nested.cxx		\
		Modules/ocaml.cxx		\
		Modules/octave.cxx		\
		Modules/overload.cxx		\
		Modules/perl5.cxx		\
		Modules/php.cxx			\
		Modules/python.cxx		\
		Modules/r.cxx			\
		Modules/ruby.cxx		\
		Modules/scilab.cxx		\
		Modules/swigmain.cxx		\
		Modules/tcl8.cxx		\
		Modules/typepass.cxx		\
		Modules/utils.cxx		\
		Modules/xml.cxx			\
		Preprocessor/cpp.c		\
		Preprocessor/expr.c		\
		Swig/cwrap.c			\
		Swig/deprecate.c		\
		Swig/error.c			\
		Swig/extend.c			\
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
		Swig/typemap.c			\
		Swig/typeobj.c			\
		Swig/typesys.c			\
		Swig/wrapfunc.c

bin_PROGRAMS = eswig

# Use GNU make's grouped targets to avoid repeated bison execution for
# each target.
CParse/parser.c CParse/parser.h &: CParse/parser.y
	$(BISON) $(AM_YFLAGS) $(YFLAGS) --output=CParse/parser.c $(srcdir)/CParse/parser.y

# The executable is copied to the root directory for installation and running the test-suite.
# This occurs on each invocation of make and is a step towards providing support for multiple
# build directories.
all-local: eswig@EXEEXT@
	cp -f $(top_builddir)/Source/eswig@EXEEXT@ $(top_builddir)/swig@EXEEXT@

# Add clang-format checking (warnings) to dependencies building the executable
 ifneq (,$(CLANG_FORMAT)) # Note space before ifneq/endif trick to prevent automake evaluating and removing this block during configure time
all-local: format-review
 endif

clean-local:
	rm -f $(top_builddir)/swig@EXEEXT@
	rm -f core @EXTRA_CLEAN@

distclean-local:
	rm -f $(top_builddir)/Source/Include/swigconfig.h
	rm -f $(top_builddir)/Source/Include/stamp-h1

# Beautify / check source code format with clang-format.
# Note files in .clang-format-ignore will be skipped even if passed to clang-format (clang-format-18 and later).

# For warning about source formatting discrepancies
format-review:
	(cd $(srcdir) && $(CLANG_FORMAT) $(CLANG_FORMAT_OPTIONS) --dry-run */*.c */*.cxx */*.h)

# For erroring out about source formatting discrepancies
format-check:
	(cd $(srcdir) && $(CLANG_FORMAT) $(CLANG_FORMAT_OPTIONS) --dry-run --Werror  */*.c */*.cxx */*.h)

# For correcting source formatting - overwrites source files in-place
format-inplace:
	(cd $(srcdir) && $(CLANG_FORMAT) $(CLANG_FORMAT_OPTIONS) -i  */*.c */*.cxx */*.h)

format: format-inplace

CLANG_FORMAT_OPTIONS=
