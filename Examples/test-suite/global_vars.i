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
  void *vp;
  

%}
