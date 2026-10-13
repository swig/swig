#include <assert.h>
#include "member_immutable_vars/member_immutable_vars_wrap.h"

int main(int argc, const char *argv[])
{
    /* A derived class has a set function only for an inherited mutable member variable */
    member_immutable_vars_DerivedImmutableVars *d = member_immutable_vars_DerivedImmutableVars_new();
    member_immutable_vars_DerivedImmutableVars_mutable_var_set(d, 84);
    assert(member_immutable_vars_DerivedImmutableVars_mutable_var_get(d) == 84);
    assert(member_immutable_vars_DerivedImmutableVars_specific_immutable_var_get(d) == 41);
    assert(member_immutable_vars_DerivedImmutableVars_const_var_get(d) == 42);
    member_immutable_vars_DerivedImmutableVars_delete(d);

    return 0;
}
