%module default_ref

%inline %{
#include <string>

void test1(const int &x = 42) {
}

void test2(const std::string &x = "hello") {
}
%}

