#######################################################################
# $Header$
# Makefile for guile test-suite
#######################################################################

LANGUAGE   = guile_simple
include ../common.mk

# Overridden variables here
CPP_TEST_CASES += long_long

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
	@echo Checking testcase $* under Guile;

# Runs the testcase. A testcase is only run if
# a file is found which has _runme.scm appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.scm ]; then ( \
	  ./$*-guile -l $*\_runme.scm;) \
	fi;

# Clean
%.clean:
	@rm -f $*-guile

clean:
	@rm -f *_wrap* *.o *.so *~ ~* core
