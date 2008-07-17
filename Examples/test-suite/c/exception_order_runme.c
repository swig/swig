#include <stdio.h>

#include "exception_order/exception_order_proxy.h"

int main() {
  A* a = new_A();

  SWIG_try {
    A_foo(a);
  }
  SWIG_catch(E1) {

  }
  SWIG_catch(SWIG_AnyException) {
    fprintf(stderr, "foo: bad exception order\n");
  }
  SWIG_endtry;

  SWIG_try {
    A_bar(a);
  }
  SWIG_catch(E2) {

  }
  SWIG_catch(SWIG_AnyException) {
    fprintf(stderr, "bar: bad exception order\n");
  }
  SWIG_endtry;

  SWIG_try {
    A_foobar(a);
  }
  SWIG_catch(SWIG_AnyException) {
    if (strcmp(SWIG_exception.msg, "postcatch unknown") != 0) {
      fprintf(stderr, "bad exception order\n");
      SWIG_throw_msg(SWIG_exception.klass, SWIG_exception.msg);
    }
  }
  SWIG_endtry;

  SWIG_try {
    A_barfoo(a, 1);
  }
  SWIG_catch(E1) {

  }
  SWIG_catch(SWIG_AnyException) {
    fprintf(stderr, "barfoo(1): bad exception order\n");
  }
  SWIG_endtry;

  SWIG_try {
    A_barfoo(a, 2);
  }
  SWIG_catch(E2) {

  }
  SWIG_catch(SWIG_AnyException) {
    fprintf(stderr, "barfoo(2): bad exception order\n");
  }
  SWIG_endtry;

  SWIG_exit(0);
}

