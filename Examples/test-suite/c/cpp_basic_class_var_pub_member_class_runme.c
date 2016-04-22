#include <assert.h>
#include "cpp_basic_class_var_pub_member_class/cpp_basic_class_var_pub_member_class_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc;
    MySecondClass *mc2;

    mc2 = MySecondClass_new();
    mc = MyClass_new();

    assert(MySecondClass_myPubClassInstance_get(mc2));
    MySecondClass_myPubClassInstance_set(mc2, mc);
    assert(MySecondClass_myPubClassInstance_get(mc2));

    MyClass_delete(mc);
    MySecondClass_delete(mc2);

    return 0;
}
