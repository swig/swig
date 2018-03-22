%module(directors="1") ruby_director_exception

%{

static int c_counter;
static int d_counter;

class ShouldBeDestroyed {
public:
  ShouldBeDestroyed() {
    c_counter++;
  }

  ~ShouldBeDestroyed() {
    d_counter++;
  }
};

class Base {
public:
  Base() : m(1) {}
  Base(int i) : m(i) {}
  virtual ~Base() {}
  virtual int ret_m() { return m; };
private:
  int m;
};

int call_ret_m(Base *b) {
  ShouldBeDestroyed s;
  return b->ret_m();
}

%}

%init %{
  c_counter = 0;
  d_counter = 0;
%}

%feature("director:except") {
  throw Swig::DirectorMethodException($error);
}
%exception {
  try { $action }
  catch (Swig::DirectorException &e) { rb_exc_raise(e.getError()); }
}
%feature("director") Base;

class Base {
public:
  Base();
  Base(int);
  virtual ~Base();
  virtual int ret_m();
};

static int c_counter;
static int d_counter;

int call_ret_m(Base *b);
