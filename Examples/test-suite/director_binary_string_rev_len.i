%module(directors="1") director_binary_string_rev_len;

%feature("director") Callback;

#if !defined(SWIGC)
/* There is no concept of a higher level binary string in C */
%apply (size_t LENGTH, char *STRING) { (int sizeAA, char *dataBufferAA) };
#endif

%inline %{
#include <string.h>

#define BUFFER_SIZE_AA 8

class Callback {
public:
  virtual ~Callback() {}
  virtual int run(int sizeAA, char* dataBufferAA) {
    return 0;
  }
};

class Caller {
private:
  Callback *_callback;
public:
  Caller(Callback *cb): _callback(cb) {}
  int call() {
    if (_callback) {
      char aa[BUFFER_SIZE_AA];
      memset(aa, 9, BUFFER_SIZE_AA);
      return _callback->run(BUFFER_SIZE_AA, aa);
    }
    return 0;
  }
};

%}
