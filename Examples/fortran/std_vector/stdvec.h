/* File : stdvec.h */

#ifndef std_vector_stdvec_hh
#define std_vector_stdvec_hh

#include <cstddef>
#include <vector>
#include <utility>

/* ------------------------------------------------------------------------- */
template<class T>
inline std::vector<T>& as_reference(std::vector<T>& inp)
{ return inp; }

template<class T>
inline const std::vector<T>& as_const_reference(const std::vector<T>& inp)
{ return inp; }

template<class T>
inline std::vector<T>& as_array_ptr(std::vector<T>& inp)
{ return inp; }

template<class T>
const std::vector<T> &as_array(const std::vector<T> &inp) {
  return inp;
}

template<class T>
void print_view(const T* data, std::size_t view);

template<class T>
void print_vec(const std::vector<T> &inp) {
  print_view<T>((!inp.empty() ? &(*inp.begin()) : NULL), inp.size());
}


/* ------------------------------------------------------------------------- */
#endif // std_vector_stdvec_hh


