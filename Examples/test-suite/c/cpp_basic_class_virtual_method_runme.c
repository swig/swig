#include <assert.h>
#include "cpp_basic_class_virtual_method/cpp_basic_class_virtual_method_wrap.h"

int main()
{
    BaseClass *bc = BaseClass_new();
    NonMethodOverwritingClass *noc = NonMethodOverwritingClass_new();
    MethodOverwritingClass *oc = MethodOverwritingClass_new();
    BaseClass *inherited_bc = (BaseClass*)MethodOverwritingClass_new();

    assert(BaseClass_myInt(bc) == 0xba53);
    assert(NonMethodOverwritingClass_myInt(noc) == 0xba53);
    assert(MethodOverwritingClass_myInt(oc) == 0xa173123d);
    assert(BaseClass_myInt((BaseClass*)noc) == 0xba53);
    assert(BaseClass_myInt((BaseClass*)oc) == 0xa173123d);
    assert(BaseClass_myInt(inherited_bc) == 0xa173123d);
    
    BaseClass_delete(bc);
    NonMethodOverwritingClass_delete(noc);
    MethodOverwritingClass_delete(oc);
    BaseClass_delete(inherited_bc);
    
    return 0;
}
