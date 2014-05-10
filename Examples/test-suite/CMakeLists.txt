
set ( SWIG_EXECUTABLE ${CMAKE_BINARY_DIR}/swig )

set ( CPP_TEST_CASES
        abstract_access
        abstract_inherit
        abstract_inherit_ok
        abstract_signature
        abstract_typedef
        abstract_typedef2
        abstract_virtual
        access_change
        add_link
        aggregate
        allowexcept
        allprotected
        allprotected_not
        anonymous_bitfield
        apply_signed_char
        apply_strings
        argout
        array_member
        array_typedef_memberin
        arrayref
        arrays_dimensionless
        arrays_global
        arrays_global_twodim
        arrays_scope
        autodoc
        bloody_hell
        bools
        catches
        cast_operator
        casts
        char_binary
        char_strings
        class_forward
        class_ignore
        class_scope_weird
        compactdefaultargs
        const_const_2
        constant_pointers
        constover
        constructor_copy
        constructor_exception
        constructor_explicit
        constructor_ignore
        constructor_rename
        constructor_value
        contract
        conversion
        conversion_namespace
        conversion_ns_template
        cplusplus_throw
        cpp_basic
        cpp_enum
        cpp_namespace
        cpp_nodefault
        cpp_static
        cpp_typedef
        curiously_recurring_template_pattern
        default_args
        default_arg_values
        default_constructor
        defvalue_constructor
        derived_byvalue
        derived_nested
        destructor_reprotected
        director_abstract
        director_alternating
        director_basic
        director_binary_string
        director_classes
        director_classic
        director_constructor
        director_default
        director_detect
        director_enum
        director_exception
        director_extend
        director_finalizer
        director_frob
        director_ignore
        director_keywords
        director_namespace_clash
        director_nspace
        director_nspace_director_name_collision
        director_nested
        director_overload
        director_overload2
        director_primitives
        director_protected
        director_protected_overloaded
        director_redefined
        director_smartptr
        director_thread
        director_unroll
        director_using
        director_wombat
        disown
        dynamic_cast
        empty
        enum_plus
        enum_rename
        enum_scope_template
        enum_template
        enum_thorough
        enum_var
        evil_diamond
        evil_diamond_ns
        evil_diamond_prop
        exception_order
        extend
        extend_constructor_destructor
        extend_default
        extend_placement
        extend_special_variables
        extend_template
        extend_template_ns
        extend_typedef_class
        extern_c
        extern_namespace
        extern_throws
        expressions
        features
        fragments
        friends
        funcptr_cpp
        fvirtual
        global_namespace
        global_ns_arg
        global_scope_types
        global_vars
        grouping
        ignore_parameter
        import_nomodule
        inherit
        inherit_missing
        inherit_same_name
        inherit_target_language
        inherit_void_arg
        inline_initializer
        insert_directive
        keyword_rename
        kind
        langobj
        li_attribute
        li_attribute_template
        li_boost_shared_ptr
        li_boost_shared_ptr_bits
        li_boost_shared_ptr_template
        li_boost_shared_ptr_attribute
        li_carrays
        li_cdata
        li_cpointer
        li_std_auto_ptr
        li_stdint
        li_swigtype_inout
        li_typemaps
        li_typemaps_apply
        li_windows
        long_long_apply
        memberin_extend
        member_funcptr_galore
        member_pointer
        member_template
        minherit
        minherit2
        mixed_types
        multiple_inheritance
        name_cxx
        name_warnings
        namespace_class
        namespace_enum
        namespace_extend
        namespace_forward_declaration
        namespace_nested
        namespace_spaces
        namespace_template
        namespace_typedef_class
        namespace_typemap
        namespace_union
        namespace_virtual_method
        nspace
        nspace_extend
        naturalvar
        naturalvar_more
        naturalvar_onoff
        nested_class
        nested_directors
        nested_comment
        nested_scope
        nested_workaround
        newobject1
        null_pointer
        operator_overload
        operator_overload_break
        operator_pointer_ref
        operbool
        ordering
        overload_bool
        overload_copy
        overload_extend
        overload_method
        overload_numeric
        overload_rename
        overload_return_type
        overload_simple
        overload_subtype
        overload_template
        overload_template_fast
        pointer_reference
        preproc_constants
        primitive_ref
        private_assign
        protected_rename
        pure_virtual
        redefined
        redefined_not
        refcount
        reference_global_vars
        register_par
        rename1
        rename2
        rename3
        rename4
        rename_scope
        rename_simple
        rename_strip_encoder
        rename_pcre_encoder
        rename_pcre_enum
        rename_predicates
        restrict_cplusplus
        return_const_value
        return_value_scope
        rname
        samename
        sizet
        smart_pointer_const
        smart_pointer_const2
        smart_pointer_const_overload
        smart_pointer_extend
        smart_pointer_member
        smart_pointer_multi
        smart_pointer_multi_typedef
        smart_pointer_namespace
        smart_pointer_namespace2
        smart_pointer_not
        smart_pointer_overload
        smart_pointer_protected
        smart_pointer_rename
        smart_pointer_simple
        smart_pointer_static
        smart_pointer_template_const_overload
        smart_pointer_template_defaults_overload
        smart_pointer_templatemethods
        smart_pointer_templatevariables
        smart_pointer_typedef
        special_variables
        special_variable_macros
        static_array_member
        static_const_member
        static_const_member_2
        struct_initialization_cpp
        struct_value
        symbol_clash
        template_arg_replace
        template_arg_scope
        template_arg_typename
        template_array_numeric
        template_basic
        template_base_template
        template_classes
        template_const_ref
        template_construct
        template_default
        template_default2
        template_default_arg
        template_default_arg_virtual_destructor
        template_default_class_parms
        template_default_class_parms_typedef
        template_default_inherit
        template_default_qualify
        template_default_vw
        template_enum
        template_enum_ns_inherit
        template_enum_typedef
        template_explicit
        template_extend1
        template_extend2
        template_extend_overload
        template_extend_overload_2
        template_forward
        template_inherit
        template_inherit_abstract
        template_int_const
        template_methods
        template_namespace_forward_declaration
        template_using_directive_and_declaration_forward
        template_nested
        template_nested_typemaps
        template_ns
        template_ns2
        template_ns3
        template_ns4
        template_ns_enum
        template_ns_enum2
        template_ns_inherit
        template_ns_scope
        template_partial_arg
        template_partial_specialization
        template_partial_specialization_typedef
        template_qualifier
        template_ref_type
        template_rename
        template_retvalue
        template_specialization
        template_specialization_defarg
        template_specialization_enum
        template_static
        template_tbase_template
        template_template_parameters
        template_typedef
        template_typedef_class_template
        template_typedef_cplx
        template_typedef_cplx2
        template_typedef_cplx3
        template_typedef_cplx4
        template_typedef_cplx5
        template_typedef_funcptr
        template_typedef_inherit
        template_typedef_ns
        template_typedef_ptr
        template_typedef_rec
        template_typedef_typedef
        template_typemaps
        template_typemaps_typedef
        template_typemaps_typedef2
        template_using
        template_virtual
        template_whitespace
        threads
        threads_exception
        throw_exception
        typedef_array_member
        typedef_class
        typedef_funcptr
        typedef_inherit
        typedef_mptr
        typedef_reference
        typedef_scope
        typedef_sizet
        typedef_struct
        typedef_typedef
        typemap_arrays
        typemap_array_qualifiers
        typemap_delete
        typemap_directorout
        typemap_global_scope
        typemap_manyargs
        typemap_namespace
        typemap_ns_using
        typemap_numinputs
        typemap_template
        typemap_template_parm_typedef
        typemap_out_optimal
        typemap_qualifier_strip
        typemap_variables
        typemap_various
        typename
        types_directive
        union_scope
        using1
        using2
        using_composition
        using_directive_and_declaration
        using_directive_and_declaration_forward
        using_extend
        using_inherit
        using_namespace
        using_namespace_loop
        using_pointers
        using_private
        using_protected
        valuewrapper
        valuewrapper_base
        valuewrapper_const
        valuewrapper_opaque
        varargs
        varargs_overload
        virtual_destructor
        virtual_poly
        virtual_vs_nonvirtual_base
        voidtest
        wallkw
        wrapmacro)

