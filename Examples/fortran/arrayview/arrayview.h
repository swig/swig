/* File : arrayview.h */

#ifndef arrayview_arrayview_hh
#define arrayview_arrayview_hh

#include <algorithm>
#include <iostream>
#include <utility>

/* -------------------------------------------------------------------------
 * \brief Reverse the contents of an array in-place
 */
template<class T>
void reverse(std::pair<T *, std::size_t> view) {
  std::reverse(view.first, view.first + view.second);
}

/* -------------------------------------------------------------------------
 * \brief Sort the contents of an array in-place
 */
template<class T>
void sort(std::pair<T *, std::size_t> view) {
  std::sort(view.first, view.first + view.second);
}

/* -------------------------------------------------------------------------
 * \brief Do a binary search on a sorted array
 *
 * \return The fortran index (starts with 1) or zero if not found
 */
template<class T>
int find_sorted(std::pair<const T *, std::size_t> view, T val) {
  const T *start = view.first;
  const T *stop = view.first + view.second;
  const T *iter = std::lower_bound(start, stop, val);
  if (iter == stop || *iter != val)
    return 0;

  // Add 1 to convert to Fortran index
  return (iter - start) + 1;
}

/* -------------------------------------------------------------------------
 * \brief Passthrough function for getting a view from the original array
 */
template<class T>
std::pair<T *, std::size_t> get_view(std::pair<T *, std::size_t> view) {
  return view;
}

/* -------------------------------------------------------------------------
 * \brief Print the contents of an array
 */
template<class T>
void print_array(std::pair<const T *, size_t> view) {
  const T *data = view.first;
  const T *end_data = data + view.second;

  using std::cout;

  cout << "{";
  const char *sep = "";
  for (; data != end_data; ++data) {
    cout << sep << *data;
    sep = ", ";
  }
  cout << "}\n";
}

/* ------------------------------------------------------------------------- */
#endif                                 // arrayview_arrayview_hh


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
