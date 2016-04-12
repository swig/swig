#include "abstract_virtual/abstract_virtual_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	B *b = new_B();
	D *d = new_D();
	E *e = new_E();

	assert(B_foo(b) == 0);
	assert(D_foo(d) == 0);
	assert(E_foo(e) == 0);

	delete_B(b);
	delete_D(d);
	delete_E(e);

	return 0;
}
