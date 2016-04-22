#include "abstract_typedef/abstract_typedef_wrap.h"
#include <stdbool.h>
#include <assert.h>

int main(int argc, const char *argv[]) {
	Engine *e = Engine_new();
	A *a = A_new();

	assert(AbstractBaseClass_write(a, e) == true);

	A_delete(a);
	Engine_delete(e);

	return 0;
}
