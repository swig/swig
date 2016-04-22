#include "abstract_virtual/abstract_virtual_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	B *b = B_new();
	D *d = D_new();
	E *e = E_new();

	assert(B_foo(b) == 0);
	assert(D_foo(d) == 0);
	assert(E_foo(e) == 0);

	B_delete(b);
	D_delete(d);
	E_delete(e);

	return 0;
}
