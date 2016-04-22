#include "add_link/add_link_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	Foo *f = Foo_new();
	Foo *f2 = Foo_blah(f);

	assert(f2 != 0);

	Foo_delete(f);
	Foo_delete(f2);

	return 0;
}
