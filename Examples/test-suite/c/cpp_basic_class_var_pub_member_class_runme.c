#include <assert.h>
#include "cpp_basic_class_var_pub_member_class/cpp_basic_class_var_pub_member_class_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc;
    MySecondClass *mc2;

    mc2 = new_MySecondClass();
    mc = new_MyClass();

    assert(MySecondClass_myPubClassInstance_get(mc2));
    MySecondClass_myPubClassInstance_set(mc2, mc);
    assert(MySecondClass_myPubClassInstance_get(mc2));

    delete_MyClass(mc);
    delete_MySecondClass(mc2);

    return 0;
}
