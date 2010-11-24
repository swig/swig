module runme;

import std.stdio;
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

  writefln( "a = %s", a );
  writefln( "b = %s", b );

  writeln( "Trying some C callback functions:" );
  writefln( "    ADD(a,b) = %s", example.do_op( a, b, example.ADD ) );
  writefln( "    SUB(a,b) = %s", example.do_op( a, b, example.SUB ) );
  writefln( "    MUL(a,b) = %s", example.do_op( a, b, example.MUL ) );

  writeln( "Now the same with callback functions defined in D:" );
  writefln( "    add(a,b) = %s", example.do_op( a, b, &add ) );
  writefln( "    sub(a,b) = %s", example.do_op( a, b, &sub ) );
  writefln( "    mul(a,b) = %s", example.do_op( a, b, &mul ) );
}
