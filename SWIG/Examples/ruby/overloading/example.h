#ifndef EXAMPLE_H
#define EXAMPLE_H

class Bar {
public:
    Bar();
    Bar(const Bar&);
    Bar(double);
    Bar(double, char *);
    Bar(int, int);
    Bar(char *);
    Bar(int);
    Bar(long);
    Bar(Bar *);

    void foo(double);
    void foo(double, char *);
    void foo(int, int);
    void foo(char *);
    void foo(int);
    void foo(long);
    void foo(Bar *);
};

void foo(double);
void foo(double, char *);
void foo(int, int);
void foo(char *);
void foo(int);
void foo(long);
void foo(Bar *);

#endif
