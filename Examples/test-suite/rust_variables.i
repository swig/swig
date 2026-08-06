%module rust_variables

%inline %{

int rust_global_value = 7;
const int rust_global_const = 11;

class RustVarBox {
public:
  RustVarBox() : value(3) {
  }

  int value;
  static int static_value;
  static const int static_const = 17;
};

int RustVarBox::static_value = 5;

%}
