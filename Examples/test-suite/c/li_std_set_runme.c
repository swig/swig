#include "li_std_set/li_std_set_wrap.h"
#include <assert.h>

int main() {
    {
        li_std_set_IntSet* is = li_std_set_IntSet_new();

        li_std_set_IntSet_add(is, 1);
        li_std_set_IntSet_add(is, 4);
        li_std_set_IntSet_add(is, 9);

        assert( li_std_set_IntSet_size(is) == 3 );
        assert( li_std_set_IntSet_has(is, 4) );
        assert( !li_std_set_IntSet_has(is, 16) );

        li_std_set_IntSet_delete(is);
    }

    {
        li_std_set_StringSet* ss = li_std_set_StringSet_new();

        li_std_set_StringSet_add(ss, "foo");
        li_std_set_StringSet_add(ss, "bar");

        assert( li_std_set_StringSet_size(ss) == 2 );
        assert( li_std_set_StringSet_has(ss, "bar") );
        assert( !li_std_set_StringSet_has(ss, "baz") );

        li_std_set_StringSet_delete(ss);
    }

    return 0;
}
