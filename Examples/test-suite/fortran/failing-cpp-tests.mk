
# C++11 tests: wrapper error
FAILING_CPP_TESTS += \
  cpp11_lambda_functions \
  cpp11_rvalue_reference2 \
  cpp11_rvalue_reference3 \
  cpp11_template_explicit

# C++11 tests: link error
FAILING_CPP_TESTS += \
  cpp11_default_delete

# C++11 tests: fortran error
FAILING_CPP_TESTS += \
  cpp11_strongly_typed_enumerations

# Private 'operator new' causes build error since it's not detected by the type
# traits
ifneq (,$(HAVE_CXX11_COMPILER))
FAILING_CPP_TESTS += private_assign
endif

# failed to compile fortran
FAILING_CPP_TESTS += \
  abstract_signature \
  contract \
  director_classes \
  director_default \
  director_detect \
  director_keywords \
  director_overload2 \
  enum_scope_template \
  enum_thorough \
  extend_default \
  fvirtual \
  inherit_target_language \
  li_attribute \
  li_boost_shared_ptr \
  multiple_inheritance \
  multiple_inheritance_abstract \
  multiple_inheritance_interfaces \
  multiple_inheritance_nspace \
  multiple_inheritance_shared_ptr \
  namespace_class \
  nested_scope \
  nested_workaround \
  overload_arrays \
  overload_complicated \
  overload_method \
  overload_return_type \
  overload_simple \
  overload_subtype \
  refcount \
  smart_pointer_template_defaults_overload \
  template_extend_overload \
  template_methods \
  template_typedef_inherit \
  using_composition \
  using_extend \
  using_inherit \
  variable_replacement \
  virtual_poly
