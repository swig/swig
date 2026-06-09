%module using_nested_member_typedef

// using declaration with a typedef scope qualifier (UsingBaseClass::Me) that leads through a base
// class nested inside another class. Also a three level deep nested class.

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Space::UsingOuter::UsingNestedBase;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Space::UsingOutermost::UsingMiddle;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Space::UsingOutermost::UsingMiddle::UsingNestedBase;

%inline %{
namespace Space {
struct UsingOuter {
    struct UsingNestedBase {
        typedef UsingNestedBase Me;
    protected:
        int hh(int i) { return i; }
    };
};
struct UsingDerived : UsingOuter::UsingNestedBase {
    typedef UsingOuter::UsingNestedBase UsingBaseClass;
    using UsingBaseClass::Me::hh;
};

struct UsingOutermost {
    struct UsingMiddle {
        struct UsingNestedBase {
            typedef UsingNestedBase Me;
        protected:
            int jj(int i) { return i; }
        };
    };
};
struct UsingDerivedDeep : UsingOutermost::UsingMiddle::UsingNestedBase {
    typedef UsingOutermost::UsingMiddle::UsingNestedBase UsingBaseClass;
    using UsingBaseClass::Me::jj;
};
}
%}
