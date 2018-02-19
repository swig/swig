/* -------------------------------------------------------------------------
 * std_set.i
 * ------------------------------------------------------------------------- */

%{
#include <set>
  %}
template<class _Key, class _Compare = std::less<_Key>, class _Alloc = allocator<_Key> >
class set {
public:
  typedef std::size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef _Key value_type;
  typedef _Key key_type;
  typedef value_type *pointer;
  typedef const value_type *const_pointer;
  typedef value_type &reference;
  typedef const value_type &const_reference;
  typedef _Alloc allocator_type;

public:
  set();

  bool empty() const;
  size_type size() const;
  void clear();
  size_type erase(const key_type &x);
  size_type count(const key_type &x) const;
};


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
