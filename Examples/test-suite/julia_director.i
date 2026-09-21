%module(directors="1") julia_director
%feature("director") Callback;
%include <std_string.i>
%inline %{
#include <stdexcept>
class Callback {
public:
  Callback() {}
  virtual ~Callback() {}
  virtual int value(int n) { return n + 1; }
  virtual double real(double n) { return n / 2; }
  virtual int size_value(size_t n) { return n ? 1 : 0; }
  virtual unsigned int unsigned_value(unsigned int n) { return n; }
  virtual std::string echo(const std::string &value) { return value; }
  int call(int n) { return value(n); }
  double call_real(double n) { return real(n); }
  int call_size(size_t n) { return size_value(n); }
  unsigned int call_unsigned(unsigned int n) { return unsigned_value(n); }
  std::string call_echo(const std::string &value) { return echo(value); }
};
%}

#ifdef SWIGJULIA
%inline %{
#include <julia.h>
bool caught_frame_restored(Callback &callback) {
  jl_gcframe_t *before = jl_pgcstack;
  try {
    callback.value(1);
  } catch (const std::exception &) {
    return jl_pgcstack == before;
  }
  return false;
}
%}
#endif
