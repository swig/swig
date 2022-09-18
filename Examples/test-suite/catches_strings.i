%module catches_strings

%include <std_string.i>

%catches(const char *) StringsThrower::charstring;
%catches(std::string) StringsThrower::stdstring;

%inline %{
struct StringsThrower {
  static void charstring() {
    throw "charstring message";
  }
  static void stdstring() {
    throw std::string("stdstring message");
  }
};
%}
