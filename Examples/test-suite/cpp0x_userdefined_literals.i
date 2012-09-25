/* This testcase checks whether SWIG correctly parses the user-defined literals
   introduced in C++0x. */
%module cpp0x_userdefined_literals

%inline %{
#include <iostream>

struct OutputType {
  int val;
  OutputType(int v) : val(v) {}
};

// Raw literal
OutputType operator "" _myRawLiteral(const char * value) { return OutputType(10); }

// Cooked numeric literals
OutputType operator "" _mySuffixIntegral(unsigned long long) { return OutputType(20); }
OutputType operator "" _mySuffixFloat(long double) { return OutputType(30); }

// Cooked string literals
OutputType operator "" _mySuffix1(const char * string_values, size_t num_chars) { return OutputType(100); }
OutputType operator "" _mySuffix2(const wchar_t * string_values, size_t num_chars) { return OutputType(200); }
OutputType operator "" _mySuffix3(const char16_t * string_values, size_t num_chars) { return OutputType(300); }
OutputType operator "" _mySuffix4(const char32_t * string_values, size_t num_chars) { return OutputType(400); }

%}
