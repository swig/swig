%module xxx

template<class Y, class T=int> struct X { void primary() {} };
template<class YY> struct X<YY*> { void special(YY*) {} };

%template(Xbad1) X<>;
%template(Xokay1) X<const char *>;
%template(Xokay2) X<const short *, int>;
%template(Xbad2) X<const char *, int, double>;
