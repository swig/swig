#######################################################################
# $Header$
# 
# SWIG test suite makefile.
# The test suite comprises many different test cases, which have
# typically produced bugs in the past. The aim is to have the test 
# cases compiling for every language modules. Some testcase have
# a runtime test which is written in each of the module's language.
#
# This makefile runs SWIG on the testcases, compiles the c/c++ code
# then builds the object code for use by the language.
# To complete a test in a language follow these guidelines: 
# 1) Add testcases to CPP_TEST_CASES (c++) or C_TEST_CASES (c).
# 2) If not already done, create a makefile which:
#    a) Defines LANGUAGE matching a language rule in Examples/Makefile, 
#       for example LANGUAGE = java
#    b) Define rules for %.ctest and %.cpptest and %.clean.
#
# The variables below can be overridden after including this makefile
#######################################################################

#######################################################################
# Variables
#######################################################################
TOP        = ../..
SWIG       = $(TOP)/../swig
TEST_SUITE = test-suite
CXXSRCS    = 
CSRCS      = 
TARGET     = $*
SWIGOPT    = -I$(TOP)/$(TEST_SUITE)
INCLUDE    = -I$(TOP)/$(TEST_SUITE)
INTERFACE  = $*.i

# C++ test cases. (Can be run individually using make testcase.cpptest.)
CPP_TEST_CASES = \
	constant_pointers \
	cpp_enum \
	cpp_static \
	virtual_destructor \
	cplusplus-throw \
	pointer-reference \
	casts \
	template-whitespace \
	anonymous-arg \
	static-array-member

# C test cases. (Can be run individually using make testcase.ctest.)
C_TEST_CASES   = \
	defines \
	sizeof_pointer \
	unions \
	macro-2 \
#	long-long \
	const-const \
	char-constant \
	name \
	preproc-1 

ALL_TEST_CASES = $(CPP_TEST_CASES:=.cpptest) $(C_TEST_CASES:=.ctest)
ALL_CLEAN      = $(CPP_TEST_CASES:=.clean) $(C_TEST_CASES:=.clean)

#######################################################################
# The following applies for all module languages
#######################################################################
all:	$(ALL_TEST_CASES)

check: all

swig_and_compile_cpp =  \
	$(MAKE) -f $(TOP)/Makefile CXXSRCS="$(CXXSRCS)" SWIG="$(SWIG)" \
	INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" \
	TARGET="$(TARGET)" INTERFACE="$(INTERFACE)" $(LANGUAGE)_cpp

swig_and_compile_c =  \
	$(MAKE) -f $(TOP)/Makefile CSRCS="$(CSRCS)" SWIG="$(SWIG)" \
	INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" \
	TARGET="$(TARGET)" INTERFACE="$(INTERFACE)" $(LANGUAGE)

#######################################################################
# Clean
#######################################################################
clean: $(ALL_CLEAN)

