#######################################################################
# $Header$
# Makefile for guile test-suite (with SCM API)
#######################################################################

include ../guile/Makefile

VARIANT = _scm
# Refer to the guile directory for the run scripts
SCRIPTPREFIX = ../guile/

# Runs the testcase. A testcase is only run if
# a file is found which has _runme.scm appended after the testcase name.
run_testcase = \
	if [ -f $(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then ( \
	  env LD_LIBRARY_PATH=$(DYNAMIC_LIB_PATH):$$LD_LIBRARY_PATH guile -l $(SCRIPTPREFIX)$*$(SCRIPTSUFFIX);) \
	fi;

setup = \
	@if [ -f $(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then		  \
	  echo "Checking testcase $* (with run test) under $(LANGUAGE) (with SCM API)" ; \
	else								  \
	  echo "Checking testcase $* under $(LANGUAGE) (with SCM API)" ;		  \
	fi;
