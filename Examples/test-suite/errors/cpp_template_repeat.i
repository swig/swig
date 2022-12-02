%module xxx

template<class T> T blah(T x) { };

%template(iblah) blah<int>;
%template(iiblah) blah<int>;

// empty template instantiations for template functions warn (unlike for template classes)
%template() blah<double>;
%template() blah<double>;
%template() blah<double>;

%template(sblah) blah<short>;
%template(sblah) blah<short>;

%template() blah<const char *>;
%template() blah<const char *>;
%template(sblah) blah<const char *>;
