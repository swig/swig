#include "li_boost_shared_ptr_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
    {
        li_boost_shared_ptr::Klass k("me oh my");
        assert( k.getValue() == "me oh my" );
    }

    {
        li_boost_shared_ptr::Klass k{li_boost_shared_ptr_factorycreate()};
        assert( k.getValue() == "factorycreate" );
    }
}
