%module extend
%inline %{
class Extended {
  int value_;
public:
  Extended(int value = 2) : value_(value) {}
  int value() const { return value_; }
};
%}
%extend Extended {
  Extended(int left, int right) { return new Extended(left + right); }
  int scaled(int factor = 3) const { return $self->value() * factor; }
  int combined(int left) const { return $self->value() + left; }
  int combined(int left, int right) const { return $self->value() + left + right; }
  static int sum(int left, int right = 4) { return left + right; }
}

%inline %{
class TemplatedConstructor {
  int value_;
public:
  template<class T> TemplatedConstructor(T value) : value_(value) {}
  int value() const { return value_; }
};
%}
%extend TemplatedConstructor {
  %template(TemplatedConstructor) TemplatedConstructor<int>;
  int doubled() const { return 2 * $self->value(); }
}
%typemap(in, tsstub_in="null") const double ** {
  if (!swig_wasmjs::borrowed_value($input).isNull())
    SWIG_exception_fail(SWIG_TypeError, "Expected null");
  $1 = 0;
}
%inline %{
bool null_deep_const(const double **value) { return value == 0; }
%}

%inline %{
class ExplicitValue {
public:
  int value;
  explicit ExplicitValue(int input = 0) : value(input) {}
};
ExplicitValue explicit_copy(ExplicitValue input) { return input; }
int explicit_ref(const ExplicitValue& input) { return input.value; }
class Primary {
public:
  static int primary_static(int value) { return value + 1; }
};
class Secondary {
public:
  static ExplicitValue make(int value = 9) { return ExplicitValue(value); }
  static int scale(int value) { return value * 2; }
  static int scale(int value, int factor) { return value * factor; }
};
class Multiple : public Primary, public Secondary {};
%}
