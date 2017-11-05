%module pod_struct

%rename(RenamedOtherStruct) OtherStruct;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK) SimpleStruct::s; /* Setting a const char * variable may leak memory. */

#ifdef SWIGFORTRAN
// Treat the struct as a native fortran struct rather than as a class with
// getters/setters.
%fortran_bindc_struct(OtherStruct);
%fortran_bindc_struct(SimpleStruct);
%bindc set_val;
%bindc set_ptr;
%bindc get_ptr_arg;
%bindc get_ptr;
%bindc get_val;
%bindc get_cptr;
%bindc get_handle;
#endif


%inline %{

typedef double (*BinaryOp)(double x, double y);

#ifdef __cplusplus
struct Foo;
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
    // Foo f // uncommenting will produce an error in Fortran since 'Foo' is a
             // class and not POD
} SimpleStruct;
%}

%{
static SimpleStruct global_struct = {0,0,0,0,0,0,{0,0},{0,0,0}};
static SimpleStruct* global_struct_ptr = 0;
%}

%inline %{

#ifdef __cplusplus
void set_ref(const SimpleStruct& s) {global_struct = s; }
void get_ref_arg(SimpleStruct& s) { s = global_struct; }
SimpleStruct& get_ref() { return global_struct; }
const SimpleStruct& get_cref() { return global_struct; }

extern "C" {
#endif

void set_val(SimpleStruct s) { global_struct = s; }
void set_ptr(const SimpleStruct* s) { global_struct = *s; }
void get_ptr_arg(SimpleStruct* s) { *s = global_struct; }
SimpleStruct get_val() { return global_struct; }
SimpleStruct* get_ptr() { return &global_struct; }
const SimpleStruct* get_cptr() { return &global_struct; }
SimpleStruct** get_handle() { return &global_struct_ptr; }

#ifdef __cplusplus
}
#endif
%}
