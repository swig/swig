%module using_member

/* using declaration tests, including renaming */
%warnfilter(SWIGWARN_LANG_USING_NAME_DIFFERENT) one::twotwo::threetwo::BB::great;

%rename(greater) one::two::three::interface1::AA::great(int);
%rename(greater) one::two::three::interface1::AA::great(float);
%rename(greater) one::CC::great;
%rename(greater) one::DD::great;
%rename(greaterstill) one::DD::great(bool);

#ifdef SWIGLUA
// Lua does now have a separate integer type, but didn't used to
// and SWIG doesn't yet know about it (see #1918) so for now suppress
// warnings about functions with overloads on int vs double, etc.
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) B::get(double);
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) one::two::three::interface1::AA::great(float);
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) one::CC::great;
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) one::DD::great(float);
#endif

%inline %{
namespace interface1
{
    struct A
    {
        int get(int) {return 10;}
    };
}
using interface1::A;

struct B : public A
{
    using A::get;
    int get(double) {return 20;}
};


namespace one {
    namespace two {
        namespace three {
            namespace interface1
            {
                class AA
                {
                public:
                    int great(int) {return 0;}
                    int great(float) {return 1;}
                };
            }
            using interface1::AA;
        }
    }
    namespace twotwo {
        namespace threetwo {
            class BB : public two::three::AA
            {
            public:
// TODO: two::three::AA::great not introduced
                using two::three::AA::great;
                int great(bool) {return 2;}
                int jj() {return 3;}
            };
        }
    }

    class CC : public two::three::AA
    {
    public:
      using two::three::AA::great;
      int great(bool) {return 20;}
    };

    class DD : public two::three::AA
    {
    public:
      using two::three::AA::great;
      int great(bool) {return 30;}
    };
}
%}
