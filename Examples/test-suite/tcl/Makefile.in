#######################################################################
# $Header$
# Makefile for tcl test-suite
#######################################################################

LANGUAGE   = tcl
SCRIPTSUFFIX = _runme.tcl 

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
# a file is found which has _runme.tcl appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.tcl ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH tclsh $*\_runme.tcl;) \
	fi;

# Clean
%.clean:
	

clean:
	$(MAKE) -f $(TOP)/Makefile tcl_clean
