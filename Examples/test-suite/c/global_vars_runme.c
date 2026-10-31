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

    global_vars_A *an = global_vars_A_new();
    global_vars_A_x_set(an, 42);
    global_vars_assign_ap(an);
    assert(global_vars_ap_get() == an);
    global_vars_avp_set(an);
    assert(global_vars_avp_get() == an);
    assert(global_vars_A_x_get(global_vars_avp_get()) == 42);
    global_vars_avp_set(NULL);
    assert(global_vars_avp_get() == NULL);
    global_vars_A_delete(an);

    global_vars_A_x_set(global_vars_a_get(), 7);
    assert(global_vars_A_x_get(global_vars_acp_get()) == 7);
    assert(global_vars_A_x_get(global_vars_acvp_get()) == 7);
    assert(global_vars_A_x_get(global_vars_acpr_get()) == 7);

    global_vars_h_set(global_vars_Hola);
    assert(*global_vars_hcp_get() == global_vars_Hola);
    assert(*global_vars_hcpr_get() == global_vars_Hola);
    global_vars_assign_hp(global_vars_hcpr_get());
    assert(global_vars_hp_get() == global_vars_hcp_get());

    return 0;
}
