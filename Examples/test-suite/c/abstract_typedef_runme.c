#include "abstract_typedef/abstract_typedef_wrap.h"
#include <stdbool.h>
#include <assert.h>

int main(int argc, const char *argv[]) {
	Engine *e = new_Engine();
	A *a = new_A();

	assert(AbstractBaseClass_write(a, e) == true);

	delete_A(a);
	delete_Engine(e);

	return 0;
}
