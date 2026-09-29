%module(directors="1") director
%feature("director") Callback;
%newobject make_callback;
%ignore constructor_failure;
%insert("js") %{
__m.handle_count = () => M.count_emval_handles();
%}
%inline %{
#include <stdexcept>
bool& constructor_failure() { static bool fail = false; return fail; }
void set_constructor_failure(bool fail) { constructor_failure() = fail; }
class Callback {
public:
  Callback() { if (constructor_failure()) throw std::runtime_error("expected constructor failure"); }
  virtual ~Callback() {}
  virtual long long wide(long long n) { return n; }
  virtual int call(int n) { return n + 1; }
};
int invoke(Callback *callback, int n) { return callback->call(n); }
long long invoke_wide(Callback *callback, long long n) { return callback->wide(n); }
Callback *borrow(Callback *callback) { return callback; }
Callback *make_callback() { return new Callback(); }
%}
