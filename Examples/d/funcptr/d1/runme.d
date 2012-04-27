module runme;

import tango.io.Stdout;
static import example;

extern(C) int add(int a, int b) {
  return a + b;
}

extern(C) int sub(int a, int b) {
  return a - b;
}

extern(C) int mul(int a, int b) {
  return a * b;
}

void main() {
  int a = 37;
  int b = 42;

  Stdout( "a = " )( a ).newline;
  Stdout( "b = " )( b ).newline;

  Stdout( "Trying some C callback functions:" ).newline;
  Stdout( "    ADD(a,b) = " )( example.do_op( a, b, example.ADD ) ).newline;
  Stdout( "    SUB(a,b) = " )( example.do_op( a, b, example.SUB ) ).newline;
  Stdout( "    MUL(a,b) = " )( example.do_op( a, b, example.MUL ) ).newline;

  version (LDC) {
    // Currently, there is no way to specify the calling convention for
    // function pointer parameters in D, but LDC does strict typechecking for
    // them (which is reasonable, but not covered by the language spec yet).
    // As a result, there is no way to make the code below compile with LDC at
    // the moment, so just skip it.
  } else {
    Stdout( "Now the same with callback functions defined in D:" ).newline;
    Stdout( "    add(a,b) = " )( example.do_op( a, b, &add ) ).newline;
    Stdout( "    sub(a,b) = " )( example.do_op( a, b, &sub ) ).newline;
    Stdout( "    mul(a,b) = " )( example.do_op( a, b, &mul ) ).newline;
  }
}
