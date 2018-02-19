/* -------------------------------------------------------------------------
 * std_vector.i
 * ------------------------------------------------------------------------- */

%{
#include <vector>
%}

/*!
 * This module defines a std::vector class and convenience typemaps.
 *
 * Use \code
  %apply const std::vector<int> NATIVE& { const std::vector<int>& }
 \endcode
 * to wrap all const vector references as native fortran array input/output.
 *
 * TODO:
 *  - Add initialization/assignment from fortran array
 *  - Extend with return-as-view ?
 *  - Extend with return-allocatable ?
 *
 * To avoid wrapping std::vector but still instantiate the typemaps that
 * allow native wrapping, use
 * `%template() std::vector<double>` .
 */
%include "std_container.i"

namespace std {
  template<class _Tp, class _Alloc = std::allocator<_Tp> >
  class vector {
  public:
    typedef std::size_t size_type;
    typedef _Tp value_type;
    typedef value_type *pointer;
    typedef const value_type *const_pointer;
    typedef _Tp &reference;
    typedef const _Tp &const_reference;
    typedef _Alloc allocator_type;

  public:
    // Constructors
    vector();
    vector(size_type count);
    vector(size_type count, const value_type &v);

    // Accessors
    size_type size() const;
    size_type capacity() const;
    bool empty() const;
    void clear();

    // Modify
    void reserve(size_type count);
    void resize(size_type count);
    void resize(size_type count, const value_type &v);
    void push_back(const value_type &v);

    const_reference front() const;
    const_reference back() const;

    // Extend for Fortran
    %extend{
      // C indexing used here!
      void set(size_type index, const_reference v) {
        // TODO: check range
        (*$self)[index] = v;
      }

      // C indexing used here!
      value_type get(size_type index) {
        // TODO: check range
        return (*$self)[index];
      }
    } // end extend

  // Declare typemaps for using 'NATIVE' wrapping
  %std_native_container(std::vector<_Tp, _Alloc>)
};

// Specialize on bool
template<class _Alloc>
class vector<bool, _Alloc> {
  /* NOT IMPLEMENTED */
};
}                                 // end namespace std


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
