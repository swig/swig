%module(directors="1") director_binary_string;

%feature("director") Callback;

%apply (char *STRING, size_t LENGTH) { (char *dataBufferAA, int sizeAA) };
%apply (char *STRING, size_t LENGTH) { (char *dataBufferBB, int sizeBB) };
%apply (const char *STRING, size_t LENGTH) { (const char *data, size_t datalen) };

%inline %{
#include <stdlib.h>
#include <string.h>

#define BUFFER_SIZE_AA 8
#define BUFFER_SIZE_BB 5

class Callback {
public:
  virtual ~Callback() {}
  virtual int run(char* dataBufferAA, int sizeAA, char* dataBufferBB, int sizeBB) {
    return 0;
  }
  virtual int writeData(const char* data, size_t datalen) = 0;
};

class Caller {
private:
  Callback *_callback;
public:
  Caller(): _callback(NULL) {}
  void delCallback() { _callback = NULL; }
  void setCallback(Callback *cb) { _callback = cb; }
  int call() {
    if (_callback) {
      char aa[BUFFER_SIZE_AA];
      memset(aa, 9, BUFFER_SIZE_AA);
      char bb[BUFFER_SIZE_BB];
      memset(bb, 13, BUFFER_SIZE_BB);
      return _callback->run(aa, BUFFER_SIZE_AA, bb, BUFFER_SIZE_BB);
    }
    return 0;
  }
  void call_null() {
    if (_callback) {
      _callback->run(NULL, 0, NULL, 0);
    }
  }
  int callWriteData() {
    if (_callback) {
      char aa[BUFFER_SIZE_AA];
      memset(aa, 9, BUFFER_SIZE_AA);
      return _callback->writeData(aa, BUFFER_SIZE_AA);
    }
    return 0;
  }
};

%}
