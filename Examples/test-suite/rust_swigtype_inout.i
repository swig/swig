%module rust_swigtype_inout

%include <swigtype_inout.i>

%apply SWIGTYPE *& OUTPUT { InoutThing *&thing_out };

%inline %{
struct InoutThing {
  InoutThing(int value) : value(value) {
  }

  int value;
};

void rust_make_inout_thing(InoutThing *&thing_out) {
  thing_out = new InoutThing(61);
}

int rust_inout_thing_value(InoutThing *thing) {
  return thing->value;
}
%}
