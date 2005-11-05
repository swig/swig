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
#    c) Define srcdir, top_srcdir and top_builddir (these are the
#       equivalent to configure's variables of the same name).
#
# The variables below can be overridden after including this makefile
#######################################################################

#######################################################################
# Variables
#######################################################################
SWIG       = $(top_builddir)preinst-swig
SWIG_LIB   = $(top_srcdir)/Lib
TEST_SUITE = test-suite
EXAMPLES   = Examples
CXXSRCS    = 
CSRCS      = 
TARGETPREFIX = 
TARGETSUFFIX = 
SWIGOPT    = -I$(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)/$(LANGUAGE) -I$(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)
INCLUDES   = -I$(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)/$(LANGUAGE) -I$(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)
LIBS       = -L.
LIBPREFIX  = lib

#
# Please keep test cases in alphabetical order.
# Note that any whitespace after the last entry in each list will break make
#

# Broken C++ test cases. (Can be run individually using make testcase.cpptest.)
CPP_TEST_BROKEN += \
	constants \
	cpp_broken \
	namespace_union \
	nested_comment \
	overload_complicated \
	template_default_pointer \
	template_expr


# Broken C test cases. (Can be run individually using make testcase.ctest.)
C_TEST_BROKEN += \
	tag_no_clash_with_variable


# C++ test cases. (Can be run individually using make testcase.cpptest.)
CPP_TEST_CASES += \
	abstract_access \
	abstract_inherit \
	abstract_inherit_ok \
	abstract_signature \
	abstract_typedef \
	abstract_typedef2 \
	abstract_virtual \
	access_change \
	add_link \
	aggregate \
	anonymous_bitfield \
	argout \
	array_member \
	array_typedef_memberin \
	arrayref \
	arrays_dimensionless \
	arrays_global \
	arrays_global_twodim \
	arrays_scope \
	bloody_hell \
	bools \
	casts \
	cast_operator \
	char_strings \
	class_ignore \
	class_scope_weird \
	const_const_2 \
	constant_pointers \
	constover \
	constructor_exception \
	constructor_explicit \
	constructor_value \
	contract \
	compactdefaultargs \
	conversion \
	conversion_namespace \
	conversion_ns_template \
	cplusplus_throw \
	cpp_basic \
	cpp_enum \
	cpp_namespace \
	cpp_nodefault \
	cpp_static \
	cpp_typedef \
	default_constructor \
	default_args \
	defvalue_constructor \
	derived_byvalue \
	derived_nested \
	destructor_reprotected \
	director_abstract \
	director_basic \
	director_constructor \
	director_detect \
	director_default \
	director_enum \
	director_exception \
	director_frob \
	director_finalizer \
	director_nested \
	director_protected \
	director_redefined \
	director_unroll \
	director_wombat \
	disown \
	dynamic_cast \
	empty \
	enum_plus \
	enum_scope_template \
	enum_template \
	enum_thorough \
	enum_var \
	evil_diamond \
	evil_diamond_ns \
	evil_diamond_prop \
	exception_order \
	extend_default \
	extend_placement \
	extend_template \
	extend_template_ns \
	extern_namespace \
	extern_throws \
	features \
	friends \
	global_ns_arg \
	global_vars \
	grouping \
	ignore_parameter \
	import_nomodule \
	inherit \
	inherit_missing \
	inherit_same_name \
	inherit_void_arg \
	inline_initializer \
	kind \
	langobj \
	li_attribute \
	li_carrays \
	li_cdata \
	li_cpointer \
	li_typemaps \
	long_long_apply \
	member_template \
	minherit \
	mixed_types \
	multiple_inheritance \
	name_cxx \
	name_warnings \
	namespace_class \
	namespace_enum \
	namespace_extend \
	namespace_nested \
	namespace_spaces \
	namespace_template \
	namespace_typedef_class \
	namespace_typemap \
	namespace_virtual_method \
	newobject1 \
	ordering \
	operator_overload \
	overload_copy \
	overload_extend \
	overload_rename \
	overload_simple \
	overload_subtype \
	overload_template \
	pointer_reference \
	primitive_ref \
	private_assign \
        protected_rename \
	pure_virtual \
	redefined \
	refcount \
	reference_global_vars \
	register_par \
	rename_scope \
	return_const_value \
	return_value_scope \
	rname \
	sizet \
	smart_pointer_const \
	smart_pointer_const2 \
	smart_pointer_extend \
	smart_pointer_member \
	smart_pointer_multi \
	smart_pointer_multi_typedef \
	smart_pointer_namespace \
	smart_pointer_namespace2 \
	smart_pointer_not \
	smart_pointer_overload \
	smart_pointer_protected \
	smart_pointer_rename \
	smart_pointer_simple \
	smart_pointer_static \
	smart_pointer_typedef \
	static_array_member \
	static_const_member \
	static_const_member_2 \
	struct_value \
	template \
	template_array_numeric \
	template_arg_replace \
	template_arg_scope \
	template_arg_typename \
	template_base_template \
	template_classes \
	template_const_ref \
	template_construct \
	template_default \
	template_default2 \
	template_default_arg \
	template_default_inherit \
	template_default_qualify \
	template_default_vw \
	template_enum \
	template_enum_ns_inherit \
	template_enum_typedef \
	template_explicit \
	template_extend_overload \
	template_extend_overload_2 \
	template_extend1 \
	template_extend2 \
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
	template_partial_arg \
	template_qualifier \
	template_qualifier \
	template_ref_type \
	template_rename \
	template_retvalue \
	template_specialization \
	template_specialization_defarg \
	template_specialization_enum \
	template_static \
	template_tbase_template \
	template_typedef \
	template_typedef_cplx \
	template_typedef_cplx2 \
	template_typedef_cplx3 \
	template_typedef_cplx4 \
	template_typedef_cplx5 \
	template_typedef_ns \
	template_typedef_ptr \
	template_using \
	template_virtual \
	template_whitespace \
	threads \
	throw_exception \
	typedef_array_member \
	typedef_class \
	typedef_funcptr \
	typedef_inherit \
	typedef_mptr \
	typedef_reference \
	typedef_scope \
	typedef_struct \
	typemap_namespace \
	typemap_ns_using \
	typemap_numinputs \
	typemap_variables \
	typemap_various \
	typename \
	union_scope \
	using1 \
	using2 \
	using_composition \
	using_extend \
	using_inherit \
	using_namespace \
	using_pointers \
	using_private \
	using_protected \
	valuewrapper \
	valuewrapper_base \
	valuewrapper_const \
	valuewrapper_opaque \
	varargs \
	virtual_destructor \
	virtual_poly \
	voidtest \
	wrapmacro

