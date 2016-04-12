#include <assert.h>
#include "cpp_basic_class_method/cpp_basic_class_method_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc = new_MyClass();

    assert(MyClass_someMethod(mc) == 42);

    delete_MyClass(mc);

    return 0;
}
