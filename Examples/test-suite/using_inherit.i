%module using_inherit

#ifdef SWIGLUA	// lua only has one numeric type, so some overloads shadow each other creating warnings
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) Foo::test;
#endif

%inline %{

class Foo {
public:
     int test(int x) { return x; }
     double test(double x) { return x; };
};

class Bar : public Foo {
public:
     using Foo::test;
};

%}

