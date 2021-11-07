#include "li_std_map/li_std_map_wrap.h"
#include <assert.h>

int main() {
    li_std_map_A* a1 = li_std_map_A_new_i(3);
    li_std_map_A* a2 = li_std_map_A_new_i(7);

    li_std_map_mapA* mA = li_std_map_mapA_new();
    li_std_map_mapA_set(mA, 1, a1);
    li_std_map_mapA_set(mA, 2, a2);

    assert( li_std_map_mapA_size(mA) == 2 );

    {
        li_std_map_A* a = li_std_map_mapA_get(mA, 1);
        assert( li_std_map_A_val_get(a) == 3 );
    }

    assert( !li_std_map_mapA_has_key(mA, 3) );

    li_std_map_mapA_delete(mA);
    li_std_map_A_delete(a2);
    li_std_map_A_delete(a1);

    return 0;
}
