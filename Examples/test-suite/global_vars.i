%module global_vars

%inline %{

  struct A 
  {
    int x;
  };  

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
