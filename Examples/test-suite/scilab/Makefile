#######################################################################
# Makefile for scilab test-suite
#######################################################################

LANGUAGE     = scilab
SCILAB       = scilab
SCRIPTSUFFIX = _runme.sci
srcdir       = .
top_srcdir   = ../../..
top_builddir = ../../..

include $(srcdir)/../common.mk

# Overridden variables here
# none!

# Rules for the different types of tests
%.cpptest: 
	
%.ctest:
	$(setup)
	+$(swig_and_compile_c)
	$(run_testcase)

%.multicpptest: 
	
# Runs the testcase. A testcase is only run if
# a file is found which has _runme.sci appended after the testcase name.
run_testcase = \
	if [ -f $(srcdir)/$(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then (	  \
	  env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH $(RUNTOOL) $(SCILAB) -nwni -nb -f $(srcdir)/$(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ; ) \
	fi; \


# Clean: remove the generated .sci file
%.clean:
	@rm -f $*.sci *_wrap.c

clean:
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile scilab_clean
