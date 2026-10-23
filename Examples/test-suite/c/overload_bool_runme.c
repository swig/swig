#include <assert.h>
#include <string.h>
#include "overload_bool/overload_bool_wrap.h"

int main(int argc, const char *argv[])
{
    /* A const bool reference parameter is passed by value */
    assert(strcmp(overload_bool_boolfunction_ref(true), "true") == 0);
    assert(strcmp(overload_bool_boolfunction_ref(false), "false") == 0);

    return 0;
}
