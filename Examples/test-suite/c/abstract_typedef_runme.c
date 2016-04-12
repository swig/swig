#include "abstract_typedef/abstract_typedef_wrap.h"
#include <stdbool.h>
#include <assert.h>

int main(int argc, const char *argv[]) {
	Engine *e = new_Engine();
	PerseEngine *pe = new_PersEngine();
	A *a = new_A();

	assert(A_write(e) == true);
	assert(A_write(pe) == true);

	delete_A(a);
	delete_PerseEngine(pe);
	delete_Engine(e);

	return 0;
}