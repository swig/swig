%module(directors="1",dirprot="1") director_abstract
%{
#include <string>

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() = 0;
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

%}

%include "std_string.i"

%feature("director") Foo;

class Foo {
public:
  virtual ~Foo() {}
  virtual std::string ping() = 0;
  virtual std::string pong() { return "Foo::pong();" + ping(); }
};



%feature("director");

%inline %{
class Example0
{
protected:
  int xsize, ysize;
  
public:
  
  Example0(int x, int y)
    : xsize(x), ysize(y) { }

  Example0() { }

public:
  virtual ~Example0() {}
  
  int  GetXSize() const { return xsize; }
  
  // pure virtual methods that must be overridden
  virtual int Color(unsigned char r, unsigned char g, unsigned char b)  
  {
    return 0;
  }
  

  static int get_color(Example0 *ptr, unsigned char r, 
		       unsigned char g, unsigned char b) {
    return ptr->Color(r, g, b);
  }
};

class Example1
{
protected:
  int xsize, ysize;
  
public:
  
  Example1(int x, int y)
    : xsize(x), ysize(y) { }

  Example1() { }

public:
  virtual ~Example1() {}
  
  int  GetXSize() const { return xsize; }
  
  // pure virtual methods that must be overridden
  virtual int Color(unsigned char r, unsigned char g, unsigned char b)  = 0;

  static int get_color(Example1 *ptr, unsigned char r, 
		       unsigned char g, unsigned char b) {
    return ptr->Color(r, g, b);
  }
  

};


class Example2
{
protected:
 int xsize, ysize;

protected:
  Example2(int x, int y)
    : xsize(x), ysize(y) { }

public:

  virtual ~Example2() {}

  int  GetXSize() const { return xsize; }

  // pure virtual methods that must be overridden
  virtual int Color(unsigned char r, unsigned char g, unsigned char b) = 0;

  static int get_color(Example2 *ptr, unsigned char r, 
		       unsigned char g, unsigned char b) {
    return ptr->Color(r, g, b);
  }
};

namespace ns 
{
  template <class T>
  class Example3
  {
  public:
    Example3()
    {
    }
    
    Example3(int x, int y) { }

    virtual ~Example3() {}
    
    // pure virtual methods that must be overridden
    virtual int Color(unsigned char r, unsigned char g, unsigned char b) = 0;    

    static int get_color(Example3 *ptr, unsigned char r, 
			 unsigned char g, unsigned char b) {
      return ptr->Color(r, g, b);
    }
  };
}    
%}

%template(Example3_i) ns::Example3<int>;
