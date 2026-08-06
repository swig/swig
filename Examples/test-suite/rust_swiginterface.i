%module rust_swiginterface

%include <swiginterface.i>

%inline %{
struct RustInterfaceThing {
  virtual ~RustInterfaceThing() {}
  virtual int value() const { return 7; }
};
%}

%interface(RustInterfaceThing)
