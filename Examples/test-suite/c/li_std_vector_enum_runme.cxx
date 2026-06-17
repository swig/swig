#include "li_std_vector_enum/li_std_vector_enum_wrap.h"

#include <assert.h>
#include <memory>

using namespace li_std_vector_enum;

int main() {
    EnumVector ev;

    std::unique_ptr<vector_numbers> nums{ev.nums()};

    int expected = 0;
    for ( auto n : *nums ) {
        expected += 10;
        assert( n == expected );
    }

    assert( expected == 30 );
}
