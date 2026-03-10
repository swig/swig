#######################################################################
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
#    c) Define srcdir, top_srcdir and top_builddir (these are the
#       equivalent to configure's variables of the same name).
# 3) One off special commandline options for a testcase can be added.
#    See custom tests below.
#
# The 'check' target runs the testcases including SWIG invocation,
# C/C++ compilation, target language compilation (if any) and runtime
# test (if there is an associated 'runme' test).
# The 'partialcheck' target only invokes SWIG.
# The 'all' target is the same as the 'check' target but also includes
# known broken testcases.
# The 'clean' target cleans up.
#
# Note that the RUNTOOL, COMPILETOOL and SWIGTOOL variables can be used
# for invoking tools for the runtime tests and target language 
# compiler (eg javac), and on SWIG respectively. For example, valgrind
# can be used for memory checking of the runtime tests using:
#   make RUNTOOL="valgrind --leak-check=full"
# and valgrind can be used when invoking SWIG using:
#   make SWIGTOOL="valgrind --tool=memcheck"
#
# An individual test run can be debugged easily:
#   make director_string.cpptest RUNTOOL="gdb --args"
#
# The variables below can be overridden after including this makefile
#######################################################################

#######################################################################
# Variables
#######################################################################

ifneq (,$(USE_VALGRIND))
VALGRIND_OPT = --leak-check=full
RUNTOOL    = valgrind $(VALGRIND_OPT)
else
RUNTOOL    =
endif
COMPILETOOL=
SWIGTOOL   =

SWIGEXE   = $(top_builddir)/swig
SWIG_LIB_DIR = $(top_srcdir)/Lib
TEST_SUITE = test-suite
EXAMPLES   = Examples
CXXSRCS    = 
CSRCS      = 
TARGETPREFIX = 
TARGETSUFFIX = 
SWIGOPT    = -outcurrentdir -I$(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)
INCLUDES   = -I$(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)
LIBS       = -L.
LIBPREFIX  = lib
ACTION     = check
INTERFACEDIR = ../
SRCDIR     = $(srcdir)/
SCRIPTDIR  = $(srcdir)

# This can be set to ":" on make command line to suppress progress messages.
ECHO_PROGRESS := echo

# Portable dos2unix / fromdos for stripping CR
FROMDOS    = tr -d '\r'

# Regenerate Makefile if Makefile.in or config.status have changed.
Makefile: $(srcdir)/Makefile.in ../../../config.status
	cd ../../../ && $(SHELL) ./config.status $(EXAMPLES)/$(TEST_SUITE)/$(LANGUAGE)/Makefile

#
# Please keep test cases in alphabetical order.
# Note that any whitespace after the last entry in each list will break make
#

# Broken C++ test cases. (Can be run individually using: make testcase.cpptest)
CPP_TEST_BROKEN += \
	constants \
	director_nested_class \
	exception_partial_info \
	extend_variable \
	li_boost_shared_ptr_template \
	nested_private \
	template_default_pointer \
	$(CPP11_TEST_BROKEN) \
	$(CPP14_TEST_BROKEN) \
	$(CPP17_TEST_BROKEN) \
	$(CPP20_TEST_BROKEN)


# Broken C test cases. (Can be run individually using: make testcase.ctest)
C_TEST_BROKEN += \
	tag_no_clash_with_variable \

# C++ test cases. (Can be run individually using: make testcase.cpptest)
CPP_TEST_CASES += \
	base \

# C++11 test cases.
CPP11_TEST_CASES += \

# Broken C++11 test cases.
CPP11_TEST_BROKEN = \
#	cpp11_reference_wrapper \     # No typemaps

# C++14 test cases.
CPP14_TEST_CASES += \

# Broken C++14 test cases.
CPP14_TEST_BROKEN = \

# C++17 test cases.
CPP17_TEST_CASES += \

# Broken C++17 test cases.
CPP17_TEST_BROKEN = \

# C++20 test cases.
CPP20_TEST_CASES += \

# Broken C++20 test cases.
CPP20_TEST_BROKEN = \

