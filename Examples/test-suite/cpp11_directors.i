%module(directors="1") cpp11_directors
%feature("director");

%inline %{

class Foo {
  public:
    virtual ~Foo() noexcept {}
    virtual int ping() noexcept = 0;
    virtual int pong() noexcept = 0;
    virtual int pang() const& noexcept = 0;
    virtual int peng() & noexcept = 0;
    virtual int pung() & = 0;
};

%}
