/* This interface file tests whether SWIG handles the (non-standard)
   long long types.

   SWIG 1.3a5 throws a syntax error.
*/

/* Silly sample typemaps */
%typemap(in) long long, unsigned long long "$target = 42;";
%typemap(out) long long, unsigned long long "$target = SCM_BOOL_F;";

%inline %{
void foo1(long long x) {}
void foo2(long long int x) {}
void foo3(signed long long int x) {}
void foo4(unsigned long long int x) {}
void foo5(signed long long x) {}
void foo6(unsigned long long x) {}

long long bar1() {return 0;}
long long int bar2() {return 0;}
signed long long int bar3() {return 0;}
unsigned long long int bar4() {return 0;}
signed long long bar5() {return 0;}
unsigned long long bar6() {return 0;}
%}