# Doxygen support test cases: can only be used with languages supporting
# Doxygen comment translation (currently a subset of languages) and only if not
# disabled by configure via SKIP_DOXYGEN_TEST_CASES.
ifneq ($(SKIP_DOXYGEN_TEST_CASES),1)
csharp_HAS_DOXYGEN := 1
java_HAS_DOXYGEN := 1
python_HAS_DOXYGEN := 1

HAS_DOXYGEN := $($(LANGUAGE)_HAS_DOXYGEN)
endif

ifdef HAS_DOXYGEN
DOXYGEN_TEST_CASES += \

$(DOXYGEN_TEST_CASES:=.cpptest): SWIGOPT += -doxygen

CPP_TEST_CASES += $(DOXYGEN_TEST_CASES)
endif

#
# Put all the heavy STD/STL cases here, where they can be skipped if needed
#
CPP_STD_TEST_CASES += \

ifndef SKIP_CPP_STD_CASES
CPP_TEST_CASES += ${CPP_STD_TEST_CASES}
endif

ifeq (1,$(HAVE_CXX11))
CPP_TEST_CASES += $(CPP11_TEST_CASES)
endif

ifeq (1,$(HAVE_CXX14))
CPP_TEST_CASES += $(CPP14_TEST_CASES)
endif

ifeq (1,$(HAVE_CXX17))
CPP_TEST_CASES += $(CPP17_TEST_CASES)
endif

ifeq (1,$(HAVE_CXX20))
CPP_TEST_CASES += $(CPP20_TEST_CASES)
endif

# C test cases. (Can be run individually using: make testcase.ctest)
C_TEST_CASES += \


# Multi-module C++ test cases . (Can be run individually using make testcase.multicpptest)
MULTI_CPP_TEST_CASES += \

# Custom tests - tests with additional commandline options
wallkw.cpptest: SWIGOPT += -Wallkw
preproc_include.ctest: SWIGOPT += -includeall
command_line_define.ctest: SWIGOPT += -DFOO -DBAR=123 -DBAZ -UBAZ -UNOTSET
preproc_predefined_stdc.ctest: SWIGOPT += -std=c23
preproc_predefined_stdcpp.cpptest: SWIGOPT += -std=c++23

# Allow modules to define temporarily failing tests.
C_TEST_CASES := $(filter-out $(FAILING_C_TESTS),$(C_TEST_CASES))
CPP_TEST_CASES := $(filter-out $(FAILING_CPP_TESTS),$(CPP_TEST_CASES))
CPP11_TEST_CASES := $(filter-out $(FAILING_CPP_TESTS),$(CPP11_TEST_CASES))
CPP14_TEST_CASES := $(filter-out $(FAILING_CPP_TESTS),$(CPP14_TEST_CASES))
CPP17_TEST_CASES := $(filter-out $(FAILING_CPP_TESTS),$(CPP17_TEST_CASES))
CPP20_TEST_CASES := $(filter-out $(FAILING_CPP_TESTS),$(CPP20_TEST_CASES))
MULTI_CPP_TEST_CASES := $(filter-out $(FAILING_MULTI_CPP_TESTS),$(MULTI_CPP_TEST_CASES))


NOT_BROKEN_TEST_CASES =	$(CPP_TEST_CASES:=.cpptest) \
			$(C_TEST_CASES:=.ctest) \
			$(MULTI_CPP_TEST_CASES:=.multicpptest) \
			$(EXTRA_TEST_CASES)

BROKEN_TEST_CASES = 	$(CPP_TEST_BROKEN:=.cpptest) \
			$(C_TEST_BROKEN:=.ctest)

ALL_CLEAN = 		$(CPP_TEST_CASES:=.clean) \
			$(CPP11_TEST_CASES:=.clean) \
			$(CPP14_TEST_CASES:=.clean) \
			$(CPP17_TEST_CASES:=.clean) \
			$(CPP20_TEST_CASES:=.clean) \
			$(C_TEST_CASES:=.clean) \
			$(MULTI_CPP_TEST_CASES:=.clean) \
			$(CPP_TEST_BROKEN:=.clean) \
			$(C_TEST_BROKEN:=.clean)

#######################################################################
# Error test suite has its own set of test cases
#######################################################################
ifneq (,$(ERROR_TEST_CASES))
check: $(ERROR_TEST_CASES)
else

#######################################################################
# The following applies for all module languages
#######################################################################
all: $(NOT_BROKEN_TEST_CASES) $(BROKEN_TEST_CASES)

