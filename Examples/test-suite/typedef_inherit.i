// Inheritance through a typedef name
%module typedef_inherit

  
%inline %{
class Foo {
public:
     virtual ~Foo () { }
  
     virtual char *blah() {
	return (char *) "Foo::blah";
     }
};

typedef Foo FooObj;

class Bar : public FooObj {
 public:
  virtual char *blah() {
    return (char *) "Bar::blah";
  }
};

char *do_blah(FooObj *f) {
  return f->blah();
}

typedef struct spam {
  virtual ~spam()
  {
  }
  
  virtual char *blah() {
    return (char *) "Spam::blah";
  }

  const char *far1() {
    return "Spam::far1";
  }
} Spam;

struct Grok : public Spam {
   virtual ~Grok() { }
   virtual char *blah() {
       return (char *) "Grok::blah";
   }
};

static char * do_blah2(Spam *s) {
   return s->blah();
}

// Inheriting through a self-referential typedef ('typedef struct Thing Thing;')
typedef struct Thing Thing;

struct Thing {
  virtual ~Thing() {}
  virtual const char *blah() {
    return "Thing::blah";
  }
};

struct DerivedThing : public Thing {
  virtual const char *blah() {
    return "DerivedThing::blah";
  }
};

static const char *do_blah3(Thing *t) {
  return t->blah();
}
%}

