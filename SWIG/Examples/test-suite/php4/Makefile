#######################################################################
# Makefile for php4 test-suite
#######################################################################

LANGUAGE   = php4
SCRIPTSUFFIX = _runme.php4

include ../common.mk

# Overridden variables here
SWIGOPT    = -I$(TOP)/../Lib -I$(TOP)/$(TEST_SUITE) 
TARGETPREFIX = php_

makecpptests:
	@bash -ec 'for test in $(CPP_TEST_CASES) ; do make clean && make $${test}.cpptest; done'

maketests: makecpptests makectests

makectests:
	@bash -ec 'for test in $(C_TEST_CASES) ; do make clean && make $${test}.cpptest; done'

runcpptests:
	@bash -ec 'for test in $(CPP_TEST_CASES) ; do if [ -f $${test}_runme.php4 ] ; then make clean && make $${test}.cpptest; fi ; done'

runctests:
	@bash -ec 'for test in $(C_TEST_CASES) ; do if [ -f $${test}_runme.php4 ] ; then make clean && make $${test}.cpptest; fi; done'

runtests: runcpptests runctests

# write out tests without a _runme.php4
missingcpptests:
	@bash -ec 'for test in $(CPP_TEST_CASES) ; do test -f $${test}_runme.php4 || echo $${test}; done'

missingctests:
	@bash -ec 'for test in $(C_TEST_CASES) ; do test -f $${test}_runme.php4 || echo $${test}; done'

missingtests: missingcpptests missingctests

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
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH php -q -d extension_dir=. $*\_runme.php4;) \
	fi;

# Clean: remove the generated .php file
%.clean:
	@rm -f $*.php;

clean:
	$(MAKE) -f $(TOP)/Makefile php4_clean
