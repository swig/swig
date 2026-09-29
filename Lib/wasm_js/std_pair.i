%include <std_common.i>
namespace std {
  template <class A, class B> struct pair {
    %wasm_container(std::pair<A, B>)
    A first;
    B second;
    pair();
    pair(A first, B second);
    pair(const pair &other);
  };
}
