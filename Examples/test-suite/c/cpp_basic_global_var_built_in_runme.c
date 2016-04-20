#include <assert.h>
#include "cpp_basic_global_var_built_in/cpp_basic_global_var_built_in_wrap.h"

int main(int argc, const char *argv[])
{
    assert(myGlobalInt == 42);

    myGlobalInt = 4711;

    assert(myGlobalInt == 4711);

    return 0;
}
