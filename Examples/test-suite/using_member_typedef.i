%module using_member_typedef

// Test using declarations pointing to a member in base class that is a typedef

%inline %{
namespace Space {
struct UsingBase {
    virtual void m() {}
    virtual ~UsingBase() {}
    typedef int Integer;
    typedef UsingBase Me;
};
struct UsingDerivedA : UsingBase {
    using UsingBase::Integer;
    int aa(Integer i) { return i; }
};
struct UsingDerivedB : UsingBase {
    typedef UsingBase UsingBaseClass;
    using UsingBaseClass::Integer;
    int bb(UsingBaseClass::Integer i) { return i; }
    int bbb(Integer i) { return i; }
};
struct UsingDerivedC : UsingBase {
    typedef UsingBase UsingBaseClass;
    typedef UsingBaseClass::Me::Integer Integer;
    int cc(UsingBaseClass::Me::Integer i) { return i; }
    int ccc(Integer i) { return i; }
};
struct UsingDerivedD : UsingBase {
    typedef UsingBase UsingBaseClass;
    using UsingBaseClass::Me::Integer; // More complex typedef lookup - issue #2694
    int dd(UsingBaseClass::Me::Integer i) { return i; }
    int ddd(Integer i) { return i; }
};
struct UsingDerivedE : UsingBase {
    typedef UsingBase UsingBaseClass;
    using Space::UsingDerivedE::UsingBaseClass::Me::Integer; // as above but namespace qualified
    int ee(Space::UsingDerivedE::UsingBaseClass::Me::Integer i) { return i; }
    int eee(Integer i) { return i; }
};
struct UsingDerivedF : UsingBase {
    typedef UsingBase UsingBaseTD;
    typedef UsingBaseTD UsingBaseClass;
    using UsingBaseClass::Me::Integer; // Double typedef lookup added
    int ff(UsingBaseClass::Me::Integer i) { return i; }
    int fff(Integer i) { return i; }
};
// 'Integer' is inherited into the scope named by the typedef qualifier rather than being a
// direct member of it, so the member lookup in the resolved scope has to climb the inheritance chain
struct UsingGrandBase {
    virtual void m() {}
    virtual ~UsingGrandBase() {}
    typedef int Integer;
};
struct UsingMidBase : UsingGrandBase {
    typedef UsingMidBase Me;
};
struct UsingDerivedG : UsingMidBase {
    typedef UsingMidBase UsingBaseClass;
    using UsingBaseClass::Me::Integer; // Integer is inherited into the resolved scope, not a direct member
    int gg(UsingBaseClass::Me::Integer i) { return i; }
    int ggg(Integer i) { return i; }
};
}

using namespace Space;
int a_tester(UsingDerivedA::Integer i) { return i; }
int b_tester(UsingDerivedB::Integer i) { return i; }
int c_tester(UsingDerivedC::Integer i) { return i; }
int d_tester(UsingDerivedD::Integer i) { return i; }
int e_tester(UsingDerivedE::Integer i) { return i; }
int f_tester(UsingDerivedF::Integer i) { return i; }
int g_tester(UsingDerivedG::Integer i) { return i; }
%}
