#include "argout/argout_wrap.h"
#include <assert.h>
#include <string.h>

int main(int argc, const char *argv[]) {
  int *ip = argout_new_intp();
  void *handle = 0;

  argout_intp_assign(ip, 42);
  assert(argout_incp(ip) == 42);
  assert(argout_intp_value(ip) == 43);
  assert(argout_incr(ip) == 43);
  assert(argout_intp_value(ip) == 44);
  assert(argout_inctr(ip) == 44);
  assert(argout_intp_value(ip) == 45);
  argout_delete_intp(ip);

  argout_voidhandle(&handle);
  assert(strcmp(argout_handle(handle), "Here it is") == 0);
  return 0;
}
