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
# 1) Add testcases to CPP_TEST_CASES (c++) or C_TEST_CASES (c) or
#    MULTI_CPP_TEST_CASES (multi-module c++ tests)
# 2) If not already done, create a makefile which:
#    a) Defines LANGUAGE matching a language rule in Examples/Makefile, 
#       for example LANGUAGE = java
#    b) Define rules for %.ctest, %.cpptest, %.multicpptest and %.clean.
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
TARGETPREFIX = 
TARGETSUFFIX = 
SWIGOPT    = -I$(TOP)/$(TEST_SUITE)
INCLUDE    = -I$(TOP)/$(TEST_SUITE)
RUNTIMEDIR = ../$(TOP)/Runtime/.libs
DYNAMIC_LIB_PATH = $(RUNTIMEDIR):.

# Please keep test cases in alphabetical order.

# C++ test cases. (Can be run individually using make testcase.cpptest.)
CPP_TEST_CASES += \
	add_link \
	anonymous_arg \
	casts \
	constover \
	const_const_2 \
	constant_pointers \
	cpp_enum \
	cpp_enum_scope \
	cpp_static \
	cplusplus_throw \
	default_constructor \
	explicit \
	kind \
	minherit \
	name_cxx \
	pointer_cxx \
	pointer_reference \
	pure_virtual \
	rname \
	static_array_member \
	static_const_member \
	template \
	template_inherit \
	template_whitespace \
	typename \
	virtual_destructor \
	voidtest


# C test cases. (Can be run individually using make testcase.ctest.)
C_TEST_CASES += \
	arrayptr \
	arrays \
	char_constant \
	const_const \
	defineop \
	defines \
	enum \
	long_long \
	macro_2 \
	name \
	nested \
	preproc_1 \
	preproc_2 \
	ret_by_value \
	sizeof_pointer \
	sneaky1 \
	typemap_subst \
	unions


MULTI_CPP_TEST_CASES += \
	imports

ALL_TEST_CASES = $(CPP_TEST_CASES:=.cpptest) \
		 $(C_TEST_CASES:=.ctest) \
		 $(MULTI_CPP_TEST_CASES:=.multicpptest)
ALL_CLEAN      = $(CPP_TEST_CASES:=.clean) \
		 $(C_TEST_CASES:=.clean) \
		 $(MULTI_CPP_TEST_CASES:=.clean)

#######################################################################
# The following applies for all module languages
#######################################################################
all:	$(ALL_TEST_CASES)

check: all

swig_and_compile_cpp =  \
	$(MAKE) -f $(TOP)/Makefile CXXSRCS="$(CXXSRCS)" SWIG="$(SWIG)" \
	INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_c =  \
	$(MAKE) -f $(TOP)/Makefile CSRCS="$(CSRCS)" SWIG="$(SWIG)" \
	INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)

swig_and_compile_multi_cpp = \
	for f in `cat $(TOP)/$(TEST_SUITE)/$*.list` ; do \
	  $(MAKE) -f $(TOP)/Makefile CXXSRCS="$(CXXSRCS)" SWIG="$(SWIG)" \
	  INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" RUNTIMEDIR="$(RUNTIMEDIR)" \
	  TARGET="$(TARGETPREFIX)$${f}$(TARGETSUFFIX)" INTERFACE="$$f.i" \
	  $(LANGUAGE)$(VARIANT)_multi_cpp; \
	done

setup = \
	@if [ -f $(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then		  \
	  echo "Checking testcase $* (with run test) under $(LANGUAGE)" ; \
	else								  \
	  echo "Checking testcase $* under $(LANGUAGE)" ;		  \
	fi;



#######################################################################
# Clean
#######################################################################
clean: $(ALL_CLEAN)

