#include "cpp_enum/cpp_enum_wrap.h"
#include <assert.h>
#include <stdio.h>

int main(int argc, const char *argv[]) {

	enum cpp_enum_SOME_ENUM e = cpp_enum_ENUM_ONE, *p;

	// check the constructor's default value
	cpp_enum_StructWithEnums *s = cpp_enum_StructWithEnums_new();
	assert(cpp_enum_StructWithEnums_some_enum_get(s) == cpp_enum_ENUM_ONE);

	// check setter
	cpp_enum_StructWithEnums_some_enum_set(s, cpp_enum_ENUM_TWO);
	assert(cpp_enum_StructWithEnums_some_enum_get(s) == cpp_enum_ENUM_TWO);

	// check function call
	cpp_enum_StructWithEnums_enum_test1(s, e, &e, &e);

	// check function call
	cpp_enum_StructWithEnums_enum_test2(s, e, &e, &e);

	// check function call
	assert(cpp_enum_StructWithEnums_enum_test3(s) == cpp_enum_ENUM_ONE);

	// check function call
	assert(cpp_enum_StructWithEnums_enum_test4(s) == cpp_enum_ENUM_TWO);

	// check function call
	p = cpp_enum_StructWithEnums_enum_test5(s);
	assert(*p == cpp_enum_ENUM_TWO);

	// check function call
	p = cpp_enum_StructWithEnums_enum_test6(s);
	assert(*p == cpp_enum_ENUM_TWO);

	// check function call
	p = cpp_enum_StructWithEnums_enum_test7(s);
	assert(*p == cpp_enum_ENUM_TWO);

	// check function call
	p = cpp_enum_StructWithEnums_enum_test8(s);
	assert(*p == cpp_enum_ENUM_TWO);
	
	cpp_enum_StructWithEnums_delete(s);

	cpp_enum_Foo *f = cpp_enum_Foo_new();

	// check the constructor's default value
	assert(cpp_enum_Foo_hola_get(f) == cpp_enum_Foo_Hello);

	cpp_enum_Foo_hola_set(f, cpp_enum_Foo_Hi);
	assert(cpp_enum_Foo_hola_get(f) == cpp_enum_Foo_Hi);

	cpp_enum_Foo_delete(f);

	//check C enum
	cpp_enum_hi_set(cpp_enum_Hi);
	cpp_enum_hi_set(cpp_enum_Hello);

	// check typedef enum
	cpp_enum_play_state t;

	t = cpp_enum_PLAY;
	assert(t == 1);

	t = cpp_enum_STOP;
	assert(t == 0);

	return 0;
}
