%module(directors="1") director_overload2

%feature("director");


%inline %{
struct OverloadBase {
  virtual ~OverloadBase() {}
  virtual void mmm() {}
  virtual void nnn(int vvv) {}
  virtual void nnn() {}
};
struct OverloadDerived1 : OverloadBase {
  virtual void nnn(int vvv) {}
#if defined(__SUNPRO_CC)
  virtual void nnn() {}
#elif defined(SWIGPHP) // FIXME: Hack to stop director_overload2 failing for PHP8
  virtual void nnn() {}
#endif
};
struct OverloadDerived2 : OverloadBase {
#if defined(__SUNPRO_CC)
  virtual void nnn(int vvv) {}
#elif defined(SWIGPHP) // FIXME: Hack to stop director_overload2 failing for PHP8
  virtual void nnn(int vvv) {}
#endif
  virtual void nnn() {}
};
%}

