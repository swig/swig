#include <assert.h>
#include "cpp_basic_class_var_pub_member_atom/cpp_basic_class_var_pub_member_atom_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc = new_MyClass();

    assert(MyClass_myPubInt_get(mc) == 42);
    MyClass_myPubInt_set(mc, 4711);
    assert(MyClass_myPubInt_get(mc) == 4711);

    delete_MyClass(mc);

    return 0;
}
