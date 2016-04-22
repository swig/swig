#include <assert.h>
#include "cpp_basic_class_var_pub_member_built_in/cpp_basic_class_var_pub_member_built_in_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc = MyClass_new();

    assert(MyClass_myPubInt_get(mc) == 42);
    MyClass_myPubInt_set(mc, 4711);
    assert(MyClass_myPubInt_get(mc) == 4711);

    MyClass_delete(mc);

    return 0;
}
