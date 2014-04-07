%module derived_module

%import "base_module.i"

%inline %{
class derived : public base {
public:
  int bar();
};
%}
