%module volatile_qualifiers

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK); /* memory leak when setting a pointer variable */

%{
static int string_length(const volatile char *s) {
  int n = 0;
  while (s[n])
    ++n;
  return n;
}
%}

%inline %{
struct Item {
  int x;
  Item(int x) : x(x) {}
};

int int_ptr(int *p) { return *p; }
int const_int_ptr(const int *p) { return *p; }
int volatile_int_ptr(volatile int *p) { return *p; }
int const_volatile_int_ptr(const volatile int *p) { return *p; }
int volatile_int_ref(volatile int &r) { return r; }
int const_volatile_int_ref(const volatile int &r) { return r; }

int char_ptr(char *s) { return string_length(s); }
int const_char_ptr(const char *s) { return string_length(s); }
int volatile_char_ptr(volatile char *s) { return string_length(s); }
int const_volatile_char_ptr(const volatile char *s) { return string_length(s); }

int item_ptr(Item *p) { return p->x; }
int const_item_ptr(const Item *p) { return p->x; }
int volatile_item_ptr(volatile Item *p) { return p->x; }
int const_volatile_item_ptr(const volatile Item *p) { return p->x; }
int volatile_item_ref(volatile Item &r) { return r.x; }
int const_volatile_item_ref(const volatile Item &r) { return r.x; }
%}

// A volatile parameter is deprecated in C++20, so these are defined without the volatile that is not part of the function type
%{
int int_volatile_ptr(int *p) { return *p; }
int volatile_int_value(int i) { return i; }
int const_volatile_int_value(int i) { return i; }
int char_volatile_ptr(char *s) { return string_length(s); }
int item_volatile_ptr(Item *p) { return p->x; }
int volatile_item_value(Item i) { return i.x; }
int const_volatile_item_value(Item i) { return i.x; }
%}
int int_volatile_ptr(int *volatile p);
int volatile_int_value(volatile int i);
int const_volatile_int_value(const volatile int i);
int char_volatile_ptr(char *volatile s);
int item_volatile_ptr(Item *volatile p);
// TODO: fix the wrappers of a volatile class passed by value, which copy it from a pointer to volatile and do not compile
#if !defined(SWIGCSHARP) && !defined(SWIGD) && !defined(SWIGGO) && !defined(SWIGJAVA)
int volatile_item_value(volatile Item i);
int const_volatile_item_value(const volatile Item i);
#endif

%inline %{

volatile int *volatile_int_ptr_return() {
  static volatile int i = 50;
  return &i;
}
const volatile char *const_volatile_char_ptr_return() { return "return"; }
volatile Item *volatile_item_ptr_return(Item *p) { return p; }
const volatile Item &const_volatile_item_ref_return(Item &r) { return r; }

volatile int global_volatile_int = 1;
const volatile int global_const_volatile_int = 2;
char *volatile global_char_volatile_ptr = 0;
Item *volatile global_item_volatile_ptr = 0;
// TODO: fix the getters of a global variable that is a pointer to volatile, which do not compile
#if !defined(SWIGOCTAVE) && !defined(SWIGPYTHON) && !defined(SWIGRUBY) && !defined(SWIGSCILAB) && !defined(SWIGTCL)
volatile int *global_volatile_int_ptr = 0;
volatile Item *global_volatile_item_ptr = 0;
#endif
// TODO: fix the getter of a global variable that is a const volatile char pointer, which does not compile
#if !defined(SWIGGUILE) && !defined(SWIGOCTAVE) && !defined(SWIGPERL) && !defined(SWIGPYTHON) && !defined(SWIGRUBY) && !defined(SWIGSCILAB) && !defined(SWIGTCL)
const volatile char *const global_const_volatile_char_const_ptr = "global";
#endif

struct Members {
  volatile int volatile_int;
  const volatile int const_volatile_int;
  char *volatile char_volatile_ptr;
  volatile Item *volatile_item_ptr;
  Item *volatile item_volatile_ptr;
  static volatile int static_volatile_int;
  static const volatile int static_const_volatile_int;
  static char *volatile static_char_volatile_ptr;
  static Item *volatile static_item_volatile_ptr;
  Members() : volatile_int(10), const_volatile_int(20), char_volatile_ptr(0), volatile_item_ptr(0), item_volatile_ptr(0) {}
};
volatile int Members::static_volatile_int = 30;
const volatile int Members::static_const_volatile_int = 40;
char *volatile Members::static_char_volatile_ptr = 0;
Item *volatile Members::static_item_volatile_ptr = 0;
%}

// A const volatile type uses a typemap for its const type before one for its type without qualifiers
%typemap(check) int &iii, int *ppp, char *sss, Item &item_ref, Item *item_ptr, const int &vvv %{
#error Incorrect typemap for $symname: $type
%}
%typemap(check) const int &iii, const int *ppp, const char *sss, const Item &item_ref, const Item *item_ptr, int &vvv, int &uuu %{
/* Correct typemap for $symname: $type */
%}

%inline %{
void volly_ref(const volatile int &iii) {}
void volly_ptr(const volatile int *ppp) {}
void volly_string(const volatile char *sss) {}
void volly_item_ref(const volatile Item &item_ref) {}
void volly_item_ptr(const volatile Item *item_ptr) {}
void volly_volatile_ref(volatile int &vvv) {}
void volly_unqualified_ref(const volatile int &uuu) {}
%}
