%module default_char

%inline %{
void test1(char c = 'x') {}
void test2(char c = '\0') {}
%}

