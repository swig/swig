%module xxx
int foo(int x);
int foo(double x);

class Foo {
public:
    int bar(int);
    int bar(double);
};

class Spam {
public:
    Spam();
    Spam(int);
};
