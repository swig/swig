#include "li_std_pair/li_std_pair_wrap.h"
#include <assert.h>

int main() {
    {
        IntPair* intPair = makeIntPair(7, 6);
        assert(IntPair_first_get(intPair)==7 && IntPair_second_get(intPair)==6);

        assert(product1(intPair) == 42);
        assert(product2(intPair) == 42);
        assert(product3(intPair) == 42);

        IntPair_delete(intPair);
    }

    {
        IntPair* intPairPtr = makeIntPairPtr(7, 6);
        assert(IntPair_first_get(intPairPtr)==7 && IntPair_second_get(intPairPtr)==6);

        assert(product1(intPairPtr) == 42);
        assert(product2(intPairPtr) == 42);
        assert(product3(intPairPtr) == 42);
    }

    {
        IntPair* intPairRef = makeIntPairRef(7, 6);
        assert(IntPair_first_get(intPairRef)==7 && IntPair_second_get(intPairRef)==6);

        assert(product1(intPairRef) == 42);
        assert(product2(intPairRef) == 42);
        assert(product3(intPairRef) == 42);
    }

    {
        IntPair* intPairConstRef = makeIntPairConstRef(7, 6);
        assert(IntPair_first_get(intPairConstRef)==7 && IntPair_second_get(intPairConstRef)==6);

        assert(product1(intPairConstRef) == 42);
        assert(product2(intPairConstRef) == 42);
        assert(product3(intPairConstRef) == 42);
    }
}
