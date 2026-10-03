%module(directors="1") matlab_director
%feature("director") Callback;
%feature("director") NamedConstructor;
%apply int &OUTPUT { int &extra };
#ifdef SWIGMATLAB
%typemap(directorargout) int &extra { $1 = (int)mxGetScalar($result); }
#endif
%inline %{
static int live_callbacks = 0;
static int active_calls = 0;
struct CallGuard {
  CallGuard() { ++active_calls; }
  ~CallGuard() { --active_calls; }
};
int callback_count() { return live_callbacks; }
int active_call_count() { return active_calls; }
struct Callback {
  Callback() { ++live_callbacks; }
  virtual ~Callback() { --live_callbacks; }
  virtual int value(int x) { return x; }
  virtual int split(int x, int &extra) { extra = x + 1; return x; }
};
int invoke(Callback &callback, int value) {
  CallGuard guard;
  return callback.value(value);
}
int invoke_split(Callback &callback, int value) {
  int extra = 0;
  return callback.split(value, extra) + extra;
}
%}

%inline %{
struct NamedConstructor {
  NamedConstructor(int self) : initial(self) {}
  NamedConstructor(double self, int self0) : initial((int)self + self0) {}
  virtual ~NamedConstructor() {}
  virtual int method() { return initial; }
  int initial;
};
int invoke_named(NamedConstructor &callback) { return callback.method(); }
%}
