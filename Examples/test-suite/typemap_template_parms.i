%module typemap_template_parms

%typemap(ret) int "_this_will_not_compile_int_$symname"

%extend X {
%typemap(ret) T lake "/* ret lake X<T> */"
%typemap(ret) T X<T>::rake "/* ret rake X<T> */"

// Overrides below: %typemap(ret) T take
%typemap(ret) T X<T>::take "/* ret take X<T> */"
}

%inline %{
template<typename T> struct X {
#if defined(SWIG)
%typemap(ret) T bake "/* ret bake X<T> */"
%typemap(ret) T X<T>::make "/* ret make X<T> */"
%typemap(ret) T take "_rake_T_this_will_not_compile_"
#endif
  T bake() { return T(); }
  T make() { return T(); }
  T lake() { return T(); }
  T rake() { return T(); }
  T take() { return T(); }
};
%}

%template(Xint) X<int>;
