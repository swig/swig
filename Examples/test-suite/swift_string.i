%module swift_string
// Swift-specific test: std::string maps to Swift String.
%include <std_string.i>
%inline %{
#include <string>
std::string greet(const std::string &name) { return "Hello, " + name; }
int length(const std::string &s) { return (int)s.size(); }
std::string echo(std::string s) { return s; }
%}
