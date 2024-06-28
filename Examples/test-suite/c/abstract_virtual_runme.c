#include "abstract_virtual/abstract_virtual_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	abstract_virtual_B *b = abstract_virtual_B_new();
	abstract_virtual_D *d = abstract_virtual_D_new();
	abstract_virtual_E *e = abstract_virtual_E_new();

	assert(abstract_virtual_B_foo(b) == 0);
	assert(abstract_virtual_D_foo(d) == 0);
	assert(abstract_virtual_E_foo(e) == 0);

	abstract_virtual_B_delete(b);
	abstract_virtual_D_delete(d);
	abstract_virtual_E_delete(e);

	return 0;
}
