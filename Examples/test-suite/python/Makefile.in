#######################################################################
# $Header$
# Makefile for python test-suite
#######################################################################

LANGUAGE   = python
SCRIPTSUFFIX = _runme.py

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
# a file is found which has _runme.py appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.py ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH python $*\_runme.py;) \
	fi;

# Clean: remove the generated .py file
%.clean:
	@rm -f $*.py;

clean:
	$(MAKE) -f $(TOP)/Makefile python_clean

