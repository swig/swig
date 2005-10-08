/* This was broken in the perl module.  See bug 962115 
It tests basic multiple inheritance */

%module(ruby_minherit="1") multiple_inheritance

%warnfilter(813,833,870) FooBar;	/* C#, Java, Php4 multiple inheritance */
%warnfilter(813,833,870) FooBarSpam;	/* C#, Java, Php4 multiple inheritance */


%inline %{

class Bar {
public:
  virtual ~Bar()
  {
  }
  
  virtual int bar() { return 1; }
};

class Foo {
public:
  virtual ~Foo()
  {
  }

  virtual int foo() { return 2; }
};

template<class T> class Spam {
public:
  virtual ~Spam()
  {
  }
  
  virtual int spam(const T& t) { return 100; }
};
%}

%template(SpamInt) Spam<int>;

%inline %{
class FooBar : public Foo, public Bar {
public:
  virtual int fooBar() { return 3; }
};

class FooBarSpam : public Foo, public Bar, public Spam<int> {
public:
  virtual int fooBarSpam() { return 4; }
};

%}

// Languages that don't support multiple inheritance should inherit from one of the non-ignored classes
%ignore IgnoreMe;
%ignore IgnoreMeToo;

%inline %{
class IgnoreMe {
public:
  virtual int ignoreme() { return 5; }
};
class IgnoreMeToo {
public:
  virtual int ignoremetoo() { return 6; }
};
class IgnoreDerived1 : public IgnoreMe, public Bar {
public:
  virtual int ignorederived1() { return 7; }
};
class IgnoreDerived2 : public IgnoreMe, public IgnoreMeToo, public Bar {
public:
  virtual int ignorederived2() { return 8; }
};
class IgnoreDerived3 : public IgnoreMe, public Bar, public IgnoreMeToo {
public:
  virtual int ignorederived3() { return 9; }
};
class IgnoreDerived4 : public Bar, public IgnoreMe, public IgnoreMeToo {
public:
  virtual int ignorederived4() { return 10; }
};
%}

