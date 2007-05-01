%module li_std_pair

%include "std_pair.i"

namespace std {
  %template(IntPair)   pair<int, int>;
  %template(ValuePair) pair< swig::LANGUAGE_OBJ, swig::LANGUAGE_OBJ >;
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

/* Test the "in" typemap for const pair<T, U>* */
int product3(const std::pair<int, int> *p) {
    return p->first*p->second;
}

%}

