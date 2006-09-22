%module(directors="1") director_ignore

%warnfilter(SWIGWARN_LANG_DIRECTOR_ABSTRACT) DIgnoreOnlyConstructor;

%include "std_string.i"

%feature("director");

%ignore OverloadedMethod(int n, int xoffset = 0, int yoffset = 0);
%ignore OverloadedProtectedMethod(int n, int xoffset = 0, int yoffset = 0);
%ignore DIgnoreConstructor(bool b);
%ignore DIgnoreOnlyConstructor(bool b);
%ignore Pointers;
%ignore References;

%inline %{

#include <string>
class DIgnores
{
  public:
    virtual ~DIgnores() {}
    virtual void OverloadedMethod(int n, int xoffset = 0, int yoffset = 0) {}
    virtual void OverloadedMethod(bool b) {}
    virtual int Triple(int n) { return n*3; }
    virtual int& References(int& n) { static int nn; nn=n; return nn; }
    virtual int* Pointers(int* n) { static int nn; nn=*n; return &nn; }
  protected:
    virtual void OverloadedProtectedMethod(int n, int xoffset = 0, int yoffset = 0) {}
    virtual void OverloadedProtectedMethod() {}
};

class DAbstractIgnores
{
  public:
    virtual ~DAbstractIgnores() {}
    virtual double OverloadedMethod(int n, int xoffset = 0, int yoffset = 0) = 0;
    virtual double OverloadedMethod(bool b) = 0;
    virtual int Quadruple(int n) { return n*4; }
    virtual int& References(int& n) { static int nn; nn=n; return nn; }
    virtual int* Pointers(int* n) { static int nn; nn=*n; return &nn; }
  protected:
    virtual double OverloadedProtectedMethod(int n, int xoffset = 0, int yoffset = 0) = 0;
    virtual double OverloadedProtectedMethod() = 0;
};

class DIgnoreConstructor
{
  public:
    virtual ~DIgnoreConstructor() {}
    DIgnoreConstructor(std::string s, int i) {}
    DIgnoreConstructor(bool b) {}
};

class DIgnoreOnlyConstructor
{
  public:
    virtual ~DIgnoreOnlyConstructor() {}
    DIgnoreOnlyConstructor(bool b) {}
};

%}

