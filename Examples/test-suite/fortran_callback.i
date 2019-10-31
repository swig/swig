%module fortran_callback

// Declare callback signature
%fortrancallback("%s");
#ifdef __cplusplus
extern "C" {
#endif
int binary_op(int left, int right);
void stupid_op(int left, int right);
void stupider_op();
#ifdef __cplusplus
} // end extern
#endif
%nofortrancallback;

// Create callbacks and define functions *unless using bindc*
%callback("%s_cb");

%inline %{
#ifdef __cplusplus
extern "C" {
#endif

int add(int left, int right) { return left + right; }
int mul(int left, int right) { return left * right; }

#ifdef __cplusplus
} // end extern
#endif
%}

%nocallback;

// Declare callback signature *and* create function with wrapper
%fortrancallback("%s_cb") call_binary;

%{
#include <string.h>
#include <stdio.h>
%}

%inline %{
#ifdef __cplusplus
extern "C" {
#endif

typedef int also_an_int;

typedef int (*binary_op_cb)(int, int);
int call_binary(binary_op_cb fptr, int left, also_an_int right)
{ return (*fptr)(left, right); }

#ifdef __cplusplus
} // end extern
#endif

typedef int (*noarg_cb)(void);
int call_things(noarg_cb fptr)
{ return (*fptr)(); }

typedef void (*one_int_cb)(int);
void also_call_things(one_int_cb fptr, int val)
{ return (*fptr)(val); }

binary_op_cb get_a_callback(const char* name) {
  if (strcmp(name, "add") == 0) {
    return &add;
  } else if (strcmp(name, "mul") == 0) {
    return &mul;
  }
  // printf("Invalid callback name '%s'\n", name);
  return NULL;
}
%}

%warnfilter(SWIGWARN_TYPEMAP_UNDEF,SWIGWARN_LANG_NATIVE_UNIMPL) execute;

// Opaque callback
%{
#ifdef __cplusplus
extern "C" {
#endif
typedef struct { int i; } Foo;
#ifdef __cplusplus
}
#endif
%}

%inline %{
typedef int (*take_foo)(Foo);

void execute(take_foo fptr, Foo f) {
  (*fptr)(f);
}
%}

#ifdef __cplusplus

%warnfilter(SWIGWARN_TYPEMAP_UNDEF,SWIGWARN_LANG_NATIVE_UNIMPL) execute_bar;

%inline %{
class Bar {};

typedef int (*take_bar)(Bar);

void execute_bar(take_bar fptr, Bar b) {
  (*fptr)(b);
}
%}
#endif
