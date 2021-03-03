%module cpp11_alias_nested_template_scoping

// Test to check a template parameter type is expanded when the template parameter
// is used twice in a type name. Expansion was
// Y< short >::YYY< T >::value_type >
// instead of
// Y< short >::YYY< short >::value_type >

#if !defined(SWIGCSHARP) && !defined(SWIGJAVA)
%feature("flatnested") ZZZ;
#endif

%inline %{
template<typename T> struct Y {
  typedef T value_type;
  typedef Y YY;
  template<typename T2> using YYY = Y<T2>;
  template<typename T2> struct ZZZ {
    typedef T2 another_type;
  };
  value_type create1() const { return T(); }
  typename Y::value_type create2() const { return T(); }
  typename Y<T>::value_type create3() const { return T(); }
  typename YY::value_type create4() const { return T(); }
  typename Y<T>::YY::value_type create5() const { return T(); }
  Y<T>::YYY<T>::value_type create6() const { return T(); }
  typename Y<T>::template ZZZ<T>::another_type create7() const { return T(); }

  // With global scope prefix
  typename ::Y<T>::value_type create13() const { return T(); }

  typename ::Y<T>::YY::value_type create15() const { return T(); }
  ::Y<T>::YYY<T>::value_type create16() const { return T(); }
  typename ::Y<T>::template ZZZ<T>::another_type create17() const { return T(); }
};
%}

%extend Y {
%template() YYY<short>;
%template() ZZZ<short>;
};
// Use above workaround instead of below (which currently gives syntax error)
// %template() Y<short>::YYY<short>;

%template(Yshort) Y<short>;
