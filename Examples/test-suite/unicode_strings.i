%module unicode_strings

%include <std_string.i>

%inline %{

const char* test_c_str(void) {
        return "h\xe9llo";
}

std::string test_std_string(void) {
        return std::string("h\xe9llo");
}

%}
