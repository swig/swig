/* This testcase checks whether Swig correctly parses the user-defined literals
   for the string introduced in C++0x. */
%module cpp0x_userdefined_literals

%inline %{
#include <iostream>

struct OutputType {
	int val;

	OutputType(int v) { v=val; }	
};

/* Note: GCC doesn't support user-defined literals yet! */
struct TT {
OutputType operator "" (const char * string_values, size_t num_chars) { return OutputType(100); }
OutputType operator "" _mySuffix1(const char * string_values, size_t num_chars) { return OutputType(100); }
OutputType operator "" _mySuffix2(const wchar_t * string_values, size_t num_chars) { return OutputType(200); }
OutputType operator "" _mySuffix3(const char16_t * string_values, size_t num_chars) { return OutputType(300); }
OutputType operator "" _mySuffix4(const char32_t * string_values, size_t num_chars) { return OutputType(400); }
OutputType operator "" _mySuffix5(int value) /* cooked version - ie. atoi() of string */ { return OutputType(500); }
};

%}
