%module xxx

template<class T> T blah(T x) { };

%template(iblah) blah<int>;
%template(iiblah) blah<int>;

