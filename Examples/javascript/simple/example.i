/* File : example.i */
%module example

%include "std_string.i"

%inline %{
extern int    gcd(int x, int y);
extern float  gcd(float x, float y);
extern char*  helloString(char* s);
extern void delete_helloString(char *newstr);
extern std::string helloString(std::string s); 
extern void bar(int x, int y = 3, int z = 4);

extern double Foo;
%}
