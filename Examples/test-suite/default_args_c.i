%module default_args_c

%{
#if defined(__clang__)
#pragma clang diagnostic push
// Suppress: use of logical '||' with constant operand
#pragma clang diagnostic ignored "-Wconstant-logical-operand"
#endif
%}

/* Default arguments for C code */
int foo1(int x = 42 || 3);
int foo43(int x = 42 | 3);

%{
int foo1(int x) {
  return x;
}
int foo43(int x) {
  return x;
}
%}
