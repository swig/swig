// Tests %extend with default arguments as well as %extend with default arguments with overloading

%module extend_default

%warnfilter(302) Override::over; 
%warnfilter(302) Override::overload; 
%warnfilter(302) Override::ride; 

// %extend before the class definition
%extend Before {
  Before(int i = -1, double d = -1.0) { 
    Before *self = new Before();
    self->i = i;
    self->d = d;
    return self;
  }
  static double AddedStaticMethod(int i = -1, double d = -1) { return i+d; }
  double AddedMethod(int i = -1, double d = -1.0) { return i+d; }
}

%inline %{
struct Before {
  double d;
  int i;
};
%}

// %extend after the class definition
%inline %{
struct After {
  double d;
  int i;
};
%}

%extend After {
  After(int i = -1, double d = -1.0) { 
    After *self = new After();
    self->i = i;
    self->d = d;
    return self;
  }
  static double AddedStaticMethod(int i = -1, double d = -1) { return i+d; }
  double AddedMethod(int i = -1, double d = -1.0) { return i+d; }
}


// %extend before the class definition - with overloading and default args
%extend OverBefore {
  OverBefore(int i = -1, double d = -1.0) { 
    OverBefore *self = new OverBefore("boo");
    self->i = i;
    self->d = d;
    return self;
  }
  static double AddedStaticMethod(int i = -1, double d = -1) { return i+d; }
  double AddedMethod(int i = -1, double d = -1.0) { return i+d; }
}

%inline %{
struct OverBefore {
  OverBefore(const char *str, int ii = -2, double dd = -2.0) : d(dd), i(ii) { str=0; }
  static double AddedStaticMethod(const char*, int ii = -1, double dd = -1) { return ii+dd; }
  double AddedMethod(const char*, int ii = -1, double dd = -1.0) { return ii+dd; }
  double d;
  int i;
};
%}

// %extend after the class definition - with overloading and default args
%extend OverAfter {
  OverAfter(int i = -1, double d = -1.0) { 
    OverAfter *self = new OverAfter("boo");
    self->i = i;
    self->d = d;
    return self;
  }
  static double AddedStaticMethod(int i = -1, double d = -1) { return i+d; }
  double AddedMethod(int i = -1, double d = -1.0) { return i+d; }
}

%inline %{
struct OverAfter {
  OverAfter(const char *str, int i = -2, double d = -2.0) : d(d), i(i) { str=0; }
  static double AddedStaticMethod(const char*, int i = -1, double d = -1) { return i+d; }
  double AddedMethod(const char*, int i = -1, double d = -1.0) { return i+d; }
  double d;
  int i;
};
%}


// %extend overrides the class definition
%extend Override {
  int over(int a) { return a*a; } // SWIG should give a warning then choose this one over the real one
  int overload(int a) { return a*a; } // Similarly, but this one generated uncompileable code in SWIG-1.3.22
}
%inline %{
struct Override {
  int over(int a = -1) { return a; }
  int ride(int a = -1) { return a; }
  int overload(int a) { return a; }
  int overload() { return -10; }
};
%}
%extend Override {
  int ride(int a) { return a+a; } // SWIG should give a warning then ignore this one
}
