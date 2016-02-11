%module(directors="1") java_abstract_directors

%feature("director") Director1;

%inline %{
class Director0 {
 public:
  virtual ~Director0() {}
  virtual void Method1() = 0;
  virtual void Method2() {};
};
%}

%feature("director") Director1;

%abstractdirector Director1::Method1;

%inline %{
class Director1 {
 public:
  virtual ~Director1() {}
  virtual void Method1() = 0;
  virtual void Method2() {};
};
%}

%feature("director") Director2;

%abstractdirector Director2;

%inline %{
class Director2 {
 public:
  virtual ~Director2() {}
  virtual void Method1() = 0;
  virtual void Method2() {};
};
%}

%feature("director") Director3;

%inline %{
class Director3 {
 public:
  virtual ~Director3() {}
  virtual void Method1() = 0;
  virtual void Method2() {};
};
%}

%feature("director") Director4;

%abstractdirector;

%inline %{
class Director4 {
 public:
  virtual ~Director4() {}
  virtual void Method1() = 0;
  virtual void Method2() {};
};
%}