#
# Put all the heavy STD/STL cases here, where they can be skipped if needed
#
CPP_STD_TEST_CASES += \
	director_string \
	li_std_deque \
	li_std_except \
        li_std_pair \
	li_std_string \
	li_std_vector \
	template_typedef_fnc \
	template_type_namespace \
	template_opaque \

ifndef SKIP_CPP_STD_CASES
CPP_TEST_CASES += ${CPP_STD_TEST_CASES}
endif


# C test cases. (Can be run individually using make testcase.ctest.)
C_TEST_CASES += \
	arrays \
	char_constant \
	const_const \
	empty \
	enums \
	extern_declaration \
	function_typedef \
	immutable \
	inctest \
	lextype \
	li_carrays \
	li_cdata \
	li_cmalloc \
	li_constraints \
	li_cpointer \
	li_math \
	long_long \
	name \
	nested \
	newobject2 \
	overload_extend \
	overload_extendc \
	preproc \
	ret_by_value \
	sizeof_pointer \
	sneaky1 \
	struct_rename \
	typedef_struct \
	typemap_subst \
	unions


# Multi-module C++ test cases . (Can be run individually using make testcase.multicpptest.)
MULTI_CPP_TEST_CASES += \
	clientdata_prop \
	imports \
	template_typedef_import

NOT_BROKEN_TEST_CASES =	$(CPP_TEST_CASES:=.cpptest) \
			$(C_TEST_CASES:=.ctest) \
			$(MULTI_CPP_TEST_CASES:=.multicpptest)

BROKEN_TEST_CASES = 	$(CPP_TEST_BROKEN:=.cpptest) \
			$(C_TEST_BROKEN:=.ctest)

ALL_CLEAN = 		$(CPP_TEST_CASES:=.clean) \
			$(C_TEST_CASES:=.clean) \
			$(MULTI_CPP_TEST_CASES:=.clean) \
			$(CPP_TEST_BROKEN:=.clean) \
			$(C_TEST_BROKEN:=.clean)

#######################################################################
# The following applies for all module languages
#######################################################################
all:	$(BROKEN_TEST_CASES) $(NOT_BROKEN_TEST_CASES)

check: 	$(NOT_BROKEN_TEST_CASES)

broken: $(BROKEN_TEST_CASES)

swig_and_compile_cpp =  \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile CXXSRCS="$(CXXSRCS)" \
	SWIG_LIB="$(SWIG_LIB)" SWIG="$(SWIG)" \
	INCLUDES="$(INCLUDES)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)_cpp

swig_and_compile_c =  \
	$(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile CSRCS="$(CSRCS)" \
	SWIG_LIB="$(SWIG_LIB)" SWIG="$(SWIG)" \
	INCLUDES="$(INCLUDES)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	TARGET="$(TARGETPREFIX)$*$(TARGETSUFFIX)" INTERFACE="$*.i" \
	$(LANGUAGE)$(VARIANT)

swig_and_compile_multi_cpp = \
	for f in `cat $(top_srcdir)/$(EXAMPLES)/$(TEST_SUITE)/$*.list` ; do \
	  $(MAKE) -f $(top_builddir)/$(EXAMPLES)/Makefile CXXSRCS="$(CXXSRCS)" \
	  SWIG_LIB="$(SWIG_LIB)" SWIG="$(SWIG)" LIBS='$(LIBS)' \
	  INCLUDES="$(INCLUDES)" SWIGOPT="$(SWIGOPT)" NOLINK=true \
	  TARGET="$(TARGETPREFIX)$${f}$(TARGETSUFFIX)" INTERFACE="$$f.i" \
	  $(LANGUAGE)$(VARIANT)_cpp; \
	done

swig_and_compile_runtime = \

setup = \
	if [ -f $(srcdir)/$(SCRIPTPREFIX)$*$(SCRIPTSUFFIX) ]; then	  \
	  echo "Checking testcase $* (with run test) under $(LANGUAGE)" ; \
	else								  \
	  echo "Checking testcase $* under $(LANGUAGE)" ;		  \
	fi;



#######################################################################
# Clean
#######################################################################
clean: $(ALL_CLEAN)

distclean: clean
	@rm -f Makefile

.PHONY: all check broken clean distclean 

