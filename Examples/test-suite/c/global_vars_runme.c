#include <assert.h>
#include <string.h>
#include "global_vars/global_vars_wrap.h"

int main(int argc, const char *argv[])
{
    global_vars_init();

    assert(strcmp(global_vars_b_get(), "string b") == 0);
    assert(global_vars_x_get() == 1234);

    return 0;
}
