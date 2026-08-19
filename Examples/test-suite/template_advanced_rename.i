%module template_advanced_rename

%inline %{
namespace Quirky {
template<typename T> T funky(T a, T b) { return a+b; }
template<typename T> T funky(T a) { return a; }
template<typename T> void funky() {}
}
%}

%rename("%s_void") Quirky::funky<int>();
%template(funky_int) Quirky::funky<int>;

%rename("%(firstuppercase)s_NoParms") Quirky::funky<double>();
%template(funky_double) Quirky::funky<double>;

%rename("%(uppercase)s") Quirky::funky<bool>;
%template() Quirky::funky<bool>;

%inline %{
namespace Golden {
  template<typename T> T goose(T t);
}
%}

%{
template<typename T> T Golden::goose(T t) { return t; }
%}

%rename("%(firstuppercase)s") Golden::goose<int>(int t);
%template() Golden::goose<int>;

%rename("%(regex:/^(.*)::(.*)/\\1_\\2/)s", fullname=1) Golden::goose<bool>;
%template() Golden::goose<bool>;

/* Advanced renaming of instantiated class templates, not just function templates */
%inline %{
namespace Quirky {
template<typename T> struct Wonky {
  T twiddle(T t) { return t; }
};
}
%}

%rename("%s_Renamed") Quirky::Wonky<int>;
%template(WonkyInt) Quirky::Wonky<int>;

%rename("%(uppercase)s") Quirky::Wonky<double>;
%template(WonkyDouble) Quirky::Wonky<double>;

%rename("%(regex:/^(.*)::(.*)/\\1_\\2/)s", fullname=1) Quirky::Wonky<bool>;
%template(WonkyBool) Quirky::Wonky<bool>;

/* A wildcard class rename must not collapse a class template's partial specializations onto one name */
%rename("%s", %$isclass) "";

%inline %{
namespace Quirky {
template<typename T, typename U> struct Bumpy {
  T flat(T t) { return t; }
};

template<typename T, typename U> struct Bumpy<T *, U> {
  T *pointy(T *t) { return t; }
};

template<typename U> struct Bumpy<bool, U> {
  bool boolish(bool b) { return b; }
};
}
%}

%template(BumpyInt) Quirky::Bumpy<int, short>;
%template(BumpyPtr) Quirky::Bumpy<int *, short>;
%template(BumpyBool) Quirky::Bumpy<bool, short>;

// The %rename applies to the template declaration rather than to the instantiation %template names,
// which used to leave the two argument overload uninstantiated.
%rename(spinner_two) Whirl::spinner(T, T);

%inline %{
namespace Whirl {
template<typename T> int spinner(T a) { return 1; }
template<typename T> int spinner(T a, T b) { return 2; }
}
%}

%template(spinner) Whirl::spinner<int>;
