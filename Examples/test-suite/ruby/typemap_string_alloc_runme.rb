require 'swig_assert'
require 'typemap_string_alloc'

Typemap_string_alloc.Custom_Reset()
Typemap_string_alloc.some_text = 'one'
Typemap_string_alloc.some_text = 'two'

swig_assert_equal_simple(Typemap_string_alloc.Custom_WasAllocated(), true)
swig_assert_equal_simple(Typemap_string_alloc.Custom_WasDeallocated(), true)
