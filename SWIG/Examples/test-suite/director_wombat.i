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
  virtual int           meth(T param)
                        { return param; }
};

typedef Foo<int>        Foo_int;

class Bar
{
public:
  virtual              ~Bar();
  virtual Foo_int      *meth();
  virtual void          foo_meth(Foo_int &, int);
};

Bar::~Bar()
{ /* NOP */ }

Foo_int *
Bar::meth()
{
  return new Foo_int();
}

void
Bar::foo_meth(Foo_int &arg, int param)
{
}
%}

%template(Foo_integers) Foo<int>;
