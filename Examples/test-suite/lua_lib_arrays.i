/* Testcase for the Lua array typemaps in typemaps.i, which are not used by default */
%module lua_lib_arrays

%include <typemaps.i>

%apply int INPUT[ANY] { int in_fixed[3] }
%apply int INOUT[ANY] { int inout_fixed[3] }
%apply (int *INPUT, int) { (int *in_var, int len) }
%apply (int *INOUT, int) { (int *inout_var, int len) }
%apply enum SWIGTYPE INPUT[ANY] { Colour in_colours[2] }
%apply SWIGTYPE* INPUT[ANY] { LuaArrayItem *in_items[2] }

%inline %{
int sum_fixed(int in_fixed[3]) {
  return in_fixed ? in_fixed[0] + in_fixed[1] + in_fixed[2] : -1;
}

void double_fixed(int inout_fixed[3]) {
  if (inout_fixed) {
    for (int i = 0; i < 3; i++)
      inout_fixed[i] *= 2;
  }
}

int sum_var(int *in_var, int len) {
  int sum = 0;
  if (!in_var)
    return len == 0 ? -1 : -2;
  for (int i = 0; i < len; i++)
    sum += in_var[i];
  return sum;
}

void double_var(int *inout_var, int len) {
  if (inout_var) {
    for (int i = 0; i < len; i++)
      inout_var[i] *= 2;
  }
}

enum Colour { Red, Green, Blue };

int first_colour(Colour in_colours[2]) {
  return in_colours ? in_colours[0] : -1;
}

struct LuaArrayItem {
  int value;
};

int items_sum(LuaArrayItem *in_items[2]) {
  return in_items ? in_items[0]->value + in_items[1]->value : -1;
}
%}
