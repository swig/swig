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
SWIG_LIB   = $(TOP)/../Lib
TEST_SUITE = test-suite
CXXSRCS    = 
CSRCS      = 
TARGETPREFIX = 
TARGETSUFFIX = 
SWIGOPT    = -I$(TOP)/$(TEST_SUITE)
INCLUDES   = -I$(TOP)/$(TEST_SUITE)
RUNTIMEDIR = ../$(TOP)/Runtime/.libs
DYNAMIC_LIB_PATH = $(RUNTIMEDIR):.

# Please keep test cases in alphabetical order.
#
# EXCEPTION: PLEASE PUT BROKEN TEST CASES AT THE TOP OF THIS LIST.

# C++ test cases. (Can be run individually using make testcase.cpptest.)

CPP_TEST_BROKEN = \
	cast_operator \
	arrayref \
	abstract_typedef \
	namespace_nested \
	template_default_arg \
	template_extend_overload \
	template_extend_overload_2 \
	template_specialization_defarg \
	template_specialization_enum \
	using_namespace

CPP_TEST_CASES += $(CPP_TEST_BROKEN)

CPP_TEST_CASES += \
	abstract_inherit \
	abstract_inherit_ok \
	abstract_signature \
	add_link \
	anonymous_arg \
	argout \
	arrays_global \
	arrays_global_twodim \
	arrays_scope \
	bool_default \
	bools \
	casts \
	class_ignore \
	const_const_2 \
	constant_pointers \
	constover \
	constructor_exception \
	constructor_explicit \
	constructor_value \
	conversion \
	conversion_namespace \
	conversion_ns_template \
	cplusplus_throw \
	cpp_enum \
	cpp_enum_scope \
	cpp_enum_scope \
	cpp_namespace \
	cpp_nodefault \
	cpp_static \
	cpp_typedef \
	default_cast \
	default_constructor \
	default_ns \
	default_ref \
	dynamic_cast \
	enum_plus \
	enum_scope \
	enum_scope_template \
	enum_var \
	evil_diamond \
	evil_diamond_ns \
	evil_diamond_prop \
	explicit \
	extend_template \
	extend_template_ns \
	global_ns_arg \
	grouping \
	ignore_parameter \
	import_nomodule \
	inherit_missing \
	kind \
	lib_carrays \
	lib_cdata \
	lib_cpointer \
	lib_std_deque \
	lib_std_string \
	lib_std_vector \
	lib_typemaps \
	member_template \
	minherit \
	name_cxx \
	name_inherit \
	namespace_enum \
	namespace_extend \
	namespace_template \
	namespace_typemap \
	newobject1 \
	overload_complicated \
	overload_copy \
	overload_extend \
	overload_simple \
	overload_subtype \
	overload_template \
	pointer_reference \
	primitive_ref \
	private_assign \
	pure_virtual \
	reference_global_vars \
	rename_default \
	rename_default \
	rename_scope \
	return_value_scope \
	rname \
	smart_pointer_const \
	smart_pointer_multi \
	smart_pointer_multi_typedef \
	smart_pointer_not \
	smart_pointer_overload \
	smart_pointer_protected \
	smart_pointer_rename \
	smart_pointer_simple \
	smart_pointer_typedef \
	static_array_member \
	static_const_member \
	static_const_member_2 \
	struct_value \
	template \
	template_arg_replace \
	template_arg_scope \
	template_arg_typename \
	template_base_template \
	template_classes \
	template_const_ref \
	template_construct \
	template_default \
	template_default2 \
	template_default_inherit \
	template_default_qualify \
	template_enum \
	template_enum_ns_inherit \
	template_enum_typedef \
	template_forward \
	template_inherit \
	template_inherit_abstract \
	template_int_const \
	template_ns \
	template_ns2 \
	template_ns3 \
	template_ns4 \
	template_ns_enum \
	template_ns_enum2 \
	template_ns_inherit \
	template_ns_scope \
	template_qualifier \
	template_qualifier \
	template_rename \
	template_retvalue \
	template_specialization \
	template_static \
	template_tbase_template \
	template_type_namespace \
	template_typedef \
	template_typedef_cplx \
	template_typedef_cplx2 \
	template_typedef_cplx3 \
	template_typedef_cplx4 \
	template_virtual \
	template_whitespace \
	throw_exception \
	typedef_array_member \
	typedef_funcptr \
	typedef_inherit \
	typedef_mptr \
	typedef_reference \
	typedef_scope \
	typemap_namespace \
	typemap_ns_using \
	typename \
	union_scope \
	using1 \
	using2 \
	using_composition \
	using_extend \
	using_inherit \
	using_private \
	using_protected \
	valuewrapper_base \
	varargs \
	virtual_destructor \
	voidtest

# C test cases. (Can be run individually using make testcase.ctest.)
C_TEST_CASES += \
	arrayptr \
	arrays \
	char_constant \
	const_const \
	cpp_macro_noarg \
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
	newobject2 \
	overload_extendc \
	preproc_1 \
	preproc_2 \
	preproc_3 \
	ret_by_value \
	sizeof_pointer \
	sneaky1 \
	typemap_subst \
	unions


MULTI_CPP_TEST_CASES += \
	imports \
	template_typedef_import

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
	$(MAKE) -f $(TOP)/Makefile CXXSRCS="$(CXXSRCS)" SWIG_LIB="$(SWIG_LIB)" SWIG="$(SWIG)" \
	INCLUDES="$(INCLUDES)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_c =  \
	$(MAKE) -f $(TOP)/Makefile CSRCS="$(CSRCS)" SWIG_LIB="$(SWIG_LIB)" SWIG="$(SWIG)" \
	INCLUDES="$(INCLUDES)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)

swig_and_compile_multi_cpp = \
	for f in `cat $(TOP)/$(TEST_SUITE)/$*.list` ; do \
	  $(MAKE) -f $(TOP)/Makefile CXXSRCS="$(CXXSRCS)" SWIG_LIB="$(SWIG_LIB)" SWIG="$(SWIG)" \
	  INCLUDES="$(INCLUDES)" SWIGOPT="$(SWIGOPT)" RUNTIMEDIR="$(RUNTIMEDIR)" \
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

