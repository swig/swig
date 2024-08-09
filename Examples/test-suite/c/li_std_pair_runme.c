#include "li_std_pair/li_std_pair_wrap.h"
#include <assert.h>

int main() {
    {
        li_std_pair_IntPair* intPair = li_std_pair_makeIntPair(7, 6);
        assert(li_std_pair_IntPair_first_get(intPair)==7 && li_std_pair_IntPair_second_get(intPair)==6);

        assert(li_std_pair_product1(intPair) == 42);
        assert(li_std_pair_product2(intPair) == 42);
        assert(li_std_pair_product3(intPair) == 42);

        li_std_pair_IntPair_delete(intPair);
    }

    {
        li_std_pair_IntPair* intPairPtr = li_std_pair_makeIntPairPtr(7, 6);
        assert(li_std_pair_IntPair_first_get(intPairPtr)==7 && li_std_pair_IntPair_second_get(intPairPtr)==6);

        assert(li_std_pair_product1(intPairPtr) == 42);
        assert(li_std_pair_product2(intPairPtr) == 42);
        assert(li_std_pair_product3(intPairPtr) == 42);
    }

    {
        li_std_pair_IntPair* intPairRef = li_std_pair_makeIntPairRef(7, 6);
        assert(li_std_pair_IntPair_first_get(intPairRef)==7 && li_std_pair_IntPair_second_get(intPairRef)==6);

        assert(li_std_pair_product1(intPairRef) == 42);
        assert(li_std_pair_product2(intPairRef) == 42);
        assert(li_std_pair_product3(intPairRef) == 42);
    }

    {
        li_std_pair_IntPair* intPairConstRef = li_std_pair_makeIntPairConstRef(7, 6);
        assert(li_std_pair_IntPair_first_get(intPairConstRef)==7 && li_std_pair_IntPair_second_get(intPairConstRef)==6);

        assert(li_std_pair_product1(intPairConstRef) == 42);
        assert(li_std_pair_product2(intPairConstRef) == 42);
        assert(li_std_pair_product3(intPairConstRef) == 42);
    }
}
