#######################################################################
# $Header$
# Makefile for ruby test-suite
#######################################################################

LANGUAGE   = ruby
SCRIPTSUFFIX = _runme.rb

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
# a file is found which has _runme.rb appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.rb ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH ruby $*\_runme.rb;) \
	fi;

# Clean
%.clean:
	

clean:
	$(MAKE) -f $(TOP)/Makefile ruby_clean
