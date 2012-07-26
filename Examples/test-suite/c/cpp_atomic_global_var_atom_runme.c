#include <assert.h>
#include "cpp_atomic_global_var_atom/cpp_atomic_global_var_atom_proxy.h"

int main(int argc, const char *argv[])
{
    assert(myGlobalInt == 42);

    myGlobalInt = 4711;

    assert(myGlobalInt == 4711);

    return 0;
}
