/* File : example.h */

#include <cstddef>
#include <vector>
#include <utility>

template<class T>
inline std::vector<T>& as_reference(std::vector<T>& inp)
{ return inp; }

template<class T>
inline const std::vector<T>& as_const_reference(const std::vector<T>& inp)
{ return inp; }

template<class T>
inline const std::vector<T>& as_array_ptr(std::vector<T>& inp)
{ return inp; }

template<class T>
std::vector<T> as_array(const std::vector<T> &inp) {
  return inp;
}

template<class T>
void print_view(const T* data, std::size_t view);

template<class T>
void print_vec(const std::vector<T> &arr) {
  print_view<T>((!arr.empty() ? &(*arr.begin()) : NULL), arr.size());
}

