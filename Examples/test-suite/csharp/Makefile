#######################################################################
# $Header$
# Makefile for csharp test-suite
#######################################################################

LANGUAGE   = csharp
SCRIPTSUFFIX = _runme.cs

include ../common.mk

# Overridden variables here
TOP        = ../../..
SWIGOPT    = -I$(TOP)/$(TEST_SUITE) -package $*
#Target prefix cannot be used on Windows
#TARGETPREFIX = lib

# Rules for the different types of tests
%.cpptest: 
	$(setup) \
	(cd $*; $(swig_and_compile_cpp); ); \
	$(run_testcase)

%.ctest:
	$(setup) \
	(cd $*; $(swig_and_compile_c); ); \
	$(run_testcase)

%.multicpptest: 
	$(setup) \
	(cd $*; $(swig_and_compile_multi_cpp); ); \
	$(run_testcase)

# Makes a directory for the testcase if it does not exist
setup = \
	@if [ -f $(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then		  \
	  echo "Checking testcase $* (with run test) under $(LANGUAGE)" ; \
	else								  \
	  echo "Checking testcase $* under $(LANGUAGE)" ;		  \
	fi;								  \
	if [ ! -d $* ]; then						  \
		mkdir $*;						  \
	fi;

# Compiles csharp files then runs the testcase. A testcase is only run if
# a file is found which has _runme.cs appended after the testcase name.
# Note CSharp uses LD_LIBRARY_PATH under Unix, PATH under Cygwin/Windows and SHLIB_PATH on HPUX.
run_testcase = \
	if [ -f $*_runme.cs ]; then ( \
	  $(MAKE) -f $*/$(TOP)/Makefile CSHARPFLAGS='-o $*_runme' CSHARPSRCS='$*_runme.cs $*/*.cs' csharp_compile; \
	  env LD_LIBRARY_PATH="$*:$$LD_LIBRARY_PATH" PATH="$*:$$PATH" SHLIB_PATH="$*:$$SHLIB_PATH" ilrun $*_runme; ) \
	else ( \
	  cd $*; \
	  $(MAKE) -f $(TOP)/Makefile CSHARPFLAGS='-c' CSHARPSRCS='*.cs' csharp_compile; ); \
	fi;

# Clean: remove testcase directories
%.clean:
	@rm -f $*_runme
	@if [ -d $* ]; then \
		rm -rf $*; \
	fi;

clean:

