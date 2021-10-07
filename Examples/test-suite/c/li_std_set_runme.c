#include "li_std_set/li_std_set_wrap.h"
#include <assert.h>

int main() {
    {
        IntSet* is = IntSet_new();

        IntSet_add(is, 1);
        IntSet_add(is, 4);
        IntSet_add(is, 9);

        assert( IntSet_size(is) == 3 );
        assert( IntSet_has(is, 4) );
        assert( !IntSet_has(is, 16) );

        IntSet_delete(is);
    }

    {
        StringSet* ss = StringSet_new();

        StringSet_add(ss, "foo");
        StringSet_add(ss, "bar");

        assert( StringSet_size(ss) == 2 );
        assert( StringSet_has(ss, "bar") );
        assert( !StringSet_has(ss, "baz") );

        StringSet_delete(ss);
    }

    return 0;
}
