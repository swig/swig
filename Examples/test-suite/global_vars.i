%module global_vars

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
