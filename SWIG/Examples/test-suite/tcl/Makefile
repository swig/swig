#######################################################################
# $Header$
# Makefile for tcl test-suite
#######################################################################

LANGUAGE   = tcl
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

setup = \
	@echo Checking testcase $* under $(LANGUAGE);

# Runs the testcase. A testcase is only run if
# a file is found which has _runme.tcl appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.tcl ]; then ( \
	  tclsh $*\_runme.tcl;) \
	fi;

# Clean
%.clean:
	

clean:
	@rm -f *_wrap* *.o *~ *.so .~* core
