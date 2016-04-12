#include <assert.h>
#include "cpp_basic_class_enum/cpp_basic_class_enum_wrap.h"

int main(int argc, const char *argv[])
{
    enum MyClass_SomeEnum myEnum = MyClass_FIRST_VALUE;

    assert(myEnum != MyClass_SECOND_VALUE);

    return 0;
}
