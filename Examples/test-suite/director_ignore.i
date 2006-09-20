%module(directors="1") director_ignore

%include "std_string.i"

%feature("director");

%ignore OverloadedMethod(int n, int xoffset = 0, int yoffset = 0);
%ignore ProtectedMethod(int n, int xoffset = 0, int yoffset = 0);
%ignore DIgnoreConstructor(bool b);
%ignore DIgnoreOnlyConstructor(bool b);

%inline %{

#include <string>
class DIgnores
{
  public:
    virtual ~DIgnores() {}
    virtual void OverloadedMethod(int n, int xoffset = 0, int yoffset = 0) {}
    virtual void OverloadedMethod(bool b) {}
  protected:
    virtual void ProtectedMethod(int n, int xoffset = 0, int yoffset = 0) {}
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

/*
class DAbstractIgnores
{
  public:
    virtual ~DAbstractIgnores() {}
    virtual void OverloadedMethod(int n, int xoffset = 0, int yoffset = 0) = 0;
    virtual void OverloadedMethod(bool b) = 0;
};
*/


%}

