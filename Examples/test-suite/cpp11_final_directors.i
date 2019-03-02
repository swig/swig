%module(directors="1") cpp11_final_directors

%director Derived;
%director BaseFinalDestructor;

%warnfilter(SWIGWARN_LANG_DIRECTOR_FINAL) BaseFinalDestructor::~BaseFinalDestructor;

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
%}
