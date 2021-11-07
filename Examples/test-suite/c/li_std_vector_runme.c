#include "li_std_vector/li_std_vector_wrap.h"
#include <assert.h>

int main() {
    size_t i;

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

    return 0;
}
