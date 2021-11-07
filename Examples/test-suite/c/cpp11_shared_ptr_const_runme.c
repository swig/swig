#include "cpp11_shared_ptr_const_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
    cpp11_shared_ptr_const_Foo* f;
    cpp11_shared_ptr_const_Foo* f2;

    f = cpp11_shared_ptr_const_Foo_new(17);
    assert(cpp11_shared_ptr_const_Foo_get_m(f) == 17);
    f2 = cpp11_shared_ptr_const_foo(f);
    assert(cpp11_shared_ptr_const_Foo_get_m(f2) == 17);
    cpp11_shared_ptr_const_Foo_delete(f2);
    cpp11_shared_ptr_const_Foo_delete(f);

    return 0;
}
