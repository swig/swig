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

%inline %{
struct FooStruct {
  int num;
};
%}
%extend FooStruct {
  void no_arg() {}
  void one_req(int *required) {}
  void one_opt(int *optional = NULL) {}
  void two_arg(int *required, int *optional = NULL) {}
}

%inline %{
struct StaticStruct {
  int snum;
};
%}
%extend StaticStruct {
  static void no_arg() {}
  static void one_req(int *required) {}
  static void one_opt(int *optional = NULL) {}
  static void two_arg(int *required, int *optional = NULL) {}
}

%{
void global_opts1(int *optional) {}
void global_opts2(int *required, int *optional) {}
%}
void global_opts1(int *optional = NULL) {}
void global_opts2(int *required, int *optional = NULL) {}
