#include "abstract_access/abstract_access_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	abstract_access_D *d = abstract_access_D_new();

	assert(abstract_access_D_do_x(d) == 1);

	abstract_access_D_delete(d);

	return 0;
}
