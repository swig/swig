/* Ambiguous Julia signatures must select overloads using every argument. */
%module julia_overload_ambig

%inline %{
class A {
public:
  int v;
  A(): v(0) {}
};
class C {
public:
  int v;
  C(): v(0) {}
};
struct Bag {
  int n;
};
%}

#ifdef SWIGJULIA
%typemap(ctype)    Bag, const Bag& "void*"
%typemap(jltype)   Bag, const Bag& "Any"
%typemap(jlparam)  Bag, const Bag& "Any"
%typemap(in)       const Bag& "{ static Bag _swig_bag; $1 = &_swig_bag; }"
%typemap(typecheck, precedence=2000) const Bag& "$1 = 1;"

#endif

%inline %{
/* Complementary wildcard positions and trailing defaults. */
int f(const Bag& a, const A& b, int opts = 0) { (void)a;(void)b; return 2+opts; }
int f(const A& a, const Bag& b, int opts = 0) { (void)a;(void)b; return 3+opts; }

/* Three-argument ambiguity. */
int g(const C& a, const C& b, const Bag& c, int opts = 0)   { (void)a;(void)b;(void)c; return 10+opts; }
int g(const Bag& a, const Bag& b, const C& c, int opts = 0) { (void)a;(void)b;(void)c; return 20+opts; }

/* Different parameter names in merged overloads. */
int h(const A& obj, const Bag& tail) { (void)obj;(void)tail; return 30; }
int h(const Bag& name, const A& tail) { (void)name;(void)tail; return 40; }
int h(const C& thing, const Bag& tail) { (void)thing;(void)tail; return 50; }
%}
