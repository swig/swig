// This module tests various facets of the %rename directive

%module rname

/* Applied everywhere */
%rename(foo_i) foo(int);
%rename(foo_d) foo(double);

/* Applied only to global scope */

%rename(foo_s) ::foo(short);

/* Applied only to class scope */

%rename(foo_u) *::foo(unsigned);

%inline %{
class Bar {
public:
   char *foo(int)      { return "Bar::foo-int"; }
   char *foo(double)   { return "Bar::foo-double"; }
   char *foo(short)    { return "Bar::foo-short"; }
   char *foo(unsigned) { return "Bar::foo-unsigned"; }
};

char *foo(int)      { return "foo-int"; }
char *foo(double)   { return "foo-double"; }
char *foo(short)    { return "foo-short"; }
char *foo(unsigned) { return "foo-unsigned"; }

%}
