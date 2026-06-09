%module using_member_typedef_template

// Test using declarations pointing to a member in base class that is a typedef
// Based on using_member_typedef but base is a template

%inline %{
namespace Space {
template <typename T> struct UsingBase {
    virtual void m() {}
    typedef int Integer;
    typedef UsingBase<T> Me;
    virtual ~UsingBase() {}
};
}
namespace Other {
template <typename T> struct OtherBase {
    virtual void m() {}
    typedef int Integer;
    typedef OtherBase<T> Me;
    virtual ~OtherBase() {}
};
}
typedef int IntAlias;
typedef IntAlias IntTD;
%}

%template(UsingBaseInt) Space::UsingBase<int>;
%template(OtherBaseInt) Other::OtherBase<int>;

%inline %{
namespace Space {
struct UsingDerivedA : UsingBase<int> {
    using UsingBase<int>::Integer;
    int aa(Integer i) { return i; }
};
struct UsingDerivedB : UsingBase<int> {
    typedef UsingBase<int> UsingBaseClass;
    using UsingBaseClass::Integer;
    int bb(UsingBaseClass::Integer i) { return i; }
    int bbb(Integer i) { return i; }
};
struct UsingDerivedC : UsingBase<int> {
    typedef UsingBase<int> UsingBaseClass;
    typedef UsingBaseClass::Me::Integer Integer;
    int cc(UsingBaseClass::Me::Integer i) { return i; }
    int ccc(Integer i) { return i; }
};
struct UsingDerivedD : UsingBase<int> {
    typedef UsingBase<int> UsingBaseClass;
    using UsingBaseClass::Me::Integer; // More complex typedef lookup
    int dd(UsingBaseClass::Me::Integer i) { return i; }
    int ddd(Integer i) { return i; }
};
struct UsingDerivedE : UsingBase<int> {
    typedef UsingBase<int> UsingBaseClass;
    using Space::UsingDerivedE::UsingBaseClass::Me::Integer; // as above but namespace qualified
    int ee(Space::UsingDerivedE::UsingBaseClass::Me::Integer i) { return i; }
    int eee(Integer i) { return i; }
};
struct UsingDerivedF : UsingBase<int> {
    typedef UsingBase<int> UsingBaseTD;
    typedef UsingBaseTD UsingBaseClass;
    using UsingBaseClass::Me::Integer; // Double typedef lookup added
    int ff(UsingBaseClass::Me::Integer i) { return i; }
    int fff(Integer i) { return i; }
};
struct UsingDerivedG : UsingBase<int> {
    typedef UsingBase<IntAlias> UsingBaseTD; // A typedef in template parameters
    typedef UsingBaseTD UsingBaseClass;
    using UsingBaseClass::Me::Integer; // Double typedef lookup added
    int gg(UsingBaseClass::Me::Integer i) { return i; }
    int ggg(Integer i) { return i; }
};
struct UsingDerivedH : UsingBase<int> {
    typedef UsingBase<IntTD> UsingBaseTD;
    typedef UsingBaseTD UsingBaseClass;
    using UsingBaseClass::Me::Integer; // Double typedef lookup added
    int hh(UsingBaseClass::Me::Integer i) { return i; }
    int hhh(Integer i) { return i; }
};
}

// The typedef qualifier's template name is imported by a using declaration (not a using
// directive) and so is not directly visible - resolving the instantiated template scope has to
// qualify the template name 'OtherBase' to 'Other::OtherBase'.  A different namespace to Space is
// used here on purpose: the 'using namespace Space' below must not make the template name visible,
// otherwise the using declaration resolution would not be exercised.
using Other::OtherBase;
struct UsingDerivedI : OtherBase<int> {
    typedef OtherBase<int> UsingBaseClass;
    using UsingBaseClass::Me::Integer;
    int ii(UsingBaseClass::Me::Integer i) { return i; }
    int iii(Integer i) { return i; }
};

using namespace Space;
int a_tester(UsingDerivedA::Integer i) { return i; }
int b_tester(UsingDerivedB::Integer i) { return i; }
int c_tester(UsingDerivedC::Integer i) { return i; }
int d_tester(UsingDerivedD::Integer i) { return i; }
int e_tester(UsingDerivedE::Integer i) { return i; }
int f_tester(UsingDerivedF::Integer i) { return i; }
int g_tester(UsingDerivedG::Integer i) { return i; }
int h_tester(UsingDerivedH::Integer i) { return i; }
int i_tester(UsingDerivedI::Integer i) { return i; }
%}

