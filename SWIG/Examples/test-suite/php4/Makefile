#######################################################################
# Makefile for php4 test-suite
#######################################################################

LANGUAGE   = php4
SCRIPTSUFFIX = _runme.php4

include ../common.mk

# Overridden variables here
SWIGOPT    = -I$(TOP)/../Lib -I$(TOP)/$(TEST_SUITE) 
TARGETPREFIX = php_

runtests:
	@bash -ec 'ls *_runme.php4 | sed -e "s/_runme.php4/.cpptest/" | while read file; do make clean && make $$file; done'

# write out tests without a _runme.php4
missingtests:
	@bash -ec 'for test in $(CPP_TEST_CASES) ; do test -f $${test}_runme.php4 || echo $${test}; done'

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
# a file is found which has _runme.php4 appended after the testcase name.
run_testcase = \
	if [ -f $*\_runme.php4 ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH php -d extension_dir=. $*\_runme.php4;) \
	fi;

# Clean: remove the generated .php file
%.clean:
	@rm -f $*.php;

clean:
	@rm -f *_wrap* *.o *~ *.so *.dll .~* core *.h
