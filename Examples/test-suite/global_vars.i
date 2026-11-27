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
  A *const acp = &a;
  A *volatile avp;
  A *const volatile acvp = &a;

  int x;
  int *xp;
  int& c_member = x;

  void *vp;

  enum Hello { Hi, Hola };

  Hello h;
  Hello *hp;
  Hello &hr = h;
  Hello *const hcp = &h;
  A *const &acpr = acp;
  Hello *const &hcpr = hcp;

  void init() {
    b = "string b";
    x = 1234;
  }

  int read_x() { return x; }

  void clear_xp() { xp = 0; }

  void assign_ap(A *const p) { ap = p; }

  void assign_hp(Hello *const &p) { hp = p; }

  std::string read_b() { return b; }
%}
