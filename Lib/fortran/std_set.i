/* -------------------------------------------------------------------------
 * std_set.i
 * ------------------------------------------------------------------------- */

%include "std_common.i"

%{
#include <set>
%}

%define SWIG_STD_SET_COMMON(CLASS, _Key, _Compare, _Alloc)

public:
  // Typedefs
  typedef _Key value_type;
  typedef _Key key_type;
  typedef std::size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef value_type *pointer;
  typedef const value_type *const_pointer;
  typedef value_type &reference;
  typedef const value_type &const_reference;
  typedef _Alloc allocator_type;

public:
  CLASS();

  // - Use native Fortran integers in proxy code
  %apply int FORTRAN_INT {size_type};

  bool empty() const;
  size_type size() const;
  void clear();

  %fortransubroutine erase;

  size_type erase(const key_type& x);
  size_type count(const key_type& x) const;
  void insert(const_reference x);

%enddef

namespace std {
template<class _Key, class _Compare = std::less<_Key>, class _Alloc = std::allocator<_Key> >
class set {
  SWIG_STD_SET_COMMON(set, _Key, _Compare, _Alloc)
};
} // end namespace std

