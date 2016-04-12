#include "abstract_access/abstract_access_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	D *d = new_D();

	assert(D_do_x(d) == 1);

	delete_D(d);

	return 0;
}