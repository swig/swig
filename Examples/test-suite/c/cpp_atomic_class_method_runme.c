#include <assert.h>
#include "cpp_atomic_class_method/cpp_atomic_class_method_proxy.h"

int main(int argc, const char *argv[])
{
    MyClass *mc = new_MyClass();

    assert(MyClass_someMethod(mc) == 42);

    delete_MyClass(mc);

    return 0;
}
