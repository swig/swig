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
#
# Exception: during development, recent tests may appear at the
# top of the list since they are being used to fix bugs.


# C++ test cases. (Can be run individually using make testcase.cpptest.)
CPP_TEST_CASES += \
	conversion_ns_template \
	conversion \
	conversion_namespace \
	extend_template_ns \
	extend_template \
	rename_scope \
	valuewrapper_base \
	smart_pointer_rename \
	grouping \
	enum_scope_template \
	enum_scope \
	lib_std_deque \
	evil_diamond \
	evil_diamond_ns \
	constructor_explicit \
	lib_typemaps \
	typemap_namespace \
	ignore_parameter \
	smart_pointer_const \
	smart_pointer_overload \
	smart_pointer_multi_typedef \
	smart_pointer_typedef \
	smart_pointer_simple \
	smart_pointer_not \
	smart_pointer_multi \
	overload_extend \
	template_default2 \
	template_enum_typedef \
	template_inherit_abstract \
	template_default_qualify \
	template_enum_ns_inherit \
	template_int_const \
	return_value_scope \
	template_retvalue \
	template_ns_scope \
	constructor_exception \
	template_arg_scope \
	default_ns \
	template_ns_enum2 \
	overload_template \
	overload_copy \
	overload_simple \
	cpp_enum_scope \
	rename_default \
	template_default_inherit \
	template_virtual \
	template_ns_enum \
	template_enum \
	template_static \
	add_link \
	anonymous_arg \
	arrays_global \
	arrays_global_twodim \
	bool_default \
	casts \
	class_ignore \
	const_const_2 \
	constant_pointers \
	constover \
	constructor_value \
	cplusplus_throw \
	cpp_enum \
	cpp_enum_scope \
	cpp_namespace \
	cpp_nodefault \
	cpp_static \
	cpp_typedef \
	default_constructor \
	default_ref \
	dynamic_cast \
	explicit \
	inherit_missing \
	kind \
	lib_carrays \
	lib_cdata \
	lib_cpointer \
	lib_std_string \
	lib_std_vector \
	member_template \
	minherit \
	name_cxx \
	name_inherit \
	namespace_enum \
	namespace_extend \
	namespace_template \
	namespace_typemap \
	pointer_reference \
	primitive_ref \
	private_assign \
	pure_virtual \
	rename_default \
	rname \
	static_array_member \
	static_const_member \
	template \
	template_base_template \
	template_classes \
	template_const_ref \
	template_default \
	template_forward \
	template_inherit \
	template_ns \
	template_ns2 \
	template_ns3 \
	template_ns4 \
	template_ns_inherit \
	template_qualifier \
	template_qualifier \
	template_rename \
	template_tbase_template \
	template_whitespace \
	typedef_funcptr \
	typedef_inherit \
	typedef_mptr \
	typedef_scope \
	typename \
	virtual_destructor \
	voidtest

# C test cases. (Can be run individually using make testcase.ctest.)
C_TEST_CASES += \
	overload_extendc \
	arrayptr \
	arrays \
	char_constant \
	const_const \
	defineop \
	defines \
	enum \
	lib_carrays \
	lib_cdata \
	lib_cmalloc \
	lib_constraints \
	lib_cpointer \
	lib_math \
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
	INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_c =  \
	$(MAKE) -f $(TOP)/Makefile CSRCS="$(CSRCS)" SWIG="$(SWIG)" \
	INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)

swig_and_compile_multi_cpp = \
	for f in `cat $(TOP)/$(TEST_SUITE)/$*.list` ; do \
	  $(MAKE) -f $(TOP)/Makefile CXXSRCS="$(CXXSRCS)" SWIG="$(SWIG)" \
	  INCLUDE="$(INCLUDE)" SWIGOPT="$(SWIGOPT)" RUNTIMEDIR="$(RUNTIMEDIR)" \
	  TARGET="$(TARGETPREFIX)$${f}$(TARGETSUFFIX)" INTERFACE="$$f.i" \
	  NOLINK=true $(LANGUAGE)$(VARIANT)_multi_cpp; \
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

