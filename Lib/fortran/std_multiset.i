/* -------------------------------------------------------------------------
 * std_multiset.i
 *
 * Note: multiset interface is identical to std::set. It simply allows multiple
 * keys.
 * ------------------------------------------------------------------------- */

%include "std_set.i"

namespace std {
template<class _Key, class _Compare = std::less<_Key>, class _Alloc = std::allocator<_Key> >
class multiset {
  SWIG_STD_SET_COMMON(multiset, _Key, _Compare, _Alloc)
};
} // end namespace std


