#include "add_link/add_link_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	add_link_Foo *f = add_link_Foo_new();
	add_link_Foo *f2 = add_link_Foo_blah(f);

	assert(f2 != 0);

	add_link_Foo_delete(f);
	add_link_Foo_delete(f2);

	return 0;
}
