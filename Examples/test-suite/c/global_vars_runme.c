#include <assert.h>
#include "global_vars/global_vars_wrap.h"

int main(int argc, const char *argv[])
{
    init();

    assert(strcmp(b_get(), "string b") == 0);
    assert(x == 1234);

    return 0;
}
