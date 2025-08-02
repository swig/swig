#include "abstract_typedef/abstract_typedef_wrap.h"
#include <stdbool.h>
#include <assert.h>

int main(int argc, const char *argv[]) {
	abstract_typedef_Engine *e = abstract_typedef_Engine_new();
	abstract_typedef_A *a = abstract_typedef_A_new();

	assert(abstract_typedef_AbstractBaseClass_write((abstract_typedef_AbstractBaseClass*)a, e) == true);

	abstract_typedef_A_delete(a);
	abstract_typedef_Engine_delete(e);

	return 0;
}
