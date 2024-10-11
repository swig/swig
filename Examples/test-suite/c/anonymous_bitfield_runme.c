#include "anonymous_bitfield/anonymous_bitfield_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	anonymous_bitfield_Foo *f = anonymous_bitfield_Foo_new();

	assert(f != 0);

	anonymous_bitfield_Foo_x_set(f, 1);
	assert(anonymous_bitfield_Foo_x_get(f) == 1);
	assert(anonymous_bitfield_Foo_y_get(f) == 0);

	anonymous_bitfield_Foo_y_set(f, 0);
	assert(anonymous_bitfield_Foo_x_get(f) == 1);
	assert(anonymous_bitfield_Foo_y_get(f) == 0);

	anonymous_bitfield_Foo_f_set(f, 1);
	assert(anonymous_bitfield_Foo_f_get(f) == 1);

	anonymous_bitfield_Foo_z_set(f, 1);
	assert(anonymous_bitfield_Foo_z_get(f) == 1);

	anonymous_bitfield_Foo_seq_set(f, 1);
	assert(anonymous_bitfield_Foo_seq_get(f) == 1);

	anonymous_bitfield_Foo_delete(f);

	return 0;
}
