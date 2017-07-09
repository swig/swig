%module(directors="1") cpp11_directors
%feature("director");

%{

class Foo {
  public:
    virtual ~Foo() noexcept {}
    virtual int ping() noexcept = 0;
    virtual int pong() noexcept = 0;
};

%}

class Foo {
  public:
    virtual ~Foo() noexcept {}
    virtual int ping() noexcept = 0;
    virtual int pong() noexcept = 0;
};