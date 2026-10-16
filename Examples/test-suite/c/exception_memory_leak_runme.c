#include <assert.h>

#include "exception_memory_leak/exception_memory_leak_wrap.h"

int main() {
  exception_memory_leak_Foo *a = exception_memory_leak_Foo_new();
  exception_memory_leak_Foo *b = exception_memory_leak_Foo_new();
  assert(exception_memory_leak_Foo_get_count() == 2);

  exception_memory_leak_trigger_internal_swig_exception_rcstd_string_pFoo("no problem", a);
  assert(!exception_memory_leak_SWIG_CException_get_pending());
  assert(exception_memory_leak_Foo_get_count() == 2);
  assert(exception_memory_leak_Foo_get_freearg_count() == 1);

  /* The freearg typemap is run after the error raised in the out typemap */
  exception_memory_leak_trigger_internal_swig_exception_rcstd_string_pFoo("null", b);
  assert(exception_memory_leak_SWIG_CException_get_pending());
  exception_memory_leak_SWIG_CException_reset_pending();
  assert(exception_memory_leak_Foo_get_count() == 2);
  assert(exception_memory_leak_Foo_get_freearg_count() == 2);

  exception_memory_leak_trigger_internal_swig_exception_rcstd_string("null");
  assert(exception_memory_leak_SWIG_CException_get_pending());
  exception_memory_leak_SWIG_CException_reset_pending();
  assert(exception_memory_leak_Foo_get_count() == 2);

  exception_memory_leak_Foo_delete(a);
  exception_memory_leak_Foo_delete(b);
  assert(exception_memory_leak_Foo_get_count() == 0);

  return 0;
}
