#include "li_std_vector/li_std_vector_wrap.h"
#include <assert.h>

void test_int_vector_c() {
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
}

void test_int_vector_cxx() {
    li_std_vector::IntVector iv;
    for ( int n = 0; n < 3; ++n )
        iv.push_back(n % 2);

    assert( iv.size() == 3 );

    int sum_modulos = 0;
    for ( auto i : iv ) {
        sum_modulos += i;
    }
    assert( sum_modulos == 1 );
}

int main() {
    test_int_vector_c();
    test_int_vector_cxx();

    return 0;
}
