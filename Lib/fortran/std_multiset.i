/* -------------------------------------------------------------------------
 * std_multiset.i
 *
 * Note: multiset interface is identical to std::set. It simply allows multiple
 * keys.
 * ------------------------------------------------------------------------- */

%include "std_set.i"

%define %swig_std_multiset(_Key, _Compare, _Alloc)
  %swig_std_setcommon(multiset, _Key, _Compare, _Alloc)

  void insert(const_reference x);
%enddef

namespace std {
template<class _Key, class _Compare = std::less<_Key>, class _Alloc = std::allocator<_Key> >
class multiset {
  %swig_std_multiset( _Key, _Compare, _Alloc)
};
} // end namespace std


