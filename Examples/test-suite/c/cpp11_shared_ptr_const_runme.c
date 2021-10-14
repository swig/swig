#include "cpp11_shared_ptr_const_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
    Foo* f;
    Foo* f2;

    f = Foo_new(17);
    assert(Foo_get_m(f) == 17);
    f2 = cpp11_shared_ptr_const_foo(f);
    assert(Foo_get_m(f2) == 17);
    Foo_delete(f2);
    Foo_delete(f);

    return 0;
}
