#include "cpp_basic/cpp_basic_wrap.h"
#include <assert.h>
#include <stdio.h>

int main(int argc, const char *argv[]) {
	cpp_basic_Foo *f = cpp_basic_Foo_new(5);

	// test global static variables
	// TODO: Implement or document as not available
	/*
	assert(init_ref != 0);

	global_fptr_set(f);
	assert(cpp_basic_Foo_num_get(global_fptr_get()) == 5);

	assert(cpp_basic_Foo_num_get(global_fref_get()) == -4);
	cpp_basic_Foo_num_set(f, 6);
	global_fref_set(f);
	assert(cpp_basic_Foo_num_get(global_fref_get()) == 6);

	cpp_basic_Foo_num_set(f, 7);
	global_fval_set(f);
	assert(cpp_basic_Foo_num_get(global_fval_get()) == 7);
	*/

	cpp_basic_Foo_num_set(f, 5);
	assert(cpp_basic_Foo_num_get(f) == 5);
	assert(cpp_basic_Foo_func1(f, 2) == 20);
	assert(cpp_basic_Foo_func2(f, 2) == -10);

	// function pointer set/get tests are missing
	// because of unclear implementation details
	//foo_func_ptr_set(f, &cpp_basic_Foo_func1);

	// test of global static variable is missing
	// because of unclear implementation details
	//assert(c_init_ref != 0);

	cpp_basic_Bar *b = cpp_basic_Bar_new();

	// check default value set by constructor
	assert(cpp_basic_Bar_cint_get(b) == 3);

	// check default value set by cpp_basic_Bar initializer
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_fval_get(b)) == 15);
	// change, recheck
	cpp_basic_Foo_num_set(cpp_basic_Bar_fval_get(b), 2);
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_fval_get(b)) == 2);

	// check references
	assert(cpp_basic_Bar_fref_get(b) != 0);

	// check global static value and references
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_fref_get(b)) == -4);
	cpp_basic_Foo_num_set(cpp_basic_Bar_fref_get(b), 1);
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_fref_get(b)) == 1);
	// create new cpp_basic_Bar instance and check static member value
	cpp_basic_Bar *b2 = cpp_basic_Bar_new();
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_fref_get(b2)) == 1);
	cpp_basic_Bar_delete(b2);
	b2 = 0;

	// Try to set a pointer
	cpp_basic_Bar_fptr_set(b, f);

	assert(cpp_basic_Bar_test(b, 2, f) == 9);
	assert(cpp_basic_Bar_test(b, 2, 0) == 4);

	cpp_basic_Foo *f2 = cpp_basic_Bar_testFoo(b, 2, f);
	assert(cpp_basic_Foo_num_get(f2) == 11);
	cpp_basic_Foo_delete(f2);
	f2 = 0;

	// test static variables
	cpp_basic_Bar_global_fptr_set(f);
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_global_fptr_get()) == 5);

	cpp_basic_Foo_num_set(f, 6);
	cpp_basic_Bar_global_fref_set(f);
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_global_fref_get()) == 6);

	cpp_basic_Foo_num_set(f, 7);
	cpp_basic_Bar_global_fval_set(f);
	assert(cpp_basic_Foo_num_get(cpp_basic_Bar_global_fval_get()) == 7);

	// getting, setting and calling function pointers isn't supported yet
#if 0
	SomeTypeForMemFnPtr func1 = get_func1_ptr();
	cpp_basic_Foo_func_ptr_set(f, func1);
	assert(test_func_ptr(f, 2) == 28);
	SomeTypeForMemFnPtr func2 = get_func2_ptr();
	cpp_basic_Foo_func_ptr_set(f, func2);
	assert(test_func_ptr(f, 2) == -14);
#endif

	cpp_basic_Bar_delete(b);
	cpp_basic_Foo_delete(f);

	cpp_basic_Fl_Window *w = cpp_basic_Fl_Window_new();
	// Test whether macro worked for code extension
	// and test optional function parameters
	cpp_basic_Fl_Window_show(w);
	cpp_basic_Fl_Window_show_pv(w, 0);
	cpp_basic_Fl_Window_show_pv_pv(w, 0, 0);
	cpp_basic_Fl_Window_delete(w);
	w = 0;

	return 0;
}
