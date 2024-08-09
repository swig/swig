#include "abstract_inherit_ok_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
    abstract_inherit_ok_Foo* const spam = (abstract_inherit_ok_Foo*)abstract_inherit_ok_Spam_new();

    assert(abstract_inherit_ok_Foo_blah(spam) == 0);

    abstract_inherit_ok_Foo_delete(spam);

    return 0;
}
