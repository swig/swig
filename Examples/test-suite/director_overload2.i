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
//  virtual void nnn() {}
};
struct OverloadDerived2 : OverloadBase {
//  virtual void nnn(int vvv) {}
  virtual void nnn() {}
};
%}

