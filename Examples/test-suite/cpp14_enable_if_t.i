%module cpp14_enable_if_t

// test use of enable_if_t but without full %template instantiation, that is no enable_if_t definition is parsed

%inline %{
#include <type_traits>
typedef int node_t;
typedef int position_t;

template <typename A, typename B, std::enable_if_t<std::is_integral_v<A>, bool> = true>
  void enableif1(const A a, const B b) {}

// tests non-type template parameters within () brackets - was causing an infinite loop, issue #2418
template <typename A, typename B, std::enable_if_t<(std::is_integral_v<A>), bool> = true>
  void enableif2(const A a, const B b) {}

template <typename A, typename B, std::enable_if_t<(std::is_integral_v<A> || std::is_same_v<A, node_t>), bool> = true>
  void enableif3(const A a, const B b) {}

template <typename A, typename B, std::enable_if_t<(std::is_integral_v<A> or std::is_same_v<A, node_t>) and (std::is_integral_v<B> or std::is_same_v<B, position_t>), bool> = true>
  void enableif4(const A a, const B b) {}

template <typename A, typename B, std::enable_if_t<(std::is_integral_v<A> and std::is_integral_v<B>), bool> = true>
  int enableif5(const A a, const B b) {
    return a + b;
  }

void tester() {
  enableif5<int, int>(10, 20);
}
%}

// non-type template parameters working well in SWIG, below is a simple workaround as the 3rd parameter is defaulted for enable_if_t (which is just SFINAE to give a nice C++ compiler error)
%template(enableif5) enableif5<int, int, true>; // workaround
