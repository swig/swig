/* File : stdvec.h */

#ifndef std_vector_stdvec_hh
#define std_vector_stdvec_hh

#include <cstddef>
#include <vector>

/* ------------------------------------------------------------------------- */
template<class T>
std::pair<T *, size_t> make_view(std::vector<T> &v) {
  if (v.empty())
    return {};
  return { v.data(), v.size() };
}

/* ------------------------------------------------------------------------- */
template<class T>
std::pair<const T *, size_t> make_const_view(const std::vector<T> &v) {
  if (v.empty())
    return {};
  return { v.data(), v.size() };
}

/* ------------------------------------------------------------------------- */
template<class T>
void print_vec(const std::vector<T> &v);

/* ------------------------------------------------------------------------- */
template<class T>
void print_view(std::pair<const T *, size_t> view);

/* ------------------------------------------------------------------------- */
inline std::vector<double>& as_array_ptr(std::vector<double>& inp)
{ return inp; }

/* ------------------------------------------------------------------------- */
template<class T>
const std::vector<T> &get_vec(const std::vector<T> &inp) {
  return inp;
}

/* ------------------------------------------------------------------------- */
#endif                                 // std_vector_stdvec_hh


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
