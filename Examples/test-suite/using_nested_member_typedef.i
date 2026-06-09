%module using_nested_member_typedef

// using declaration with a typedef scope qualifier (UsingBaseClass::Me) that leads through a base
// class nested inside another class. The protected hh method is brought into the derived class.

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Space::UsingOuter::UsingNestedBase;

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
}

using namespace Space;
%}
