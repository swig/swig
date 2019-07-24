%module template_using_directive_typedef

%inline %{
namespace space {
  template<typename T> class Vector {};
  class VectorClass {};
}
struct Obj {};
%}

%template(Vector_Obj) space::Vector<Obj>;

%inline %{
namespace tns {
  using space::Vector; // template using directives were not being added into the typedef table
  using space::VectorClass;
  typedef Vector<Obj> NSVec;
}
%}

%inline %{
namespace tns {
  struct Holder {
//	using Vec = Vector<Obj>;
    typedef Vector<Obj> Vec;
    typedef VectorClass VecClass;
	Vec items;
    void holder_use1(space::Vector<Obj>, tns::NSVec, tns::Vector<Obj>) {}
    void holder_use2(space::Vector<Obj>, NSVec, Vector<Obj>) {}
    void holder_use3(tns::Holder::Vec, Holder::Vec, Vec) {}
  };
  void tns_holder_use(tns::Holder::Vec, Holder::Vec) {}
  void tns_use(space::Vector<Obj>, NSVec, tns::NSVec) {}
}
void global_holder_use(tns::Holder::Vec) {}
void global_use(space::Vector<Obj>, tns::NSVec, tns::Vector<Obj>) {}
namespace ns1 {
  void ns1_holder_use(tns::Holder::Vec) {}
}
namespace ns2 {
  using namespace tns;
  void ns2_holder_use(tns::Holder::Vec, Holder::Vec, NSVec, Vector<Obj>) {}
}
%}
