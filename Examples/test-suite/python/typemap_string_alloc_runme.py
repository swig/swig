import typemap_string_alloc

from swig_test_utils import swig_check


typemap_string_alloc.Custom_Reset()
typemap_string_alloc.cvar.some_text = "one"
typemap_string_alloc.cvar.some_text = "two"
swig_check(typemap_string_alloc.Custom_WasAllocated(), True)
swig_check(typemap_string_alloc.Custom_WasDeallocated(), True)
