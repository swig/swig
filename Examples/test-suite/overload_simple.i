// Simple tests of overloaded functions
%module overload_simple

#ifndef SWIG_NO_OVERLOAD
%immutable Spam::type;

%inline %{

struct Foo {
};

struct Bar {
};

char *foo(int) {
   return (char*) "foo:int";
}

char *foo(double) {
   return (char*) "foo:double";
}

char *foo(char *) {
   return (char*) "foo:char *";
}

char *foo(Foo *) {
   return (char*) "foo:Foo *";
}
char *foo(Bar *) {
   return (char *) "foo:Bar *";
}
char *foo(void *) {
   return (char *) "foo:void *";
}

class Spam {
public:
    Spam() { type = "none"; }
    Spam(int) { type = "int"; }
    Spam(double) { type = "double"; }
    Spam(char *) { type = "char *"; }
    Spam(Foo *) { type = "Foo *"; }
    Spam(Bar *) { type = "Bar *"; }
    Spam(void *) { type = "void *"; }
    const char *type;

char *foo(int) {
   return (char*) "foo:int";
}
char *foo(double) {
   return (char*) "foo:double";
}
char *foo(char *) {
   return (char*) "foo:char *";
}
char *foo(Foo *) {
   return (char*) "foo:Foo *";
}
char *foo(Bar *) {
   return (char *) "foo:Bar *";
}
char *foo(void *) {
   return (char *) "foo:void *";
}

static char *bar(int) {
   return (char*) "bar:int";
}
static char *bar(double) {
   return (char*) "bar:double";
}
static char *bar(char *) {
   return (char*) "bar:char *";
}
static char *bar(Foo *) {
   return (char*) "bar:Foo *";
}
static char *bar(Bar *) {
   return (char *) "bar:Bar *";
}
static char *bar(void *) {
   return (char *) "bar:void *";
}
};
%}

%include cmalloc.i
%malloc(void);

#endif

