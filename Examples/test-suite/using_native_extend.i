%module(ruby_minherit="1") using_native_extend

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) FooBar;   // C#, D, Java, PHP multiple inheritance
#ifdef SWIGLUA	// lua only has one numeric type, so some overloads shadow each other creating warnings
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) blah;
#endif

// Native sections must be written for every language that wants to support %extend %native
%extend Foo {
     // It's up to language what to do when names clash.
     //%native(blah) native_blah;
     %native(blah2) native_blah2;
};

%extend Bar {
     double blah(double x, double y) {
        return x+y;
     }
};

%inline %{
class Foo {
public:
     int blah(int x) { return x; }
     char *blah(char *x) { return x; }
};

class Bar {
public:
     int duh1() { return 1; }
     int duh(int x) { return x; }
     double blah(double x) { return x; }
};

class FooBar : public Foo, public Bar {
public:
     using Foo::blah;
     using Bar::blah;
     char *blah(char *x) { return x; }
};

%}

%extend FooBar 
{
  using Bar::duh1;
  using Bar::duh;
}

%{
#ifdef SWIGLUA
int native_blah( lua_State* L )
{
    lua_pushnumber( L, 1 );
    return 1;
}

int native_blah2( lua_State* L )
{
    lua_pushnumber( L, 2 );
    return 1;
}
#endif
%}