# TODO: remove me, for test!
# set (CPP_TEST_CASES integers aggregate abstract_access array_member bools casts varargs_overload virtual_destructor)
  
set ( LANGUAGES )

macro(test_language language extension interpreter)
  list ( APPEND LANGUAGES ${language} ${interpreter} )
  set (${language}_ext ${extension})
  set (${language}_interpreter ${interpreter})
  add_tests(${language})
endmacro()



include_directories ( ${CMAKE_CURRENT_SOURCE_DIR} )

add_custom_target ( check-test-suite )

macro(add_tests language)
  set (TEST_TARGETS)
  set (TEST_SRCS)
  foreach( testname ${CPP_TEST_CASES} )
    set (SWIG_CXX_FLAG)
    set ( SWIG_CXX_EXTENSION ".c")
    if (1)
      set (SWIG_CXX_FLAG "-c++")
      set(SWIG_CXX_EXTENSION ".cxx") 
    endif ()
    
    math(EXPR _SIZEOF_VOID_P_BITS "8 * ${CMAKE_SIZEOF_VOID_P}")
    if ( ${language} STREQUAL go )
      set ( SWIG_CXX_FLAG "-intgosize;${_SIZEOF_VOID_P_BITS};${SWIG_CXX_FLAG}" )
    endif ()
    
    if ( ${language} STREQUAL guile )
      set ( SWIG_CXX_FLAG "-Linkage;passive;${SWIG_CXX_FLAG}" )
    endif()
    
    set (SWIG_OUTPUT ${testname}${language}_wrap${SWIG_CXX_EXTENSION} )
    
    set (LANG_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/Lib/${language})
    if (${language} STREQUAL perl)
      set(LANG_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/Lib/${language}5)
    endif ()
    add_custom_command(OUTPUT ${SWIG_OUTPUT}
      COMMAND ${SWIG_EXECUTABLE} -${language} ${SWIG_CXX_FLAG}
      -I${LANG_INCLUDE_DIR} -I${CMAKE_BINARY_DIR} -I${CMAKE_SOURCE_DIR}/Lib 
      -o ${SWIG_OUTPUT}
      ${CMAKE_CURRENT_SOURCE_DIR}/../${testname}.i
      DEPENDS swig
    )
    set(name ${testname}-${language})
    
    set(SWIG_MODULE_${name}_REAL_NAME ${testname}_${language})

    add_library(${SWIG_MODULE_${name}_REAL_NAME} MODULE EXCLUDE_FROM_ALL ${SWIG_OUTPUT} )
    list (APPEND TEST_TARGETS ${SWIG_MODULE_${name}_REAL_NAME})
    
    set_target_properties(${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES LIBRARY_OUTPUT_NAME ${testname})
    set_target_properties(${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES PREFIX "")
    
    if(${language} STREQUAL guile)  
      set_target_properties (${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES PREFIX "lib")
    elseif(${language} STREQUAL java)
      set_target_properties (${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES PREFIX "lib")
      if (APPLE)
        set_target_properties (${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES SUFFIX ".jnilib")
      endif ()
    elseif (${language} STREQUAL octave)
      set_target_properties(${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES SUFFIX ".oct")
    elseif (${language} STREQUAL python)
      set_target_properties(${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES LIBRARY_OUTPUT_NAME _${testname})
      if(WIN32 AND NOT CYGWIN)
        set_target_properties(${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES SUFFIX ".pyd")
      endif()
    elseif(${language} STREQUAL ruby)
      if (APPLE)
        set_target_properties (${SWIG_MODULE_${name}_REAL_NAME} PROPERTIES SUFFIX ".bundle")
      endif ()
    endif ()  

    set ( testfile ${CMAKE_CURRENT_SOURCE_DIR}/${testname}_runme${${language}_ext} )
    if ( EXISTS ${testfile} ) 
    
      add_test(${name} "${${language}_interpreter}" ${${language}_args} ${testfile} )
      list (APPEND TEST_SRCS ${testfile} )
      if ( DEFINED ${language}_test_environment )
        set_tests_properties ( ${name} PROPERTIES ENVIRONMENT "${${language}_test_environment}" )
      endif ()
    endif ()
  endforeach()
  
  add_custom_target ( check-${language}-test-suite 
                      COMMAND ${CMAKE_CTEST_COMMAND} -R "-${language}" -j2
                      DEPENDS ${TEST_TARGETS} ${TEST_SRCS}
                    )
  add_dependencies(check-test-suite check-${language}-test-suite)
endmacro()





  
option ( USE_CSHARP "C#" OFF )
if ( USE_CSHARP )
  add_subdirectory ( csharp )
endif ()

option ( USE_D "D" OFF )
if ( USE_D )
  add_subdirectory ( d )
endif ()

option ( USE_GO "Go" OFF )
if ( USE_GO )
  add_subdirectory ( go )
endif ()

option ( USE_GUILE "Guile" ON )
if ( USE_GUILE )
  add_subdirectory ( guile )
endif ()

option ( USE_JAVA "Java" OFF )
if ( USE_JAVA )
  add_subdirectory ( java )
endif ()

option ( USE_LUA "Lua" ON )
if ( USE_LUA )
  add_subdirectory ( lua )
endif()

option ( USE_OCTAVE "Octave" ON )
if ( USE_OCTAVE )
  add_subdirectory ( octave )
endif()
    
option ( USE_PERL "Perl" ON )
if ( USE_PERL )
  add_subdirectory ( perl5 )
endif ()

option ( USE_PYTHON "Python" ON )
if ( USE_PYTHON )
  add_subdirectory ( python )
endif ()

option ( USE_R "R" OFF )
if ( USE_R )
  add_subdirectory ( r )
endif ()

option ( USE_RUBY "ruby" ON )
if ( USE_RUBY )
  add_subdirectory ( ruby )
endif ()
