%module default_cast

%inline %{
void foo(const char *m = (const char *) NULL) { }
void bar(const char *m = (const char *) "Hello") { }
%}

