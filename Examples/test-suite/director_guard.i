// This test is for testing director_guard.swg and director thread safety
// Note: other languages should define SWIG_THREADS instead of the threads="1" module Python option
%module(directors="1", threads="1") director_guard;

%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) Callback::run;

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
