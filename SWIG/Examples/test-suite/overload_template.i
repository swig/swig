%module overload_template
%inline %{

int foo() {
  return 3;
}
template <class T>
  int foo(int x) {
     return x;
  }

template<class T>
  T max(T a, T b) { return  (a > b) ? a : b; }
%}                                     


%template(max) max<int>;
%template(max) max<double>;

