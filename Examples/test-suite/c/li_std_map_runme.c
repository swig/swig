#include "li_std_map/li_std_map_wrap.h"
#include <assert.h>

int main() {
    A* a1 = A_new_i(3);
    A* a2 = A_new_i(7);

    mapA* mA = mapA_new();
    mapA_set(mA, 1, a1);
    mapA_set(mA, 2, a2);

    assert( mapA_size(mA) == 2 );

    {
        A* a = mapA_get(mA, 1);
        assert( A_val_get(a) == 3 );
    }

    assert( !mapA_has_key(mA, 3) );

    mapA_delete(mA);
    A_delete(a2);
    A_delete(a1);

    return 0;
}
