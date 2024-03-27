%module cpp11_ignore_attributes

#if defined(__has_cpp_attribute) || defined(__cpp_attrributes)
#error This test is meant to test -ignoreattrs
#endif

%include "cpp11_attribute_specifiers.i"

// This works only when ignoring the attributes
typedef [[invalid]] void* void_ptr;
