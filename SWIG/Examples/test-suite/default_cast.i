%module default_cast

%inline %{
void foo(const char *m = (const char *) NULL) { };
%}

