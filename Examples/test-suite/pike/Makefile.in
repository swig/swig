#######################################################################
# $Header$
# Makefile for Pike test-suite
#######################################################################

LANGUAGE   = pike
SCRIPTSUFFIX = _runme.pike

include ../common.mk

# Overridden variables here
TARGETSUFFIX = 
SWIGOPT    = -I$(TOP)/$(TEST_SUITE)

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
# a file is found which has _runme.pike appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.pike ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH pike $*\_runme.pike;) \
	fi;

# Clean: remove the generated .pike file
%.clean:
	@rm -f $*.pike;

clean:
	$(MAKE) -f $(TOP)/Makefile pike_clean

