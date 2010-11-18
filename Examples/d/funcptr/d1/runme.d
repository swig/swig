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

  Stdout( "Now the same with callback functions defined in D:" ).newline;
  Stdout( "    add(a,b) = " )( example.do_op( a, b, &add ) ).newline;
  Stdout( "    sub(a,b) = " )( example.do_op( a, b, &sub ) ).newline;
  Stdout( "    mul(a,b) = " )( example.do_op( a, b, &mul ) ).newline;
}
