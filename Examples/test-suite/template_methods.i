// Test %ignore and %rename for templated methods

%module template_methods

%warnfilter(SWIGWARN_LANG_TEMPLATE_METHOD_IGNORE) convolve1<float>();
%warnfilter(SWIGWARN_LANG_TEMPLATE_METHOD_IGNORE) convolve3<float>();

///////////////////
%ignore convolve1<float>(float a);

%inline %{
template <typename ImageT> int convolve1() {  ImageT t; return 0; }
template <typename ImageT> void convolve1(ImageT a) { ImageT t = a; }
%}

%template() convolve1<float>;
%template(convolve1Bool) convolve1<bool>;


///////////////////
%ignore convolve2<float>(float a);

%inline %{
template <typename ImageT> int convolve2() {  ImageT t; return 0; }
template <typename ImageT> void convolve2(ImageT a) { ImageT t = a; }
%}

%template(convolve2Float) convolve2<float>;

///////////////////
%rename(convolve3FloatRenamed) convolve3<float>(float a);

%inline %{
template <typename ImageT> int convolve3() {  ImageT t; return 0; }
template <typename ImageT> void convolve3(ImageT a) { ImageT t = a; }
%}

%template() convolve3<float>;

///////////////////
%rename(convolve4FloatRenamed) convolve4<float>(float a);

%inline %{
template <typename ImageT> int convolve4() {  ImageT t; return 0; }
template <typename ImageT> void convolve4(ImageT a) { ImageT t = a; }
%}

%template(convolve4Float) convolve4<float>;


///////////////////
%rename(convolve5FloatRenamed) convolve5<float>;
%ignore convolve5<bool>;

%inline %{
template <typename ImageT> int convolve5() {  ImageT t; return 0; }
template <typename ImageT> void convolve5(ImageT a) { ImageT t = a; }
%}

%template() convolve5<float>;
%template() convolve5<bool>;


////////////////////////////////////////////////////////////////////////////
%rename(KlassTMethodBoolRenamed) Klass::tmethod(bool);
%rename(KlassStaticTMethodBoolRenamed) Klass::statictmethod(bool);

%inline %{
struct Klass {
  template<typename X> X tmethod(X x) { return x; }
  template<typename X> void tmethod() {}
  template<typename X> static X statictmethod(X x) { return x; }
  template<typename X> static void statictmethod() {}
};
%}
%template(KlassTMethodBool) Klass::tmethod<bool>;
%template(KlassStaticTMethodBool) Klass::statictmethod<bool>;

