%module voidtest

// A (void) parameter list must be matched exactly by %ignore and %rename, an empty parameter list does not match
%ignore globalfunc_ignored(void);
%ignore VoidIgnored::memberfunc_ignored(void);
%ignore VoidIgnored::staticmemberfunc_ignored(void);

%rename(globalfunc_renamed) globalfunc_torename(void);
%rename(memberfunc_renamed) Foo::memberfunc_torename(void);
%rename(staticmemberfunc_renamed) Foo::staticmemberfunc_torename(void);

%inline %{
void globalfunc(void) {}
void globalfunc_torename(void) {}

typedef void VOID_TP;
typedef VOID_TP VOID_TYPE;
void globalfunc_typedef(VOID_TYPE) {}

class Foo {
public:
   Foo(void) { }
   void memberfunc(void) { }
   void* get_this() { return this; }
   static void staticmemberfunc(void) { }
   void memberfunc_torename(void) { }
   static void staticmemberfunc_torename(void) { }
};

class FooVoidTypedef {
public:
   FooVoidTypedef(VOID_TYPE) { }
   void memberfunc(VOID_TYPE) { }
   void memberfunc_const(VOID_TYPE) const { }
   void *memberfunc_const_voidptr(VOID_TYPE) const { return 0; }
   virtual ~FooVoidTypedef() { }
   static void staticmemberfunc(VOID_TYPE) { }
};

void *vfunc1(void *f) { return f; }
void *vfunc2(Foo *f) { return f; }
Foo  *vfunc3(void *f) { return (Foo *) f; }
Foo  *vfunc4(Foo *f) { return f; }
const void *vfunc_const(const void *f) { return f; }

bool test_pointers_equal(void *a, void *b) { return a == b; }

%}

%{
class VoidIgnored {};
%}

// Declared to SWIG only, so the wrappers will not compile should any of the %ignore above not match
void globalfunc_ignored(void);

class VoidIgnored {
public:
   void memberfunc_ignored(void);
   static void staticmemberfunc_ignored(void);
};
