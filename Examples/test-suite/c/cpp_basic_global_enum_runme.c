#include <assert.h>
#include "cpp_basic_global_enum/cpp_basic_global_enum_wrap.h"

int main(int argc, const char *argv[])
{
    enum SomeEnum myEnum = FIRST_VALUE;

    assert(myEnum != SECOND_VALUE);

    return 0;
}
