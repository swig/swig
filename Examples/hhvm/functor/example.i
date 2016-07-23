/* File : example.i */
%module example


%inline %{
// From B. Strousjoup, "The C++ Programming Language, Third Edition", p. 514
template<class T> class Sum {
   T res;
public:
   Sum(T i = 0) : res(i) { }
   void operator() (T x) { res += x; }
   T result() const { return res; }
};

%}

%rename(__invoke)  *::operator();	// invoke handles functors for php classes

// Instantiate a few versions
%template(intSum) Sum<int>;
%template(doubleSum) Sum<double>;




