%module voidtest

%inline %{
void globalfunc(void) {}

typedef void VOID_TP;
typedef VOID_TP VOID_TYPE;
void globalfunc_typedef(VOID_TYPE) {}

class Foo {
public:
   Foo(void) { }
   void memberfunc(void) { }
   void* get_this() { return this; }
   static void staticmemberfunc(void) { }
};

class FooVoidTypedef {
public:
#if 0
   FooVoidTypedef(VOID_TYPE) { }
#endif
   void memberfunc(VOID_TYPE) { }
   static void staticmemberfunc(VOID_TYPE) { }
};

void *vfunc1(void *f) { return f; }
void *vfunc2(Foo *f) { return f; }
Foo  *vfunc3(void *f) { return (Foo *) f; }
Foo  *vfunc4(Foo *f) { return f; }

bool test_pointers_equal(void *a, void *b) { return a == b; }

%}
