#include "anonymous_bitfield/anonymous_bitfield_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	Foo *f = new_Foo();

	assert(f != 0);

	Foo_x_set(f, 1);
	assert(Foo_x_get(f) == 1);
	assert(Foo_y_get(f) == 1);

	Foo_y_set(f, 0);
	assert(Foo_x_get(f) == 0);
	assert(Foo_y_get(f) == 0);

	Foo_f_set(f, 1);
	assert(Foo_f_get(f) == 1);

	Foo_z_set(f, 1);
	assert(Foo_z_get(f) == 1);

	Foo_seq_set(f, 1);
	assert(Foo_seq_get(f) == 1);

	delete_Foo(f);

	return 0;
}
