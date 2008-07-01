/* File : example.i */
%module example

%inline %{
extern double Foo;
extern double *Foo_ptr;
extern char *my_str;
extern char **array_of_strs;
extern char *get_str(int i, void* ptr, float ff);
extern int gcd(int x, int y);
%}

