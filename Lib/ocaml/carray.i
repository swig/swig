template < class T > class SWIG_OCAML_ARRAY_WRAPPER {
public:
  SWIG_OCAML_ARRAY_WRAPPER( T *t ) : t(t) { }
  SWIG_OCAML_ARRAY_WRAPPER( T &t ) : t(&t) { }
  SWIG_OCAML_ARRAY_WRAPPER( T t[] ) : t(&t[0]) { }
  T &operator[]( int n ) { return t[n]; }
  SWIG_OCAML_ARRAY_WRAPPER offset( int elts ) {
	return SWIG_OCAML_ARRAY_WRAPPER( t + elts );
  }
  T *operator & () { return t; }
  void own() { owned = true; }
  void disown() { owned = false; }
  ~SWIG_OCAML_ARRAY_WRAPPER() {
    if( owned ) delete t;
  }

private:
  T *t;
  int owned;
};

%typemap(ocaml,out) SWIGTYPE [ANY] {
  $result = new SWIG_OCAML_ARRAY_WRAPPER($1);
}

%typemap(ocaml,varout) SWIGTYPE [ANY] {
  $result = new SWIG_OCAML_ARRAY_WRAPPER($1);
}

%typemap(ocaml,in) SWIGTYPE [ANY] {
  $1 = (SWIG_OCAML_ARRAY_WRAPPER<$ltype> *)$input;
}

%typemap(ocaml,varin) SWIGTYPE [ANY] {
  $1 = (SWIG_OCAML_ARRAY_WRAPPER<$ltype> *)$input;
}
