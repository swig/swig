#include <stdio.h>
#include <stdlib.h>

#include "exception_order/exception_order_wrap.h"

int main() {
  exception_order_A* a = exception_order_A_new();

  exception_order_A_foo(a);
  if (!exception_order_SWIG_CException_get_pending()) {
    fprintf(stderr, "foo: bad exception order\n");
  } else {
      exception_order_SWIG_CException_reset_pending();
  }

  exception_order_A_bar(a);
  if (!exception_order_SWIG_CException_get_pending()) {
    fprintf(stderr, "bar: bad exception order\n");
  } else {
      exception_order_SWIG_CException_reset_pending();
  }

  exception_order_A_foobar(a);
  if (!exception_order_SWIG_CException_get_pending()) {
    fprintf(stderr, "foobar: bad exception order\n");
  } else {
      exception_order_SWIG_CException_reset_pending();
  }

  exception_order_A_barfoo(a, 1);
  if (!exception_order_SWIG_CException_get_pending()) {
    fprintf(stderr, "barfoo(1): bad exception order\n");
  } else {
      exception_order_SWIG_CException_reset_pending();
  }

  exception_order_A_barfoo(a, 2);
  if (!exception_order_SWIG_CException_get_pending()) {
    fprintf(stderr, "barfoo(2): bad exception order\n");
  } else {
      exception_order_SWIG_CException_reset_pending();
  }

  exit(0);
}

