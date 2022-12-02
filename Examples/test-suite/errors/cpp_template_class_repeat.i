%module xxx

template<typename T> struct A {};
%template(Aint) A<int>;
%template(Aint2) A<int>; // Now ignored and issues a warning

template<typename T> struct B {};
%template() B<int>;
%template(Bint) B<int>; // OK

template<typename T> struct C {};
%template() C<int>;
%template() C<int>; // Quietly ignored now
%template(Cint) C<int>; // OK

template <typename T, typename U = short> struct D {};
%template(Dint) D<int>;
%template(Dintshort) D<int, short>;

template<typename T> struct E {};
%template(Eint) E<int>;
%template(Eint) E<int>; // Always has been ignored as a redefined identifier


template<typename T> struct F {};
%template(Fint) F<int>;
%template() F<int>; // Quietly ignored
%template() F<int>; // Quietly ignored

template<typename T> struct G {};
%template() G<int>;
%template() G<int>; // Quietly ignored
%template(Gint) G<int>;
%template() G<int>; // Quietly ignored
