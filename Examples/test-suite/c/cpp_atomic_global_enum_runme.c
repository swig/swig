#include <assert.h>
#include "cpp_atomic_global_enum/cpp_atomic_global_enum_proxy.h"

int main(int argc, const char *argv[])
{
    enum SomeEnum myEnum = FIRST_VALUE;

    assert(myEnum != SECOND_VALUE);

    return 0;
}
