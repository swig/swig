%module cpp17_enable_if_t

// test use of enable_if_t but without full %template instantiation, that is no enable_if_t definition is parsed

%inline %{
#if defined(_MSC_VER) && _MSC_VER < 1920
#define or ||
#define and &&
#endif

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
  enableif5(10, 20);
}
%}

// non-type template parameters working well in SWIG, below is a simple workaround as the 3rd parameter is defaulted for enable_if_t (which is just SFINAE to give a nice C++ compiler error)
%template(enableif5) enableif5<int, int, true>; // workaround

%inline %{
// #961 no name for defaulted template parameter
template<typename T, typename = std::enable_if_t<std::is_enum<T>::value>>
void uuu() {}
template<typename T, typename E = std::enable_if_t<std::is_enum<T>::value>>
void uuuE() {}

template<typename T, typename = typename std::enable_if<std::is_floating_point<T>::value>::type>
void vvv() {}
template<typename T, typename E = typename std::enable_if<std::is_floating_point<T>::value>::type>
void vvvE() {}

// More variations of enable_if and enable_if_t
template<typename T, typename std::enable_if<std::is_floating_point<T>::value>::type* = nullptr>
void www() {}

template<typename T, typename std::enable_if_t<std::is_enum<T>::value, int> = 0>
void xxx() {}

enum TestEnum { Enum1 = 1, Enum2 };
struct TestStruct {};

void tester2() {
  uuu<TestEnum>();
//  uuu<TestStruct>(); // compilation error
  uuuE<TestEnum>();
//  uuuE<TestStruct>(); // compilation error
  vvv<double>();
//  vvv<TestStruct>(); // compilation error
  vvvE<double>();
//  vvvE<TestStruct>(); // compilation error

  www<double>();
//  www<TestStruct>(); // compilation error
  xxx<TestEnum>();
//  xxx<TestStruct>(); // compilation error
}
%}
