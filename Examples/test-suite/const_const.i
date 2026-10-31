/* This interface file tests whether SWIG handles types like
   "const int *const" right.

   SWIG 1.3a5 signals a syntax error.
*/

%module const_const

%typemap(in) const int *const { $1 = NULL; }

%inline %{
void foo(const int *const i) {}
%}

%{
static const char *number_name(int i) { return i == 1 ? "one" : "other"; }
%}

%inline %{
const char **names_get(void) {
  static const char *names[] = {"zero", "one", 0};
  return names;
}

const char *(*namer_get(void))(int) { return number_name; }

struct Point {
  int x;
};
enum Colour { RED, GREEN };

int point_x(const struct Point *p) { return p->x; }
int colour_value(const enum Colour *const *c) { return (int)**c; }
%}
