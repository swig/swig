%module(directors="1") cpp11_final_directors

%director Derived;

// Check SWIG will not wrap these classes as directors where the destructors are final
%director BaseFinalDestructor;
%director BaseFinalDestructor2;

%warnfilter(SWIGWARN_LANG_DIRECTOR_FINAL) BaseFinalDestructor::~BaseFinalDestructor;
%warnfilter(SWIGWARN_LANG_DIRECTOR_FINAL) BaseFinalDestructor2::~BaseFinalDestructor2;

%inline %{
struct Base {
  virtual void basemeth() final {}
  virtual ~Base() {}
};

struct Derived : Base {
  virtual int derivedmeth() final { return 1; }
  virtual int meth() { return 2; }
  virtual ~Derived() {}
};

struct BaseFinalDestructor {
  virtual void basefinalmeth() final {}
  virtual ~BaseFinalDestructor() final {}
};

struct BaseFinalDestructor2 {
  virtual void basefinalmeth() {}
  virtual ~BaseFinalDestructor2() final {}
};
%}
