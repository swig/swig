%module global_vars

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK);                   /* memory leak when setting a ptr/ref variable */

%include std_string.i

%inline %{

  struct A 
  {
    int x;
  };  

  std::string b;
  A a;
  A *ap;
  const A *cap;
  A &ar = a;

  int x;
  int *xp;
  int& c = x;

  void *vp;

  enum Hello { Hi, Hola };

  Hello h;
  Hello *hp;
  Hello &hr = h;
%}
