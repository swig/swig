%module xx

struct Low : High {
};

struct Small;

struct Big : Small {
};

%inline %{
namespace A {
  class XYZ {};
  template<typename T> struct ABC :
                                    public B::ABC<T> {
};
}
namespace B {
  template<typename T> struct ABC {
    void aaa(T t) {}
  };
}
%}
%template(ABCXYZ) A::ABC<A::XYZ>;

%template() B::ABC<int>;
%template(ABCint) A::ABC<int>;

template<typename T>
struct Another : WrongOrderBase<int> {
};
%template(AnotherBool) Another<bool>;

template<typename T> class WrongOrderBase {};
%template(ForAnotherInt) WrongOrderBase<int>;
