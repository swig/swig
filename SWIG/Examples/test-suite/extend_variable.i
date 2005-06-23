%module extend_variable

// Tests %extend for variables

%inline %{
class ExtendMe {
  double var;
public:
  ExtendMe(){}
  bool get(double &d) {
    d = var;
    return true;
  }
  bool set(const double &d) {
    var = d;
    return true;
  }
};
%}

%extend ExtendMe {
  ExtendVar;
};

%{
namespace {
  static double StaticVar = 0;
}

// If possible, all language modules should use this naming format for consistency
void ExtendMe_ExtendVar_set(ExtendMe *thisptr, double value) {
  thisptr->set(value);
}
double ExtendMe_ExtendVar_get(ExtendMe *thisptr) {
  double value = 0;
  thisptr->get(value);
  return value;
}
%}
