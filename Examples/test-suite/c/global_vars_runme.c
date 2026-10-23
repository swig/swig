#include <assert.h>
#include <string.h>
#include "global_vars/global_vars_wrap.h"

int main(int argc, const char *argv[])
{
    global_vars_init();

    assert(strcmp(global_vars_b_get(), "string b") == 0);
    assert(global_vars_x_get() == 1234);

    int value = 5678;
    global_vars_c_member_set(&value);
    assert(global_vars_x_get() == 5678);

    /* A reference cannot be NULL */
    global_vars_c_member_set(NULL);
    assert(global_vars_SWIG_CException_get_pending());
    global_vars_SWIG_CException_reset_pending();
    global_vars_hr_set(NULL);
    assert(global_vars_SWIG_CException_get_pending());
    global_vars_SWIG_CException_reset_pending();
    global_vars_ar_set(NULL);
    assert(global_vars_SWIG_CException_get_pending());
    global_vars_SWIG_CException_reset_pending();
    assert(global_vars_x_get() == 5678);

    return 0;
}
