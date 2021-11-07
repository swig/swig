#include "li_boost_shared_ptr_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
    {
        li_boost_shared_ptr_Klass* k = li_boost_shared_ptr_Klass_new_rcstd_string("me oh my");
        assert( strcmp(li_boost_shared_ptr_Klass_getValue(k), "me oh my") == 0 );
        li_boost_shared_ptr_Klass_delete(k);
    }

    {
        li_boost_shared_ptr_Klass* k = li_boost_shared_ptr_factorycreate();
        assert( strcmp(li_boost_shared_ptr_Klass_getValue(k), "factorycreate") == 0 );
        li_boost_shared_ptr_Klass_delete(k);
    }
}
