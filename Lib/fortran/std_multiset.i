/* -------------------------------------------------------------------------
 * std_multiset.i
 *
 * Note: multiset interface is identical to std::set. It simply allows multiple
 * keys.
 * ------------------------------------------------------------------------- */

%include "std_common.i"

%{
#include <set>
%}

%fortransubroutine std::multiset::erase;

namespace std {

template<class _Key, class _Compare = std::less<_Key>, class _Alloc = std::allocator<_Key> >
class multiset {
public:
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
  set();

  // - Use native Fortran integers in proxy code
  %apply int FORTRAN_INT {size_type};

  bool empty() const;
  size_type size() const;
  void clear();
  size_type erase(const key_type& x);
  size_type count(const key_type& x) const;
  void insert(const_reference x);
};
} // namespace std

