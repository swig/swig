#include "li_boost_shared_ptr_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
    {
        Klass* k = Klass_new_rcstd_string("me oh my");
        assert( strcmp(Klass_getValue(k), "me oh my") == 0 );
        Klass_delete(k);
    }

    {
        Klass* k = li_boost_shared_ptr_factorycreate();
        assert( strcmp(Klass_getValue(k), "factorycreate") == 0 );
        Klass_delete(k);
    }
}
