#!/bin/sh -ex
NAME="$1"
EXT=cxx
BUILDDIR=$HOME/_code/_build/swig-debug/Examples/test-suite/fortran
test -f ../python/${NAME}_runme.py
test -f ../java/${NAME}_runme.java
template-gen ${NAME}.runme.f90
mv ${NAME}.runme.f90 ${NAME}_runme.f90
open $BUILDDIR/${NAME}.f90 $BUILDDIR/${NAME}_wrap.${EXT}
open ../python/${NAME}_runme.py ../java/${NAME}_runme.java ../${NAME}.i
open ${NAME}_runme.f90

# Incomplete tests written in both python and java that compile fortran:
# kwargs_feature
# li_boost_shared_ptr_bits
# li_boost_shared_ptr_director
# li_boost_shared_ptr_template
# li_carrays
# li_carrays_cpp
# li_cdata
# li_cdata_cpp
# li_std_auto_ptr
# li_std_vector
# li_std_vector_enum
# member_pointer
# member_pointer_const
# nested_template_base
# operator_overload
# overload_template
# pointer_reference
# primitive_ref
# profiletest
# rename_pcre_encoder
# ret_by_value
# smart_pointer_const_overload
# special_variable_macros
# template_class_reuse_name
# template_classes
# template_default_arg
# template_default_cache
# template_using_directive_typedef
# typedef_classforward_same_name
# typedef_funcptr
# typemap_arrays
# typemap_namespace
# typemap_out_optimal
# unions
# varargs

# Ignoring for the moment:
# constant_directive
# cpp11_li_std_array
# cpp11_ref_qualifiers
# cpp11_ref_qualifiers_rvalue_unignore
# cpp11_result_of
# cpp11_shared_ptr_overload
# cpp11_strongly_typed_enumerations
# cpp11_template_typedefs
# cpp11_thread_local
# cpp11_type_aliasing
# director_abstract
# director_basic
# director_classic
# director_enum
# director_exception
# director_frob
# director_pass_by_value
# director_protected
# director_smartptr
# director_string
# director_thread
# director_unroll
# dynamic_cast
# enum_forward