broken: $(BROKEN_TEST_CASES)

check: $(NOT_BROKEN_TEST_CASES)
	@echo $(words $^) $(LANGUAGE) tests passed

check-c: $(C_TEST_CASES:=.ctest)

check-cpp: $(CPP_TEST_CASES:=.cpptest)

check-cpp11: $(CPP11_TEST_CASES:=.cpptest)

check-cpp14: $(CPP14_TEST_CASES:=.cpptest)

check-cpp17: $(CPP17_TEST_CASES:=.cpptest)

check-cpp20: $(CPP20_TEST_CASES:=.cpptest)

check-multicpp: $(MULTI_CPP_TEST_CASES:=.multicpptest)

ifdef HAS_DOXYGEN
check-doxygen: $(DOXYGEN_TEST_CASES:=.cpptest)
endif

check-failing-test = \
	$(MAKE) -s $1.$2 >/dev/null 2>/dev/null && echo "Failing test $1 passed."

check-failing:
	+-$(foreach t,$(FAILING_C_TESTS),$(call check-failing-test,$t,ctest);)
	+-$(foreach t,$(FAILING_CPP_TESTS),$(call check-failing-test,$t,cpptest);)
	+-$(foreach t,$(FAILING_MULTI_CPP_TESTS),$(call check-failing-test,$t,multicpptest);)
endif

# partialcheck target runs SWIG only, ie no compilation or running of tests (for a subset of languages)
partialcheck:
	$(MAKE) check CC=true CXX=true LDSHARED=true CXXSHARED=true RUNTOOL=true COMPILETOOL=true

swig_and_compile_cpp_helper = \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	LIBS='$(LIBS)' INCLUDES='$(INCLUDES)' SWIGOPT=$(2) NOLINK=true \
	TARGET="$(TARGETPREFIX)$(1)$(TARGETSUFFIX)" INTERFACEDIR='$(INTERFACEDIR)' INTERFACE="$(1).i" \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_cpp =  \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	INCLUDES='$(INCLUDES)' SWIGOPT='$(SWIGOPT)' NOLINK=true \
	TARGET='$(TARGETPREFIX)$*$(TARGETSUFFIX)' INTERFACEDIR='$(INTERFACEDIR)' INTERFACE='$*.i' \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_c =  \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile SRCDIR='$(SRCDIR)' CSRCS='$(CSRCS)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	INCLUDES='$(INCLUDES)' SWIGOPT='$(SWIGOPT)' NOLINK=true \
	TARGET='$(TARGETPREFIX)$*$(TARGETSUFFIX)' INTERFACEDIR='$(INTERFACEDIR)' INTERFACE='$*.i' \
	$(LANGUAGE)$(VARIANT)

swig_and_compile_multi_cpp = \
	for f in `cat $(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)/$*.list | $(FROMDOS)` ; do \
	  $(call swig_and_compile_cpp_helper,$${f},'$(SWIGOPT)'); \
	done

swig_and_compile_external =  \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile SRCDIR='$(SRCDIR)' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	TARGET='$*_wrap_hdr.h' \
	$(LANGUAGE)$(VARIANT)_externalhdr && \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(CXXSRCS) $*_external.cxx' \
	SWIG_LIB_DIR='$(SWIG_LIB_DIR)' SWIGEXE='$(SWIGEXE)' \
	INCLUDES='$(INCLUDES)' SWIGOPT='$(SWIGOPT)' NOLINK=true \
	TARGET='$(TARGETPREFIX)$*$(TARGETSUFFIX)' INTERFACEDIR='$(INTERFACEDIR)' INTERFACE='$*.i' \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_runtime = \

setup = \
	if [ -f $(SCRIPTDIR)/$(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then	  \
	  $(ECHO_PROGRESS) "$(ACTION)ing $(LANGUAGE) testcase $* (with run test)" ; \
	else								  \
	  $(ECHO_PROGRESS) "$(ACTION)ing $(LANGUAGE) testcase $*" ;		  \
	fi

#######################################################################
# Clean
#######################################################################
clean: $(ALL_CLEAN)

distclean: clean
	@rm -f Makefile

.PHONY: all check partialcheck broken clean distclean 

