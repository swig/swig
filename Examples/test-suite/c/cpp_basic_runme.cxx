#include "cpp_basic/cpp_basic_wrap.h"
#include <assert.h>

using namespace cpp_basic;

int main(int argc, const char *argv[]) {
  Foo f(5);
  Bar b;

  // NULL is passed on and returned for a pointer to a class
  assert(b.fptr() == nullptr);
  b.fptr(&f);
  Foo *fptr = b.fptr();
  assert(fptr->num() == 5);
  delete fptr;
  b.fptr(nullptr);
  assert(b.fptr() == nullptr);

  assert(b.test(2, &f) == 22);
  assert(b.test(2, nullptr) == 17);

  Bar::global_fptr(&f);
  Foo *global_fptr = Bar::global_fptr();
  assert(global_fptr->num() == 5);
  delete global_fptr;
  Bar::global_fptr(nullptr);
  assert(Bar::global_fptr() == nullptr);
  return 0;
}
