%module fortran_bindc

%rename(RenamedOtherStruct) OtherStruct;

// Treat the struct as a native fortran struct rather than as a class with
// getters/setters.
%fortran_struct(OtherStruct);
%fortran_struct(SimpleStruct);
%fortranbindc set_val;
%fortranbindc set_ptr;
%fortranbindc get_ptr_arg;
%fortranbindc get_ptr;
%fortranbindc get_val;
%fortranbindc get_cptr;
%fortranbindc get_handle;

%fortranbindc sum_array;

// Bind some global variables
%fortranbindc my_global_int;
%fortranbindc my_const_global_int;

%inline %{

typedef double (*BinaryOp)(double x, double y);

#ifdef __cplusplus
struct Foo;
extern "C" {
#endif

typedef struct {
  int j;
  int k;
} OtherStruct;

typedef struct {
  int i;
  double d;
  char c;
  BinaryOp funptr;
  void* v;
  const char* s;
  OtherStruct o;
  float p[3];
  /* Foo f // uncommenting will produce an error in Fortran since 'Foo' is a
   class and not POD */
} SimpleStruct;
%}

%{
  static SimpleStruct global_struct = {0,0,0,0,0,0,{0,0},{0,0,0}};
  static SimpleStruct* global_struct_ptr = 0;
  static SimpleStruct const* global_struct_const_ptr = 0;
%}

%inline %{

#ifdef __cplusplus
} // end extern

void set_ref(const SimpleStruct& s) {global_struct = s; }
void get_ref_arg(SimpleStruct& s) { s = global_struct; }
SimpleStruct& get_ref() { return global_struct; }
const SimpleStruct& get_cref() { return global_struct; }

SimpleStruct * &get_ref_ptr() { return global_struct_ptr; }
SimpleStruct const* & get_cref_ptr() { return global_struct_const_ptr; }

void set_val_cpp(SimpleStruct s) { global_struct = s; }

extern "C" {
#endif

void set_val(SimpleStruct s) { global_struct = s; }
void set_ptr(const SimpleStruct* s) { global_struct = *s; }
void get_ptr_arg(SimpleStruct* s) { *s = global_struct; }
SimpleStruct get_val() { return global_struct; }
SimpleStruct* get_ptr() { return &global_struct; }
const SimpleStruct* get_cptr() { return &global_struct; }
SimpleStruct** get_handle() { return &global_struct_ptr; }
SimpleStruct const** get_chandle() { return &global_struct_const_ptr; }

int my_global_int;
extern const int my_const_global_int;

int get_my_global_int_from_c() { return my_global_int; }

#ifdef __cplusplus
}
#endif
%}

%{
#ifdef __cplusplus
extern "C" const int my_const_global_int = 9;
#endif
%}

%fortranconst is_cplusplus;
#ifdef __cplusplus
%constant int is_cplusplus = 1;
#else
%constant int is_cplusplus = 0;
#endif

%fortran_struct(AB);
%fortran_struct(XY);

%include <carrays.i>

%array_functions(int,intArray);
%array_class(double, doubleArray);
%array_class(short, shortArray);

%inline %{
typedef struct {
  int x;
  int y;
} XY;
XY globalXYArray[3];

typedef struct {
  int a;
  int b;
} AB;

AB globalABArray[3];
%}

%array_class(XY, XYArray)
%array_functions(AB, ABArray)

%inline %{
#ifdef __cplusplus
extern "C" {
#endif
short sum_array(short x[5]) {
  short sum = 0;
  int i;
  for (i=0; i<5; i++) {
    sum = sum + x[i];
  }
  return sum;
}
#ifdef __cplusplus
}
#endif
%}

%fortranbindc oned_unknown;
%fortranbindc twod_unknown_int;
%fortranbindc saxpy;
%fortranbindc make_intstruct;
%fortranbindc get_instruct_i;

%inline %{
#ifdef __cplusplus
extern "C" {
#endif
/* The "bindc" typemap will be used on these for Fortran */
void oned_unknown(int a[]) { a[0] = 0; }
void twod_unknown_int(int a[][10], int nj) {
    int i, j;
    for (j = 0; j < nj; ++j) {
        for (i = 0; i < 10; ++i) {
            a[j][i] = 10 * j + i + 1;
        }
    }
}

void saxpy(int n, float sa, const float* sx, float* sy) {
  int i;
  for (i = 0; i < n; ++i)
    sy[i] += sa * sx[i];
}

// Opaque C struct and c-bound functions
struct IntStruct_;
typedef struct IntStruct_ IntStruct;
IntStruct* make_intstruct(const int *value);
int get_instruct_i(IntStruct* s);

#ifdef __cplusplus
}
#endif
%}

%{
struct IntStruct_ {
  int i;
};

IntStruct* make_intstruct(const int *value) {
  static IntStruct foo;
  foo.i = *value;
  return &foo;
}
int get_instruct_i(IntStruct* s) {
  return s->i;
}
%}

// Character strings
%{
#include <string.h>
%}

%fortranbindc strlen;
%fortranbindc getstr;

#ifdef __cplusplus
extern "C" {
#endif
int strlen(const char *s);
#ifdef __cplusplus
}
#endif

%inline %{
#ifdef __cplusplus
extern "C" {
#endif
const char* getstr(int choice) {
  switch(choice) {
    case 0: return "zero";
    case 1: return "one";
    case 2: return "two";
  }
  return "unknown";
}
#ifdef __cplusplus
}
#endif
%}

