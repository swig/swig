#######################################################################
# $Header$
# Makefile for python test-suite
#######################################################################

LANGUAGE   = python
include ../common.mk

# Overridden variables here
TARGET     = $*c
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

setup = \
	@echo Checking testcase $* under $(LANGUAGE);

# Runs the testcase. A testcase is only run if
# a file is found which has _runme.py appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.py ]; then ( \
	  python $*\_runme.py;) \
	fi;

# Clean: remove the generated .py file
%.clean:
	@rm -f $*.py;

clean:
	@rm -f *_wrap* *.o *~ *.so *.pyc .~* core
