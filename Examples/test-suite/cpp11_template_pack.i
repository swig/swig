%module cpp11_template_pack

%inline %{
  template <typename T, typename... U>
  class Object {
  };

  template <typename T>
  class Object0 {};

  template <typename T>
  int fn0(Object0<T>) {
    return 1;
  }

  template <typename T, typename... U>
  int fn1(Object<T, U...>) {
    return 1;
  }

  template <typename T, typename... U>
  int fn2(T (*fn)(U...)) {
    return 1;
  }
%}


%template(fn0_1) fn0<int>;
%template(fn1_3) fn1<int, int, int>;
%template(fn2_3) fn2<int, int, int>;
