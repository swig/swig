#include "li_std_vector/li_std_vector_wrap.h"
#include <assert.h>

int main() {
    size_t i;

    IntVector* iv = IntVector_new();
    assert( IntVector_size(iv) == 0 );

    IntVector_push_back(iv, 1);
    IntVector_push_back(iv, 4);
    IntVector_push_back(iv, 9);
    assert( IntVector_size(iv) == 3 );

    for ( i = 0; i < 3; i++ ) {
        assert( IntVector_get(iv, i) == (i + 1)*(i + 1) );
    }

    IntVector_delete(iv);

    return 0;
}
