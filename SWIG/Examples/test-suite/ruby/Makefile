#######################################################################
# $Header$
# Makefile for ruby test-suite
#######################################################################

LANGUAGE   = ruby
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
# a file is found which has _runme.rb appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.rb ]; then ( \
	  ruby $*\_runme.rb;) \
	fi;

# Clean
%.clean:
	

clean:
	@rm -f *_wrap* *.o *~ *.so .~* core
