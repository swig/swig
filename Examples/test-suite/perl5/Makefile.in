#######################################################################
# $Header$
# Makefile for perl5 test-suite
#######################################################################

LANGUAGE   = perl5
SCRIPTSUFFIX = _runme.pl

include ../common.mk

# Overridden variables here
SWIGOPT    = -shadow -I$(TOP)/$(TEST_SUITE)

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
# a file is found which has _runme.pl appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.pl ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH perl $*\_runme.pl;) \
	fi;

# Clean: remove the generated .pm file
%.clean:
	@rm -f $*.pm;

clean:
	$(MAKE) -f $(TOP)/Makefile perl5_clean
