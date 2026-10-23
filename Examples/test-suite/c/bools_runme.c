#include "bools/bools_wrap.h"
#include <assert.h>

int main() {
    // bool constant
    assert(constbool == false);

    // bool variables
    assert(bools_bool1_get() == true);
    assert(bools_bool2_get() == false);
    assert(bools_value(bools_pbool_get()) == bools_bool1_get());
    assert(bools_value(bools_rbool_get()) == bools_bool2_get());
    assert(bools_value(bools_const_pbool_get()) == bools_bool1_get());
    assert(bools_const_rbool_get() == bools_bool2_get());

    // bool functions
    assert(bools_bo(false) == false);
    assert(bools_bo(true) == true);
    assert(bools_value(bools_rbo(bools_rbool_get())) == bools_bool2_get());
    assert(bools_value(bools_pbo(bools_pbool_get())) == bools_bool1_get());
    assert(bools_const_rbo(false) == false);
    assert(bools_const_rbo(true) == true);
    assert(bools_value(bools_const_pbo(bools_const_pbool_get())) == bools_bool1_get());
    assert(bools_bo_const_ref(false) == false);
    assert(bools_bo_const_ref(true) == true);

    return 0;
}
