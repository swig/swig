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

    /* A volatile pointer member variable has a set function, a const volatile one does not */
    member_immutable_vars_ImmutableVars *v = member_immutable_vars_ImmutableVars_new();
    member_immutable_vars_PointerVars *p = member_immutable_vars_PointerVars_new(v);
    assert(member_immutable_vars_PointerVars_volatile_ptr_var_get(p) == v);
    assert(member_immutable_vars_ImmutableVars_const_var_get(member_immutable_vars_PointerVars_const_volatile_ptr_var_get(p)) == 42);
    member_immutable_vars_PointerVars_volatile_ptr_var_set(p, NULL);
    assert(member_immutable_vars_PointerVars_volatile_ptr_var_get(p) == NULL);
    member_immutable_vars_PointerVars_delete(p);
    member_immutable_vars_ImmutableVars_delete(v);

    return 0;
}
