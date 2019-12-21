/* -------------------------------------------------------------------------
 * std_set.i
 * ------------------------------------------------------------------------- */

%include "std_common.i"

%{
#include <set>
%}

// methods used by both set *and* multiset
%define %swig_std_setcommon(CLASS, _Key, _Compare, _Alloc)

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
%enddef

%define %swig_std_set(_Key, _Compare, _Alloc)
  %swig_std_setcommon(set, _Key, _Compare, _Alloc)

  %fortransubroutine insert;

  %extend {
    bool insert(const_reference x) {
      std::pair<std::set<_Key, _Compare, _Alloc >::iterator, bool> result = $self->insert(x);
      return result.second;
    }
  }
%enddef

namespace std {
template<class _Key, class _Compare = std::less<_Key>, class _Alloc = std::allocator<_Key> >
class set {
  %swig_std_set(_Key, _Compare, _Alloc)
};
} // end namespace std

