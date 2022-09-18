%module catches_strings

%include <std_string.i>

%catches(const char *) StringsThrower::charstring;

%inline %{
struct StringsThrower {
  static void charstring() {
    throw "charstring message";
  }
};
%}
