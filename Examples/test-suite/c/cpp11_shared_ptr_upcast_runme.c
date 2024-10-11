#include "cpp11_shared_ptr_upcast_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
    {
        cpp11_shared_ptr_upcast_Derived* d;

        d = cpp11_shared_ptr_upcast_Derived_new_i(17);
        assert( cpp11_shared_ptr_upcast_base_num1((cpp11_shared_ptr_upcast_Base *)d) == -1 );
        assert( cpp11_shared_ptr_upcast_derived_num1(d) == 17 );

        cpp11_shared_ptr_upcast_Derived_delete(d);
    }

    {
        cpp11_shared_ptr_upcast_Derived2* d2;

        d2 = cpp11_shared_ptr_upcast_Derived2_new_i(289);
        assert( cpp11_shared_ptr_upcast_base2_num1((cpp11_shared_ptr_upcast_Base2 *)d2) == -1 );
        assert( cpp11_shared_ptr_upcast_derived2_num1(d2) == 289 );

        cpp11_shared_ptr_upcast_Derived2_delete(d2);
    }

    return 0;
}
