%module(directors="1") director_wombat

%feature(director) Bar;
%feature(director) Foo<int>;

%inline %{
template<typename T> class Foo
{
public:
                        Foo()
                        { /* NOP */ }
  virtual              ~Foo()
                        { /* NOP */ }
  virtual int           meth(T param) { return param; }
};

typedef Foo<int>        Foo_int;

class Bar
{
public:
  virtual              ~Bar();
  virtual Foo_int      *meth();
};

Bar::~Bar()
{ /* NOP */ }

Foo_int *
Bar::meth()
{
  return new Foo_int();
}
%}

%template(Foo_integers) Foo<int>;
