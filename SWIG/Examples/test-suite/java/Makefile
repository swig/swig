#######################################################################
# $Header$
# Makefile for java test-suite
#######################################################################

LANGUAGE   = java
SCRIPTSUFFIX = _runme.java

include ../common.mk

# Overridden variables here
TOP        = ../../..
SWIGOPT    = -shadow -I$(TOP)/$(TEST_SUITE) -package $*
TARGETPREFIX = lib

# Rules for the different types of tests
%.cpptest: 
	$(setup) \
	(cd $*; $(swig_and_compile_cpp); ); \
	$(run_testcase)

%.ctest:
	$(setup) \
	(cd $*; $(swig_and_compile_c); ); \
	$(run_testcase)

# Makes a directory for the testcase if it does not exist
setup = \
	@if [ -f $(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then		  \
	  echo "Checking testcase $* (with run test) under $(LANGUAGE)" ; \
	else								  \
	  echo "Checking testcase $* under $(LANGUAGE)" ;		  \
	fi;								  \
	if [ ! -d $* ]; then						  \
		mkdir $*;						  \
	fi;

# Compiles java files then runs the testcase. A testcase is only run if
# a file is found which has _runme.java appended after the testcase name.
run_testcase = \
	(cd $*; javac *.java; ); \
	if [ -f $*\_runme.java ]; then ( \
	  javac $*\_runme.java; \
	  cd $*; \
	  java -classpath .. $*\_runme;) \
	fi;

# Clean: remove testcase directories
%.clean:
	@if [ -d $* ]; then \
		rm -rf $*; \
	fi;

clean:
	@rm -f *.class
