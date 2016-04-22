#include <assert.h>
#include "cpp_basic_class_method/cpp_basic_class_method_wrap.h"

int main(int argc, const char *argv[])
{
    MyClass *mc = MyClass_new();

    assert(MyClass_someMethod(mc) == 42);

    MyClass_delete(mc);

    return 0;
}
