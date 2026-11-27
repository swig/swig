/* This interface file tests whether SWIG handles pointer-reference
   (*&) arguments.

   SWIG 1.3a5 signals a syntax error.
*/

%module pointer_reference

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK);                   /* memory leak when setting a ptr/ref variable */

#ifdef SWIGGUILE
/* A silly testing typemap for feeding a doubly indirect integer */
%typemap(in) int *&XYZZY (int temp1, int *temp2) {
   temp1 = scm_to_int($input); temp2 = &temp1; $1 = &temp2;
};
#endif

%inline %{
void foo(int *&XYZZY) {}
%}


// Test pointer reference typemaps shipped with SWIG (add in SWIG 1.3.28 for many languages)
%inline %{
struct Struct {
  int value;
  Struct(int v) : value(v) {}
  static Struct instance;
  static Struct *pInstance;
};

void set(Struct *const& s) {
  Struct::instance = *s;
}
Struct *const& get() {
  return Struct::pInstance;
}
int overloading(int i) {
  return 111;
}
int overloading(Struct *const& s) {
  return 222;
}
// A non-const reference to a pointer takes a pointer to a pointer, not a pointer
int pointer_reference_value(Struct *& s) {
  return s ? s->value : -1;
}
// So does a const volatile reference to a pointer
int pointer_reference_const_volatile(Struct *const volatile & s) {
  return s ? s->value : -1;
}
typedef Struct *const StructConstPtr;
typedef Struct *volatile StructVolatilePtr;
// A const reference to a typedef of a const pointer is a 'Struct *const&'
int pointer_reference_typedef_const(const StructConstPtr & s) {
  return s ? s->value : -1;
}
// A const reference to a typedef of a volatile pointer is a 'Struct *const volatile&'
int pointer_reference_typedef_volatile(const StructVolatilePtr & s) {
  return s ? s->value : -1;
}
%}

// A const reference to a pointer to a builtin type or to a pointer to one, a pointer to a pointer to an enum and a reference to a pointer to an enum
%inline %{
int int_pointer_reference_value(int *const &p) {
  return *p;
}
int int_pointer_pointer_reference_value(int **const &p) {
  return **p;
}
enum Colour { RED, GREEN };
int colour_pointer_pointer_value(Colour **c) {
  return **c;
}
int colour_pointer_reference_value(Colour *&c) {
  return *c;
}
%}

// A pointer to a class that is not wrapped
%inline %{
struct Opaque;
Opaque *opaque_pointer();
Opaque *const& opaque_pointer_reference();
int opaque_value(Opaque *const& o);
%}

%{
struct Opaque {
  int value;
};
Opaque opaque_instance = { 30 };
Opaque *opaque_instance_pointer = &opaque_instance;
Opaque *opaque_pointer() {
  return opaque_instance_pointer;
}
Opaque *const& opaque_pointer_reference() {
  return opaque_instance_pointer;
}
int opaque_value(Opaque *const& o) {
  return o->value;
}
%}

%{
Struct Struct::instance = Struct(10);
Struct *Struct::pInstance = &Struct::instance;
%}

