%module(directors="1") cpp11_final_directors

%director Derived;

// A final method gets no director override, including when the final declaration overrides an
// inherited virtual, where the entry that virtual added has to go with it.

// Check SWIG will not wrap these classes as directors where the destructors are final
%director BaseFinalDestructor;
%director BaseFinalDestructor2;

%warnfilter(SWIGWARN_LANG_DIRECTOR_FINAL) BaseFinalDestructor::~BaseFinalDestructor;
%warnfilter(SWIGWARN_LANG_DIRECTOR_FINAL) BaseFinalDestructor2::~BaseFinalDestructor2;

%{
#if defined(__clang__)
// Suppress: class with destructor marked 'final' cannot be inherited from [-Wfinal-dtor-non-final-class]
#pragma clang diagnostic ignored "-Wfinal-dtor-non-final-class"
#endif
%}

%inline %{
struct Base {
  virtual void basemeth() final {}
  virtual int finalinderived() { return 10; }
  virtual int finalinderived2() { return 20; }
  virtual ~Base() {}
};

struct Derived : Base {
  virtual int derivedmeth() final { return 1; }
  virtual int meth() { return 2; }
  // Final overrides of an inherited virtual, spelt with and without the virtual keyword
  int finalinderived() final { return 11; }
  virtual int finalinderived2() final { return 21; }
  virtual ~Derived() {}
};

// Called through a base pointer, so a director override of the callee would show up here
int call_finalinderived(Base *b) { return b->finalinderived(); }
int call_finalinderived2(Base *b) { return b->finalinderived2(); }
int call_meth(Derived *d) { return d->meth(); }

struct BaseFinalDestructor {
  virtual void basefinalmeth() final {}
  virtual ~BaseFinalDestructor() final {}
};

struct BaseFinalDestructor2 {
  virtual void basefinalmeth() {}
  virtual ~BaseFinalDestructor2() final {}
};
%}
