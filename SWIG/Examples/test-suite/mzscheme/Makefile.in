#######################################################################
# $Header$
# Makefile for mzscheme test-suite
#######################################################################

LANGUAGE   = mzscheme
SCRIPTSUFFIX = _runme.scm

include ../common.mk

# Overridden variables here

# Rules for the different types of tests
%.cpptest: 
	$(setup) \
	($(swig_and_compile_cpp); ); \
	$(run_testcase)

%.ctest:
	$(setup) \
	($(swig_and_compile_c); ); \
	$(run_testcase)

%.multicpptest: 
	$(setup) \
	($(swig_and_compile_multi_cpp); ); \
	$(run_testcase)

# Runs the testcase. A testcase is only run if
# a file is found which has _runme.scm appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.scm ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH mzscheme -r $*\_runme.scm;) \
	fi;

# Clean
%.clean:
	
clean:
	$(MAKE) -f $(TOP)/Makefile mzscheme_clean
