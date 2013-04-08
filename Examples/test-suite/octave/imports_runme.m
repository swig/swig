# This is the import runtime testcase.

# If imports_b is loaded before imports_a, a seg fault occurred during interpreter cleanup/exit in version 3.1 and 3.2, seems okay in 3.6
imports_a;
imports_b;

x = imports_b.B();
x.hello();

a = imports_a.A();

c = imports_b.C();
a1 = c.get_a(c);
a2 = c.get_a_type(c);

a1.hello();
a2.hello();
assert(swig_this(a1)==swig_this(a2));
assert(strcmp(swig_type(a1),swig_type(a2)));

