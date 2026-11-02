#include "li_std_vector/li_std_vector_wrap.h"
#include <assert.h>

int main() {
    size_t i;
    int values[2] = {1, 2};
    const int *cp = &values[1];

    li_std_vector_IntVector* iv = li_std_vector_IntVector_new();
    assert( li_std_vector_IntVector_size(iv) == 0 );

    li_std_vector_IntVector_push_back(iv, 1);
    li_std_vector_IntVector_push_back(iv, 4);
    li_std_vector_IntVector_push_back(iv, 9);
    assert( li_std_vector_IntVector_size(iv) == 3 );

    for ( i = 0; i < 3; i++ ) {
        assert( li_std_vector_IntVector_get(iv, i) == (i + 1)*(i + 1) );
    }

    li_std_vector_IntVector_delete(iv);

    /* A const reference to a pointer to a builtin type is passed and returned as the pointer */
    {
        li_std_vector_IntPtrVector* ipv = li_std_vector_IntPtrVector_new();
        li_std_vector_IntConstPtrVector* icpv = li_std_vector_IntConstPtrVector_new();

        li_std_vector_IntPtrVector_push_back(ipv, &values[0]);
        assert( li_std_vector_IntPtrVector_get(ipv, 0) == &values[0] );
        li_std_vector_IntPtrVector_set(ipv, 0, &values[1]);
        assert( *li_std_vector_IntPtrVector_get(ipv, 0) == 2 );

        li_std_vector_IntConstPtrVector_push_back(icpv, cp);
        assert( li_std_vector_IntConstPtrVector_get(icpv, 0) == cp );
        assert( *li_std_vector_IntConstPtrVector_get(icpv, 0) == 2 );

        li_std_vector_IntConstPtrVector_delete(icpv);
        li_std_vector_IntPtrVector_delete(ipv);
    }

    return 0;
}
