#include "abstract_access/abstract_access_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	D *d = D_new();

	assert(D_do_x(d) == 1);

	D_delete(d);

	return 0;
}
