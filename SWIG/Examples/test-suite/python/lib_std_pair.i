%module lib_std_pair

%include "std_pair.i"

%{
  struct A 
  {
  };
  struct B
  {
  };
%}


namespace std {
  %template(IntPair) pair<int, int>;
  %template(AIntPair) pair<A, int>;

  %template(ABPair) pair<A, B>;
  %template(IntAPair) pair<int, A>;
}

%inline %{

/* Test the "out" typemap for pair<T, U> */
std::pair<int, int> makeIntPair(int a, int b) {
    return std::make_pair(a, b);
}

/**
 * There is no "out" typemap for a pointer to a pair, so
 * this should return a wrapped instance of a std::pair
 * instead of the native "array" type for the target language.
 */
std::pair<int, int> * makeIntPairPtr(int a, int b) {
    static std::pair<int, int> p = std::make_pair(a, b);
    return &p;
}

/**
 * There is no "out" typemap for a non-const reference to a pair, so
 * this should return a wrapped instance of a std::pair instead of
 * the native "array" type for the target language.
 */
std::pair<int, int>& makeIntPairRef(int a, int b) {
    static std::pair<int, int> p = std::make_pair(a, b);
    return p;
}

/**
 * There is no "out" typemap for a const reference to a pair, so
 * this should return a wrapped instance of a std::pair
 * instead of the native "array" type for the target language.
 */
const std::pair<int, int> & makeIntPairConstRef(int a, int b) {
    static std::pair<int, int> p = std::make_pair(a, b);
    return p;
}

/* Test the "in" typemap for pair<T, U> */
int product1(std::pair<int, int> p) {
    return p.first*p.second;
}

/* Test the "in" typemap for const pair<T, U>& */
int product2(const std::pair<int, int>& p) {
    return p.first*p.second;
}

std::pair<int, int> 
  p_ident(std::pair<int, int> p, const std::pair<int, int>& q) {
  return p;
}

#if 0
std::pair<char, char> 
  p_ident(std::pair<char, char> p, const std::pair<char, char>& q) {
  return p;
}

/* Test the "in" typemap for const pair<T, U>* */
std::pair<A, B> 
  p_ident(std::pair<A, B> p, const std::pair<A, B>& q) {
  return q;
}

/* Test the "in" typemap for const pair<T, U>* */
std::pair<int, A> 
  p_ident(std::pair<int, A> p, const std::pair<int, A>& q) {
  return p;
}


std::pair<int, int> 
  p_ident(std::pair<int, int> p, const std::pair<A, int>& q) {
  return p;
}

std::pair<int, int> 
  p_ident(std::pair<int, int> p, const std::pair<A, B>& q) {
  return p;
}
#endif
%}

