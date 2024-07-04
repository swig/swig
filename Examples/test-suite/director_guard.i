%module(directors="1") director_guard;

%feature("director") Callback;

%inline %{

class Callback {
public:
  virtual const char *run() const { return "tst1"; }
  virtual ~Callback() {}

};

class Caller {
private:
  Callback *_callback;
public:
  Caller(Callback *cb): _callback(cb) { }
  const char *call() { return _callback->run(); }
};

%}
