%module(directors="1") director_pass_by_value

#if defined(SWIGD)
%rename(trace) debug;
#endif

%director DirectorPassByValueAbstractBase;

%include "cpp11_move_only_helper.i"

%ignore PassedByValue::operator=;
%ignore PassedByValue::PassedByValue(PassedByValue &&);

%inline %{
#include <iostream>
using namespace std;
int debug = false;
struct PassedByValue {
  PassedByValue(int v = 0x12345678) { val = v; if (debug) cout << "PassedByValue(0x" << hex << val << ")" << " " << this << endl; Counter::normal_constructor++; }

  PassedByValue(const PassedByValue &other) { val = other.val; if (debug) cout << "PassedByValue(const PassedByValue &)" << " " << this << " " << &other << endl; Counter::copy_constructor++;}
  PassedByValue & operator=(const PassedByValue &other) { val = other.val; if (debug) cout << "operator=(const PassedByValue &)" << " " << this << " " << &other << endl; Counter::copy_assignment++; return *this; }

#if __cplusplus >= 201103L
  PassedByValue(PassedByValue &&other) noexcept { val = other.val; if (debug) cout << "PassedByValue(PassedByValue &&)" << " " << this << endl; Counter::move_constructor++; }
  PassedByValue & operator=(PassedByValue &&other) noexcept { val = other.val; if (debug) cout << "operator=(PassedByValue &&)" << " " << this << endl; Counter::move_assignment++; return *this; }
  ~PassedByValue() { if (debug) cout << "~PassedByValue()" << " " << this << endl; Counter::destructor++; }
#endif

  int getVal() { return val; }
private:
  int val;
};


int doSomething(int x) {
  int yy[256];
  yy[0] =0x9876;
  return yy[0];
}

class DirectorPassByValueAbstractBase {
public:
  virtual void virtualMethod(PassedByValue pbv) = 0;
  virtual void virtualConstMethod(const PassedByValue pbv) {}
  virtual ~DirectorPassByValueAbstractBase () {}
};

class Caller {
public:
  void call_virtualMethod(DirectorPassByValueAbstractBase &f) {
    f.virtualMethod(PassedByValue());
  }
};

bool has_cplusplus11() {
#if __cplusplus >= 201103L
  return true;
#else
  return false;
#endif
}
%}
